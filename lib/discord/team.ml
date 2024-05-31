open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type member = {
  membership_state: int;
  team_id: snowflake;
  user: User.t;
  role: string;
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type t = {
  icon : string option;
  id : snowflake;
  members : member list;
  name : string;
  owner_user_id : snowflake;
} [@@yojson.allow_extra_fields] [@@deriving yojson]
