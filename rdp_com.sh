#!/bin/bash
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

vmd -dispdev text -e com_rm.tcl
# [ $? -eq 0 ] && python3 xyz_com_merge/xyz_com_merge.py --inxyz micelle.xyz --indat com.dat --out micelle_com.xyz --atomtype X
python3 xyz_com_merge/xyz_com_merge.py --inxyz micelle.xyz --indat com.dat --out micelle_com.xyz --atomtype X
vmd -dispdev text -e com_rm_rhor.tcl
