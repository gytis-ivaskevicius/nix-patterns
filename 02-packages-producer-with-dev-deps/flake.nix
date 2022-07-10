{
  description = "Flake exposing a package";

  # No dependencies = no problems :)
  outputs = { self }: {

    # Function returning packages. Should NEVER depend on nixpkgs, instead consume it from its arguments.
    overlays.default = _: prev: {
      myPackage2 = prev.callPackage ({ ruby }: ruby) { };
    };

  };
}
