open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type type_ =
  | PONG
  | CHANNEL_MESSAGE_WITH_SOURCE
  | DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE
  | DEFERRED_UPDATE_MESSAGE
  | UPDATE_MESSAGE
  | APPLICATION_COMMAND_AUTOCOMPLETE_RESULT
  | MODAL
  | PREMIUM_REQUIRED

let yojson_of_type_ = function
  | PONG                                    -> `Int 1
  | CHANNEL_MESSAGE_WITH_SOURCE             -> `Int 4
  | DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE    -> `Int 5
  | DEFERRED_UPDATE_MESSAGE                 -> `Int 6
  | UPDATE_MESSAGE                          -> `Int 7
  | APPLICATION_COMMAND_AUTOCOMPLETE_RESULT -> `Int 8
  | MODAL                                   -> `Int 9
  | PREMIUM_REQUIRED                        -> `Int 10

let type__of_yojson = function
  | `Int 1  -> PONG
  | `Int 4  -> CHANNEL_MESSAGE_WITH_SOURCE
  | `Int 5  -> DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE
  | `Int 6  -> DEFERRED_UPDATE_MESSAGE
  | `Int 7  -> UPDATE_MESSAGE
  | `Int 8  -> APPLICATION_COMMAND_AUTOCOMPLETE_RESULT
  | `Int 9  -> MODAL
  | `Int 10 -> PREMIUM_REQUIRED
  | _       -> raise (Yojson.Json_error "Invalid interaction response type")

type data = {
  content: string option [@default None];
} [@@deriving yojson]

type t = {
  type_: type_; [@key "type"]
  data: data option [@yojson.option];
} [@@deriving yojson]

let pong = { type_ = PONG; data = None }
let channel_message_with_source content =
  { type_ = CHANNEL_MESSAGE_WITH_SOURCE; data = Some { content = Some content } }
let deferred_channel_message_with_source =
  { type_ = DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE; data = None }

let body_of_t t = yojson_of_t t |> Yojson.Safe.to_string |> Httpx.Body.of_string

let ok t = 
  let headers = Httpx.Header.of_list [ "content-type", "application/json"] in
  Httpx.Response.make ~status:`OK ~headers (), body_of_t t

let follow_up ~env ~application_id ~discord_token ~interaction:Interaction.{ token; _ } msg =
  let uri = Printf.sprintf "webhooks/%s/%s" application_id token in
  let body = Yojson.Safe.to_string @@ yojson_of_data { content = Some msg } in
  Client.post_request ~env ~discord_token ~body uri
