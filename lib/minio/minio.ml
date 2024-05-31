module Config = Config

open struct
  let handle_error ~err_msg response =
    if response.Http.Response.status |> Http.Status.to_int < 300 then ()
    else (
      Logs.err (fun m -> m "%s: %a" err_msg Http.Response.pp response);
      failwith err_msg
    )
end

let get_object ~env ~cwd ~config path =
  let open Eio in
  let basename = Filename.basename path in
  Client.call ~env ~config `GET path ~handler:(fun (response, body) ->
    handle_error ~err_msg:"Failed to get object" response;
    Path.with_open_out ~create:(`Exclusive 0o600) Path.(cwd / basename) (Flow.copy body)
  );
  basename

let put_object ~env ~cwd ~config filename path =
  let body = Eio.Path.(load @@ cwd / filename) in
  Client.call ~env ~config ~body `PUT Filename.(concat path filename) ~handler:(fun (response, _) ->
    handle_error ~err_msg:"Failed to put object" response;
  )

let delete_object ~env ~config path =
  Client.call ~env ~config `DELETE path ~handler:(fun (response, _) ->
    handle_error ~err_msg:"Failed to delete object" response;
  )
