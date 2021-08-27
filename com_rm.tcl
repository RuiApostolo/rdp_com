###############################################################################
# This script creates an xyz file for a micelle and its COM                   #
# Intended to be used with xyz_com_merge.py                                   #
# Created by Rui Apóstolo                                                     #
# Version 1.0 August 2021                                                     #
###############################################################################
#                             EDITABLE PARAMETERS                             #
###############################################################################
# set micelle atom types
# set micelle_names "not type 8 9 10"
# loading from file instead
set micelle_indexes_file "atoms_list.txt"
# set load_ts_start
set load_ts_start 700
# set load_ts_stop // -1 == last
set load_ts_stop -1
# set load_ts_skip
set load_ts_skip 1
# load trajectory file
mol new dump.npt.lammpstrj type lammpstrj first $load_ts_start last $load_ts_stop step $load_ts_skip waitfor all autobonds off
# mol new dump.npt.lammpstrj type lammpstrj first $ts_start last $ts_stop $ts_skip waitfor all autobonds off
# set write_ts_start // 0 == load_ts_start
set write_ts_start 0
# end of last range (relative to loaded dump file start, first timestep is always 0)
set write_ts_stop [expr [molinfo top get numframes] - 1]
# set skip (== 1 outputs every timestep)
set write_ts_skip $load_ts_skip
# COM coordinate file name
set com_file "com.dat"
# XYZ of micelle file name
set xyz_file "micelle.xyz"
# set ref toggle
set pbc_ref_toggle 1
# set reference atom (centre for pbc join)
set pbc_ref_atom "index 1214"

###############################################################################
#                         END OF EDITABLE PARAMETERS                          #
###############################################################################
#  PROCEDURES  #
################
proc readfile {filename} {
    set f [open $filename]
    set data [read $f]
    close $f
    return $data
}

##############
#  PACKAGES  #
##############
package require pbctools
package require topotools

puts " "
puts " "
puts "Loading complete, writing COM coordinates file"
puts " "

# load micelle atom indexes from file
set micelle_names [readfile $micelle_indexes_file]
# set micelle atom selection
set micelle [atomselect top $micelle_names]
# remove periodic imates
$micelle set chain 1
# check for $pbc_ref_toggle and branch as appropriate
if {$pbc_ref_toggle == 1} {
  pbc join chain -sel $micelle_names -ref $pbc_ref_atom -first 0 -last 0
} elseif {$pbc_ref_toggle == 0} {
  pbc join chain -sel $micelle_names -first 0 -last 0
} else {
  puts "pbc_ref must be 0 or 1"
  # exit with error
  exit 1
}


pbc unwrap -sel $micelle_names -all
# open output file
set fout1 [open $com_file w+]
# FOR loop from ts_start to ts_stop with step ts_skip
for {set i $write_ts_start} {$i <= $write_ts_stop} {incr i $write_ts_skip} {
  # set timestep
  $micelle frame $i
  $micelle update
  # Calculate COM from micelle
  # micelle_com is an array size 3
  set micelle_com [measure center $micelle weight mass]
  puts $fout1 "${micelle_com}"
}
close $fout1

puts " "
puts "Writing micelle XYZ file"
puts " "

animate write xyz "micelle.xyz" beg $write_ts_start end $write_ts_stop skip $write_ts_skip waitfor all sel $micelle 

exit 0
