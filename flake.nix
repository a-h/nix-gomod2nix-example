{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/23.11";
    };
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sbomnix = {
      url = "github:tiiuae/sbomnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, gomod2nix, sbomnix }:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
        };
      });
    in
    {
      packages = forAllSystems ({ system, pkgs, ... }:
        let
          buildGoApplication = gomod2nix.legacyPackages.${system}.buildGoApplication;
        in
        {
          default = buildGoApplication {
            # Required args.
            name = "nix-gomod2nix-example";
            src = ./.;

            # Override default Go with Go 1.21.
            #
            # In the latest versions of Go, the go.mod can contain 1.21.5
            # In that case, if the toolchain doesn't match, the go build operation will
            # try and download the correct toolchain.
            #
            # To prevent this, update the go.mod file to contain `go 1.21` instead of `go 1.21.5`.
            go = pkgs.go_1_21;

            # Must be added due to bug https://github.com/nix-community/gomod2nix/issues/120
            pwd = ./.;

            # Optional flags.
            CGO_ENABLED = 0;
            flags = [ "-trimpath" ];
            ldflags = [ "-s" "-w" "-extldflags -static" ];
          };
        });

      devShells = forAllSystems ({ system, pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go_1_21
            gotools
            gomod2nix.packages.${system}.default # gomod2nix CLI
            sbomnix.packages.${system}.default # sbomnix CLI
          ];
        };
      });
    };
}
