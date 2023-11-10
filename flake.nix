{
  description = "Snowfall Cowsay";

  inputs = {
    # NOTE: ttyd had a bug on 23.05 that caused whitespace characters
    # to not receive colors which broke cow2img. Currently, unstable
    # is required in order to function properly.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=v2.1.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vhs = {
      url = "github:snowfallorg/vhs?ref=v1.0.0";
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

      snowfall = {
        namespace = "snowfallorg";
      };

      alias.packages.default = "cowsay";
    };
}
