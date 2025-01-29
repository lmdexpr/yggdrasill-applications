module Ratatoskr_config = Config

open Discord.Slash_command
open Discord.Interaction_response

let ping = make
  ~name:"ping"
  ~type_:CHAT_INPUT
  ~description:"reply Pong!"
  @@ fun _ -> 
  channel_message_with_source "Pong!"

let encode = make
  ~name:"encode"
  ~type_:CHAT_INPUT
  ~description:"encode a zip file containing flac files to a mp3 file."
  ~options:[
    make_opt
      ~name:"path"
      ~type_:STRING
      ~description:"Path of a zip file containing flac files."
      ~required:true
      ();
  ]
  @@ fun interaction ->
  Nidhoggr.submit interaction;
  deferred_channel_message_with_source

let register_all ~env ~application_id ~discord_token guild_ids =
  let all = [ 
    ping; 
    encode; 
  ] in
  guild_ids |> List.iter (fun guild_id ->
    Logs.info (fun m -> m "register_all: guild id is %s" guild_id);
    all |> List.iter (fun com -> 
      match Discord.Slash_command.register ~application_id ~discord_token ~guild_id com with
      | _ -> ()
      | effect (Discord.Effect.Post_request {host; headers; path; body}), k -> 
        let resp, body = Httpx.request ~env `POST ~headers ~host ~path ~body in

        let body = Eio.Flow.read_all body in
        Logs.debug (fun m -> m "  resp: %a" Httpx.Response.pp resp);
        Logs.debug (fun m -> m "  body: %s" body);
        let code = Httpx.(Response.status resp |> Status.to_int) in
        if code < 300 then
          Logs.info  (fun m -> m "register_all: ok w/ %d" code)
        else (
          Logs.warn (fun m -> m "register_all: failed w/ %d" code);
          Logs.warn (fun m -> m "register_all: body: %s" body);
        );

        Effect.Deep.continue k ""
    );
  );
  all

let match_ ~ok ~ng all (interaction: Discord.Interaction.t) =
  let (let*)   = Option.bind in
  match
  let* data    = interaction.data in
  let* command = List.find_opt (fun Discord.Slash_command.{ name; _ } -> name = data.name) all in
  Some command.handler
  with
  | Some handler -> ok handler
  | None         -> ng ()
