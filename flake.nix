{
  description = "My Nix library";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vhs = {
      url = "github:snowfallorg/vhs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cowfiles = {
      url = "github:paulkaefer/cowsay-files";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.;

      overlay-package-namespace = "snowfallorg";

      outputs-builder = channels: {
        packages.default = "cowsay";
      };
    };
}
