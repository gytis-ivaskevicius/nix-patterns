{
  description = "Flake used for testing and development environment";

  inputs.root.url = path:../;
  inputs.nixpkgs.url = github:gytis-ivaskevicius/nixpkgs/10e0ac7e0a764e64f967d78869671dda37001160;

  outputs = { self, root, nixpkgs }: {

    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

    perSystem = { system }:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = builtins.mapAttrs (name: value: pkgs.callPackage value { }) self.blueprints;

        devShells.default = pkgs.mkShell {
          name = "simple-devshell";

          inputsFrom = [
            (builtins.attrValues self.packages.${system})
          ];
        };
      };


  };
}
