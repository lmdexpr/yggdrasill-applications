open Httpx.Infix

let version = "v10"

let post_request ~env ~discord_token ~body path =
  let headers = Httpx.Header.of_list [
    "user-agent", "DiscordBot (https://github.com/lmdexpr/yggdrasill, 0.1)";
    "Authorization", Printf.sprintf "Bot %s" discord_token;
    "accept", "*/*"; 
    "Content-type", "application/json"; 
  ] in
  let path = "api" / version / path in
  Httpx.request ~env ~host:"discord.com" ~headers `POST ~path ~body 
