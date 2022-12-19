{ self, ... }: {
  perSystem = { config, self', inputs', system, pkgs, ... }:

    let
      dependencies = with config.purs-nix.ps-pkgs; [
        aff
        effect
        config.purs-nix.ps-pkgs.foreign
        halogen
        maybe
        media-types
        nullable
        pre
        uri
        web-file
        web-html
      ];

      npmlock2nix = pkgs.callPackages self.inputs.npmlock2nix { };
      nodeModules = npmlock2nix.node_modules { src = ./.; };
      foreign.FilePond.node_modules = nodeModules + /node_modules;

      ps = config.purs-nix.purs {
        inherit dependencies foreign;
        dir = ./.;
      };

    in

    {
      packages = {
        filepond-halogen =
          (config.purs-nix.build {
            name = "filepond-halogen";
            src.path = ./.;
            info = { inherit dependencies foreign; };
          }).overrideAttrs (old: {
            passthru = old.passthru // {
              cssFiles = [
                "${nodeModules}/node_modules/filepond/dist/filepond.css"
                "${nodeModules}/node_modules/filepond-plugin-get-file/dist/filepond-plugin-get-file.css"
                "${nodeModules}/node_modules/filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css"
                "${nodeModules}/node_modules/filepond-plugin-media-preview/dist/filepond-plugin-media-preview.css"
              ];
            };
          })
        ;
      };

      extra-shell-tools = [ (config.make-command { inherit ps; pkg = ./.; }) ];
    };

  flake = { };
}
