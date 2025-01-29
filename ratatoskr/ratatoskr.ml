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

let ok t =
  let headers, body = Interaction_response.ok t in
  Response.make ~status:`OK ~headers:Header.(of_list headers) (),
  Body.of_string body

let go all body =
  match Interaction.of_string body with
  | ({ type_ = APPLICATION_COMMAND; data = Some data; _ } as interaction) -> 
    (match
      List.find_opt (fun Slash_command.{ name; _ } -> name = data.name) all
      |> Option.map (fun Slash_command.{ handler; _ } -> handler)
      with
      | Some handler -> ok (handler interaction)
      | None         -> bad_request ()
    )
  | { type_ = APPLICATION_COMMAND; _ } -> bad_request ()
  | { type_ = PING; _ }                -> ok Interaction_response.pong
  | _                                  -> service_unavailable ()

let go all req body =
  let headers = Header.to_list @@ Request.headers req in
  match verify_key ~public_key headers body with
  | Some _ -> go all body
  | None   -> unauthorized ()

let serve env =
  let all = Commands.register_all ~env ~application_id ~discord_token guild_ids in
  Server.run ~env ~port 
    ~on_error:(fun ex -> Logs.err (fun f -> f "%a" Eio.Exn.pp ex))
    ~callback:(fun _socket req body ->
      match Request.(meth req, resource req, has_body req) with
      | `POST, "/", `Yes -> go all req Eio.Flow.(read_all body)
      | `POST, "/", _    -> bad_request ()
      | `POST,   _, _    -> not_found ()
      | _                -> method_not_allowed ()
    )

let () =
  Eio_main.run @@ fun env ->
  Mirage_crypto_rng_eio.run (module Mirage_crypto_rng.Fortuna) env @@ fun () ->

  let spawn = Eio.Domain_manager.run env#domain_mgr in
  Eio.Fiber.both
    (fun () -> spawn @@ serve env)
    (fun () -> spawn @@ Nidhoggr.run ~env ~application_id ~discord_token ~config:config.niflheimr)
