# flake-parts module for rust platform
localFlake: {
  perSystem = {
    lib,
    system,
    pkgs,
    ...
  }: let
    toolchain = let
      fenix = localFlake.withSystem system ({inputs', ...}: inputs'.fenix);
      inherit (fenix.packages.minimal) toolchain;
    in
      toolchain.overrideAttrs {
        propagatedSandboxProfile = ''
          ; Allow the system OpenSSL to read its config on 14.2+.
          ; discussed here: https://github.com/NixOS/nix/issues/9625#issuecomment-1863545248
          (allow file-read* (literal "/private/etc/ssl/openssl.cnf"))
        '';
      };
  in {
    options.rustPlatform = lib.mkOption {
      default = pkgs.makeRustPlatform {
        cargo = toolchain;
        rustc = toolchain;
      };
    };
  };
}
