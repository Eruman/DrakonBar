# Tester-generator by Bardynin Dmitry aka Eruman
# Astrakhan-Sochi 2015-2019

gen::add_generator ����������� gen_Tester::generate

namespace eval gen_Tester {

# Autogenerated with DRAKON Editor 1.26
#include <tcl.h>

#set gen::legalLoop "{for (*} for(* while(*"

set correct {
    Serial.begin Serial.print Serial.println digitalWrite digitalRead pinMode analogRead analogWrite 
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
    		return "$returns $name\($param_text\) \{"
    	} else {
    		return "$name\($param_text\) \{"
    	}
}

proc extract_signature { text name } {
    #item 92
    	#set a [split $name " "]
    set a [split $name ")"]

	#log "\n text >>> $text \n"
    set lines [ gen::separate_from_comments $text ]
	#tk_messageBox -icon info -message $lines -title "lines"
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
#    			set returns "void"
    			set returns "instruction"
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
    #::ds::speak "Generating started" -E2 -S55 -i


    set names [ $gdb eval {
        SELECT name FROM diagrams
        } ]
    #$gen_Tester::correct
    set newnames ""
    foreach name $names {
        set s1 [string first ")" $name ]
        if { $s1 > 0 } { set name [string range $name $s1+1 end] }
        set name [string trimleft $name]
        set name [string trimright $name]
        append newnames " \{" $name "\}"
        #tk_messageBox -icon info -message "name:$name*" -title "newnames:$newnames*"
    }
    #tk_messageBox -icon info -message "gen_Tester::correct:$gen_Tester::correct *" -title "names:$newnames*"
    append gen_Tester::correct $newnames
    #tk_messageBox -icon info -message "gen_Tester::correct:$gen_Tester::correct *" -title "names:$newnames*"

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
			# ���������� ��� ������ ��� �������������
			rewire_wiring_pause $gdb $diagram_id
			rewire_wiring_pause_ins $gdb $diagram_id
			rewire_wiring_insertion $gdb $diagram_id
			rewire_wiring_output $gdb $diagram_id
			rewire_wiring_input $gdb $diagram_id
			rewire_wiring_timer $gdb $diagram_id
			rewire_wiring_process $gdb $diagram_id
			rewire_wiring_shelf $gdb $diagram_id
            rewire_wiring_if $gdb $diagram_id

			# ������������ text & text2 � ������ ����
    		rewire_wiring_rem2text $gdb $diagram_id
	        # ��������� ��� ������ � ���������� �����
			rewire_color $gdb $diagram_id
			incr _ind1768
		}

    	set callbacks [ make_callbacks ]
    	gen::fix_graph $gdb $callbacks 1
    	unpack [ gen::scan_file_description $db { header footer } ] header footer
		###################################################
		      set timers [ $gdb eval {
		            select text
		            from vertices
		            where type = 'timer' } ]
		        foreach n $timers {
		          set n [ mytranslit_declaration $n ]
		          set n [ my_name_translit $n ]
		          log "unsigned long  $n ;"
		          set n [ split $n "="]
		          append header "\n unsigned long  [lindex $n 0] ;\n"
		        }
    	set use_nogoto 1
    	set functions [ gen::generate_functions $db $gdb $callbacks $use_nogoto ]
    	if { [ graph::errors_occured ] } { return }
            set hfile [ replace_extension $filename "tst" ]
            set hname [ mytranslit_declaration  [file tail $hfile] ]
            set hname [ string map {" " "_"} $hname ]
            set hfile [file dirname $hfile]/$hname
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
	set tail $filename
	set last [ string last "." $tail ]

	set cut_tail [ string range $tail 0 $last ]
        file delete -force -- $cut_tail     # ������� �������� �����
#	exec start.exe $hfile
	after 1000
	set command "[auto_execok start] {} [list $hfile]"
	if { $command == {} } { return }
	if { [ catch {exec {*}$command &} err ] } {
	  tk_messageBox -icon error -message "error '$err' with\n'$command'"
	}

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
    set cbks [ dict replace $cbks signature gen_Tester::extract_signature ]
    set cbks [ dict replace $cbks body gen_Tester::generate_body ]
    #gen::put_callback cbks if_close  gen_java::block_close

	return $cbks
}

proc newline_cut { texttrans } {
    set texttrans [ string map {"\n"   " "} $texttrans ]
    set texttrans [ string map {"                "  " "} $texttrans ]
    set texttrans [ string map {"        "  " "} $texttrans ]
    set texttrans [ string map {"    "  " "} $texttrans ]
    set texttrans [ string map {"  "  " "} $texttrans ]
    set texttrans [ string map {"  "  " "} $texttrans ]
    set texttrans [ string map {"  "  " "} $texttrans ]
    set texttrans [ string trimleft $texttrans ]
    set texttrans [ string trimright $texttrans ]
    return $texttrans
}

proc digit_cut { texttrans } {
    set texttrans [ string map {" "  ""} $texttrans ]
    set texttrans [ string map {"0"  ""} $texttrans ]
    set texttrans [ string map {"1"  ""} $texttrans ]
    set texttrans [ string map {"2"  ""} $texttrans ]
    set texttrans [ string map {"3"  ""} $texttrans ]
    set texttrans [ string map {"4"  ""} $texttrans ]
    set texttrans [ string map {"5"  ""} $texttrans ]
    set texttrans [ string map {"6"  ""} $texttrans ]
    set texttrans [ string map {"7"  ""} $texttrans ]
    set texttrans [ string map {"8"  ""} $texttrans ]
    set texttrans [ string map {"9"  ""} $texttrans ]
    set texttrans [ string map {","  ""} $texttrans ]
    set texttrans [ string map {"."  ""} $texttrans ]
    set texttrans [ string map {"-"  ""} $texttrans ]
    return $texttrans
}

proc nodigit_cut { text } {
    tk_messageBox -message "text: $text"
    set no_dig_text [ digit_cut $text ]
    tk_messageBox -message "no_dig_text: $no_dig_text : $text"
    set text [ string map {$no_dig_text  ""} $text ]
    tk_messageBox -message "text: $text"
    set text [ string map {" "  ""} $text ]
    tk_messageBox -message "text::: $text"
    return $text
}

proc newline_cut_to { texttrans } {
    set texttrans [ string map {";\n"   " "} $texttrans ]
    return $texttrans
}

proc my_name_translit { texttrans } {

    set texttrans [ string map {"                "  " "} $texttrans ]
    set texttrans [ string map {"        "  " "} $texttrans ]
    set texttrans [ string map {"    "  " "} $texttrans ]
    set texttrans [ string map {"  "  " "} $texttrans ]
    set texttrans [ string map {"  "  " "} $texttrans ]
    set texttrans [ string map {"  "  " "} $texttrans ]
    set texttrans [ string map {" ("   "("} $texttrans ]
    set texttrans [ string map {" )"   ")"} $texttrans ]
    set texttrans [ string map {" \n"   "\n"} $texttrans ]
    set texttrans [ string map {" ;"   ";"} $texttrans ]
    set texttrans [ string trimleft     $texttrans]
    set texttrans [ string trimright    $texttrans]
    set texttrans [ string map {" "   "_"} $texttrans ]
    set texttrans [ string map {"_("   "("} $texttrans ]

    set texttrans [ string map {"(����)"  "byte "} $texttrans ]
    set texttrans [ string map {"(���)"   "int "} $texttrans ]
    set texttrans [ string map {"(���)"   "double " } $texttrans ]
    set texttrans [ string map {"(���)"   "boolean " } $texttrans ]
    set texttrans [ string map {"(���)"   "char "   } $texttrans ]
    set texttrans [ string map {"(���)"   "char* "  } $texttrans ]
    set texttrans [ string map {"(���)"   "String " } $texttrans ]
    set texttrans [ string map {"(�����)" "const "  } $texttrans ]

    set texttrans [ string map {"(byte)"  "byte "} $texttrans ]
    set texttrans [ string map {"(int)"   "int "} $texttrans ]
    set texttrans [ string map {"(double)"  "double " } $texttrans ]
    set texttrans [ string map {"(boolean)" "boolean " } $texttrans ]
    set texttrans [ string map {"(char)"   "char "   } $texttrans ]
    set texttrans [ string map {"(char*)"  "char* "  } $texttrans ]
    set texttrans [ string map {"(String)" "String " } $texttrans ]
    set texttrans [ string map {"(const)" "const "  } $texttrans ]

    set texttrans [ string map {"+"   "_plus_"} $texttrans ]
    set texttrans [ string map {"-"   "_minus_"} $texttrans ]
    set texttrans [ string map {"*"   "_star_"} $texttrans ]
    set texttrans [ string map {"/"   "_slash_"} $texttrans ]
    set texttrans [ string map {"%"   "_perc_"} $texttrans ]

    set texttrans [ string map {" _"   " "} $texttrans ]
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

    set texttrans [ string map {"������� " "return " } $texttrans ]
    set texttrans [ string map {":=" "=" } $texttrans ]
    set texttrans [ string map {"\n" ";\n"  } $texttrans ]

    set texttrans [ string map {"== >"   ">"} $texttrans ]
    set texttrans [ string map {"== <"   "<"} $texttrans ]
    set texttrans [ string map {"== <="   "<="} $texttrans ]
    set texttrans [ string map {"== =<"   "=<"} $texttrans ]
    set texttrans [ string map {"== >="   ">="} $texttrans ]
    set texttrans [ string map {"== =>"   "=>"} $texttrans ]

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
proc mytranslit_declaration { texttrans } {
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

    set texttrans [ string map {"���������" "setup" } $texttrans ]
    set texttrans [ string map {"���������" "loop" } $texttrans ]

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
        "// Autogenerated with DRAKON Editor $version "
    puts $fhandle \
        "// Generator adopted by Bardynin Dmitry, Astrakhan-Sochi, 2019, ver.0.11"

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
        		append lines ";"
            		puts $fhandle $lines
            		puts $fhandle ""
            	   }
            }
        }

        foreach function $functions {
        	unpack $function diagram_id name signature body
       	set type [ lindex $signature 0 ]
            if  {$type != "comment" } {
                if  {$name eq "setup" || $name eq "���������" } {
         		puts $fhandle ""
         		set declaration [ build_declaration $name $signature ]
        		set declaration [ mytranslit_declaration $declaration ]
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
           	if  {$type != "comment" } {
                if  {$name eq "loop" || $name eq "���������" } {
        		puts $fhandle ""
            		set declaration [ build_declaration $name $signature ]
            		set declaration [ mytranslit_declaration $declaration ]
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
                         &&  $name !="header" &&  $name != "���������"
                         &&  $name !="���������"  && $name!="���������"} {
            		puts $fhandle ""
#############################
			set name [ my_name_translit $name ]
#############################
            		set declaration [ build_declaration $name $signature ]
            		set declaration [ mytranslit_declaration $declaration ]
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

proc rewire_wiring_pause { gdb diagram_id } {
	  # item 32
	  log "rewire: $diagram_id"
	  set starts [ $gdb eval {
	    select vertex_id
	    from vertices
	    where type = 'pause'
	    and right = ''
	    and diagram_id = :diagram_id } ]
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

	    if { [ convert2msec $text ] != "" } {
	      set new_text "delay([ convert2msec $text ]); //pause $text"
	    } else {
	      graph::p.error $diagram_id [ list $item_id ] "Pause: ������������ �������� ������ ���������: [digit_cut $text ]"
	    }

	    $gdb eval {
	      update vertices
	      set text = :new_text
	      where vertex_id = :vertex_id
	    }
	    incr _ind1734
	  }
	}

proc rewire_wiring_pause_ins { gdb diagram_id } {
	  # item 32
	  log "rewire: $diagram_id"
	  set starts [ $gdb eval {
	    select vertex_id
	    from vertices
	    where type = 'pause'
	    and up != ''
	    and right != ''
	    and diagram_id = :diagram_id } ]
	  set _col1734 $starts
	  set _len1734 [ llength $_col1734 ]
	  set _ind1734 0
	  while { 1 } {
	    if {$_ind1734 < $_len1734} {
	      } else { break }
	    set vertex_id [ lindex $_col1734 $_ind1734 ]
	    unpack [ $gdb eval {
	    select text, item_id, right
	    from vertices
	    where vertex_id = :vertex_id
	    } ] text item_id right

	    # tk_messageBox -message "text !$text!$item_id!$right!text item_id right"

	    set time_ins ""
	    if { $right != "" } {
	      set time_ins [ $gdb eval {
	        select text
	        from vertices
	        where left = :right } ]
	        # tk_messageBox -message "timer $timer "
	      }
	    set time_ins [ newline_cut $time_ins ]
	    if { [ is_dia_name $time_ins $gdb] != 1 } {
	        graph::p.error $diagram_id [ list $item_id ] "��������� \"$time_ins\" �� �������"
	    }
	    set time_ins [ my_name_translit $time_ins ]

	    # set timer [compress $timer]
	    if { [ convert2msec $text ] == "" } {
	      graph::p.error $diagram_id [ list $item_id ] "Pause_Insertion: ������������ �������� ������ ���������: [digit_cut $text ]"
	    }

	    set new_text "unsigned long delay_$item_id = millis();\n\
	    while\(\(millis\()-delay_$item_id) < [ convert2msec $text ]) \{ $time_ins\(); \}  "
	    # set new_text "// delay($text); // pause + insertion "

	    $gdb eval {
	      update vertices
	      set text = :new_text
	      where vertex_id = :vertex_id
	    }
	    incr _ind1734
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
#########################
	    set text2 [ newline_cut $text2 ]
        set s1 [string first "\(" $text2]
        if { [ is_dia_name $text2 $gdb] != 1 } {
          graph::p.error $diagram_id [ list $item_id ] "��������� \"$text2\" �� �������"
        }
        #tk_messageBox -message "text2 $text2 "
	    set text2 [ my_name_translit $text2 ]
        #tk_messageBox -message "text2 $text2 "
	    #set a [split $text2 " "]
	    #if {[lindex $a 1] != ""} {set text2 [lindex $a 1] }
# ��������� ������������ � ������
#########################

            set exper [string last ")" $text2]
            if {$exper < 0} { set new_text "$text = $text2\(); // input without parameter"
                } else { set new_text "$text = $text2; // input with parameter" }

            $gdb eval {
            	update vertices
            	set text = :new_text
            	where vertex_id = :vertex_id
            }
            incr _ind1734
        }
}

proc rewire_wiring_insertion { gdb diagram_id } {
	#item 38
	log "rewire_insertion: $diagram_id"
	set starts [ $gdb eval {
	    select vertex_id
	    from vertices
	    where type = 'insertion'
	    and up != ''
	    and diagram_id = :diagram_id } ]
	set _col1734 $starts
	set _len1734 [ llength $_col1734 ]
	set _ind1734 0
	while { 1 } {
	    if {$_ind1734 < $_len1734} {
	    } else { break }
	    set vertex_id [ lindex $_col1734 $_ind1734 ]
	    unpack [ $gdb eval {
	      select text, item_id, left
	      from vertices
	      where vertex_id = :vertex_id
	      } ] text item_id left

	    set text [ newline_cut $text ]
	    if { [ is_dia_name $text $gdb] != 1 } {
	        graph::p.error $diagram_id [ list $item_id ] "��������� \"$text\" �� �������"
	    }
	    set text [ my_name_translit $text ]
	    #set a [split $text " "]
	    #if {[lindex $a 1] != ""} {set text [lindex $a 1] }
	    #########################
	    set timer ""
	    if { $left != "" } {
	      	set timer [ $gdb eval {
	        	select text
	        	from vertices
	        	where right = :left  } ]
	        # tk_messageBox -message "timer $timer "
	    }
	    set timer [compress $timer]
	    if {$timer != ""} {
	        set val [split $timer "="]
	        set time [lindex $val 1 ]

  	        if { [ convert2msec $time ] == "" } {
    	        graph::p.error $diagram_id [ list $item_id ] "Insertion: ������������ �������� ������ ���������: [digit_cut $time ]"
	        }

	        # tk_messageBox -message "llength val [llength $val] "
	        if { [llength $val] != 2 } {graph::p.error $diagram_id [ list $item_id ] "������ � ������� �������� �������: $timer"}
  	        set new_text "//Synchronizer by timer $timer ; \nwhile \(millis\()-_timer_[lindex $val 0] < [convert2msec $time]) {} \n  $text\(); // insertion"
	    } else {
	    	set new_text "$text\(); // insertion"
	    }
	    $gdb eval {
	      	update vertices
	      	set text = :new_text
	      	where vertex_id = :vertex_id
	    }
	    incr _ind1734
	}
}

proc rewire_wiring_timer { gdb diagram_id } {
	  #item 38
	  log "rewire_timer: $diagram_id"
	  set starts [ $gdb eval {
	    select vertex_id
	    from vertices
	    where type = 'timer'
	    and diagram_id = :diagram_id } ]
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
	    set text [compress $text]
	    set val [split $text "="]
	    set time [ convert2msec [lindex $val 1 ] ]
	    set text "[lindex $val 0]=$time"
	    if { $time == "" } {
	      graph::p.error $diagram_id [ list $item_id ] "Timer: ������������ �������� ������ ���������: [digit_cut $text ]"
	    }

	    if { [llength $val] != 2 } {graph::p.error $diagram_id [ list $item_id ] "������ � ����������� �������� �������."}
	    set new_text "_timer_$text + millis\(); // Set timer $text"
	    $gdb eval {
	      update vertices
	      set text = :new_text
	      where vertex_id = :vertex_id
	    }
	    incr _ind1734
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
	  set _col1734 $starts
	  set _len1734 [ llength $_col1734 ]
	  set _ind1734 0
	  while { 1 } {
	    if {$_ind1734 < $_len1734} {
	      } else { break }
	    set vertex_id [ lindex $_col1734 $_ind1734 ]
	    unpack [ $gdb eval {
	      select text, text2, item_id, left
	      from vertices
	      where vertex_id = :vertex_id
	      } ] text text2 item_id left
	    #########################
	    set text2 [ newline_cut $text2 ]
	    if { [ is_dia_name $text2 $gdb] != 1 } {
	      graph::p.error $diagram_id [ list $item_id ] "��������� \"$text2\" �� �������"
	    }
	    set text2 [ my_name_translit $text2 ]
	    if {$text2 == ""} {set text2 "Serial.print" }
	    #set a [split $text2 " "]
	    #if {[lindex $a 1] != ""} {set text2 [lindex $a 1] }
	    #########################
	    set timer ""
	    if { $left != "" } {
	      set timer [ $gdb eval {
	        select text
	        from vertices
	        where right = :left  } ]
	        # tk_messageBox -message "timer $timer "
	    }
	    if {$timer != ""} {
	      set timer [compress $timer]
	      set val [split $timer "="]
	      set time [lindex $val 1 ]
	      if { [ convert2msec $time ] == "" } {
	        graph::p.error $diagram_id [ list $item_id ] "Output: ������������ �������� ������ ���������: [digit_cut $timer ]"
	      }
	      # tk_messageBox -message "llength val [llength $val] "
	      if { [llength $val] != 2 } {
	        graph::p.error $diagram_id [ list $item_id ] "Output: ������ � ������� �������� �������: $timer "
	      }
	      set new_text "//Synchronizer by timer $timer ; \nwhile \(millis\()-_timer_[lindex $val 0] < [ convert2msec $time ]) { } \n$text2\($text); // output"
	    } else {
	      set new_text "$text2\($text); // output"
	    }
	    $gdb eval {
	      update vertices
	      set text = :new_text
	      where vertex_id = :vertex_id
	    }
	    incr _ind1734
	  }
	}

proc rewire_wiring_process { gdb diagram_id } {
    set starts [ $gdb eval {
       	select vertex_id
       	from vertices
       	where type = 'process'
    	and diagram_id = :diagram_id } ]
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
	    set text [ my_name_translit $text ]
        set new_text "$text\($text2); // process \& command"
        $gdb eval {
          	update vertices
           	set text = :new_text
           	where vertex_id = :vertex_id
        }
        incr _ind1734
    }
}

proc rewire_wiring_if { gdb diagram_id } {
    set starts [ $gdb eval {
       	select vertex_id
       	from vertices
       	where type = 'if'
    	and diagram_id = :diagram_id } ]
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
        set text [ string map {"\?"    ""} $text ]
        set new_text "$text"
        $gdb eval {
          	update vertices
           	set text = :new_text
           	where vertex_id = :vertex_id
        }
        incr _ind1734
    }
}


proc rewire_wiring_shelf { gdb diagram_id } {
    set starts [ $gdb eval { select vertex_id from vertices
       	where type = 'shelf' and diagram_id = :diagram_id } ]
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
		set text [ newline_cut $text ]
        set new_text "$text2= $text; // shelf"
        $gdb eval {
          	update vertices set text = :new_text
           	where vertex_id = :vertex_id
        }
        incr _ind1734
    }
}

proc rewire_wiring_rem2text { gdb diagram_id } {
    set starts [ $gdb eval { select vertex_id from vertices
      where type = 'action' and diagram_id = :diagram_id } ]
    lappend starts [ $gdb eval { select vertex_id from vertices
      where type = 'insertion' and diagram_id = :diagram_id } ]
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
		if { $text2 != "" } {
			set new_text "\/* $text2 *\/ \n$text"
		    $gdb eval {
          		update vertices set text = :new_text
           		where vertex_id = :vertex_id
			}
        }
        incr _ind1734
    }
}

# ��������� ��� ����������� ����� �� ��������� �����, � ���������.
proc rewire_color { gdb diagram_id } {
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
			select text, text2, item_id, type
			from vertices
			where vertex_id = :vertex_id
		} ] text text2 item_id type
		# ������ ��������, ���� �� ������ ������
		if { $text == "" && $type != "" && $type != "case" } {
		  graph::p.error $diagram_id [ list $item_id ] "������ ������ ��� ��������� ���������. $type"
		}
		set my_names [ $db eval { SELECT color FROM items WHERE diagram_id = :diagram_id AND item_id = :item_id
			AND (type = "action" OR type = "pause" OR type = "insertion" OR type = "input" OR type = "output" OR type = "process" OR type = "shelf") } ]
		set lll [ llength [lindex $my_names 0] ]
		# ���� � ������� "�����" ���-�� ��������, �� ��������� ����
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

proc is_dia_name { name gdb} {
    #tk_messageBox -icon info -message $name -title "$name"
    set s1 [string last "\(" $name ]
    if { $s1 > 0 } { set name [string range $name 0 $s1-1] }
    set name [string trimright $name]
    set name [string trimleft $name]
    #tk_messageBox -icon info -message $name -title "$name"
    foreach names $gen_Tester::correct {
        set s1 [string first ")" $names ]
        if { $s1 > 0 } { set names [string range $names $s1+1 end] }
        set names [string trimleft $names]
        set names [string trimright $names]
        #tk_messageBox -icon info -message "name:$name*" -title "names:$names*"
        if { $names == $name } { return 1}
    }
    set names [ $gdb eval {
      SELECT name FROM diagrams WHERE name = :name
      } ]
    if { $names == ""} { return 0} else {return 1}
}

proc compress { text } {
    set text [ string map {" "   ""} $text ]
    lappend my {*}$text
    return [string trim $my " "]
}

proc convert2msec { text } {
	if { [scan $text "%d"] == 0 } { return "0" }
    set val [ digit_cut $text ]
	if { $val == "��" || $val == "����" || $val == "msec" || $val == "ms" } {
      	return "[scan $text "%d"]"
    } elseif { $val == "���" || $val == "�" || $val == "sec" || $val == "s" || $val == "c" } {
      	return "[expr [scan $text "%d"]*1000]"
    } elseif { $val == "���" || $val == "�" || $val == "min" || $val == "m" } {
      	return "[expr [scan $text "%d"]*60000 ]"
    }
}

}