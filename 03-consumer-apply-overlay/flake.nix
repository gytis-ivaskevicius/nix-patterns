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
          # In rare cases this may result in:
          # - Accidental packages overwriting
          # - Infinite recursion
          overlays = [
            firstPackageSet.overlays.default
            secondPackageSet.overlays.default
          ];
        };
      in
      {
        packages = {
          inherit (pkgs) myPackage myPackage2;
        };
      };

  };
}
