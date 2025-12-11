{
  description = "Ziglings - Learn Zig by fixing tiny broken programs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls.url = "github:zigtools/zls";
    zls.inputs.nixpkgs.follows = "nixpkgs";
    zls.inputs.zig-overlay.follows = "zig-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      zig-overlay,
      zls,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Define the specific Zig version here so we can pass it to ZLS
        zig = zig-overlay.packages.${system}.master;

        # Override ZLS to ensure it builds using our specific Zig version
        zls-pkg = zls.packages.${system}.zls.overrideAttrs (old: {
          nativeBuildInputs = [ zig ];
        });
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            zig
            zls-pkg
          ];

          shellHook = ''
            echo "====================================="
            echo "Ziglings development environment"
            echo "====================================="
            echo ""
            echo "Zig version:"
            zig version
            echo ""
            echo "ZLS version:"
            zls --version
            echo ""
            echo "Run 'zig build' to get started!"
            echo "====================================="
          '';
        };
      }
    );
}
