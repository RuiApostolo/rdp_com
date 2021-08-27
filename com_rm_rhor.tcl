###############################################################################
# This script creates an xyz file for a micelle and its COM                   #
# Intended to be used with xyz_com_merge.py                                   #
# Created by Rui Apóstolo                                                     #
# Version 1.0 August 2021                                                     #
###############################################################################
#                             EDITABLE PARAMETERS                             #
###############################################################################
# load trajectory file
# mol new micelle_with_com.xyz type lammpstrj waitfor all autobonds off
animate read xyz micelle_com.xyz waitfor all
# set type of COM
set com_type "type X"
# set bin width
set bin_width 0.5
# set max distance for g(r) // vmd default is 10.0
set r_max 50.0
# set ts_start
set ts_start 0
# set ts_stop // -1 == last
set ts_stop [expr [molinfo top get numframes] - 1]
# set ts_skip
set ts_skip 1
# set outfile name
set outfile "gofr.dat"

###############################################################################
#                         END OF EDITABLE PARAMETERS                          #
###############################################################################

puts ""
puts "Loading complete, calculating gofr."
puts ""


set com_sel [atomselect top $com_type]
append micelle_type "not " $com_type
set micelle_sel [atomselect top ${micelle_type}]

set gofr_data [measure gofr $com_sel $micelle_sel delta $bin_width rmax $r_max usepbc 0 selupdate 0 first $ts_start last $ts_stop step $ts_skip]

puts ""
puts "gofr complete, writing data."
puts ""

set fout1 [open $outfile w]

set r [lindex $gofr_data 0]
set gr2 [lindex $gofr_data 1]
set igr [lindex $gofr_data 2]

set i 0
foreach j $r k $gr2 l $igr {
   puts $fout1 "$j $k $l"
}

close $fout1

puts ""
puts "Writing complete."
puts ""

exit 0
