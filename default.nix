{ self, ... }: {
  perSystem = { config, ... }: {
    packages.filepond-halogen = config.purs-nix-build ./.;
  };
}
