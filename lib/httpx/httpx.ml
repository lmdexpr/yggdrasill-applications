open struct
  (* TODO: error handling *)
  let authenticator = Ca_certs.authenticator () |> Result.get_ok;;

  let https =
    Tls.Config.client ~authenticator ()
    |> Result.to_option
    |> Option.map (fun tls_config ->
      fun uri raw ->
      let host =
        Uri.host uri
        |> Option.map (fun x -> Domain_name.(host_exn (of_string_exn x)))
      in
      Tls_eio.client_of_flow ?host tls_config raw
    )
end

module Status   = Http.Status
module Request  = Http.Request
module Response = Http.Response

module Header = struct 
  include Cohttp.Header

  let list_of_request req = Request.headers req |> to_list
end

module Body   = Cohttp_eio.Body
module Client = Cohttp_eio.Client

module Server = struct 
  include Cohttp_eio.Server

  let run ~env ~port ~callback ~on_error =
    Eio.Switch.run @@ fun sw ->
    let socket =
      Eio.Net.listen env#net ~sw ~backlog:128 ~reuse_addr:true (`Tcp (Eio.Net.Ipaddr.V4.any, port))
    in
    Logs.info (fun f -> f "Listening on port %d" port);
    run socket ~on_error @@ make ~callback ()
end

let handle_error ~err_msg response =
  if response.Http.Response.status |> Http.Status.to_int < 300 then ()
  else (
    Logs.err (fun m -> m "%s: %a" err_msg Http.Response.pp response);
    failwith err_msg
  )

let request ~env ~host ~headers ~path ?(query=[]) ?body meth =
  let headers = Header.of_list headers in
  let uri     = Uri.make ~scheme:"https" ~host ~path ~query () in
  let body    = Option.map Body.of_string body in
  let client  = Client.make ~https Eio.Stdenv.(net env) in
  Logs.debug (fun m -> m "Headers: %a" Http.Header.pp_hum headers);
  Eio.Switch.run @@ fun sw ->
  Client.call ~sw ~headers client meth uri ?body

let empty_response ~status = Response.make ~status (), Body.of_string ""
let not_found ()           = empty_response ~status:`Not_found
let unauthorized ()        = empty_response ~status:`Unauthorized
let bad_request ()         = empty_response ~status:`Bad_request
let service_unavailable () = empty_response ~status:`Service_unavailable
let method_not_allowed ()  = empty_response ~status:`Method_not_allowed

module Infix = struct
  let (/) = Filename.concat
end
