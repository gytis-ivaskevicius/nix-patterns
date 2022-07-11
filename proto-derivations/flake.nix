{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {
    systems = [ "x86_64-linux" ];

    protoDerivations = {
      zlib-ng = import ./derivations/zlib-ng.nix;
      hello = import ./derivations/hello.nix;
    };


    perSystem = { system }:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = builtins.mapAttrs (name: value: pkgs.callPackage value {}) self.protoDerivations;
      };


  };
}
