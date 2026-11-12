{ appimageTools, fetchurl }:
let
  pname = "lichii";
  version = "160";
  desktopId = "io.github.zortos293.lichii";

  src = fetchurl {
    url = "https://github.com/zortos293/Lichii/releases/download/build-${version}/lichii-linux-x86_64-pgo.AppImage";
    hash = "sha256-zBoJ5Gw+Bg6vEJE0BAoUSK4I/b1RtYZuE+qfQrDZEzI=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.libgpg-error ];

  extraInstallCommands = ''
    install -Dm444 ${contents}/${desktopId}.desktop $out/share/applications/${desktopId}.desktop
    install -Dm444 ${contents}/${desktopId}.png $out/share/icons/hicolor/256x256/apps/${desktopId}.png
  '';

  meta = {
    description = "Nintendo Switch and Switch 2 emulator";
    homepage = "https://github.com/zortos293/Lichii";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
