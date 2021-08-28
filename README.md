# rdp\_com


The files and scripts in this repo aim to give a baseline to calculate the radial density profile from the COM of a system.

Although care was taken to make the default options sensible, it is inevitable that different systems will have very different needs and, therefore, scritps and their options will need to be adapted to each individual system.

## Requirements

This tool needs [Python3][python] and [VMD][vmd] to run.

## Submodule

This repo uses the [xyz\_com\_merge submodule][xyzcommerge]. To keep the submodule up-to-date with any `git pull` commands, use:

    git submodule update --init --recursive
    git config --global submodule.recurse true

## Usage

The [bash script][script] runs all the parts of the system, but options are available in other files.

The first file to be run is [com\_rm.tcl][tcl], which has several options:
- `micelle_atomselect_file`: file with the vmd-style atomselection text to use for the selection of a micelle (or target group of atoms). A choice to use a file was done here because with complex systems of many molecules, these texts can grow large and hard to create. Example text: `index >= 130 and index <= 194 or index >= 390 and index <= 519`
- `micelle_names`: if the atom selection text is in the file, use the `readfile` version. Otherwise, if your atom selection text is simple, you can assign the text directly to the variable.
- `load_ts_start`: the number of the first timestep to load from the LAMMPS dumpfile defined below.
- `load_ts_stop`: the number of the last timestep to load from the LAMMPS dumpfile defined below. A value of `-1` is the same as choosing the last timestep of the dumpfile.
- `load_ts_step`: load every `N` timesteps from the LAMMPS dumpfile defined below. A value of `1` loads every timestep, a value of `2` skips every other timestep, etc.
- `mol new dump.npt.lammpstrj type lammpstrj first $load_ts_start last $load_ts_stop step $load_ts_step waitfor all autobonds off` - change which LAMMPS dumpfile to load by changing `dump.npt.lammsptrj` do a different one. Relative paths are accepted.
- `write_ts_start`: Of the timsteps loaded, which one to start the XYZ file writing from. Supposedly, this and following values should always be 0 and number of frames, but some situations might require different values.
- `write_ts_stop`: the default of `[expr [molinfo top get numframes] - 1]` gets the number of frames loaded and sets the variable to the index of the last one (VMD is 0-indexed, thus the `- 1` operation).
- `write_ts_step`: by default the same as `load_ts_step`, but can be changed to something else. Affects how often the COM and the XYZ files write, a value of `1` writes every timestep, a value of `2` skips every other timestep, etc.
- `com_file`: the name of the file where the COM coordinates will be written to. This file will have one line per timestep, and each line has three whitespace separated fields for the `x`, `y`, and `z` coordinates.
- `xyz_file`: the name of the file where the xyz coordinates of the micelle (or other target system) will be written to. This file has the normal syntax for a XYZ file.
- `pbc_ref_toggle`: accepts values of `0` or `1`. If set to `1`, it will use the atom selected by `pbc_ref_atom` to use as the central atom for the `pbc join chain` operation (see VMD manual). If set to `0` it will default to the first atom selected by the `micelle_names` variable.
- `pbc_ref_atom`: atom selection for the `pbc join chain` operation. Only used if `pbc_ref_toggle` is set to `1`. See VMD manual for more information.

Then the [bash script][script] runs the [xyz\_com\_merge][xyzcommerge] utility (see that repo for detaisl). The input flags are the XYZ and COM file names, the output flag is for the name of the new XYZ file with the COM merged, and the atomtype flag is the atom type the merged script gives to the COM 'atom'.

Finally, the script runs a second tcl script that calculates the <i>g</i>(<i>r</i>) and the radial density profile from the COM of the target system. The editable variables in this file are:
- `animate read xyz micelle_com.xyz waitfor all`: the file name will need to be changed if a different one was used in the previous step.
- `com_type`: the atom type of the COM 'atom'.
- `bin_width`: the bin width for the <i>g</i>(<i>r</i>) histogram.
- `r_max`: the max distance from the COM to calculate <i>g</i>(<i>r</i>) from.
- `ts_start`: the first timestep to calculate <i>g</i>(<i>r</i>) from.
- `ts_stop`: the first timestep to calculate <i>g</i>(<i>r</i>) from.
- `ts_step`: output <i>g</i>(<i>r</i>) every `N` timestep.
- `outfile`: the name of the file to write the <i>g</i>(<i>r</i>) to.



[python]: <https://www.python.org/downloads/> (Download Python 3)
[vmd]: <https://www.ks.uiuc.edu/Research/vmd/> (Visual Molecular Dynamics)
[xyzcommerge]: <https://github.com/RuiApostolo/xyz_com_merge> (xyz\_com\_merge github)
[script]: <./com_rm_rhor.sh> (bash script)
[tcl]: <./com_rm.tcl> (tcl script) 
