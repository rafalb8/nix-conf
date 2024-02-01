# Home-Manager function to add autostart entries
config: packages: builtins.listToAttrs (map
  (pkg:
    let
      home = config.home-manager.users.${config.user.name}.home.homeDirectory;
      customPath = home + "/.nix-profile/share/applications/" + pkg.pname + ".desktop";
    in
    {
      name = ".config/autostart/" + pkg.pname + ".desktop";
      value =
        if builtins.pathExists customPath then {
          # Use custom desktop entry
          source = customPath;
        } else if pkg ? desktopItem then {
          # If pkg contains text attribute
          text = pkg.desktopItem.text;
        } else if pkg ? source then {
          # Custom source name
          source = pkg + "/share/applications/" + pkg.source;
        } else {
          # Others
          source = pkg + "/share/applications/" + pkg.pname + ".desktop";
        };
    }
  )
  packages)

