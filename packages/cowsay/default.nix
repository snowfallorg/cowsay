{ lib, writeShellApplication, cowfiles, cowsay, ... }:

writeShellApplication {
  name = "cowsay";
  text = ''
    COWS=(${cowfiles}/cows/*.cow)
    TOTAL_COWS=$(ls ${cowfiles}/cows/*.cow | wc -l)

    RAND_COW=$(($RANDOM % $TOTAL_COWS))

    ${cowsay}/bin/cowsay -f ''${COWS[$RAND_COW]} $@
  '';

  checkPhase = "";

  runtimeInputs = [ cowsay ];
}
