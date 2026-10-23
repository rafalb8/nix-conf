{ appimageTools
, fetchurl
, makeDesktopItem
, makeWrapper
, writeShellScript
}:
let
  pname = "strata-desktop";
  version = "0.2.7";

  src = fetchurl {
    url = "https://github.com/Niko1221/Strata/releases/download/v${version}/Strata-${version}-linux-x86_64.AppImage";
    hash = "sha256-cBoDJXKbvnXrJMd67h5FuPwuRqdO8dJUdc/vKj7xsoE=";
  };

  appRun = writeShellScript "strata-AppRun" ''
    if [ "$1" = "--cli" ]; then
      shift
      exec "$APPDIR/usr/lib/Strata/control/bin/strata" "$@"
    fi
    exec "$APPDIR/AppRun-desktop" "$@"
  '';

  contents = appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      mv "$out/AppRun" "$out/AppRun-desktop"
      ln -s ${appRun} "$out/AppRun"
    '';
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Strata";
    exec = "strata-desktop";
    icon = "strata-desktop";
    categories = [ "Development" ];
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = contents;

  nativeBuildInputs = [ makeWrapper ];

  profile = ''
    export SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"
  '';

  extraInstallCommands = ''
    makeWrapper "$out/bin/strata-desktop" "$out/bin/strata" \
      --add-flags "--cli"

    mkdir -p "$out/share"
    cp -r ${desktopItem}/share/applications "$out/share/"

    if [ -d "${contents}/usr/share/icons" ]; then
      cp -r ${contents}/usr/share/icons "$out/share/"
    fi
  '';
}
