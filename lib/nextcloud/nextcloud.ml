module Config = Config

open struct
  let handle_error ~err_msg response =
    if response.Http.Response.status |> Http.Status.to_int < 300 then ()
    else (
      Logs.err (fun m -> m "%s: %a" err_msg Http.Response.pp response);
      failwith err_msg
    )

  let request ~config:Config.{ host; username; password } ~path =
    let headers =
      Http.Header.of_list @@
      [
        "Host", host;
        "User-Agent", "ocaml-nextcloud";
        "Accept", "*/*";
      ]
    in
    let headers = Cohttp.Header.add_authorization headers @@ `Basic (username,password) in
    let path = 
      let (/) = Filename.concat in
      "/remote.php/dav/files" / username / path 
    in
    Https.request ~host ~headers ~path
end

let get ~env ~cwd ~config path =
  let open Eio in
  let basename = Filename.basename path in
  request ~env ~config `GET ~path ~handler:(fun (response, body) ->
    Logs.info (fun m -> m "[nextcloud] GET %a" Http.Response.pp response);
    handle_error ~err_msg:"Failed to get" response;
    Path.with_open_out ~create:(`Exclusive 0o600) Path.(cwd / basename) (Flow.copy body);
    Logs.info (fun m -> m "Downloaded %s" basename);
  );
  basename

let put ~env ~cwd ~config filename path =
  let body = Eio.Path.(load @@ cwd / filename) in
  request ~env ~config ~body `PUT ~path:Filename.(concat path filename) ~handler:(fun (response, _) ->
    Logs.info (fun m -> m "[nextcloud] PUT %a" Http.Response.pp response);
    handle_error ~err_msg:"Failed to put" response;
    Logs.info (fun m -> m "Uploaded %s" filename);
  )

let delete ~env ~config path =
  request ~env ~config `DELETE ~path ~handler:(fun (response, _) ->
    Logs.info (fun m -> m "[nextcloud] DELETE %a" Http.Response.pp response);
    handle_error ~err_msg:"Failed to delete" response;
    Logs.info (fun m -> m "Deleted %s" path);
  )
