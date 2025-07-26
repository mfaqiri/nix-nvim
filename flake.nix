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
        nvf.homeManagerModules.default
        ./nvim.nix
      ];

      flake = {
        homeManagerModules = {
          nvim-conf = import ./nvim.nix;
          default = self.homeManagerModules.nvim-conf;
        };
        systems = [
          "x86_64-linux"
          "x86_64-darwin"
        ];
        perSystem = {pkgs, ...}: {
          # Provides the default formatter for 'nix fmt', which will format the
          # entire tree with Alejandra. The wrapper script is necessary due to
          # changes to the behaviour of Nix, which now encourages wrappers for
          # tree-wide formatting.
          vim-plugins = pkgs.vimPlugins;

          formatter = pkgs.writeShellApplication {
            name = "nix3-fmt-wrapper";

            runtimeInputs = [
              pkgs.alejandra
              pkgs.fd
            ];

            text = ''
              # Find Nix files in the tree and format them with Alejandra
              fd "$@" -t f -e nix -x alejandra -q '{}'
            '';
          };

          # Provides checks to be built an ran on 'nix flake check'. They can also
          # be built individually with 'nix build' as described below.
          checks = {
            # Check if codebase is properly formatted.
            # This can be initiated with `nix build .#checks.<system>.nix-fmt`
            # or with `nix flake check`
            nix-fmt = pkgs.runCommand "nix-fmt-check" {nativeBuildInputs = [pkgs.alejandra];} ''
              alejandra --check ${self} < /dev/null | tee $out
            '';
          };
        };
      };
    });
}
