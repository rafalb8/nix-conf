{ stdenv, fetchurl, makeDesktopItem }:
stdenv.mkDerivation (final: {
  pname = "eden";
  version = "0.2.0-rc2";

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${final.version}/Eden-Linux-v${final.version}-amd64-clang-pgo.AppImage";
    sha256 = "01c83a21cb82myrsjjnxz9hffjg1s6f00qk9j8jxjfzdvq9r52pz"; # nix-prefetch-url <url>
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
