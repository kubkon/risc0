{
  description = "risc0";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/31bf02434acbba190b8d4d2a77c4d83f8eeb71e6";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };


  outputs = {
    flake-utils,
    nixpkgs,
    rust-overlay,
    ...
  } @ inputs: let
    overlays = [(import rust-overlay)];
    systems = [ "aarch64-darwin" "x86_64-linux" ];
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rustVersion = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);
        darwinInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
        #   pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          # pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.Metal
        ];
        sharedInputs = with pkgs; [
          rustVersion
        ];
      in rec {
        # TODO expose as flake package
        devShells.default = pkgs.stdenvNoCC.mkDerivation {
          name = "risc0";
          buildInputs = darwinInputs ++ sharedInputs;
        };
      }
    );
}
