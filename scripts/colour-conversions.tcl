## https://sites.google.com/site/gnocltclgtk/gnocl-cookbook/converting-between-colour-expressions
#---------------
# colour-conversions.tcl
#---------------
# William J Giddings
# 04-Mar-2013
#---------------
# Notes:
# Manipulate 8-bit colour expresions.
# Conversion proceedures will test for and handle alpha channel values.
#---------------

#---------------
# convert integer RGB8A values to hexadecimal
#---------------
#
proc RGB8_2_HEX {clr} {   
    switch [llength $clr] {
        3 {
            scan $clr "%d %d %d" r g b
            return [format "#%02x%02x%02x" $r $g $b]
            }
        4 {
            scan $clr "%d %d %d %d" r g b a
            return [format "#%02x%02x%02x%02x" $r $g $b $a]
            }
        } ;# end switch
    return -1
}

#---------------
# convert hexadecimal values to RGB8/RGB8A
#---------------
#
proc HEX_2_RGB8 {clr} {
    if { [string range $clr 0 0] != "#"} { return -1 }
    scan [string range $clr 1 2] %x R
    scan [string range $clr 3 4] %x G
    scan [string range $clr 5 6] %x B
    switch [string length $clr] {
        7 {
            return "$R $G $B"
            }
        9 {
            scan [string range $clr 7 8] %x A
            return "$R $G $B $A"
            }
        } ;# end switch
    return -1
}



#---------------
# express value in range as float within between 0 and 1 to specified number of decimal places
#---------------
#
proc unitize {val {range 255} {places 3}} {   
    return [format "%1.${places}f" [expr ${val}.0/$range]]
}

#---------------
# convert 8bit integer RGB8/RGB8A list to floats
#---------------
#
proc RGB8_2_FLOAT {clr} {
    switch [llength $clr] {
        3 {   
            scan $clr "%d %d %d" r g b
            set r [unitize $r]
            set g [unitize $g]
            set b [unitize $b] 
            return "$r $g $b"
            }
        4 {
            scan $clr "%d %d %d %d" r g b a
            set r [unitize $r]
            set g [unitize $g]
            set b [unitize $b]
            set a [unitize $a]
            return "$r $g $b $a"
            }
        }
    return -1
}

#---------------
# convert hexadecimal colour values to floats
#---------------
#
proc HEX_2_FLOAT {clr} {
    return [RGB8_2_FLOAT [HEX_2_RGB8 $clr]]
}

#---------------
# convert colour float to RGB8/RGB8A
#---------------
#
proc FLOAT_2_RGB8 {clr} {
    switch [llength $clr] {
        3 {
            scan $clr "%f %f %f" r g b
            set r [format %d [expr int($r * 255)]]
            set g [format %d [expr int($g * 255)]]
            set b [format %d [expr int($b * 255)]]
            return "$r $g $b"
            }
        4 {
            scan $clr "%f %f %f %f" r g b a       
            set r [format %d [expr int($r * 255)]]
            set g [format %d [expr int($g * 255)]]
            set b [format %d [expr int($b * 255)]]
            set a [format %d [expr int($a * 255)]]       
            return "$r $g $b $a"
            }
        } ;# end switch
    return -1
}

#---------------
# convert decimal colour to hexadecimal
#---------------
#
proc FLOAT_2_HEX {clr} {
    switch [llength $clr] {
        3 {
            scan $clr "%f %f %f" r g b a   
            set r [format %d [expr int($r * 255)]]
            set g [format %d [expr int($g * 255)]]
            set b [format %d [expr int($b * 255)]]       
            return [format "#%02x%02x%02x" $r $g $b]
            }
        4 {
            scan $clr "%f %f %f %f" r g b a       
            set r [format %d [expr int($r * 255)]]
            set g [format %d [expr int($g * 255)]]
            set b [format %d [expr int($b * 255)]]
            set a [format %d [expr int($a * 255)]]       
            return [format "#%02x%02x%02x%02x" $r $g $b $a]
            }
        } ;# end switch
    return -1
}

#---------------
# test
#---------------
#set color [RGB8_2_HEX "255 255 255"]
#puts "1    $color"
#set color [RGB8_2_HEX "255 255 255 128"]
#puts "2    $color"
#puts "3    [HEX_2_RGB8 $color]"
#puts "4    [RGB8_2_FLOAT "255 255 255 127"]"
#puts "5    [HEX_2_FLOAT #FF0000]"
#puts "6    [FLOAT_2_RGB8 "1.0 1.0 1.0 0.5"]"
#puts "7    [FLOAT_2_HEX "1.0 1.0 1.0 0.5"]"
