module Ratatoskr_config = Config
open Discord

open struct
  let ping = Slash_command.make
    ~name:"ping"
    ~type_:Slash_command.CHAT_INPUT
    ~description:"reply Pong!"
    @@ fun _ -> Interaction_response.channel_message_with_source "Pong!"

  let encode = Slash_command.make
    ~name:"encode"
    ~type_:Slash_command.CHAT_INPUT
    ~description:"encode a zip file containing flac files to a mp3 file."
    ~options:[
      Slash_command.make_opt
        ~name:"path"
        ~type_:Slash_command.STRING
        ~description:"Path of a zip file containing flac files."
        ~required:true
        ();
    ]
    @@ fun interaction ->
    Nidhoggr.submit interaction;
    Interaction_response.deferred_channel_message_with_source

  let all = [ ping; encode; ]
end

let register_all ~env ~application_id ~discord_token guild_ids =
  List.iter (fun guild_id ->
    Logs.info (fun m -> m "register_all: guild id is %s" guild_id);
    List.iter (fun command ->
      try
        Slash_command.register ~env ~application_id ~discord_token ~guild_id command ~handler:(fun (resp, body) ->
          let body = Eio.Flow.read_all body in
          Logs.debug (fun m -> m "  resp: %a" Http.Response.pp resp);
          Logs.debug (fun m -> m "  body: %s" body);
          let code = Http.(Response.status resp |> Status.to_int) in
          if code < 300 then
            Logs.info  (fun m -> m "register_all: ok w/ %d" code)
          else begin
            Logs.warn (fun m -> m "register_all: failed w/ %d" code);
            Logs.warn (fun m -> m "register_all: body: %s" body);
            end
        );
      with e ->
        let msg   = Printexc.to_string e
        and stack = Printexc.get_backtrace () in
        Logs.err (fun m -> m "register_all: %s%s" msg stack);
    ) all
  ) guild_ids;
  all

let match_ all ~ok ~ng (interaction: Interaction.t) =
  let (let*) = Option.bind in
  match
  let* data    = interaction.data in
  let* command = List.find_opt (fun Slash_command.{ name; _ } -> name = data.name) all in
  Some command.handler
  with
  | Some handler -> ok (handler interaction)
  | None         -> ng ()
