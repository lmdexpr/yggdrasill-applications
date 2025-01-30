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
open Httpx

let () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level log_level;
  Logs_threaded.enable ();
  Logs.Src.set_level Cohttp_eio.src log_level

let callback req body =
  match Request.(meth req, resource req, has_body req) with
  | `POST, "/", `Yes -> Slash_command.dispatch ~public_key Commands.all Header.(list_of_request req) Eio.Flow.(read_all body)
  | `POST, "/", _    -> `Bad_request
  | `POST,   _, _    -> `Not_found
  | _                -> `Method_not_allowed

let serve env =
  Commands.register_all ~env ~application_id ~discord_token guild_ids;
  Server.run ~env ~port 
    ~on_error:(fun ex -> Logs.err (fun f -> f "%a" Eio.Exn.pp ex))
    ~callback:(fun _socket req body ->
      match callback req body with
      | `Bad_request         -> bad_request ()
      | `Unauthorized        -> unauthorized ()
      | `Service_unavailable -> service_unavailable ()
      | `Not_found           -> not_found ()
      | `Method_not_allowed  -> method_not_allowed ()
      | `Ok t                ->
        let headers, body = Interaction_response.ok t in
        Response.make ~status:`OK ~headers:Header.(of_list headers) (),
        Body.of_string body
    )

let () =
  Eio_main.run @@ fun env ->
  Mirage_crypto_rng_eio.run (module Mirage_crypto_rng.Fortuna) env @@ fun () ->

  let spawn = Eio.Domain_manager.run env#domain_mgr in
  Eio.Fiber.both
    (fun () -> spawn @@ serve env)
    (fun () -> spawn @@ Nidhoggr.run ~env ~application_id ~discord_token ~config:config.niflheimr)
