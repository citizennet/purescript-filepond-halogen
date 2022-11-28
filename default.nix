{ self, inputs, ... }: {
  perSystem = { config, pkgs, ... }: {
    packages.filepond-halogen = (config.purs-nix-build ./.).overrideAttrs (old: {
      passthru = old.passthru // {
        cssFiles =
          let
            # TODO: Expose purs.nix foreign node modules, so it can be reused.
            nodeModules = (import inputs.npmlock2nix { inherit pkgs; }).node_modules { src = ./.; };
          in
          [
            "${nodeModules}/node_modules/filepond/dist/filepond.css"
            "${nodeModules}/node_modules/filepond-plugin-get-file/dist/filepond-plugin-get-file.css"
            "${nodeModules}/node_modules/filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css"
            "${nodeModules}/node_modules/filepond-plugin-media-preview/dist/filepond-plugin-media-preview.css"
          ];
      };
    })
    ;
  };
}
