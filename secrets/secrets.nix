# secrets/secrets.nix
let
  agenixKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOQOCuWhMbi+7B5G6EQanpzLBxIp+61u+p/2eV7BBbS wd15@pippi";
in
{
  "opencommit-api-key.age".publicKeys = [ agenixKey ];
}
