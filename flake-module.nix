{lib, ...}: {
  perSystem = {
    config,
    system,
    pkgs,
    ...
  }: let
    inherit (pkgs) apple-sdk_12 fetchFromGitHub;
    inherit (pkgs.llvmPackages_latest) clang bintools stdenv;
    buildRustPackage = config.rustPlatform.buildRustPackage.override {inherit stdenv;};
  in {
    packages.softnet = buildRustPackage rec {
      pname = "softnet";
      version = "0.13.1";

      src = fetchFromGitHub {
        owner = "cirruslabs";
        repo = "${pname}";
        rev = "${version}";
        hash = "sha256-h8A3XyPH3agSKd/HrHFJrPcMy7qKi3ykVWeVYwX0gH8=";
      };

      useFetchCargoVendor = true;
      cargoHash = "sha256-ALUAy4aHXMIgepBjhYgyYagY6K4rG1O4Cyt1ko13lyE=";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        cp target/*/release/${pname} -t $out/bin

        runHook postInstall
      '';

      buildInputs = [
        apple-sdk_12
      ];

      nativeBuildInputs = [
        clang
        bintools
      ];

      env.RUSTFLAGS = lib.concatMapStringsSep " " (x: "-C ${x}") [
        "target-cpu=native"
        "codegen-units=1"
        "embed-bitcode=yes"
        "linker=${clang}/bin/cc"
        "link-args=-fuse-ld=lld"
        "lto=thin"
        "opt-level=3"
        "strip=debuginfo"
      ];
      env = {
        NIX_ENFORCE_NO_NATIVE = 0;
        NIX_ENFORCE_PURITY = 0;
      };

      # hardeningDisable = [ "fortify" ];
    };
  };
}
