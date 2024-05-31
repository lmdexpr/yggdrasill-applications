open Eio.Path

module Config = Nextcloud.Config

open struct
  let mkdir path =
    try
      mkdir path ~perm:0o700;
      Logs.debug (fun f -> f "mkdir %a : ok" Eio.Path.pp path)
    with
    | Eio.Io (Eio.Fs.E Already_exists _, _) ->
      Logs.warn (fun f -> f "mkdir %a : already exists" Eio.Path.pp path)
    | ex ->
      Logs.err (fun f -> f "%a" Eio.Exn.pp ex)

  let run ~env ~config input_path =
    let cwd = Eio.Stdenv.cwd env / "encode_workspace" in mkdir cwd;

    Eio.Switch.run_protected @@ fun _sw ->
    Fun.protect ~finally:(fun () -> rmtree cwd) @@ fun () ->

    let download_zip = Nextcloud.get ~env ~cwd ~config input_path in 

    let mp3_filename = Filename.(basename input_path |> chop_extension |> Printf.sprintf "%s.mp3") in
    Encoder.flacs_zip_to_mp3 ~env ~cwd download_zip mp3_filename;

    let output_path = Filename.dirname input_path in
    Nextcloud.put    ~env ~config ~cwd mp3_filename output_path;
    Nextcloud.delete ~env ~config input_path

  let stream = Eio.Stream.create 1
end

let submit = Eio.Stream.add stream

let run ~env ~application_id ~discord_token ~config = 
  Logs.info (fun f -> f "Nidhoggr ready");
  let rec go () =
    let interaction = Eio.Stream.take stream in
    let follow_up msg =
      Discord.Interaction_response.follow_up ~env ~application_id ~discord_token ~interaction msg
    in
    Logs.info (fun m -> m "[encode] start");
    (try
      let path = Discord.Interaction.find_option_string_exn interaction "path" in
      run ~env ~config path;
      follow_up ("Done! " ^ path) ~handler:(function (response, _) ->
        Logs.info (fun m -> m "[encode] resp: %a" Http.Response.pp response);
      );
    with e ->
      Logs.err Printexc.(fun m -> m "[encode] %s%s" (to_string e) (get_backtrace ()));
      follow_up ("Failed! check the log for more details.") ~handler:(function (response, body) ->
        Logs.err (fun m -> m "[encode] resp: %a" Http.Response.pp response);
        Logs.err (fun m -> m "[encode] body: %s" @@ Eio.Flow.read_all body);
      );
    );
    Logs.info (fun m -> m "[encode] done");
    go ()
  in
  go ()
