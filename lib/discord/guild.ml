open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type member = {
  user: User.t option [@yojson.option];
  nick: string option [@yojson.option];
  avatar: string option [@yojson.option];
  roles: snowflake list;
  joined_at: timestamp;
  premium_since: string option [@yojson.option];
  deaf: bool;
  mute: bool;
  flags: int;
  pending: bool option [@yojson.option];
  permissions: string option [@yojson.option];
  communication_disabled_until: string option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type feature =
  | ANIMATED_BANNER
  | ANIMATED_ICON
  | APPLICATION_COMMAND_PERMISSIONS_V2
  | AUTO_MODERATION
  | BANNER
  | COMMUNITY
  | CREATOR_MONETIZABLE_PROVISIONAL
  | CREATOR_STORE_PAGE
  | DEVELOPER_SUPPORT_SERVER
  | DISCOVERABLE
  | FEATURABLE
  | INVITES_DISABLED
  | INVITE_SPLASH
  | MEMBER_VERIFICATION_GATE_ENABLED
  | MORE_STICKERS
  | NEWS
  | PARTNERED	
  | PREVIEW_ENABLED
  | RAID_ALERTS_DISABLED
  | ROLE_ICONS
  | ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE
  | ROLE_SUBSCRIPTIONS_ENABLED
  | TICKETED_EVENTS_ENABLED
  | VANITY_URL
  | VERIFIED
  | VIP_REGIONS
  | WELCOME_SCREEN_ENABLED
  [@@deriving yojson]

module Welcome_screen = struct
  type channel = {
    channel_id: snowflake;
    description: string;
    emoji_id: snowflake option [@yojson.option];
    emoji_name: string option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type t = {
    description: string option [@yojson.option];
    welcome_channels: channel list;
  } [@@yojson.allow_extra_fields] [@@deriving yojson]
end

type sticker = {
  id: snowflake;
  pack_id: snowflake option [@yojson.option];
  name: string;
  description: string option [@yojson.option];
  tags: string;
  asset: string option [@yojson.option];
  type_: int [@key "type"];
  format_type: int;
  available: bool option [@yojson.option];
  guild_id: snowflake option [@yojson.option];
  user: User.t option [@yojson.option];
  sort_value: int option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type t = {
  id: snowflake;
  name: string option [@yojson.option];
  icon: string option [@yojson.option];
  icon_hash: string option [@yojson.option];
  splash: string option [@yojson.option];
  discovery_splash: string option [@yojson.option];
  owner: bool option [@yojson.option];
  owner_id: snowflake option [@yojson.option];
  permissions: string option [@yojson.option];
  region: string option [@yojson.option];
  afk_channel_id: snowflake option [@yojson.option];
  afk_timeout: int option [@yojson.option];
  widget_enabled: bool option [@yojson.option];
  widget_channel_id: snowflake option [@yojson.option];
  verification_level: int option [@yojson.option];
  default_message_notifications: int option [@yojson.option];
  explicit_content_filter: int option [@yojson.option];
  roles: Role.t list [@default []];
  emojis: Emoji.t list [@default []];
  features: feature list [@default []];
  mfa_level: int option [@yojson.option];
  application_id: snowflake option [@yojson.option];
  system_channel_id: snowflake option [@yojson.option];
  system_channel_flags: int option [@yojson.option];
  rules_channel_id: snowflake option [@yojson.option];
  max_presences: int option [@yojson.option];
  max_members: int option [@yojson.option];
  vanity_url_code: string option [@yojson.option];
  description: string option [@yojson.option];
  banner: string option [@yojson.option];
  premium_tier: int option [@yojson.option];
  premium_subscription_count: int option [@yojson.option];
  preferred_locale: string option [@yojson.option];
  public_updates_channel_id: snowflake option [@yojson.option];
  max_video_channel_users: int option [@yojson.option];
  max_stage_video_channel_users: int option [@yojson.option];
  approximate_member_count: int option [@yojson.option];
  approximate_presence_count: int option [@yojson.option];
  welcome_screen: Welcome_screen.t option [@yojson.option];
  nsfw_level: int option [@yojson.option];
  stickers: sticker list [@default []];
  premium_progress_bar_enabled: bool option [@yojson.option];
  safety_alerts_channel_id: snowflake option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]
