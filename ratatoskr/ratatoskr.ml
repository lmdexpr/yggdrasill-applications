let Config.{
  port; log_level; 
  discord = Discord.Config.{
    public_key;
    discord_token;
    application_id;
    guild_ids
  };
  _;
} as config = Config.load ()

open Discord

let () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level log_level;
  Logs_threaded.enable ();
  Logs.Src.set_level Cohttp_eio.src log_level

let empty_response ~status = Cohttp.Response.make ~status (), Cohttp_eio.Body.of_string ""

let go all request body =
  let headers = Http.Request.headers request in
  Logs.debug (fun f -> f "Received a POST request");
  Logs.debug (fun f -> f "headers: %a" Http.Header.pp_hum headers);
  Logs.debug (fun f -> f "body: %s" body);
  let verified = 
    Option.is_some @@ verify_key ~public_key headers body 
  in
  Logs.debug (fun f -> f "Request is %s" (if verified then "verified" else "not verified"));
  if not verified then empty_response ~status:`Unauthorized
  else (
    let body = Interaction.of_string body in
    Logs.debug (fun f -> f "Parsed body: %a" Interaction.pp body);
    let headers = Http.Header.of_list [
      "content-type", "application/json";
    ] in
    let ok t  = Cohttp.Response.make ~status:`OK ~headers (), Interaction_response.(body_of_t t) in
    let ng () = empty_response ~status:`Bad_request in
    match body.type_ with
    | PING                -> ok Interaction_response.pong
    | APPLICATION_COMMAND -> Commands.match_ all ~ok ~ng body
    | _                   -> empty_response ~status:`Service_unavailable
  )

let run env =
  let all = Commands.register_all ~env ~application_id ~discord_token guild_ids in

  let callback _socket request body =
    match Http.Request.(meth request, resource request, has_body request) with
    | `POST, "/", `Yes -> go all request Eio.Flow.(read_all body)
    | `POST, "/", _    -> empty_response ~status:`Bad_request
    | `POST,   _, _    -> empty_response ~status:`Not_found
    | _                -> empty_response ~status:`Method_not_allowed
  in

  let on_error ex = Logs.warn (fun f -> f "%a" Eio.Exn.pp ex) in

  Eio.Switch.run @@ fun sw ->
  let socket =
    Eio.Net.listen env#net ~sw ~backlog:128 ~reuse_addr:true (`Tcp (Eio.Net.Ipaddr.V4.any, port))
  in
  Logs.info (fun f -> f "Listening on port %d" port);
  Cohttp_eio.(Server.run socket ~on_error @@ Server.make ~callback ())

let () =
  Eio_main.run @@ fun env ->
  Mirage_crypto_rng_eio.run (module Mirage_crypto_rng.Fortuna) env @@ fun () ->

  let spawn = Eio.Domain_manager.run env#domain_mgr in
  Eio.Fiber.both
    (fun () -> spawn @@ run env)
    (fun () -> spawn @@ Nidhoggr.run ~env ~application_id ~discord_token ~config:config.niflheimr)
