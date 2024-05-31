open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type tags = {
  bot_id: snowflake option [@yojson.option];
  integration_id: snowflake option [@yojson.option];
  premium_subscriber: null option [@yojson.option];
  subscription_listing_id: snowflake option [@yojson.option];
  available_for_purchase: null option [@yojson.option];
  guild_connections: null option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type t = {
  id: snowflake;
  name: string;
  color: int;
  hoist: bool;
  icon: string option [@yojson.option];
  unicode_emoji: string option [@yojson.option];
  position: int;
  permissions: string;
  managed: bool;
  mentionable: bool;
  tags: tags option [@yojson.option];
  flags: int;
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type subscription = {
  role_subscription_listing_id: snowflake;
  tier_name: string;
  total_month_subscribed: int;
  is_renewal: bool;
} [@@yojson.allow_extra_fields] [@@deriving yojson]
