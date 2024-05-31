open struct
  let version = "v10"
  
  let request ~env ~discord_token ?(headers=Cohttp.Header.of_list []) ~meth ~body path =
    let headers = Cohttp.Header.add_list headers [
      "user-agent", "DiscordBot (https://github.com/lmdexpr/yggdrasill, 0.1)";
      "Authorization", Printf.sprintf "Bot %s" discord_token;
      "accept", "*/*";
    ] in
    let path =
      let (/) = Filename.concat in
      "api" / version / path
    in
    Https.request ~env ~host:"discord.com" ~headers meth ~path ~body 
end

let post_request ~env = 
  request ~env ~meth:`POST ~headers:Cohttp.Header.(of_list [ "Content-type", "application/json"; ])
