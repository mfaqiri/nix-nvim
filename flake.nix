{
  description = "My nvim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    flake-parts,
    nixpkgs,
    nvf,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [
      ];

      flake = {
        nixosConfigurations = {
          myNvim = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };

            modules = [
              nvf.homeManagerModules.default
              ./nvim.nix
            ];
          };
        };
      };
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
    });
}
