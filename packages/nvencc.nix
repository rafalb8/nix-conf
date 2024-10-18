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
  version = "7.70";

  src = fetchurl {
    url = "https://github.com/rigaya/NVEnc/releases/download/${version}/nvencc_${version}_Ubuntu24.04_amd64.deb";
    hash = "sha256-Fms9Cx1MDuMIU0QJ3YvnZwWoEpsfyxcjFqAnbifomXQ=";
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
