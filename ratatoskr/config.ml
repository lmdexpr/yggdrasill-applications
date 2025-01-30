type t = {
  port : int;
  log_level : Logs.level option;
  discord : Discord.Config.t;
  niflheimr : Nidhoggr.Config.t;
  eio_backend : string;
}

open struct
  open Printf

  let default_prefix = "RATATOSKR"

  let with_prefix ?prefix name = 
    let prefix = Option.value prefix ~default:default_prefix in
    let prefix = if prefix = "" then "" else prefix ^ "_" in
    prefix ^ name

  let getenv ?prefix ~default name =
    with_prefix ?prefix name |> Sys.getenv_opt |> Option.value ~default

  let getenv_exn ?prefix name =
    let name = with_prefix ?prefix name in
    match name |> Sys.getenv_opt with
    | Some x -> x
    | None   -> failwith @@ sprintf "Environment variable %s is not set" name

  let level_of_string = function
    | "debug"   -> Some Logs.Debug
    | "warning" -> Some Logs.Warning
    | "error"   -> Some Logs.Error
    | _         -> Some Logs.Info

  let verify_env ?prefix name value =
    if getenv_exn ?prefix name = value then value
    else
      failwith @@ sprintf "Environment variable %s is not set to the expected value '%s'" name value
end

let load () = {
  port      = getenv ~default:"8080" "PORT" |> int_of_string;
  log_level = getenv ~default:"info" "LOG_LEVEL" |> level_of_string;

  discord = Discord.Config.load ~prefix:default_prefix ();

  niflheimr = Nidhoggr.Config.{
    host     = getenv ~default:"localhost" "NIFLHEIMR_HOST";
    username = getenv_exn "NIFLHEIMR_USERNAME";
    password = getenv_exn "NIFLHEIMR_PASSWORD";
  };

  eio_backend = verify_env ~prefix:"" "EIO_BACKEND" "posix";
}

let load () =
  let open Effect.Deep in
  let open Discord.Effect in
  match load () with
  | effect (Get_string key), k -> continue k @@ getenv_exn key
  | x -> x
