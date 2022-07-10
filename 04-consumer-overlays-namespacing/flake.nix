{
  description = "Flake exposing a package";

  inputs.nixpkgs.url = github:gytis-ivaskevicius/nixpkgs/10e0ac7e0a764e64f967d78869671dda37001160;

  inputs.firstPackageSet.url = path:../01-packages-producer;
  inputs.secondPackageSet.url = path:../02-packages-producer-with-dev-deps;

  outputs = { self, nixpkgs, firstPackageSet, secondPackageSet }: {

    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

    perSystem = { system }:
      let
        # nixpkgs with overlays applied. Importing nixpkgs is an expensive procedure, should not be done more than once during flake evaluation
        pkgs = import nixpkgs {
          inherit system;
          # This approach almost removes posibility of accidental packages overwriting and infinite recursion
          overlays = [
            (final: prev: {
              firstPackageSet = firstPackageSet.overlays.default final prev;
              secondPackageSet = secondPackageSet.overlays.default final prev;

              joinedPacakageSet = nixpkgs.lib.composeManyExtensions [
                firstPackageSet.overlays.default
                secondPackageSet.overlays.default
              ] final prev;
            })
          ];
        };
      in
      {
        packages = {
          # inherit (pkgs.firstPackageSet) myPackage;
          # inherit (pkgs.secondPackageSet) myPackage2;
          inherit (pkgs.joinedPacakageSet) myPackage myPackage2;
        };
      };

  };
}
