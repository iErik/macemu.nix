{ self }:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.basilisk2;
  sys = pkgs.stdenv.hostPlatform.system;
in
{
  options.programs.basilisk2 = {
    enable = lib.mkEnableOption "Basilisk II 68k Macintosh emulator";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${sys}.basilisk2;
      description = "Basilisk II package to install.";
    };
  };

  config = lib.mkIf cfg.enable { home.packages = [ cfg.package ]; };
}
