# nix-patterns

This repository depends on these two PR's. For more information refer to 'Future work' section
- https://github.com/NixOS/nixpkgs/pull/180557
- https://github.com/NixOS/nix/pull/6773


## Problem
Our issue is not [poor flake.lock file parsing performance](https://github.com/NixOS/nix/issues/6627), nor is [poor `follows` ergonomics](https://github.com/NixOS/nix/issues/5576), and not even [1000 instances of nixpkgs](https://zimbatm.com/notes/1000-instances-of-nixpkgs).
our issue is that we are treating flake `inputs` as some sort of dependency injection mechanism used for flake evaluation.


## Solution
Stop depending on `nixpkgs` (and preferaby other flakes) and this repository presents how do to this.

## TL;DR:

Please stop thinking of `follows` mechanism as dependency-injection. Instead please expose structures that consumes `pkgs` as an argument.
Using subflakes is a solid way of providing optional dependencies which may be used for development only purposes or pinning particular versions for reproducibility reasons.

**General rules of thumb for packages producing flakes:**
- All packages producing flakes should expose an `overlay`
- Avoid using first overlays argument. (It is usually named `final`)
- Overlays should **NEVER** depend on `nixpkgs`. [example](01-packages-producer/flake.nix)
- If you need nixpkgs only for testing - use [subflake approach](02-packages-producer-with-dev-deps)
- If users tend to overwrite `nixpkgs` anyways - consider using [subflake approach](02-packages-producer-with-dev-deps) for pinning (users who care about reproducibility may use subflake instead)
- Consumers should avoid consuming `packages.<system>.<name> = <drv>` unless goal is to use exactly the same nixpkgs version as author of the flake.

## Future work
- Fix grammar and improve content of this repo

- https://github.com/NixOS/nixpkgs/pull/180557
Add function `callOverlay` It has some edge cases but should cover most scenarions.

- https://github.com/NixOS/nix/pull/6773
We need a solution to define clean and simple flakes without any additional flakes because otherwise we are just returning to the same issues.
Ideally we would evaluate whole flake on per system basis where `system` argument would be determined by `nix`. If we ever change `system` format - we change whatever nix passes but still allow it to be overwritten via CLI.
Supported systems should be more of a metadata hint instead of something that forces flake to be evaluated for particular selection.

- Invent simpler data structures for exposing packages. There are basically two structures that I can think of:
    - Overlays but only with `prev` argument. `overlay :: pkgs -> attrsOf derivation`
    - Attribute set of functions that can be called with `pkgs.callPacage` to retrieve derivation. `packages :: attrsOf (attrsOf any -> derivation)`

- [Add ability set one of the inputs to null via](https://github.com/NixOS/nix/issues/6780) `follows` mechanism. This should improve usability of standard flakes like defined in [01-packages-producer example](01-packages-producer)

- [Add some sort of autoupdate of flake.lock dependency in case it is a subflake](https://github.com/NixOS/nix/issues/6779).

