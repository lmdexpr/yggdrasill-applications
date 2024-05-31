type t = {
  port : int;
  log_level : Logs.level option;
  discord : Discord.Config.t;
  niflheimr : Nidhoggr.Config.t;
}

open struct
  let with_prefix name = "RATATOSKR_" ^ name

  let getenv ~default name =
    with_prefix name |> Sys.getenv_opt |> Option.value ~default

  let getenv_exn name =
    match with_prefix name |> Sys.getenv_opt with
    | Some x -> x
    | None   -> failwith (Printf.sprintf "Environment variable %s is not set" name) 

  let level_of_string = function
    | "debug"   -> Some Logs.Debug
    | "warning" -> Some Logs.Warning
    | "error"   -> Some Logs.Error
    | _         -> Some Logs.Info
end

let load () =
  {
    port      = getenv ~default:"8080" "PORT" |> int_of_string;
    log_level = getenv ~default:"info" "LOG_LEVEL" |> level_of_string;
    discord   = {
      public_key     = getenv_exn "PUBLIC_KEY";
      discord_token  = getenv_exn "DISCORD_TOKEN";
      application_id = getenv_exn "APPLICATION_ID";
      guild_ids      = getenv ~default:"" "GUILD_IDS" |> String.split_on_char ',' |> List.filter (fun x -> x <> "");
    };
    niflheimr = Nidhoggr.Config.{
      host = getenv ~default:"localhost" "NIFLHEIMR_HOST";

      username = getenv_exn "NIFLHEIMR_USERNAME";
      password = getenv_exn "NIFLHEIMR_PASSWORD";
    };
  }
