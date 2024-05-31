open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type t = {
  id: snowflake option [@yojson.option];
  name: string option [@yojson.option];
  roles: Role.t list [@default []];
  user: User.t option [@yojson.option];
  require_colons: bool option [@yojson.option];
  managed: bool option [@yojson.option];
  animated: bool option [@yojson.option];
  available: bool option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]
