{
  description = "near-cli Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      supportedSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-linux"
        "x86_64-darwin"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.near-cli =
          pkgs.callPackage ./near-cli.nix {
            inherit (pkgs.darwin.apple_sdk.frameworks) AppKit CoreFoundation IOKit;
          };

        defaultPackage = packages.near-cli;
        defaultApp = { type = "app"; program = "${packages.near-cli}/bin/near"; };
      });
}
