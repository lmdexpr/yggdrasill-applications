module Config = Config

open struct
  let request ~config:Config.{ host; username; password } ~path =
    let headers =
      Httpx.Header.of_list @@
      [
        "Host", host;
        "User-Agent", "ocaml-nextcloud";
        "Accept", "*/*";
      ]
    in
    let headers = Httpx.Header.add_authorization headers @@ `Basic (username,password) in
    let path = 
      let (/) = Filename.concat in
      "/remote.php/dav/files" / username / path 
    in
    Httpx.request ~host ~headers ~path
end

let get ~env ~cwd ~config path =
  let open Eio in
  let basename = Filename.basename path in
  request ~env ~config `GET ~path ~handler:(fun (response, body) ->
    Logs.info (fun m -> m "[nextcloud] GET %a" Httpx.Response.pp response);
    Httpx.handle_error ~err_msg:"Failed to get" response;
    Path.with_open_out ~create:(`Exclusive 0o600) Path.(cwd / basename) (Flow.copy body);
    Logs.info (fun m -> m "Downloaded %s" basename);
  );
  basename

let put ~env ~cwd ~config filename path =
  let body = Eio.Path.(load @@ cwd / filename) in
  request ~env ~config ~body `PUT ~path:Filename.(concat path filename) ~handler:(fun (response, _) ->
    Logs.info (fun m -> m "[nextcloud] PUT %a" Httpx.Response.pp response);
    Httpx.handle_error ~err_msg:"Failed to put" response;
    Logs.info (fun m -> m "Uploaded %s" filename);
  )

let delete ~env ~config path =
  request ~env ~config `DELETE ~path ~handler:(fun (response, _) ->
    Logs.info (fun m -> m "[nextcloud] DELETE %a" Httpx.Response.pp response);
    Httpx.handle_error ~err_msg:"Failed to delete" response;
    Logs.info (fun m -> m "Deleted %s" path);
  )
