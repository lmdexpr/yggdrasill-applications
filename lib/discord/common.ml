open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type snowflake = string [@@deriving yojson]

type timestamp = string [@@deriving yojson]

type null = bool
let null_of_yojson = function
  | `Null -> true
  | _     -> false
let yojson_of_null b = if b then `Null else raise (Yojson.Json_error "null")

type integer_or_string = [ `Int of int | `String of string ]
let integer_or_string_of_yojson = function
  | `Int i    -> `Int i
  | `String s -> `String s
  | _         -> raise (Yojson.Json_error "integer_or_string")
let yojson_of_integer_or_string = function
  | `Int i    -> `Int i
  | `String s -> `String s

type string_or_integer_or_double_or_boolean = [ `String of string | `Int of int | `Float of float | `Bool of bool ]
let string_or_integer_or_double_or_boolean_of_yojson = function
  | `String s -> `String s
  | `Int i    -> `Int i
  | `Float f  -> `Float f
  | `Bool b   -> `Bool b
  | _         -> raise (Yojson.Json_error "string_or_integer_or_double_or_boolean")
let yojson_of_string_or_integer_or_double_or_boolean = function
  | `String s -> `String s
  | `Int i    -> `Int i
  | `Float f  -> `Float f
  | `Bool b   -> `Bool b
