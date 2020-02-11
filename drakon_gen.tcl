#!/usr/bin/env tclsh8.6

set use_log 0

proc require { package errors } {
	if { [ catch {
	package require $package
	} ] } {
		foreach error $errors {
			puts $error
		}
		exit
	}
}

require msgcat {
	"This script requires MsgCat package."
	"Consider installing tk8.6 or later."
}
namespace import ::msgcat::mc

set script_path [ file dirname [ file normalize [ info script ] ] ]

source [ file join $script_path scripts/art.tcl ]
source [ file join $script_path scripts/utils.tcl ]
source [ file join $script_path scripts/generators.tcl ]
source [ file join $script_path scripts/graph.tcl ]
source [ file join $script_path scripts/auto.tcl ]
source [ file join $script_path scripts/model.tcl ]
source [ file join $script_path scripts/dedit.tcl ]
source [ file join $script_path scripts/back.tcl ]
source [ file join $script_path scripts/version.tcl ]
source [ file join $script_path scripts/search.tcl ]
source [ file join $script_path scripts/colors.tcl ]
source [ file join $script_path scripts/graph2.tcl ]
source [ file join $script_path scripts/icon.links.tcl ]

source [ file join $script_path generators/c.tcl ]
source [ file join $script_path generators/cpp.tcl ]
source [ file join $script_path generators/cycle_body.tcl ]
source [ file join $script_path generators/node_sorter.tcl ]
source [ file join $script_path generators/python.tcl ]
source [ file join $script_path generators/tcl.tcl ]
source [ file join $script_path structure/struct.tcl ]
source [ file join $script_path structure/tables.tcl ]
source [ file join $script_path structure/tables_tcl.tcl ]
source [ file join $script_path structure/tables_cs.tcl ]
source [ file join $script_path structure/tables_c.tcl ]

load_sqlite
load_generators


proc print_usage { } {
	puts "\nThis utility generates code from a .drn file."
	puts "Usage: tclsh8.6 drakon_gen.tcl <options>"
	puts "Options:"
	puts "-in <filename>          The input filename."
	puts "-out <dir>              The output directory. Optional."
}

namespace eval mw {

proc set_status { ignored } {
}

}

proc get_argument { name optional } {
	global argv
	if { [ llength $argv ] % 2 != 0 } {
		puts "Error in command line arguments."
		print_usage
		exit 1
	}
	array set arguments $argv
	if { ![ info exists arguments($name) ] } {
		if { $optional } { return "" }
		puts "Error: $name argument missing."
		print_usage
		exit 1
	}
	return $arguments($name)
}

proc run { src_filename dst_filename } {
	#catch {
		set result [ mod::open db $src_filename drakon ]
		set message [ lindex $result 1 ]
		
		if { $message != "" } {
			puts $message
			exit 1
		}
		
		mwc::init db
		
		gen::generate_no_gui $dst_filename
	#} message

	#if { $message != "" } {
	#	puts $message
	#	exit 1
	#}
}


set in [ get_argument -in 0 ]
set out [ get_argument -out 1 ]

set src_filename [ file normalize $in ]
if { $out == "" } {
	set out [ file dirname $in ]
}

set out_dir [ file normalize $out ]

set name [ file tail $src_filename ]
set dst_filename [ file join $out_dir $name ]

run $src_filename $dst_filename






