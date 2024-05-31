open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Common

type overwrite = {
  id: snowflake;
  type_: string [@key "type"];
  allow: string;
  deny: string;
} [@@yojson.allow_extra_fields] [@@deriving yojson]

module Thread = struct
  type metadata = {
    archived: bool;
    auto_archive_duration: int;
    archive_timestamp: timestamp;
    locked: bool;
    invitable: bool option [@yojson.option];
    create_timestamp: timestamp option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type member = {
    id: snowflake option [@yojson.option];
    user_id: snowflake option [@yojson.option];
    join_timestamp: timestamp;
    flags: int;
    member: Guild.member option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]
end

type forum_tag = {
  id: snowflake;
  name: string;
  moderated: bool;
  emoji_id: snowflake option [@yojson.option];
  emoji_name: string option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type default_reaction = {
  emoji_id: snowflake option [@yojson.option];
  emoji_name: string option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type t = {
  id: snowflake;
  type_: int [@key "type"];
  guild_id: snowflake option [@yojson.option];
  position: int option [@yojson.option];
  permission_overwrites: overwrite list [@default []];
  name: string option [@yojson.option];
  topic: string option [@yojson.option];
  nsfw: bool option [@yojson.option];
  last_message_id: snowflake option [@yojson.option];
  bitrate: int option [@yojson.option];
  user_limit: int option [@yojson.option];
  rate_limit_per_user: int option [@yojson.option];
  recipients: User.t list [@default []];
  icon: string option [@yojson.option];
  owner_id: snowflake option [@yojson.option];
  application_id: snowflake option [@yojson.option];
  managed: bool option [@yojson.option];
  parent_id: snowflake option [@yojson.option];
  last_pin_timestamp: timestamp option [@yojson.option];
  rtc_region: string option [@yojson.option];
  video_quality_mode: int option [@yojson.option];
  message_count: int option [@yojson.option];
  member_count: int option [@yojson.option];
  thread_metadata: Thread.metadata option [@yojson.option];
  member: Thread.member option [@yojson.option];
  default_auto_archive_duration: int option [@yojson.option];
  permissions: string option [@yojson.option];
  flags: int option [@yojson.option];
  total_message_sent: int option [@yojson.option];
  available_tags: forum_tag option [@yojson.option];
  applied_tags: snowflake list [@default []];
  default_reaction_emoji: default_reaction option [@yojson.option];
  default_thread_rate_limit_per_user: int option [@yojson.option];
  default_sort_order: int option [@yojson.option];
  default_forum_layout: int option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type mention = {
  id: snowflake;
  guild_id: snowflake;
  type_: int [@key "type"];
  name: string;
} [@@yojson.allow_extra_fields] [@@deriving yojson]

type attachment = {
  id: snowflake;
  filename: string;
  description: string option [@yojson.option];
  content_type: string option [@yojson.option];
  size: int;
  url: string;
  proxy_url: string;
  height: int option [@yojson.option];
  width: int option [@yojson.option];
  ephemeral: bool option [@yojson.option];
  duration_secs: float option [@yojson.option];
  wavefrom: string option [@yojson.option];
  file: int option [@yojson.option];
} [@@yojson.allow_extra_fields] [@@deriving yojson]

module Embedded = struct
  type footer = {
    text: string;
    icon_url: string option [@yojson.option];
    proxy_icon_url: string option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type image = {
    url: string;
    proxy_url: string option [@yojson.option];
    height: int option [@yojson.option];
    width: int option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type thumbnail = {
    url: string;
    proxy_url: string option [@yojson.option];
    height: int option [@yojson.option];
    width: int option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type video = {
    url: string;
    proxy_url: string option [@yojson.option];
    height: int option [@yojson.option];
    width: int option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type provider = {
    name: string;
    url: string option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type author = {
    name: string;
    url: string option [@yojson.option];
    icon_url: string option [@yojson.option];
    proxy_icon_url: string option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type field = {
    name: string;
    value: string;
    inline: bool option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type t = {
    title: string option [@yojson.option];
    type_: string [@key "type"];
    description: string option [@yojson.option];
    url: string option [@yojson.option];
    timestamp: timestamp option [@yojson.option];
    color: int option [@yojson.option];
    footer: footer option [@yojson.option];
    image: image option [@yojson.option];
    thumbnail: thumbnail option [@yojson.option];
    video: video option [@yojson.option];
    provider: provider option [@yojson.option];
    author: author option [@yojson.option];
    fields: field list [@default []];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]
end

module Reaction = struct
  type count_details = {
    burst: int;
    normal: int;
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type t = {
    count: int;
    count_details: count_details;
    me: bool;
    me_burst: bool;
    emoji: Emoji.t;
    burst_colors: string list;
  } [@@yojson.allow_extra_fields] [@@deriving yojson]
end

module Message = struct
  type activity = {
    type_: int [@key "type"];
    party_id: string option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  type reference = {
    message_id: snowflake option [@yojson.option];
    channel_id: snowflake option [@yojson.option];
    guild_id: snowflake option [@yojson.option];
    fail_if_not_exists: bool option [@yojson.option];
  } [@@yojson.allow_extra_fields] [@@deriving yojson]

  module Interaction = struct
    type type_ =
      | PING
      | APPLICATION_COMMAND
      | MESSAGE_COMPONENT
      | APPLICATION_COMMAND_AUTOCOMPLETE
      | MODAL_SUBMIT
    let type__of_yojson = function
      | `Int 1 -> PING
      | `Int 2 -> APPLICATION_COMMAND
      | `Int 3 -> MESSAGE_COMPONENT
      | `Int 4 -> APPLICATION_COMMAND_AUTOCOMPLETE
      | `Int 5 -> MODAL_SUBMIT
      | _      -> raise (Yojson.Json_error "Interaction.type_")
    let yojson_of_type_ = function
      | PING                             -> `Int 1
      | APPLICATION_COMMAND              -> `Int 2
      | MESSAGE_COMPONENT                -> `Int 3
      | APPLICATION_COMMAND_AUTOCOMPLETE -> `Int 4
      | MODAL_SUBMIT                     -> `Int 5

    type authorizing_integration_owner = (type_ * snowflake) [@@deriving yojson]

    type metadata = {
      id: snowflake;
      type_: type_ [@key "type"];
      user_id: snowflake;
      authorizing_integration_owners: authorizing_integration_owner list;
      original_response_message_id: snowflake option [@yojson.option];
      interacted_message_id: snowflake option [@yojson.option];
      triggering_interaction_metadata: metadata option [@yojson.option];
    } [@@yojson.allow_extra_fields] [@@deriving yojson]

    type t = {
      id: snowflake;
      type_: int [@key "type"];
      name: string;
      user: User.t;
    } [@@yojson.allow_extra_fields] [@@deriving yojson]
  end

  module Component = struct
    type t = Yojson.Safe.t
    let t_of_yojson t = t
    let yojson_of_t t = t
  end

  module Sticker = struct
    type item = {
      id: snowflake;
      name: string;
      format_type: int;
    } [@@yojson.allow_extra_fields] [@@deriving yojson]

    type t = {
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
  end

  open struct
    type resolved = Yojson.Safe.t
    let resolved_of_yojson t = t
    let yojson_of_resolved t = t

    type msg = {
      id: snowflake;
      channel_id: snowflake;
      author: User.t;
      content: string;
      timestamp: timestamp;
      edited_timestamp: timestamp option [@yojson.option];
      tts: bool;
      mention_everyone: bool;
      mentions: User.t list;
      mention_roles: Role.t list;
      mention_channels: mention list;
      attachments: attachment list;
      embedded: Embedded.t list;
      reactions: Reaction.t list [@default []];
      nonce: integer_or_string option [@yojson.option];
      pinned: bool;
      webhook_id: snowflake option [@yojson.option];
      type_: int [@key "type"];
      activity: activity option [@yojson.option];
      application: Application.t option [@yojson.option];
      application_id: snowflake option [@yojson.option];
      message_reference: reference option [@yojson.option];
      flags: int option [@yojson.option];
      referenced_message: msg option [@yojson.option];
      interaction_metadata: Interaction.metadata option [@yojson.option];
      interaction: Interaction.t option [@yojson.option];
      thread: t option [@yojson.option];
      components: Component.t list [@default []];
      sticker_items: Sticker.item list [@default []];
      stickers: Sticker.t list [@default []];
      position: int option [@yojson.option];
      role_subscription_data: Role.subscription option [@yojson.option];
      resolved: resolved option [@yojson.option];
    } [@@yojson.allow_extra_fields] [@@deriving yojson]
  end

  type t = msg [@@deriving yojson]
end
