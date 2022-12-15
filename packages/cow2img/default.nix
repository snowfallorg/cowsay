{ lib
, mkShell
, fetchFromGitHub
, writeShellApplication
, substituteAll
, bashInteractive
, imagemagick
, chromium
, fortune
, ncurses
, cowsay
, gum
, vhs
, bc
, cowfiles
, ...
}:

let
  substitute = args: builtins.readFile (substituteAll args);
in
writeShellApplication
{
  name = "cow2img";

  text = substitute {
    src = ./cow2img.sh;

    inherit cowfiles;
    tape = ./cowsay.tape;
  };

  checkPhase = "";

  runtimeInputs = [
    bashInteractive
    imagemagick
    chromium
    fortune
    ncurses
    cowsay
    gum
    vhs
    bc
  ];
}
