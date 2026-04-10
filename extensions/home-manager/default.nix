{ lib, ... }: { home-manager.users."rafalb8" = { imports = lib.custom.importAll ./.; }; }
