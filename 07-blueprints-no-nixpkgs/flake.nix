{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    blueprints = {
      zlib-ng = import ./derivations/zlib-ng.nix;
      hello = import ./derivations/hello.nix;
    };

  };
}
