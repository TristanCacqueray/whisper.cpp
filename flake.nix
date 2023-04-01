{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        base-en = pkgs.fetchurl {
          url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/80da2d8bfee42b0e836fc3a9890373e5defc00a6/ggml-base.en.bin";
          sha256 = "00nhqqvgwyl9zgyy7vk9i3n017q2wlncp5p7ymsk0cpkdp47jdx0";
        };
        pkg = pkgs.stdenv.mkDerivation {
          name = "whisper.cpp";
          src = ./.;
          nativeBuildInputs = with pkgs; [ gnumake ];
          installPhase = ''
            mkdir -p $out/bin
            mv main $out/bin/whisper
          '';
          meta.mainProgram = "whisper";
        };
        mk-whisper = name: model: pkgs.writeScriptBin "whisper-${name}" "${pkg}/bin/whisper -m ${model} $*";
      in
      {
        packages.default = pkg;
        packages.whisper-base-en = mk-whisper "base-en" base-en;
      }
    );
}
