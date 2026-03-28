{ stdenv
, libsForQt5
, fetchFromGitHub
, cmake
, ninja
, pkg-config
, zlib
}:
with libsForQt5;
stdenv.mkDerivation (final: {
  pname = "tsmuxer";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "justdan96";
    repo = "tsMuxer";
    rev = "2.7.0";
    hash = "sha256-EsAXCqwkAdAvuiM3p0lU2tTwS7hN7sTINFdaVRdAwXQ=";
  };

  postPatch = ''
    # patch font path
    substituteInPlace tsMuxer/osdep/textSubtitlesRenderFT.cpp \
        --replace-fail "/usr/share/fonts/" "/run/current-system/sw/share/X11/fonts/"

    # patch symlink support
    substituteInPlace libmediation/fs/osdep/directory_unix.cpp \
        --replace-fail 'if (namelist[n]->d_type == DT_REG)' \
                        'if (namelist[n]->d_type == DT_REG || namelist[n]->d_type == DT_LNK)' \
        --replace-fail 'if (namelist[n]->d_type == DT_DIR)' \
                        'if (namelist[n]->d_type == DT_DIR || namelist[n]->d_type == DT_LNK)'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    zlib
    qtbase
    qtmultimedia
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DTSMUXER_GUI=ON"
  ];

  meta = {
    description = "A transport stream muxer for creating to Blu-ray discs or AVCHD";
    homepage = "https://github.com/justdan96/tsMuxer";
    mainProgram = "tsMuxerGUI";
    platforms = [ "x86_64-linux" ];
  };
})
