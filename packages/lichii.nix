{ appimageTools, fetchurl }:
let
  pname = "lichii";
  version = "build-228";
  desktopId = "io.github.zortos293.lichii";

  src = fetchurl {
    url = "https://github.com/zortos293/Lichii/releases/download/${version}/lichii-linux-x86_64-pgo.AppImage";
    hash = "sha256-AGEDbmhrwFN3tF3fvGmvcfwt9KgBfD/Srw1mThXOcDo=";
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
