{
  description = "Flake exposing a package";

  inputs.nixpkgs.url = github:gytis-ivaskevicius/nixpkgs/10e0ac7e0a764e64f967d78869671dda37001160;

  outputs = { self, nixpkgs }: {

    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

    # Function returning packages. Should NEVER depend on nixpkgs, instead consume it from its arguments.
    overlays.default = _: prev: {
      myPackage = prev.callPackage ({ ruby }: ruby) { };
    };


    # We should avoid depending on nixpkgs as much as possible
    # Ideally pinned packages would be exposed via subflake but that might be a little botthersome. One should ask himself if users of this flake will overwrite nixpkgs version anyways or not
    # In case of flake being autoupdated without testing - there is no point in exposing `packages`
    perSystem = { system }:
      let
        # Get pkgs reference. Alternatively we can import a custom nixpkgs with overwrites of our choosing.
        pkgs = nixpkgs.legacyPackages.${system};

        # Evaluates to { myPackage = prev.callPackage ({ ruby }: ruby) { }; }
        myPkgs = pkgs.callOverlay self.overlays.default;
      in
      {
        packages = {
          inherit (myPkgs) myPackage;
          default = myPkgs.myPackage;
        };


        devShells.default = pkgs.mkShell {
          name = "simple-devshell";

          inputsFrom = [
            (builtins.attrValues myPkgs)
          ];
        };
      };

  };
}
