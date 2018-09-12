#!/bin/sh

# Compile auxiliary transducers
hfst-regexp2fst -S -i infl_stem0.txt  > infl_stem0.hfst
hfst-regexp2fst -S -i infl_stem1.txt  > infl_stem1.hfst
hfst-regexp2fst -S -i infl_stem2.txt  > infl_stem2.hfst
hfst-regexp2fst -S -i infl_stem3.txt  > infl_stem3.hfst
hfst-regexp2fst -S -i infl_illat.txt  > infl_illat.hfst
hfst-regexp2fst -S -i infl_pl_gen.txt > infl_pl_gen.hfst
hfst-regexp2fst -S -i infl_pl_par.txt > infl_pl_par.hfst
