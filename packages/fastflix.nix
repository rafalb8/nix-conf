{ lib
, stdenv
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
stdenv.mkDerivation (final: {
  pname = "fastflix";
  version = "5.10.0";

  src = fetchzip {
    url = "https://github.com/cdgriffith/FastFlix/releases/download/${final.version}/FastFlix_${final.version}_ubuntu-24.04_x86_64.zip";
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

  installPhase = ''
    install -Dm755 FastFlix $out/bin/${final.pname}
    patchelf \
      --add-needed "${libGL}/lib/libGL.so.1" \
      --add-needed "${libGL}/lib/libEGL.so.1" \
      --add-needed "${libxcb}/lib/libxcb.so.1" \
      --add-needed "${libxkbcommon}/lib/libxkbcommon.so.0" \
      --add-needed "${libxkbcommon}/lib/libxkbcommon-x11.so.0" \
      "$out/bin/${final.pname}"
  '';

  postFixup = ''
    wrapProgram $out/bin/${final.pname} --set-default QT_QPA_PLATFORM xcb
  '';

  desktopItems = [
    (makeDesktopItem {
      name = final.pname;
      exec = "${final.pname} %u";
      desktopName = "FastFlix";
      startupWMClass = "FastFlix";
      categories = [ "AudioVideo" "Video" "TV" ];
    })
  ];

  meta = {
    description = "Free GUI for H.264, HEVC and AV1 hardware and software encoding";
    homepage = "https://github.com/cdgriffith/FastFlix";
    license = lib.licenses.mit;
    mainProgram = final.pname;
    platforms = [ "x86_64-linux" ];
  };
})
