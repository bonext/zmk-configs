{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = taira;

      lily58 = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "lily58";
        board = "nice_nano_v2";
        shield = "lily58_%PART%";
        src = ./keyboards/lily58/.;
        zephyrDepsHash = "sha256-y30Odzj7vJ5/NXubd/pTsHWJNJqBN6vg7j0cnCGEwFE=";
      };

      taira = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "taira";
        board = "nice_nano_v2";
        shield = "taira_%PART%";
        src = ./keyboards/taira/.;
        zephyrDepsHash = "sha256-y30Odzj7vJ5/NXubd/pTsHWJNJqBN6vg7j0cnCGEwFE=";
      };
    });

    devShells = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          inputsFrom = [ zmk-nix.devShells.${system}.default ];
          buildInputs = [
            pkgs.nixd
          ];
        };
      });
  };
}
