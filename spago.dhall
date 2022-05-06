{-
A Halogen wrapper for the FilePond library, providing a component that works as
a file picker/uploader.
-}
let
  name = "form2"
in
  { name
  , dependencies =
      [ "aff"
      , "effect"
      , "foreign"
      , "halogen"
      , "maybe"
      , "media-types"
      , "nullable"
      , "pre"
      , "web-file"
      , "web-html"
      ]
  , packages = ../../packages.dhall
  -- Due to a spago bug (see https://github.com/purescript/spago/issues/648)
  -- `sources` are relative to root instead of config file.
  , sources = [ "lib/${name}/src/**/*.purs" ]
  }
