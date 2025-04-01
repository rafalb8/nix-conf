{ stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, ffmpeg_6-headless
, libass
, libgcc
}:
stdenv.mkDerivation rec {
  pname = "VCEEnc";
  version = "8.34";

  src = fetchurl {
    url = "https://github.com/rigaya/${pname}/releases/download/${version}/vceencc_${version}_Ubuntu24.04_amd64.deb";
    sha256 = "089mqwjbwiga92023kwd5shd9v4sr2mfap4wgwbrhb9wb9gqw45g"; # Use nix-prefetch-url <url>
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    ffmpeg_6-headless
    stdenv.cc.cc.lib
    libass
    libgcc
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv usr/bin/vceencc $out/bin/VCEEncC
  '';
}
