open Printf
open ISO8601.Permissive

(* ref. https://github.com/mirage/ocaml-cohttp/blob/master/cohttp-async/examples/s3_cp.ml *)

open struct 
  let service = "s3"

  let ksrt (k, _) (k', _) = String.compare k k'

  let hmac_sha256 key v = Digestif.SHA256.(hmac_string ~key v |> to_raw_string)

  let iso8601date     = Format.asprintf "%a" pp_date_basic
  let iso8601datetime = Format.asprintf "%aZ" pp_datetime_basic

  module Compat = struct
    let encode_string s =
      let n = String.length s in
      let buf = Buffer.create (n * 3) in
      for i = 0 to n - 1 do
        let c = s.[i] in
        match c with
        | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '-' | '~' | '.' | '/' ->
          Buffer.add_char buf c
        | '%' ->
          let is_hex = function
            | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' -> true
            | _ -> false
          in
          if i + 2 < n then
            if is_hex s.[i + 1] && is_hex s.[i + 2] then Buffer.add_char buf c
            else Buffer.add_string buf "%25"
        | _ -> Buffer.add_string buf (sprintf "%%%X" (int_of_char c))
      done;
      Buffer.contents buf

    let encode_query_string uri =
      Uri.query uri
      |> List.sort ksrt
      |> List.map (fun (k, v) -> (k, match v with [] -> [ "" ] | x -> x))
      |> Uri.encoded_of_query
  end

  let digest s = Digestif.SHA256.(digest_string s |> to_hex)

  let hash_payload = function
    | None   -> digest ""
    | Some s -> digest s

  module Canonical_request = struct
    let make http_method uri headers hashed_payload =
      let http_method     = Http.Method.to_string http_method in
      let canoncical_uri  = Compat.encode_string (Uri.path uri) in
      let canonical_query = Compat.encode_query_string uri in
      let sorted_headers  = 
        Http.Header.to_list headers 
        |> List.sort ksrt 
        |> List.map String.(fun (k, v) -> lowercase_ascii k, trim v) 
      in
      let canonical_headers =
        sorted_headers |> List.map (fun (k, v) -> sprintf "%s:%s\n" k v) |> String.concat ""
      in
      let signed_headers = sorted_headers |> List.map fst |> String.concat ";" in
      signed_headers,
      sprintf "%s\n%s\n%s\n%s\n%s\n%s"
        http_method canoncical_uri canonical_query canonical_headers signed_headers hashed_payload
  end

  let credential Config.{ access_key; region; _ } now =
    sprintf "%s/%s/%s/%s/aws4_request" access_key (iso8601date now) region service

  let signing_key Config.{ secret_key; region; _ } now =
    let key = "AWS4" ^ secret_key in
    let key = hmac_sha256 key @@ iso8601date now in
    let key = hmac_sha256 key region in
    let key = hmac_sha256 key service in
    hmac_sha256 key "aws4_request"

  let string_to_sign Config.{ region; _ } now canonical_request =
    sprintf "AWS4-HMAC-SHA256\n%s\n%s\n%s"
      (iso8601datetime now)
      (sprintf "%s/%s/%s/aws4_request" (iso8601date now) region service)
      (digest canonical_request)

  let authorizatoin = sprintf "AWS4-HMAC-SHA256 Credential=%s, SignedHeaders=%s, Signature=%s"
end

let headers ~now ~config ?body http_method uri headers =
  let headers         = Http.Header.add headers "X-Amz-Date" (iso8601datetime now) in
  let hashed_payload  = hash_payload body in
  let headers         = Http.Header.add headers "X-Amz-Content-Sha256" hashed_payload in
  let signed_headers,
    canonical_request = Canonical_request.make http_method uri headers hashed_payload in
  let credential      = credential     config now in
  let signing_key     = signing_key    config now in
  let string_to_sign  = string_to_sign config now canonical_request in
  let signature       = hmac_sha256    signing_key string_to_sign in
  Http.Header.add_list headers
  [
    "Authorization", authorizatoin credential signed_headers signature;
  ]
