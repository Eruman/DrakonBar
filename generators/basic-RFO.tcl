# Basic-generator by Bardynin Dmitry aka Eruman
# Astrakhan 2017
			
gen::add_generator basic-RFO gen_basic::generate

namespace path {::tcl::mathop ::tcl::mathfunc}
namespace eval gen_basic {

variable keywords {
and       break     do        else      elseif
    end       false     for       function  if
    in        local     nil       not       or
    repeat    return    then      true      until
    while
}


# Autogenerated with DRAKON Editor 1.26

proc append_sm_names { gdb } {
    #item 1852
    set ids {}
    #item 1825
    $gdb eval {
    	select diagram_id, original, name
    	from diagrams
    	where original is not null
    } {
    	set sm_name $original
    	set new_name "${sm_name}_$name"
    	$gdb eval {
    		update diagrams
    		set name = :new_name
    		where diagram_id = :diagram_id
    	}
    	lappend ids $new_name
    }
    #item 1853
    return $ids
}

proc build_declaration { name signature } {
    #item 80
    	unpack $signature type access parameters returns
    	set params {}
    	foreach par $parameters {
    		lappend params [ lindex $par 0 ]
    	}
    	set param_text [ join $params ", " ]
    	if { $type == "procedure" } {
#    		return "$returns $name\($param_text\) \{"
    		return "$returns $name\($param_text\) "
    	} else {
#    		return "$name\($param_text\) \{"
    		return "$name\($param_text\) "
    	}
}

proc extract_signature { text name } {
    #item 92
    	set a [split $name " "]
    #log "\n text >>> $text \n"
    	set lines [ gen::separate_from_comments $text ]
    	set first_line [ lindex $lines 0 ]
    	set first [ lindex $first_line 0 ]
    	if { $first == "#comment" } {
    		return [ list {} [ gen::create_signature "comment" {} {} {} ]]
    	}
    	
    	set type "procedure"
    	if { $first == "ctr" } {
    		set type "ctr"
    		set lines [ lrange $lines 1 end ]
    	}
    
    	set last [ lindex $lines end ]
    	set returns_expr [ lindex $last 0 ]
    	if { [ string match "returns *" $returns_expr ] } {
    		set returns [ lindex $returns_expr 1 ]
    		set parameters [ lrange $lines 0 end-1 ]
    	} else {
    		if { [lindex $a 1] == "" } {
    			#set returns "void" 
			if  {$name !="main" &&  $name !="���������"} { 
				set returns [ mytranslit "$name:"]
	    		} else {set returns ""}

    		} else {
    			#set returns "// No void SUB \"[lindex $a 1]\" \n" 
    			set returns "\% User defined function \n" 
    		}
    		set parameters $lines
    	}
    	return [ list {} [ gen::create_signature $type public $parameters $returns ] ]
}

proc generate { db gdb filename } {
    #item 74
    log "started..."
    log ">"
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
    	rewire_basic_for $gdb $diagram_id
    	rewire_wiring_for $gdb $diagram_id
    	rewire_wiring_insertion $gdb $diagram_id
    	rewire_wiring_output $gdb $diagram_id
    	rewire_wiring_input $gdb $diagram_id
    	incr _ind1768
    }
    set callbacks [ make_callbacks ]





    set machines [ sma::extract_many_machines \
     $gdb $callbacks ]
    variable handlers
    set handlers [ append_sm_names $gdb ]
    set machine_ctrs [ make_machine_ctrs $machines ]
    set machine_decl [ make_machine_declares $machines ]
    set diagrams [ $gdb eval {
    	select diagram_id from diagrams } ]
    set _col1810 $diagrams
    set _len1810 [ llength $_col1810 ]
    set _ind1810 0
    while { 1 } {
        if {$_ind1810 < $_len1810} {
            
        } else {
            break
        }
        set diagram_id [ lindex $_col1810 $_ind1810 ]
        gen::fix_graph_for_diagram $gdb $callbacks 0 $diagram_id
        incr _ind1810
    }

    #gen::fix_graph $gdb $callbacks 0

    unpack [ gen::scan_file_description $db { header footer } ] header footer
    set use_nogoto 1
    set functions [ gen::generate_functions $db $gdb $callbacks $use_nogoto ]
    
    if { [ graph::errors_occured ] } { return }
    set hfile [ replace_extension $filename "bas" ]
    set f [ open $hfile w ]
    catch {
    	p.print_to_file $f $functions $header $footer $use_nogoto 
    } error_message
    catch { close $f }
    
    #item 103
    set f [open $hfile r] 
    while {![eof $f]} { 
    	lappend ipList [gets $f]
     }
     close $f
     set f [open $hfile w ]
     foreach curip $ipList {
     set ncurip [string trimleft $curip " " ]
     if {[string first "case " $ncurip 0 ] >=0 && [string last ":;" $curip ] >=0 } {
#        set curip [string trimright $curip ";" ]
     }
     if {[string first "// item" $ncurip 0 ] >=0 } {
        continue 
     }
     if {[string first "//" $ncurip 0 ] >=0 && [string last ";" $curip ] >=0 } {
#        set curip [string trimright $curip ";" ]
     }
     if {[string first "if " $ncurip 0 ] >=0 && [string last ";" $curip ] >=0 } {
#        set curip [string trimright $curip ";" ]
     }
     if {[string first "#" $ncurip 0 ] >=0 && [string last ";" $curip ] >=0 } {
        set curip [string trimright $curip ";" ]
     }
     if {[string trim $curip " " ] == ";" } {
        continue 
     }
     if {[string trim $curip " " ] == "\};" } {
#        set curip [string trimright $curip ";" ]
     }
     if {[string last ",;" $curip ] >=0 } {
#        set curip [string trimright $curip ";" ]
     }
    
    
     puts $f $curip  
     }
     close $f
    #item 93
    if {$error_message != ""} {
        #item 96
        error $error_message
    } else {
        
    }
}

proc generate_body { gdb diagram_id start_item node_list sorted incoming } {
    #item 26
    set callbacks [ make_callbacks ]
    	return [ cbody::generate_body $gdb $diagram_id $start_item $node_list \
    		$sorted $incoming $callbacks ]
}

proc make_callbacks { } {
    #item 20
    set cbks [ gen_java::make_callbacks ]
    set cbks [ dict replace $cbks signature gen_basic::extract_signature ]
    set cbks [ dict replace $cbks body gen_basic::generate_body ]

    gen::put_callback cbks if_start     gen_basic::if_start 

    gen::put_callback cbks while_start     gen_basic::while_start

    gen::put_callback cbks elseif_start     gen_basic::elseif_start

    gen::put_callback cbks if_end       gen_basic::if_end

    gen::put_callback cbks pass       gen_basic::pass

    gen::put_callback cbks else_start   gen_basic::else_start

    gen::put_callback cbks block_close  gen_basic::block_close

#    gen::put_callback cbks if_close  gen_basic::if_close

    gen::put_callback cbks return_none  gen_basic::return_none

    gen::put_callback cbks goto         gen_basic::goto 
    gen::put_callback cbks break        "w_r.break"

    gen::put_callback cbks for_check		"gen_basic::foreach_check"
    gen::put_callback cbks for_current		"gen_basic::foreach_current"
    gen::put_callback cbks for_init		"gen_basic::foreach_init"
    gen::put_callback cbks for_incr		"gen_basic::foreach_incr"
    gen::put_callback cbks for_declare		"gen_basic::foreach_declare"

    return $cbks
}

proc if_start { } {
 return "if "
} 
proc if_end { } {
 return " then"
}
proc while_start { } {
 return "while 1=1"
} 
proc elseif_start { } {
return "elseif "
} 
proc if_end { } {return " then"
}
proc pass { } {
return ""
}
proc else_start { } {return "else"
}
proc goto { text } {return "goto $text"
}
proc block_close {
    output depth } {
upvar 1 $output result

    set line [ gen::make_indent $depth ]

    append line "repeat"

    lappend result $line
}
proc if_close {
    output depth } {
upvar 1 $output result

    set line [ gen::make_indent $depth ]

    append line "endif"

    lappend result $line
}


proc is_for { text } {
    set trimmed [ string trim $text]
    set result [ string match "for *" $trimmed ]
    return $result 
}

proc mytranslit3 { texttrans } {
    set a [split $texttrans "\""]
error [join $texttrans $a]
    set texttrans "\n"
    for {set x 0} {$x<[llength $a ]} {incr x } {
    
  set texttrans [ join $texttrans [mytranslit2 [lindex $a $x]]]
      set texttrans [ join $texttrans "if_br"
]
      incr x
    
  set texttrans [ join $texttrans [lindex $a $x]
]
      set texttrans [ join $texttrans "else_br"
]
    }
    return $texttrans
}

proc mytranslit { texttrans } {
    #item 102
    set texttrans [ string map {" ���� "   " byte "} $texttrans ]
    set texttrans [ string map {" ��� "   " int "} $texttrans ]
    set texttrans [ string map {" ��� "   " double " } $texttrans ]
    set texttrans [ string map {" ��� "   " boolean " } $texttrans ]
    set texttrans [ string map {" ��� "   " char "   } $texttrans ]
    set texttrans [ string map {" ��� "   " char* "  } $texttrans ]
    set texttrans [ string map {" ��� "   " String " } $texttrans ]
    set texttrans [ string map {" ����� " " const "  } $texttrans ]
    set texttrans [ string map {" �������� " " unsigned " } $texttrans ]
    
    set texttrans [ string map {"\n���� "  "\nbyte "} $texttrans ]
    set texttrans [ string map {"\n��� "   "\nint "} $texttrans ]
    set texttrans [ string map {"\n��� "   "\ndouble " } $texttrans ]
    set texttrans [ string map {"\n��� "   "\nboolean " } $texttrans ]
    set texttrans [ string map {"\n��� "   "\nchar "   } $texttrans ]
    set texttrans [ string map {"\n��� "   "\nchar* "  } $texttrans ]
    set texttrans [ string map {"\n��� "   "\nString " } $texttrans ]
    set texttrans [ string map {"\n����� " "\nconst "  } $texttrans ]
    set texttrans [ string map {"\n�������� " "\nunsigned " } $texttrans ]
    
    set texttrans [ string map {"\(���� "  "\(byte "} $texttrans ]
    set texttrans [ string map {"\(��� "   "\(int "} $texttrans ]
    set texttrans [ string map {"\(��� "   "\(double " } $texttrans ]
    set texttrans [ string map {"\(��� "   "\(boolean " } $texttrans ]
    set texttrans [ string map {"\(��� "   "\(char "   } $texttrans ]
    set texttrans [ string map {"\(��� "   "\(char* "  } $texttrans ]
    set texttrans [ string map {"\(��� "   "\(String " } $texttrans ]
    set texttrans [ string map {"\(����� " "\(const "  } $texttrans ]
    set texttrans [ string map {"\(�������� " "\(unsigned " } $texttrans ]
    
    set texttrans [ string map {",���� "  ",byte "} $texttrans ]
    set texttrans [ string map {",��� "   ",int "} $texttrans ]
    set texttrans [ string map {",��� "   ",double " } $texttrans ]
    set texttrans [ string map {",��� "   ",boolean " } $texttrans ]
    set texttrans [ string map {",��� "   ",char "   } $texttrans ]
    set texttrans [ string map {",��� "   ",char* "  } $texttrans ]
    set texttrans [ string map {",��� "   ",String " } $texttrans ]
    set texttrans [ string map {",����� " ",const "  } $texttrans ]
    set texttrans [ string map {",�������� " ",unsigned " } $texttrans ]
    
#    set texttrans [ string map {"������� " "return " } $texttrans ]
#    set texttrans [ string map {"������� " "return " } $texttrans ]
#    set texttrans [ string map {"���������" "setup" } $texttrans ]
#    set texttrans [ string map {"���������" "loop" } $texttrans ]
    set texttrans [ string map {"���������" "main" } $texttrans ]
    set texttrans [ string map {":=" "=" } $texttrans ]
#    set texttrans [ string map {"\n" ";\n"  } $texttrans ]
    
    set texttrans [ string map {"; ;"   ";"} $texttrans ]
    set texttrans [ string map {";;" ";"} $texttrans ]
    set texttrans [ string map {"\{;"   "\{"   } $texttrans ]
    set texttrans [ string map {"throw new IllegalStateException" "\/\/ illegal code "} $texttrans ]
    
    set texttrans [ string map {� j � c � u � k � e � n � g � sh � szh � z � h � x} $texttrans ]
    set texttrans [ string map {� f � y � v � a � p � r � o � l  � d   � zh � ae} $texttrans ]
    set texttrans [ string map {� ja � ch � s � m � i � t � j � b � ju � jo } $texttrans ]
    set texttrans [ string map {� J � C � U � K � E � N � G � SH � SZH � Z � H � X} $texttrans ]
    set texttrans [ string map {� F � Y � V � A � P � R � O � L � D � ZH � AE} $texttrans ]
    set texttrans [ string map {� JA � CH � S � M � I � T � J � B � JU � JO } $texttrans ]
    return $texttrans
}

#proc normalize_for { var start end } {
#    #item 62
#    return "delay ();"
#}

proc p.print_to_file { fhandle functions header footer use_nogoto } {
    #item 86
    set version [ version_string ]
    puts $fhandle \
        "% Autogenerated with DRAKON Editor $version "
    puts $fhandle \
        "% Generator adopted by Bardynin Dmitry, Astrakhan, 2017, ver.0.01"
    
    puts $fhandle " "
    if { $header != "" } {
    	set header [ mytranslit $header ]
    	puts $fhandle $header
    }
        
        foreach function $functions {
        	unpack $function diagram_id name signature body
       	set type [ lindex $signature 0 ]
            if  {$type != "comment" } {
                if  {$name eq "header" || $name eq "���������" } {
         		puts $fhandle ""
        		set lines [ gen::indent $body 1 ]
        		set lines [ mytranslit $lines ]
#        		append lines ";"
            		puts $fhandle $lines
            		puts $fhandle ""
            	   }
            }
        }
        
        foreach function $functions {
           	unpack $function diagram_id name signature body
           	set type [ lindex $signature 0 ]
           	if  {$type != "comment" } {
                if  {$name eq "main" || $name eq "���������" } {
        		puts $fhandle "# Main programm"
            		set declaration [ build_declaration $name $signature ]
            		set declaration [ mytranslit $declaration ]
            		#puts $fhandle $declaration
            		set lines [ gen::indent $body 1 ]
            		set lines [ mytranslit $lines ]
            		puts $fhandle $lines
            		puts $fhandle "end\n"
            	   }
    	         }
                 if  {$type != "comment"   
                         &&  $name !="main" && $name!="setup"
                         &&  $name !="header" &&  $name != "���������" 
                         &&  $name !="���������"  && $name!="���������"} {
            		puts $fhandle ""
            		set declaration [ build_declaration $name $signature ]
            		set declaration [ mytranslit $declaration ]
			set a [split $name "."]
			if { [lindex $a 0] eq "fn" } {
            		puts $fhandle $declaration} else {
            		puts $fhandle [ mytranslit "$name:"]}
            		set lines [ gen::indent $body 1 ]
            		set lines [ mytranslit $lines ]
            		puts $fhandle $lines
			set a [split $name "."]
			if { [lindex $a 0] eq "fn" } {
            		puts $fhandle "fn.end\n"} else {
            		puts $fhandle "return\n"}
            	}
        }
    puts $fhandle ""
    set footer [ mytranslit $footer ]
    puts $fhandle $footer
}


proc rewire_basic_for { gdb diagram_id } {
    #item 32
    log "rewire: $diagram_id"

   set starts [ $gdb eval {
    	select vertex_id
    	from vertices
    	where type = 'loopstart'
    		and text like 'for %'
    		and diagram_id = :diagram_id
    } ]
    set loop_vars {}
    set _col1734 $starts
    set _len1734 [ llength $_col1734 ]
    set _ind1734 0
    while { 1 } {
        if {$_ind1734 < $_len1734} {
            
        } else {
            break
        }
        set vertex_id [ lindex $_col1734 $_ind1734 ]
        unpack [ $gdb eval { 
        	select text, item_id
        	from vertices
        	where vertex_id = :vertex_id
        } ] text item_id
        unpack [ parse_for $item_id $text ] var start end
        set new_text [ normalize_for $var $start $end ]
        $gdb eval {
        	update vertices
        	set text = :new_text
        	where vertex_id = :vertex_id
        }
        lappend loop_vars $var
        incr _ind1734
    }
    set var_list [ lsort -unique $loop_vars ]
    if {$var_list == {}} {
            
    } else {
        set vars_comma [ join $var_list ", " ]
        set declaration "% use $vars_comma"
        gen::p.save_declare_kernel $gdb $diagram_id $declaration
    }
} 

proc rewire_wiring_for { gdb diagram_id } {
    #item 32
    log "rewire: $diagram_id"
        set starts [ $gdb eval {
        	select vertex_id
        	from vertices
        	where type = 'pause'
        		and diagram_id = :diagram_id } ]
    		    set loop_vars {}
    		    set _col1734 $starts
    		    set _len1734 [ llength $_col1734 ]
    		    set _ind1734 0
    		    while { 1 } {
    		        if {$_ind1734 < $_len1734} {
            } else { break }
    		        set vertex_id [ lindex $_col1734 $_ind1734 ]
    		        unpack [ $gdb eval {
            	select text, item_id
            	from vertices
            	where vertex_id = :vertex_id
             } ] text item_id
            set new_text "pause $text"
    
            $gdb eval {
            	update vertices
            	set text = :new_text
            	where vertex_id = :vertex_id
            }
            incr _ind1734
        }
        set var_list [ lsort -unique $loop_vars ]
        if {$var_list == {}} {
            
        } else {
            set vars_comma [ join $var_list ", " ]
            set declaration "local $vars_comma"
            gen::p.save_declare_kernel $gdb $diagram_id $declaration
        }
}

proc rewire_wiring_input { gdb diagram_id } {
    #item 50
    log "rewire_input: $diagram_id"
        set starts [ $gdb eval {
        	select vertex_id
        	from vertices
        	where type = 'input'
        		and diagram_id = :diagram_id } ]
    		    set loop_vars {}
    		    set _col1734 $starts
    		    set _len1734 [ llength $_col1734 ]
    		    set _ind1734 0
    		    while { 1 } {
    		        if {$_ind1734 < $_len1734} {
    	            
            } else { break }
    		        set vertex_id [ lindex $_col1734 $_ind1734 ]
    		        unpack [ $gdb eval {
            	select text, text2, item_id
            	from vertices
            	where vertex_id = :vertex_id
             } ] text text2 item_id
            set exper [string last ")" $text2]
            if {$exper < 0} { set new_text "$text = $text2\();" 
                } else { set new_text "$text = $text2;" }
    
            $gdb eval {
            	update vertices
            	set text = :new_text
            	where vertex_id = :vertex_id
            }
            incr _ind1734
        }
        set var_list [ lsort -unique $loop_vars ]
        if {$var_list == {}} {
            
        } else {
            set vars_comma [ join $var_list ", " ]
            set declaration "local $vars_comma"
            gen::p.save_declare_kernel $gdb $diagram_id $declaration
        }
}

proc rewire_wiring_insertion { gdb diagram_id } {
    #item 38
    log "rewire_insertion: $diagram_id"
        set starts [ $gdb eval {
        	select vertex_id
        	from vertices
        	where type = 'insertion'
        		and diagram_id = :diagram_id } ]
    		    set loop_vars {}
    		    set _col1734 $starts
    		    set _len1734 [ llength $_col1734 ]
    		    set _ind1734 0
    		    while { 1 } {
    		        if {$_ind1734 < $_len1734} {
                
            } else { break }
    		        set vertex_id [ lindex $_col1734 $_ind1734 ]
    		        unpack [ $gdb eval {
            	select text, item_id
            	from vertices
            	where vertex_id = :vertex_id
             } ] text item_id
            set a [split $text "."]
            if { [lindex $a 0] eq "def" } {
              error "Error of colling $text!"
            } else { set new_text "gosub $text"}
            $gdb eval {
            	update vertices
            	set text = :new_text
            	where vertex_id = :vertex_id
            }
            incr _ind1734
        }
        set var_list [ lsort -unique $loop_vars ]
        if {$var_list == {}} {
           
        } else {
            set vars_comma [ join $var_list ", " ]
            set declaration "local $vars_comma"
            gen::p.save_declare_kernel $gdb $diagram_id $declaration
        }
}

proc rewire_wiring_output { gdb diagram_id } {
    #item 44
    log "rewire_output: $diagram_id"
        set starts [ $gdb eval {
        	select vertex_id
        	from vertices
        	where type = 'output'
        		and diagram_id = :diagram_id } ]
    		    set loop_vars {}
    		    set _col1734 $starts
    		    set _len1734 [ llength $_col1734 ]
    		    set _ind1734 0
    		    while { 1 } {
    		        if {$_ind1734 < $_len1734} {
    	            
            } else { break }
    		        set vertex_id [ lindex $_col1734 $_ind1734 ]
    		        unpack [ $gdb eval {
            	select text, text2, item_id
            	from vertices
            	where vertex_id = :vertex_id
             } ] text text2 item_id
            set new_text "$text2\($text) "
            $gdb eval {
            	update vertices
            	set text = :new_text
            	where vertex_id = :vertex_id
            }
            incr _ind1734
        }
        set var_list [ lsort -unique $loop_vars ]
        if {$var_list == {}} {
            
        } else {
            set vars_comma [ join $var_list ", " ]
            set declaration "local $vars_comma"
            gen::p.save_declare_kernel $gdb $diagram_id $declaration
        }
}


proc foreach_check { item_id first second } {
    set vars [ split_vars $item_id $first ]
    set var1 [ lindex $vars 0 ]
    return "$var1 ~= nil"
}

proc foreach_current { item_id first second } {
    return ""
}

proc foreach_declare { item_id first second } {
    set iter_var "_iter$item_id"
    set state_var "_state$item_id"
    return "local $iter_var, $state_var, $first"
}

proc foreach_incr { item_id first second } {
    set vars [ split_vars $item_id $first ]
    set iter_var "_iter$item_id"
    set state_var "_state$item_id"
    set var1 [ lindex $vars 0 ]
    return "$first = $iter_var\($state_var, $var1\)"
}

proc foreach_init { item_id first second } {
    set vars [ split_vars $item_id $first ]
    set iter_var "_iter$item_id"
    set state_var "_state$item_id"
    set var1 [ lindex $vars 0 ]
    return "$iter_var, $state_var, $var1 = $second $first = $iter_var\($state_var, $var1\)"
}

proc normalize_for { var start end } {
    return "$var = $start; $var <= $end; $var = $var + 1"
}

proc parse_for { item_id text } {
    set tokens [ to_tokens $text ]
    if {[ llength $tokens ] < 6} {
        error "Wrong 'for' syntax in item $item_id"
    } else {
        unpack $tokens for var eq start comma
        if {(($for == "for") && ($eq == "=")) && ($comma == "to")} {
            set comma_index [ string first "to" $text ]
            set target_index [ expr { $comma_index + 1 + 1 } ]
            set target [ string range $text $target_index end ]
            set end [ string trim $target ]
            return [ list $var $start $end ]
        } else {
            error "Wrong 'for' syntax in item $item_id"
        }
    }
}

proc parse_foreach { item_id init } {
    set length [ llength $init ]
    if {$length == 2} {
        
    } else {
        set message "item id: $item_id, wrong syntax in foreach. Should be: Type variable; collection"
    }
    return $init
}

proc make_machine_ctr { name states param_names messages } {
    #item 1890
    set lines {}
    #item 18880001
    set _col1888 $states
    set _len1888 [ llength $_col1888 ]
    set _ind1888 0
    while { 1 } {
        #item 18880002
        if {$_ind1888 < $_len1888} {
            
        } else {
            break
        }
        #item 18880004
        set state [ lindex $_col1888 $_ind1888 ]
        #item 18930001
        set _col1893 $messages
        set _len1893 [ llength $_col1893 ]
        set _ind1893 0
        while { 1 } {
            #item 18930002
            if {$_ind1893 < $_len1893} {
                
            } else {
                break
            }
            #item 18930004
            set message [ lindex $_col1893 $_ind1893 ]
            #item 1895
            lappend lines \
             "${name}_state_${state}.$message = ${name}_${state}_${message}"
            #item 18930003
            incr _ind1893
        }
        #item 1896
        lappend lines "${name}_state_${state}.state_name = \"$state\""
        #item 18880003
        incr _ind1888
    }
    #item 1899
    set params [ lrange $param_names 1 end ]
    set params [ linsert $params 0 "self" ]
    set params_str [ join $params ", " ]
    #item 1897
    lappend lines "function make_${name}\(\)"
    #item 1902
    lappend lines \
     "  local obj = {}"
    lappend lines \
     "  obj.type_name = \"$name\""
    #item 1903
    set first [ lindex $states 0 ]
    lappend lines "  obj.state = ${name}_state_${first}"
    #item 19000001
    set _col1900 $messages
    set _len1900 [ llength $_col1900 ]
    set _ind1900 0
    while { 1 } {
        #item 19000002
        if {$_ind1900 < $_len1900} {
            
        } else {
            break
        }
        #item 19000004
        set message [ lindex $_col1900 $_ind1900 ]
        #item 1904
        lappend lines \
         "  obj.$message = function\($params_str\)"
        lappend lines \
         "    self.state.$message\($params_str\)"
        lappend lines \
         "  end"
        #item 19000003
        incr _ind1900
    }
    #item 1898
    lappend lines "  return obj"
    lappend lines "end"
    #item 1886
    return [ join $lines "\n" ]
}

proc make_machine_ctrs { machines } {
    #item 1869
    set result ""
    #item 18670001
    set _col1867 $machines
    set _len1867 [ llength $_col1867 ]
    set _ind1867 0
    while { 1 } {
        #item 18670002
        if {$_ind1867 < $_len1867} {
            
        } else {
            break
        }
        #item 18670004
        set machine [ lindex $_col1867 $_ind1867 ]
        #item 1864
        set states [ dict get $machine "states"]
        set param_names [ dict get $machine "param_names" ]
        set messages [ dict get $machine "messages" ]
        set name [ dict get $machine "name" ]
        #item 1887
        set ctr \
        [make_machine_ctr $name $states $param_names $messages]
        #item 1863
        append result $ctr
        #item 18670003
        incr _ind1867
    }
    #item 1843
    return $result
}

proc make_machine_declares { machines } {
    #item 1913
    set lines {}
    #item 19110001
    set _col1911 $machines
    set _len1911 [ llength $_col1911 ]
    set _ind1911 0
    while { 1 } {
        #item 19110002
        if {$_ind1911 < $_len1911} {
            
        } else {
            break
        }
        #item 19110004
        set machine [ lindex $_col1911 $_ind1911 ]
        #item 1910
        set states [ dict get $machine "states"]
        set name [ dict get $machine "name" ]
        #item 19180001
        set _col1918 $states
        set _len1918 [ llength $_col1918 ]
        set _ind1918 0
        while { 1 } {
            #item 19180002
            if {$_ind1918 < $_len1918} {
                
            } else {
                break
            }
            #item 19180004
            set state [ lindex $_col1918 $_ind1918 ]
            #item 1914
            lappend lines "${name}_state_${state} = \{\}"
            #item 19180003
            incr _ind1918
        }
        #item 19110003
        incr _ind1911
    }
    #item 1915
    return [ join $lines "\n" ]
}


proc to_tokens { text } {
    #item 68
        set tokens [ search::to_tokens $text ]
        set result {}
        set _col1703 $tokens
        set _len1703 [ llength $_col1703 ]
        set _ind1703 0
        while { 1 } {
           if {$_ind1703 < $_len1703} {
               
            } else {
                break
            }
            set token [ lindex $_col1703 $_ind1703 ]
            set text [ lindex $token 0 ]
            set trimmed [ string trim $text ]
            if {$trimmed == ""} {
              
            } else {
                lappend result $text
            }
            incr _ind1703
        }
        return $result
}

}
