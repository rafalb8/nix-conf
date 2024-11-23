{ stdenv
, dpkg
, fetchurl
, autoPatchelfHook
, libstdcxx5
, ffmpeg_6
, libass
, libgcc
  # Nvidia Driver, set using (nvencc.override { nvidia = config.hardware.nvidia.package; })
, nvidia ? null
}:
stdenv.mkDerivation rec {
  pname = "NVEnc";
  version = "7.75";

  src = fetchurl {
    url = "https://github.com/rigaya/NVEnc/releases/download/${version}/nvencc_${version}_Ubuntu24.04_amd64.deb";
    sha256 = "1m6hfkkb9a7chja2kck6yyknay384fyqfcs6wz4qwnix2hwh5m5d";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    libstdcxx5
    ffmpeg_6
    libass
    libgcc
    # Nvidia Driver
    nvidia
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp usr/bin/nvencc $out/bin/nvencc
  '';
}
