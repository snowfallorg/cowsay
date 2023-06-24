{
  description = "Snowfall Cowsay";

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
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib) mapAttrsToList flatten foldl pipe;

      collect-packages =
        (system: packages:
          mapAttrsToList
            (name: package: {
              inherit system name package;
            })
            packages
        );

      collected-packages = flatten (
        mapAttrsToList collect-packages inputs.self.packages
      );

      create-jobs = jobs: entry: jobs // {
        ${entry.name} = (jobs.${entry.name} or { }) // {
          ${entry.system} = entry.package;
        };
      };

      hydraJobs = foldl create-jobs { } collected-packages;
    in
    inputs.snowfall-lib.mkFlake {
      inherit inputs hydraJobs;

      src = ./.;

      overlay-package-namespace = "snowfallorg";

      outputs-builder = channels: {
        packages.default = "cowsay";
      };
    };
}
