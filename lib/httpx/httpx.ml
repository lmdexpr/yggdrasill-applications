open struct
  let authenticator = Ca_certs.authenticator () |> Result.get_ok;;
  let connect_via_tls url socket =
    let tls_config = Tls.Config.client ~authenticator () in
    let host =
        Uri.host url
        |> Option.map (fun x -> Domain_name.(host_exn (of_string_exn x)))
    in
    Tls_eio.client_of_flow ?host tls_config socket

  let https = Option.some connect_via_tls
end

module Header = Cohttp.Header

module Status   = Http.Status
module Request  = Http.Request
module Response = Http.Response

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

let request ~env ~host ~headers ~path ~handler ?(query=[]) ?body meth =
  let uri    = Uri.make ~scheme:"https" ~host ~path ~query () in
  let body   = Option.map Body.of_string body in
  let client = Client.make ~https Eio.Stdenv.(net env) in
  Logs.debug (fun m -> m "Headers: %a" Http.Header.pp_hum headers);
  Eio.Switch.run @@ fun sw ->
  Client.call ~sw ~headers client meth uri ?body
  |> handler

let empty_response ~status = Response.make ~status (), Body.of_string ""

module Infix = struct
  let (/) = Filename.concat
end
