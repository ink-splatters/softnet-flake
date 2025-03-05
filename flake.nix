{
  description = "software networking for Tart";
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-analyzer-src.follows = "";
      };
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      flake-parts-lib,
      withSystem,
      ...
    }: let
      inherit (flake-parts-lib) importApply;
      flakeModules.default = import ./flake-module.nix;
      rustPlatform = importApply ./rust-platform.nix {inherit withSystem;};
    in {
      imports = [
        flakeModules.default
        rustPlatform
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        packages.default = config.packages.softnet;
        formatter = pkgs.alejandra;
      };

      # exports
      flake = {
        inherit flakeModules;
      };
    });
}
