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

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org" # for fenix
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    sandbox = "relaxed";
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
