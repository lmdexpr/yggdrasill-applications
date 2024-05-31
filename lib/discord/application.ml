open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type install_params = {
  scopes: string list;
  permissions: string;
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type integration_type =
  | GUILD_INSTALL
  | USER_INSTALL
let yojson_of_integration_type = function
  | GUILD_INSTALL -> `String "0"
  | USER_INSTALL  -> `String "1"
let integration_type_of_yojson = function
  | `String "0" -> GUILD_INSTALL
  | `String "1" -> USER_INSTALL
  | _           -> raise (Yojson.Json_error "integration_type")

type integration_type_configuration = {
  oauth2_install_params: install_params;
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type integration_type_and_configuration = (integration_type * integration_type_configuration) [@@deriving yojson]

type t = {
  id: snowflake;
  name: string;
  icon: string option;
  description: string;
  rpc_origins: string list [@default []];
  bot_public: bool;
  bot_require_code_grant: bool;
  bot: User.t option [@yojson.option];
  terms_of_service_url: string option [@yojson.option];
  privacy_policy_url: string option [@yojson.option];
  owner: User.t option [@yojson.option];
  summary: string option [@yojson.option];
  verify_key: string;
  team: Team.t option [@yojson.option];
  guild_id: snowflake option [@yojson.option];
  guild: Guild.t option [@yojson.option];
  primary_sku_id: snowflake option [@yojson.option];
  slug: string option [@yojson.option];
  cover_image: string option [@yojson.option];
  flags: int option [@yojson.option];
  approximate_guild_count: int option [@yojson.option];
  redirect_uris: string list [@default []];
  interactions_endpoint_url: string option [@yojson.option];
  role_connections_verification_url: string option [@yojson.option];
  tags: string list [@default []];
  install_params: install_params option [@yojson.option];
  integration_types_config: integration_type_and_configuration list [@default []];
  custom_install_url: string option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

