{
  description = "Flake exposing a package";

  inputs.nixpkgs.url = github:gytis-ivaskevicius/nixpkgs/10e0ac7e0a764e64f967d78869671dda37001160;

  inputs.firstPackageSet.url = path:../01-packages-producer;
  inputs.secondPackageSet.url = path:../02-packages-producer-with-dev-deps;

  outputs = { self, nixpkgs, firstPackageSet, secondPackageSet }: {

    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];


    perSystem = { system }:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Packages defined in first flake
        first = pkgs.callOverlay firstPackageSet.overlays.default;

        # Packages defined in second flake
        second = pkgs.callOverlay secondPackageSet.overlays.default;

        # Packages defined in first and second flakes
        joined = pkgs.callOverlays [
          firstPackageSet.overlays.default
          secondPackageSet.overlays.default
        ];
      in
      {
        packages = {
          #inherit (first) myPackage;
          #inherit (second) myPackage2;
          inherit (joined) myPackage myPackage2;
        };

      };

  };
}
