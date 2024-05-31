open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type t = {
  id: snowflake;
  username: string;
  discriminator: string;
  global_name: string option [@yojson.option];
  avatar: string option [@yojson.option];
  bot: bool option [@yojson.option];
  system: bool option [@yojson.option];
  mfa_enabled: bool option [@yojson.option];
  banner: string option [@yojson.option];
  accent_color: int option [@yojson.option];
  locale: string option [@yojson.option];
  verified: bool option [@yojson.option];
  email: string option [@yojson.option];
  flags: int option [@yojson.option];
  premium_type: int option [@yojson.option];
  public_flags: int option [@yojson.option];
  avatar_decoration: string option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]
