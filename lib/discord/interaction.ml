open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type type_ =
  | PING
  | APPLICATION_COMMAND
  | MESSAGE_COMPONENT
  | APPLICATION_COMMAND_AUTOCOMPLETE
  | MODAL_SUBMIT

let yojson_of_type_ = function
  | PING                             -> `Int 1
  | APPLICATION_COMMAND              -> `Int 2
  | MESSAGE_COMPONENT                -> `Int 3
  | APPLICATION_COMMAND_AUTOCOMPLETE -> `Int 4
  | MODAL_SUBMIT                     -> `Int 5

let type__of_yojson = function
  | `Int 1 -> PING
  | `Int 2 -> APPLICATION_COMMAND
  | `Int 3 -> MESSAGE_COMPONENT
  | `Int 4 -> APPLICATION_COMMAND_AUTOCOMPLETE
  | `Int 5 -> MODAL_SUBMIT
  | _      -> raise (Yojson.Json_error "interaction type")

type snowflake_user = (snowflake * User.t) [@@deriving yojson]
type snowflake_guild_member = (snowflake * Guild.member) [@@deriving yojson]
type snowflake_role = (snowflake * Role.t) [@@deriving yojson]
type snowflake_channel = (snowflake * Channel.t) [@@deriving yojson]
type snowflake_message = (snowflake * Channel.Message.t) [@@deriving yojson]
type snowflake_attachment = (snowflake * Channel.attachment) [@@deriving yojson]

type resolved = {
  users: snowflake_user list;
  members: snowflake_guild_member list;
  roles: snowflake_role list;
  channels: snowflake_channel list;
  messages: snowflake_message list;
  attachments: snowflake_attachment list;
} [@@yojson.allow_extra_fields] [@@deriving yojson]

module Opt = struct
  type type_ =
    | SUB_COMMAND
    | SUB_COMMAND_GROUP
    | STRING
    | INTEGER
    | BOOLEAN
    | USER
    | CHANNEL
    | ROLE
    | MENTIONABLE
    | NUMBER
    | ATTACHMENT
  let yojson_of_type_ = function
    | SUB_COMMAND       -> `Int 1
    | SUB_COMMAND_GROUP -> `Int 2
    | STRING            -> `Int 3
    | INTEGER           -> `Int 4
    | BOOLEAN           -> `Int 5
    | USER              -> `Int 6
    | CHANNEL           -> `Int 7
    | ROLE              -> `Int 8
    | MENTIONABLE       -> `Int 9
    | NUMBER            -> `Int 10
    | ATTACHMENT        -> `Int 11
  let type__of_yojson = function
    | `Int 1  -> SUB_COMMAND
    | `Int 2  -> SUB_COMMAND_GROUP
    | `Int 3  -> STRING
    | `Int 4  -> INTEGER
    | `Int 5  -> BOOLEAN
    | `Int 6  -> USER
    | `Int 7  -> CHANNEL
    | `Int 8  -> ROLE
    | `Int 9  -> MENTIONABLE
    | `Int 10 -> NUMBER
    | `Int 11 -> ATTACHMENT
    | _       -> raise (Yojson.Json_error "option type")

  type t = {
    name: string;
    type_: type_ [@key "type"];
    value: string_or_integer_or_double_or_boolean option [@yojson.option];
    options: t list [@default []];
    focused: bool option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]
end

type data = {
  id: snowflake;
  name: string;
  type_: int [@key "type"];
  resolved: resolved option [@yojson.option];
  options: Opt.t list [@default []];
  guild_id: snowflake option [@yojson.option];
  target_id: snowflake option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

open struct
  type inner = Yojson.Safe.t
  let inner_of_yojson t = t
  let yojson_of_inner t = t

  type authorizing_integration_owner = (Application.integration_type * inner) [@@deriving yojson]
end

type context_type =
  | GUILD
  | BOT_DM
  | PRIVATE_CHANNEL
let context_type_of_yojson = function
  | `Int 0 -> GUILD
  | `Int 1 -> BOT_DM
  | `Int 2 -> PRIVATE_CHANNEL
  | _      -> raise (Yojson.Json_error "context type")
let yojson_of_context_type = function
  | GUILD           -> `Int 0
  | BOT_DM          -> `Int 1
  | PRIVATE_CHANNEL -> `Int 2

type t = {
  id: snowflake;
  application_id: snowflake;
  type_: type_ [@key "type"];
  data: data option [@yojson.option];
  token: string;
  (*
  guild: Guild.t option [@yojson.option];
  guild_id: snowflake option [@yojson.option];
  channel: Channel.t option [@yojson.option];
  channel_id: snowflake option [@yojson.option];
  member: Guild.member option [@yojson.option];
  user: User.t option [@yojson.option];
  version: int;
  message: Channel.Message.t option [@yojson.option];
  app_permissions: string;
  locale: string option [@default None];
  guild_locale: string option [@default None];
  entitlements: Entitlement.t list [@default []];
  authorizing_integration_owners: authorizing_integration_owner list [@default []];
  context: context_type option [@yojson.option];
  *)
} [@@yojson.allow_extra_fields] [@@deriving yojson] 

let of_string s =
  let yojson = s |> Yojson.Safe.from_string in
  Logs.debug (fun m -> m "Interaction body: %a" Yojson.Safe.pp yojson);
  t_of_yojson yojson

let pp ppf t = t |> yojson_of_t |> Yojson.Safe.pretty_to_string |> Format.fprintf ppf "%s"

let find_option_string_exn (interaction: t) needle =
  let data = Option.get interaction.data in
  let opt  = List.find (fun Opt.{name; _} -> name = needle) data.options in
  match opt.value with Some (`String v) -> v | _ -> raise @@ Invalid_argument "opt.value"
