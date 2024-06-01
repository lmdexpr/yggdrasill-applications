module Config               = Config
module Client               = Client
module Interaction          = Interaction
module Interaction_response = Interaction_response
module Slash_command        = Slash_command

let verify_key ~public_key headers body =
  let (let*) = Option.bind in
  let* signature = Httpx.Header.get headers "x-signature-ed25519" in
  let* timestamp = Httpx.Header.get headers "x-signature-timestamp" in
  try
    Logs.debug (fun m -> m "Verifying signature: %a" Hex.pp @@ `Hex signature);
    Logs.debug (fun m -> m "Timestamp: %a" Hex.pp @@ `Hex timestamp);
    Logs.debug (fun m -> m "Body: %s" (timestamp ^ body));
    Sodium.Sign.Bytes.(verify
      (`Hex public_key  |> Hex.to_bytes |> to_public_key)
      (`Hex signature   |> Hex.to_bytes |> to_signature)
      (timestamp ^ body |> String.to_bytes)
    );
    Some ()
  with e ->
    Logs.err (fun m -> m "Verification failed: %s" (Printexc.to_string e));
    None
