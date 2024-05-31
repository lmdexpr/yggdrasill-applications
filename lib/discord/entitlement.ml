open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type t = {
  id: snowflake;
  sku_id: snowflake;
  application_id: snowflake;
  user_id: snowflake option [@yojson.option];
  type_: int [@key "type"];
  deleted: bool;
  starts_at: timestamp option [@yojson.option];
  ends_at: timestamp option [@yojson.option];
  guild_id: snowflake option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]
