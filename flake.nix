{
  description = "Basilisk II and SheepShaver — packages, overlay, and Home Manager modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          macemuSrc = pkgs.callPackage ./macemu-src.nix { };
        in
        {
          basilisk2 = pkgs.callPackage ./basilisk2.nix { src = macemuSrc; };
          sheepshaver = pkgs.callPackage ./sheepshaver.nix { src = macemuSrc; };
          default = self.packages.${system}.basilisk2;
        }
      );

      overlays.default = final: _prev: {
        basilisk2 = self.packages.${final.stdenv.hostPlatform.system}.basilisk2;
        sheepshaver = self.packages.${final.stdenv.hostPlatform.system}.sheepshaver;
      };

      homeManagerModules = {
        basilisk2 = import ./modules/home/basilisk2.nix { inherit self; };
        sheepshaver = import ./modules/home/sheepshaver.nix { inherit self; };
      };
    };
}
