open Cohttp_eio

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

let request ~env ~host ~headers ~path ~handler ?(query=[]) ?body meth =
  let uri    = Uri.make ~scheme:"https" ~host ~path ~query () in
  let body   = Option.map Body.of_string body in
  let client = Client.make ~https Eio.Stdenv.(net env) in
  Logs.debug (fun m -> m "Headers: %a" Http.Header.pp_hum headers);
  Eio.Switch.run @@ fun sw ->
  Client.call ~sw ~headers client meth uri ?body
  |> handler
