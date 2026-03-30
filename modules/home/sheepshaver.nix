{ self }:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sheepshaver;
  sys = pkgs.stdenv.hostPlatform.system;
in
{
  options.programs.sheepshaver = {
    enable = lib.mkEnableOption "SheepShaver PowerPC Mac OS emulator";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${sys}.sheepshaver;
      description = "SheepShaver package to install.";
    };
  };

  config = lib.mkIf cfg.enable { home.packages = [ cfg.package ]; };
}
