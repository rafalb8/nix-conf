{ stdenv, fetchurl, makeDesktopItem }:
stdenv.mkDerivation (final: {
  pname = "eden";
  version = "0.0.4-rc3";

  src = fetchurl {
    url = "https://github.com/eden-emulator/Releases/releases/download/v${final.version}/Eden-Linux-v${final.version}-amd64-clang-pgo.AppImage";
    sha256 = "0dkk90g1dy2rymc0mg1qq6r75cibghqxvkblpa79ym3akgpv4pcx"; # nix-prefetch-url <url>
  };

  desktopItem = makeDesktopItem {
    name = final.pname;
    desktopName = "Eden";
    exec = "${final.pname} %u";
    terminal = false;
    categories = [ "Game" "Emulator" ];
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm755 $src $out/bin/${final.pname}

    mkdir -p $out/share/applications
    cp ${final.desktopItem}/share/applications/*.desktop $out/share/applications
  '';

  meta = {
    homepage = "https://github.com/eden-emulator/Releases";
    mainProgram = final.pname;
    platforms = [ "x86_64-linux" ];
  };
})
