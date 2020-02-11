

gen::add_generator visual_Tcl gen_vtcl::generate

namespace eval gen_vtcl {

variable keywords

array set keywords {
append 1
binary 1
format 1
regexp 1
regsub 1
scan 1
string 1
subst 1
concat 1
join 1
lappend 1
lindex 1
linsert 1
list 1
llength 1
lrange 1
lreplace 1
lsearch 1
lset 1
lsort 1
split 1
expr 1
after 1
break 1
catch 1
continue 1
error 1
eval 1
for 1
foreach 1
if 1
return 1
switch 1
update 1
uplevel 1
vwait 1
while 1
array 1
global 1
incr 1
namespace 1
proc 1
rename 1
set 1
trace 1
unset 1
upvar 1
variable 1
close 1
eof 1
fblocked 1
fconfigure 1
fcopy 1
file 1
fileevent 1
flush 1
gets 1
open 1
puts 1
read 1
seek 1
socket 1
tell 1
load 1
package 1
source 1
cd 1
clock 1
exec 1
exit 1
glob 1
pid 1
pwd 1
time 1
}


proc highlight { tokens } {
	variable keywords
	set result {}
	set state "idle"
	foreach token $tokens {
		lassign $token type text
		set color $colors::syntax_keyword

		if { $text == "\n" } {
			set state "idle"
		} elseif { $state == "idle"} {
			if { $type == "op" } {
				set color $colors::syntax_operator
				if { $text == "\"" } {
					set state "string"
					set color $colors::syntax_string
				} elseif { $text == "#" } {
					set state "comment"
					set color $colors::syntax_comment
				}
			} elseif { $type == "number" } {
				set color $colors::syntax_number
			} elseif { $type == "token" } {
				if { [ info exists keywords($text) ] } {
					set color $colors::syntax_keyword
				} else {
					set color $colors::syntax_identifier
				}
			}
		} elseif { $state == "comment" } {
			set color $colors::syntax_comment
		} elseif { $state == "string" } {
			if { $text == "\{" || $text == "\}" || $text == "\(" || $text == "\)" ||
				$text == "\[" || $text == "\]" || $text == "$" } {
				set color $colors::syntax_operator
			} elseif { $text == "\"" } {
				set color $colors::syntax_string
				set state "idle"
			} elseif { $text == "\\" } {
				set state "escaping"
				set color $colors::syntax_string
			} else {
				set color $colors::syntax_string
			}
		} elseif { $state == "escaping" } {
			set color $colors::syntax_string
			set state "string"
		} else {
			set color "#000000"
		}
		lappend result $color
	}
	return $result
}




proc p.jump { item_id base depth} {
	set indent [ gen::make_indent [ expr { $base + $depth } ] ]
	if { $item_id == "last_item" } {
		set value "return \"\""
	} elseif { $item_id == "has_return" } {
		set value ""
	} else {
		set value "set _next_item_ $item_id"
	}
	return "$indent$value"
}

proc wrap_in_curly { text } {

	set trimmed [ string trim $text ]
	set first [ string index $trimmed 0 ]

	if { $first != "\{"} {
		return "\{$trimmed\}"
	} else {
		return $trimmed
	}
}

proc shelf { primary secondary } {
	set prim [ string trim $primary ]
	set first [ string index $prim 0 ]

	if { [ string is alpha $first ] } {
		if { [ string match "expr *" $prim ] } {
			set expression [ string range $prim 4 end ]
			set curled [ wrap_in_curly $expression ]
			set prim "\[expr $curled\]"
		} else {
			set prim "\[$prim\]"
		}
	}
	if { [ llength $secondary ] > 1 } {
		set result "lassign \\\n$prim \\\n$secondary"
	} else {
		set result "set $secondary \\\n$prim"
	}

	return $result
}

proc foreach_init { item_id first second } {
	set index_var "_ind$item_id"
	set coll_var "_col$item_id"
	set length_var "_len$item_id"
	return "set $coll_var $second\nset $length_var \[ llength \$$coll_var \]\nset $index_var 0"
}

proc foreach_check { item_id first second } {
	set index_var "_ind$item_id"
	set coll_var "_col$item_id"
	set length_var "_len$item_id"
	return "\$$index_var < \$$length_var"
}

proc foreach_current { item_id first second } {
	set index_var "_ind$item_id"
	set coll_var "_col$item_id"
	set length_var "_len$item_id"
	return "set $first \[ lindex \$$coll_var \$$index_var \]"
}

proc foreach_incr { item_id first second } {
	set index_var "_ind$item_id"
	return "incr $index_var"
}

proc if_cond { condition } {
	set trimmed [ string trim $condition ]
	set first [ string index $trimmed 0 ]
	if { $first == "\"" || $first == "\$" || $first == "\[" || $first == "\(" } {
		return $condition
	}
	return "\[$condition\]"
}

proc make_callbacks { } {
	set callbacks {}

	gen::put_callback callbacks assign			gen_vtcl::p.assign
	gen::put_callback callbacks compare			gen_vtcl::p.compare
	gen::put_callback callbacks compare2		gen_vtcl::p.compare2
	gen::put_callback callbacks while_start 	gen_vtcl::p.while_start
	gen::put_callback callbacks if_start		gen_vtcl::p.if_start
	gen::put_callback callbacks elseif_start	gen_vtcl::p.elseif_start
	gen::put_callback callbacks if_end			gen_vtcl::p.if_end
	gen::put_callback callbacks else_start		gen_vtcl::p.else_start
	gen::put_callback callbacks pass			gen_vtcl::p.pass
	gen::put_callback callbacks continue		gen_vtcl::p.continue
	gen::put_callback callbacks return_none		gen_vtcl::p.return_none
	gen::put_callback callbacks block_close		gen_vtcl::p.block_close
	gen::put_callback callbacks comment			gen_vtcl::p.comment
	gen::put_callback callbacks bad_case		gen_vtcl::p.bad_case
	gen::put_callback callbacks for_init		gen_vtcl::foreach_init
	gen::put_callback callbacks for_check		gen_vtcl::foreach_check
	gen::put_callback callbacks for_current		gen_vtcl::foreach_current
	gen::put_callback callbacks for_incr		gen_vtcl::foreach_incr
	gen::put_callback callbacks body			gen_vtcl::generate_body
	gen::put_callback callbacks signature		gen_vtcl::extract_signature
	gen::put_callback callbacks and				gen_vtcl::p.and
	gen::put_callback callbacks or				gen_vtcl::p.or
	gen::put_callback callbacks not				gen_vtcl::p.not
	gen::put_callback callbacks break			"break"
	gen::put_callback callbacks declare			gen_vtcl::p.declare
	gen::put_callback callbacks for_declare		gen_vtcl::for_declare
	gen::put_callback callbacks shelf			gen_vtcl::shelf
	gen::put_callback callbacks if_cond			gen_vtcl::if_cond

	return $callbacks
}

proc p.declare { type name value } {
	return ""
}

proc generate_body { gdb diagram_id start_item node_list sorted incoming } {
	set callbacks [ make_callbacks ]
	return [ cbody::generate_body $gdb $diagram_id $start_item $node_list \
		$sorted $incoming $callbacks ]
}

proc p.and { left right } {
	return "($left) && ($right)"
}

proc p.or { left right } {
	return "($left) || ($right)"
}

proc p.not { operand } {
	return "!($operand)"
}

proc p.assign { variable value } {
	return "set $variable $value"
}

proc p.compare { variable value } {
	return "\$$variable == $value"
}

proc p.compare2 { variable value } {
	return "$variable == $value"
}


proc p.while_start { } {
	return "while \{ 1 \} \{"
}

proc p.if_start { } {
	return "if \{"
}

proc p.elseif_start { } {
	return "\} elseif \{"
}

proc p.if_end { } {
	return "\} \{"
}

proc p.else_start { } {
	return "\} else \{"
}
proc p.pass { } {
	return ""
}

proc p.continue { } {
	return "continue"
}

proc p.return_none { } {
	return "return \{\}"
}

proc p.block_close { output depth } {
	upvar 1 $output result
	set line [ gen::make_indent $depth ]
	append line "\}"
	lappend result $line
}

proc p.comment { line } {
	return "#$line"
}

proc p.bad_case { switch_var select_icon_number } {
    if {[ string compare -nocase $switch_var "select" ] == 0} {
    	return "error \"Unhandled condition.\""
	} else {
		return "error \"Unexpected switch value: \$$switch_var\""
	}
}

proc for_declare { item_id first second } {
	return ""
}

proc generate { db gdb filename } {
	global errorInfo
###################################################################
	    set diagrams [ $gdb eval {
    	    	select diagram_id
        	from vertices
        	group by diagram_id
        } ]

        set _col1768 $diagrams
        set _len1768 [ llength $_col1768 ]
        set _ind1768 0
        while { 1 } {
			if {$_ind1768 < $_len1768} {

			} else {
				break
			}
			set diagram_id [ lindex $_col1768 $_ind1768 ]
			# Обработать все диаграммы для рассчета положения
			#rewire_wiring_objects $gdb $diagram_id
			incr _ind1768
		}
###################################################################

	set callbacks [ make_callbacks ]

	gen::fix_graph $gdb $callbacks 0
	unpack [ gen::scan_file_description $db { header footer } ] header footer

	set use_nogoto 1
	set functions [ gen::generate_functions $db $gdb $callbacks $use_nogoto ]

	tab::generate_tables $gdb $callbacks 0

	if { [ graph::errors_occured ] } { return }

	set vfile [ replace_extension $filename "vtcl" ]
	if { [ catch {
		set fp [open $vfile r]
		set file_data [read $fp]
		close $fp
	} error_message ] } {
	  tk_messageBox -icon error -message " ќшибка: '$error_message' with\n  ‘айл интерфейса '$vfile' не подключен."
	}


	set hfile [ replace_extension $filename "tcl" ]
	set f [ open $hfile w ]
	catch {
		#		tab::core_debug_print stdout gen_vtcl::field_selector
		p.print_to_file $f $functions $header $footer
	} error_message
	set savedInfo $errorInfo

	if { [ catch {puts $f $file_data} error_message ] } {
	  tk_messageBox -icon error -message " ќшибка: '$error_message' with\n  ‘айл интерфейса '$vfile' не подключен."
	}

	catch { close $f }

	if { $error_message != "" } {
		puts $errorInfo
		error $error_message savedInfo
	} else {
	set tail $filename
	set last [ string last "." $tail ]

	set cut_tail [ string range $tail 0 $last ]
        file delete -force -- $cut_tail     # удалить непустую папку
#	exec start.exe $hfile
	set command "[auto_execok start] {} [list $hfile]"
	if { $command == {} } { return }
	if { [ catch {exec {*}$command &} err ] } {
	  tk_messageBox -icon error -message "error '$err' with\n'$command'"
	}
    }

}

proc build_declaration { name signature } {
	unpack $signature type access parameters returns
	set result "proc $name \{"
	foreach parameter $parameters {
		append result " " [ lindex $parameter 0 ]
	}
	return "$result \} \{"
}

proc field_selector { field } {
	set indexes [ tab::get_field2_indexes $field ]
	if { $indexes == {} } { return 0 }
	return 1
}

proc p.print_to_file { fhandle functions header footer } {
	if { $header != "" } {
		puts $fhandle $header
	}
	set version [ version_string ]
	puts $fhandle \
	    "# Autogenerated with DRAKON Editor $version"

	init_current_file $fhandle
	## Генерируем таблицы данных по схеме данных (см. tables_tcl.tcl)
	#generate_data_struct



	foreach function $functions {
		unpack $function diagram_id name signature body
		set type [ lindex $signature 0 ]
		if { $type != "comment" } {
			puts $fhandle ""
			set declaration [ build_declaration $name $signature ]
			puts $fhandle $declaration
			set lines [ gen::indent $body 1 ]
			puts $fhandle $lines
			puts $fhandle "\}"
		}
	}
	puts $fhandle ""
	puts $fhandle $footer
}



proc extract_signature { text name } {
	set lines [ gen::separate_from_comments $text ]
	set first_line [ lindex $lines 0 ]
	set first [ lindex $first_line 0 ]
	if { $first == "#comment" } {
		return [ list {} [ gen::create_signature "comment" {} {} {} ]]
	}

	set parameters {}
	foreach current $lines {
		lappend parameters $current
	}

	return [ list {} [ gen::create_signature procedure public $parameters "" ] ]
}


proc rewire_wiring_objects { gdb diagram_id } {
#log "reload my_names: $my_names"
	set db [ mwc::get_db ]
	set starts [ $gdb eval { select vertex_id from vertices
		where diagram_id = :diagram_id } ]
	set _col1734 $starts
	set _len1734 [ llength $_col1734 ]
	set _ind1734 0
	while { 1 } {
		if {$_ind1734 < $_len1734} {} else { break }
		set vertex_id [ lindex $_col1734 $_ind1734 ]
		unpack [ $gdb eval {
			select text, text2, item_id
			from vertices
			where vertex_id = :vertex_id
		} ] text text2 item_id
		set my_names [ $db eval { SELECT color,x,y FROM items WHERE diagram_id = :diagram_id AND item_id = :item_id
			AND (type = "action") } ]
		log "reload my_names: $my_names"
		set lll [ llength [lindex $my_names 0] ]
		# если в позиции "цвета" что-то записано, то исключаем блок
		if { $lll > 0 } {
			set new_text "//$text; // changed color"
		} else {
			set new_text $text
		}
		$gdb eval {
			update vertices set text = :new_text
			where vertex_id = :vertex_id
		}
		incr _ind1734
	}
}




















}
