open Printf

open struct
  let create_ffmpeg_command flacs output_mp3_name =
    Logs.debug (fun m -> m "flacs: %a" (Fmt.Dump.list Fmt.string) flacs);
    let count = List.length flacs in
    List.flatten [
      ["ffmpeg"];
      flacs |> List.map (fun flac -> ["-i"; flac] ) |> List.flatten;
      if count <= 1 then []
      else 
        ["-filter_complex"; sprintf "amix=inputs=%d:duration=longest" count; ];
      ["-ab"; "32k"];
      ["-acodec"; "libmp3lame"];
      ["-f"; "mp3"];
      [output_mp3_name];
    ]
end

let flacs_zip_to_mp3 ~env ~cwd input_zip_name output_mp3_name = 
  Logs.debug (fun m -> m "flacs_zip_to_mp3 %s -> %s" input_zip_name output_mp3_name);
  let command =
    Eio.Process.run ~cwd @@ Eio.Stdenv.process_mgr env
  in
  command ["unzip"; "-j"; input_zip_name; "*.flac"];
  let flacs =
    Eio.Path.read_dir cwd |> List.filter (fun s -> Filename.extension s = ".flac")
  in
  command @@ create_ffmpeg_command flacs output_mp3_name;
  Logs.debug (fun m -> m "flacs_zip_to_mp3 done")
