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

## Github rate limit fix
`~/.config/nix/nix.conf`
```conf
access-tokens = github.com=**key**
```