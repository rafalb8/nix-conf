# Nix OS configuration

- [NixOS Wiki](https://wiki.nixos.org/)
- [Nixpkgs search](https://search.nixos.org/)
- [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/)

## Source code

- [Nixpkgs](https://github.com/NixOS/nixpkgs/)
- [Home Manager](https://github.com/nix-community/home-manager)

## Building packages

- [stdenv.mkDerivation](https://nixos.org/manual/nixpkgs/stable/#sec-using-stdenv)
- [autoPatchElfHook](https://nixos.org/manual/nixpkgs/stable/#setup-hook-autopatchelfhook)
- [AppImage](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-appimageTools)
- [Python](https://nixos.org/manual/nixpkgs/stable/#buildpythonpackage-function)

### AppImage example

```nix
{ lib
, stdenv
, fetchurl
}:
stdenv.mkDerivation rec {
  pname = "appimg";
  version = "0.0.1";

  src = fetchurl {
    url = "https://github.com/example/app/appimg-${version}.AppImage";
    hash = "";
  };

  dontUnpack = true;
  dontStrip = true;
  dontPatchELF = true;

  buildPhase = ''
    runHook preBuild

    cp $src appimg
    chmod +x appimg
    ./appimg --appimage-extract

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -m 755 -D $src $out/bin/appimg
    install -m 444 -D squashfs-root/appimg.desktop $out/share/applications/appimg.desktop
    install -m 444 -D squashfs-root/appimg.png $out/share/icons/hicolor/512x512/apps/appimg.png

    runHook postInstall
  '';

  meta = {
    description = "AppImage example";
    homepage = "https://github.com/example/app";
    platforms = [ "x86_64-linux" ];
    mainProgram = "appimg";
  };
}
```

## Github rate limit fix

`~/.config/nix/nix.conf`

```conf
access-tokens = github.com=**key**
```
