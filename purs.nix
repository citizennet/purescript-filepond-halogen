{ pkgs, npmlock2nix, ... }:

{
  name = "filepond-halogen";
  srcs = [ "src" ];
  dependencies = [
    "aff"
    "effect"
    "foreign"
    "halogen"
    "maybe"
    "media-types"
    "nullable"
    "pre"
    "uri"
    "web-file"
    "web-html"
  ];
  foreign.FilePond.node_modules =
    (npmlock2nix.node_modules { src = ./.; }) + /node_modules;
}
