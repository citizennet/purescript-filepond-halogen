{-
{{GENERATED_DOC}}

A Halogen wrapper for the FilePond library, providing a component that works as
a file picker/uploader.
-}
let
  name = "filepond-halogen"
in
  { name
  , dependencies =
      [ "aff"
      , "effect"
      , "enums"
      , "foreign"
      , "halogen"
      , "halogen-subscriptions"
      , "media-types"
      , "nullable"
      , "pre"
      , "prelude"
      , "uri"
      , "web-file"
      , "web-html"
      ]
  -- This path is relative to config file
  , packages = {{PACKAGES_DIR}}/packages.dhall
  -- This path is relative to project root
  -- See https://github.com/purescript/spago/issues/648
  , sources = [ "{{SOURCES_DIR}}/src/**/*.purs" ]
  }
