{ appimageTools
, fetchurl
, lib
  # Deps
, avahi
, cudaPackages
, curl
, gtk3
, icu75
, libayatana-appindicator
, libcap
, libdrm
, libevdev
, libnotify
, libopus
, libpulseaudio
, libva
, libvdpau
, mesa
, miniupnpc
, numactl
, openssl
, vulkan-loader
, wayland
}:
appimageTools.wrapType2 rec {
  pname = "sunshine";
  version = "2024.1005.14704";

  src = fetchurl {
    url = "https://github.com/LizardByte/Sunshine/releases/download/v${version}/sunshine.AppImage";
    hash = "sha256-TGyAJALAPFwdcKnj0Bhm7yk7XBbWJ+q8eYvVRFxgIxg=";
  };

  extraPkgs = pkgs: [
    avahi
    cudaPackages.cudatoolkit
    curl
    gtk3
    icu75
    libayatana-appindicator
    libcap
    libdrm
    libevdev
    libnotify
    libopus
    libpulseaudio
    libva
    libvdpau
    mesa
    miniupnpc
    numactl
    openssl
    vulkan-loader
    wayland
  ];

  extraInstallCommands =
    let
      contents = appimageTools.extract { inherit pname version src; };
    in
    ''
      mkdir -p $out/lib $out/share
      cp -r ${contents}/usr/share/sunshine/udev $out/lib/.
      cp -r ${contents}/usr/share/icons $out/share/.
    '';

  meta = with lib; {
    description = "Sunshine is a Game stream host for Moonlight";
    homepage = "https://github.com/LizardByte/Sunshine";
    license = licenses.gpl3Only;
    mainProgram = "sunshine";
    platforms = platforms.linux;
  };
}
