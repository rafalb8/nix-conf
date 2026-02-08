{ stdenv, fetchurl, makeDesktopItem }:
stdenv.mkDerivation (final: {
  pname = "eden";
  version = "0.1.1";

  src = fetchurl {
    url = "https://github.com/eden-emulator/Releases/releases/download/v${final.version}/Eden-Linux-v${final.version}-amd64-clang-pgo.AppImage";
    sha256 = "0pv4i4ih4m2zrrdpfwkwhgb8x7i7a754si7pdbv9rrrz6g9pbg43"; # nix-prefetch-url <url>
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
