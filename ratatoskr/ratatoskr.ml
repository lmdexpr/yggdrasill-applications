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

let go all request body =
  let headers = Httpx.Request.headers request in
  let verified = 
    Option.is_some @@ verify_key ~public_key headers body 
  in
  if not verified then Httpx.empty_response ~status:`Unauthorized
  else (
    let body = Interaction.of_string body in
    match body.type_ with
    | PING                -> Interaction_response.(ok pong)
    | APPLICATION_COMMAND -> (
      match Commands.find_handler all body with
      | Some handler -> Interaction_response.ok (handler body)
      | None         -> Httpx.empty_response ~status:`Bad_request
    )
    | _ -> Httpx.empty_response ~status:`Service_unavailable
  )

let run env =
  let all = Commands.register_all ~env ~application_id ~discord_token guild_ids in
  Httpx.Server.run ~env ~port 
    ~callback:Httpx.(fun _socket request body -> 
      match Request.(meth request, resource request, has_body request) with
      | `POST, "/", `Yes -> go all request Eio.Flow.(read_all body)
      | `POST, "/", _    -> empty_response ~status:`Bad_request
      | `POST,   _, _    -> empty_response ~status:`Not_found
      | _                -> empty_response ~status:`Method_not_allowed
    )
    ~on_error:(fun ex -> Logs.warn @@ fun f -> f "%a" Eio.Exn.pp ex)

let () =
  Eio_main.run @@ fun env ->
  Mirage_crypto_rng_eio.run (module Mirage_crypto_rng.Fortuna) env @@ fun () ->

  let spawn = Eio.Domain_manager.run env#domain_mgr in
  Eio.Fiber.both
    (fun () -> spawn @@ run env)
    (fun () -> spawn @@ Nidhoggr.run ~env ~application_id ~discord_token ~config:config.niflheimr)
