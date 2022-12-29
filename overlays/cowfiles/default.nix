{ channels
, cowfiles
, ...
}:

final: prev:
let
  blocklist = [
    "pepe"
  ];
  filtered-cowfiles = prev.runCommandNoCC "filtered-cowfiles" { src = cowfiles; } ''
    blocked_files=(${builtins.foldl' (acc: name: "${acc} \"${name}.cow\"") "" blocklist})

    mkdir -p $out/cows

    for f in $src/cows/*.cow; do
      if [ -f "$f" ] && [[ ! "''${blocked_files[@]}" =~ "$(basename $f)" ]]; then
        ln -s $f "$out/cows/$(basename $f)"
      fi
    done
  '';
in
{
  cowfiles = filtered-cowfiles;
}
