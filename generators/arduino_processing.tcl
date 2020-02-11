# Processing-generator by Bardynin Dmitry aka Eruman
# Astrakhan 2015
			
gen::add_generator Arduino_a_processing.org gen_a_processing::generate

namespace eval gen_a_processing {

# Autogenerated with DRAKON Editor 1.26

proc build_declaration { name signature } {
    #item 80
    	unpack $signature type access parameters returns
    	set params {}
    	foreach par $parameters {
    		lappend params [ lindex $par 0 ]
    	}
    	set param_text [ join $params ", " ]
    	if { $type == "procedure" } {
    		return "$returns $name\($param_text\) \{"
    	} else {
    		return "$name\($param_text\) \{"
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
    			set returns "void" 
    		} else {
    			#set returns "// No void SUB \"[lindex $a 1]\" \n" 
    			set returns "" 
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
    	rewire_wiring_for $gdb $diagram_id
    	rewire_wiring_insertion $gdb $diagram_id
    	rewire_wiring_output $gdb $diagram_id
    	rewire_wiring_input $gdb $diagram_id
    	incr _ind1768
     }
    	set callbacks [ make_callbacks ]
    	gen::fix_graph $gdb $callbacks 1
    	unpack [ gen::scan_file_description $db { header footer } ] header footer
    	set use_nogoto 1
    	set functions [ gen::generate_functions $db $gdb $callbacks $use_nogoto ]
    	if { [ graph::errors_occured ] } { return }
    	set hfile [ replace_extension $filename "pde" ]
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
        set curip [string trimright $curip ";" ]
     }
     if {[string first "// item" $ncurip 0 ] >=0 } {
        continue 
     }
     if {[string first "//" $ncurip 0 ] >=0 && [string last ";" $curip ] >=0 } {
        set curip [string trimright $curip ";" ]
     }
     if {[string first "if " $ncurip 0 ] >=0 && [string last ";" $curip ] >=0 } {
        set curip [string trimright $curip ";" ]
     }
     if {[string first "#" $ncurip 0 ] >=0 && [string last ";" $curip ] >=0 } {
        set curip [string trimright $curip ";" ]
     }
     if {[string trim $curip " " ] == ";" } {
        continue 
     }
     if {[string trim $curip " " ] == "\};" } {
        set curip [string trimright $curip ";" ]
     }
     if {[string last ",;" $curip ] >=0 } {
        set curip [string trimright $curip ";" ]
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
    set cbks [ dict replace $cbks signature gen_a_processing::extract_signature ]
    set cbks [ dict replace $cbks body gen_a_processing::generate_body ]
    return $cbks
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
    
    set texttrans [ string map {"������� " "return " } $texttrans ]
    set texttrans [ string map {"���������" "setup" } $texttrans ]
    set texttrans [ string map {"���������" "loop" } $texttrans ]
    set texttrans [ string map {":=" "=" } $texttrans ]
    set texttrans [ string map {"\n" ";\n"  } $texttrans ]
    
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

proc normalize_for { var start end } {
    #item 62
    return "delay ();"
}

proc p.print_to_file { fhandle functions header footer use_nogoto } {
    #item 86
    set version [ version_string ]
    puts $fhandle \
        "// pro Autogenerated with DRAKON Editor $version "
    puts $fhandle \
        "// Generator adopted by Bardynin Dmitry, Astrakhan, 2015 "
    
    puts $fhandle " "
    if { $header != "" } {
    	set header [ mytranslit $header ]
    	puts $fhandle $header
    }
        
        foreach function $functions {
        	unpack $function diagram_id name signature body
       	set type [ lindex $signature 0 ]
            	if  {$type != "comment" } {
                if  {$name eq "setup" || $name eq "���������" } {
         		puts $fhandle ""
         		set declaration [ build_declaration $name $signature ]
        		set declaration [ mytranslit $declaration ]
        		puts $fhandle $declaration
        		set lines [ gen::indent $body 1 ]
        		append lines ";"
        		set lines [ mytranslit $lines ]
            		puts $fhandle $lines
            		puts $fhandle "\}"
            	} }
            }
        
            foreach function $functions {
            	unpack $function diagram_id name signature body
            	set type [ lindex $signature 0 ]
            	if  {$type != "comment" } {
                    if  {$name eq "loop" || $name eq "���������" } {
            		puts $fhandle ""
            		set declaration [ build_declaration $name $signature ]
            		set declaration [ mytranslit $declaration ]
            		puts $fhandle $declaration
            		set lines [ gen::indent $body 1 ]
            		append lines ";"
            		set lines [ mytranslit $lines ]
            		puts $fhandle $lines
            		puts $fhandle "\}"
            	}
    		}
            }
        
            foreach function $functions {
            	unpack $function diagram_id name signature body
            	set type [ lindex $signature 0 ]
            	if  {$type != "comment"   
                         &&  $name !="loop" && $name!="setup"
                         &&  $name !="���������"  && $name!="���������"} {
            		puts $fhandle ""
            		set declaration [ build_declaration $name $signature ]
            		set declaration [ mytranslit $declaration ]
            		puts $fhandle $declaration
            		set lines [ gen::indent $body 1 ]
            		append lines ";"
            		set lines [ mytranslit $lines ]
            		puts $fhandle $lines
            		puts $fhandle "\}"
            	}
        }
    puts $fhandle ""
    set footer [ mytranslit $footer ]
    puts $fhandle $footer
}

proc parse_for { item_id text } {
    #item 56
        set tokens [ to_tokens $text ]
    log "token >>> $tokens"
    log "text  >>> $text"
        if {[ llength $tokens ] < 6} {
    #        error "<6 Wrong 'for' syntax in item $item_id"
        } else {
            unpack $tokens for var eq start comma
            if {(($for == "for") && ($eq == "=")) && ($comma == ",")} {
                set comma_index [ string first "," $text ]
                set target_index [ expr { $comma_index + 1 } ]
                set target [ string range $text $target_index end ]
                set end [ string trim $target ]
                return [ list $var $start $end ]
            } else {
    #            error "?? Wrong 'for' syntax in item $item_id"
            }
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
            set new_text "delay($text);"
    
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
            set new_text "$text\(); "
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
            set new_text "$text2\($text); "
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