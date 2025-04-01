{ stdenv
, fetchzip
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, autoPatchelfHook
, libz
, libGL
, libxcb
, libxkbcommon
}:
stdenv.mkDerivation rec {
  pname = "FastFlix";
  version = "5.10.0";

  src = fetchzip {
    url = "https://github.com/cdgriffith/${pname}/releases/download/${version}/${pname}_${version}_ubuntu-24.04_x86_64.zip";
    hash = "sha256-GrBWhhj+Gxx3dHbIx9vEwllHOVN/aOYMDU5jAFl2gS8=";
    stripRoot = false;
  };

  # Required. Without this fastflix won't run
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper copyDesktopItems ];

  buildInputs = [
    libz
    libGL
    libxcb
    libxkbcommon
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "fastflix";
      desktopName = pname;
      exec = "fastflix";
      categories = [ "AudioVideo" "Video" "TV" ];
    })
  ];

  installPhase = ''
    install -Dm755 ${pname} $out/bin/fastflix
    patchelf \
      --add-needed "${libGL}/lib/libGL.so.1" \
      --add-needed "${libGL}/lib/libEGL.so.1" \
      --add-needed "${libxcb}/lib/libxcb.so.1" \
      --add-needed "${libxkbcommon}/lib/libxkbcommon.so.0" \
      --add-needed "${libxkbcommon}/lib/libxkbcommon-x11.so.0" \
      "$out/bin/fastflix"

    wrapProgram $out/bin/fastflix --set QT_QPA_PLATFORM xcb
  '';
}
