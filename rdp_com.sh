#!/bin/bash
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

vmd -dispdev text -e xyz_com_gen.tcl
python3 xyz_com_merge/xyz_com_merge.py --inxyz micelle.xyz --indat com.dat --out micelle_com.xyz --atomtype X
vmd -dispdev text -e rm_com_gofr.tcl
python3 rdp.py
