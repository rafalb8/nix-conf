{ cudaPackages
, linuxPackages_latest
, dpkg
, fetchurl
, autoPatchelfHook
, autoAddDriverRunpath
, libstdcxx5
, ffmpeg
, libass
, libgcc
}:
let
  stdenv = cudaPackages.backendStdenv;
in
stdenv.mkDerivation rec {
  pname = "NVEnc";
  version = "7.69";

  src = fetchurl {
    url = "https://github.com/rigaya/NVEnc/releases/download/${version}/nvencc_${version}_Ubuntu24.04_amd64.deb";
    hash = "sha256-ixXlaMC1faIRYsJgo/72inpnXL15AGuzUpLXiHh16y8=";
  };

  unpackPhase = "dpkg-deb -x $src .";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    autoAddDriverRunpath
  ];

  buildInputs = [
    libstdcxx5
    ffmpeg
    libass
    libgcc
    cudaPackages.cudatoolkit
    linuxPackages_latest.nvidia_x11
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp usr/bin/nvencc $out/bin/nvencc
  '';
}
