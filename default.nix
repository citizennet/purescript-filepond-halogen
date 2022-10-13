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
        self'.packages.pre
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
          config.purs-nix.build {
            name = "filepond-halogen";
            src.path = ./.;
            info = { inherit dependencies foreign; };
          };
        filepond-halogen-nodeModules = nodeModules;
      };

      extra-shell-tools = [ (config.make-command { inherit ps; pkg = ./.; }) ];
    };

  flake = { };
}
