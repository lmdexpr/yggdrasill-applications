let call ~env ~config ~handler ?(params=[]) ?body meth path =
  let Config.{ host; port; _ } = config in
  let now = Eio.Time.now @@ Eio.Stdenv.clock env in
  let uri =
    Uri.make ~scheme:"http" ~host ~port () |> fun uri ->
    Uri.with_path  uri @@ "/" ^ path |> fun uri ->
    Uri.with_query uri params 
  in
  let headers =
    Http.Header.of_list @@
    [
      "Host", host;
      "User-Agent", "ocaml-minio";
      "Accept", "*/*";
    ] @
    match meth, body with
    | `PUT, Some body -> [ "Content-length", Int.to_string @@ String.length body ]
    | _               -> []
  in
  let headers = Auth.headers ~now ~config ?body meth uri headers in
  let body    = Option.map Cohttp_eio.Body.of_string body in
  let client  = Cohttp_eio.Client.make ~https:None env#net in
  Eio.Switch.run @@ fun sw ->
  Logs.debug (fun m -> m "Headers: %a" Http.Header.pp_hum headers);
  handler @@ Cohttp_eio.Client.call ~sw ~headers client meth uri ?body
