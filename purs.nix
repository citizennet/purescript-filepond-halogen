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
  foreign.FilePond = {
    type = "npm";
    path = ./.;
  };
}
