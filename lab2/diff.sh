#!/bin/bash
EXE=./ezlang.bin
IN=in
OUT=out
for infile in `ls $IN/*.ezl`; do
    base=$(basename $infile)
    outfile=$OUT/${base/.ezl/.out}
    if ($EXE < $infile | diff -w $outfile -) &> /dev/null; then
        echo "${infile} -> Perfeito";
    else
        echo "${infile} -> Diferente";
    fi
done