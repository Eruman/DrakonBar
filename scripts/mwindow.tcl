# Main window.


namespace eval mw {

variable right_moved 0
variable canvas_width
variable canvas_height

variable picture_visible 0
variable mouse_up_data 0
variable picture_my 0
variable old_dia 0
variable new_dia 0
variable dia_tree 0

set serial_port [lindex [com_list] end]
set com ""
set longpress_timer {}
set empty_double 0		; # Двойной клик по пустому полю для скролла одной кнопкой
set dia_lock 0			; # Блокировка диаграммы (аналог нажатия кнопки Shift)
set dia_temp_lock 0		; # Блокировка диаграммы (аналог нажатия кнопки Shift)
set disconnected 0
set t0 0
set rem_visible 0
set skewer_y1 10000		; # Верхняя граница шампура
set skewer_y2 10000 	; # Верхняя граница рамки силуэта
set skewer_y3 -10000 	; # Нижняя граница шампура
set skewer_x 0 			; # Ось шампура
set loop_x1 0 			; # Граница стрелки петли
set loop_x2 0 			; # Правая граница петли
set loop_x3 0 			; # Правая граница петли
set loop_y1 0 			; # Нижняя граница петли
set loop_y2 0 			; # Верхняя граница петли
set loop_y3 0 			; # Начало петли
set loop_need 0

set variant_vertex ""
set variant_vertex_ordinal 1
set previous_vertex ""

set arrow_style 0 ; # 0 - классическое изображение, 1 - со скруглением
set gen_mode 0
set terminal_mode 0
set edit_window_geom "" 

set tree_hide 0
set generated_step 1

set repeat_probe 0
set values_probe [ list \
		{"Открыть окно [.root.pnd.right add $mw::errors_main]"} \
		{"Закрыть окно [.root.pnd.right forget $mw::errors_main]"} \
		{"SQL консоль [mwc::my_libs]"} \
		{"Log в редактор: [logg $item_id]"} \
		{"Список окон: [ mw::wlist . ]"} \
		{"Координаты на холсте: [ insp::current ]"} \
		{"Контроль касания икон: [graph2::import $mwc::db $diagram_id; graph2::icons.dont.touch] $graph2::errors"} \
		{"[set db [mwc::get_db]; $db eval {select node_id, diagram_id from tree_nodes} { logg \"$node_id: $diagram_id}\"]"} \
		{"[ mwc::change_color_q $item_id #0000ff #00ff00 ; sleep 100; mwc::clear_color_q $item_id;]"} \
		{"[set com [open COM6: r+]; fconfigure $com -mode "115200,n,8,1" -blocking 0 -buffering line;]"} \
		{"[proc moree {} { puts $mw::com "S"; after 15000 moree; }; moree]"} \
		] 


### Public ###

proc tellme {  } {
	set f [info frame -2]
	dict with f {
	switch $type {
		source {
			return "Write on line $line of $file"
		}
		proc {
			return "Write on line $line of $proc"
		}
		default {
			return "Write on line $line (>$cmd<)"
		}
	}
	}
	#tk_messageBox -message "WRITTEN FROM >[info level -1]< \n			\nCALL DETAILS: [info frame -1]";
} ; # end proc
	
proc select_listbox_item { w ordinal } {
	$w see $ordinal
	$w selection clear 0 end
	$w selection set $ordinal
	$w activate $ordinal
}

proc select_dia { diagram_id replay } {
	select_dia_kernel $diagram_id 1
	back::record $diagram_id
}

proc select_dia_kernel { diagram_id hard } {
	variable current_name


	set node_id [ mwc::get_diagram_node $diagram_id ]
	mtree::select $node_id

	mwc::fetch_view
	mv::fill $diagram_id
	update_description foo foo
	set current_name [ mwc::get_dia_name $diagram_id ]
}

proc unselect_dia { ignored replay } {
	unselect_dia_ex 0 foo
}

proc unselect_dia_ex { tree_also replay } {
	variable current_name
	set current_name ""
	if { $tree_also } {
		mtree::deselect
	}
	mv::clear
	update_description foo foo
}

proc update_description { ig1 ig2 } {
	variable dia_edit_butt
	set descr [ mwc::get_dia_description ]
	change_description $descr 1
	if { [ mwc::get_current_dia ] == "" } {
		$dia_edit_butt configure -state disabled
	} else {
		$dia_edit_butt configure -state normal
	}
}

proc enable_undo { name } {
	.mainmenu.edit entryconfigure 0 -state normal -label [ mc2 "Undo: \$name" ]
}

proc disable_undo { } {
	.mainmenu.edit entryconfigure 0 -state disabled -label [ mc2 "Undo" ]
}

proc enable_redo { name } {
	.mainmenu.edit entryconfigure 1 -state normal -label [ mc2 "Redo: \$name" ]
}

proc disable_redo {	 } {
	.mainmenu.edit entryconfigure 1 -state disabled -label [ mc2 "Redo" ]
}

proc measure_text { text } {

	set font [ mwf::get_dia_font 100 ]
	set size [ font metrics $font -linespace ]

	set lines [ split $text "\n" ]
	set max_width 0
	foreach line $lines {
		set line [ string map { "\t" "dddddddd" } $line ]
		set width [ font measure $font $line ]
		if { $width > $max_width } {
			set max_width $width
		}
	}
	set line_count [ llength $lines ]
	if { $line_count == 0 } { set line_count 1 }
	set height [ expr { int($size * 1.0) * ($line_count + 0) } ]
	return [ list $max_width $height ]
}



proc get_default_family { } {
	global main_font_family
	if { $main_font_family == "" } {
		if { [ ui::is_mac ] } {
			#return system
			return Menlo
		} elseif { [ ui::is_windows ] } {
			#return Verdana
			#return "Courier New"
			return "Lucida Console"
		} else {
			#return FreeSans
			#return FreeMono
			return "Liberation Mono"
		}
	}
	return $main_font_family
}


proc get_default_font_size { } {
	global main_font_size

	if { $main_font_size == "" } {
		set size 10
		if { [ ui::is_mac ] } {
			incr size 4
		}
	} else {
		set size $main_font_size
	}
	return $size
}

proc create_main_font { } {
	set family [ get_default_family ]
	set size [ get_default_font_size ]
#	puts "Createing main_font: -family $main_font_family -size $main_font_size"
	font create main_font -family $family -size $size
}


proc icon_separator { name } {
	set path .root.top.$name
	ttk::frame $path -width 10
	pack $path -anchor nw -side left
}

proc load_gif { filename } {
	global script_path
	set path $script_path/images/$filename
	return [ image create photo -format GIF -file $path ]
}

proc icon_button { name tooltip } {
	global script_path
	set image .img.$name
	set file $script_path/images/$name.gif
	image create photo $image -format GIF -file $file

	set path .root.top.$name
	set command [ list mwc::do_create_item $name ]
	button $path -image $image	-command $command -bd 0 -relief flat -highlightthickness 0

	pack $path -anchor nw -side left -padx 1 -pady 3
	bind_popup $path $tooltip
}



proc command_button { path image_file command tooltip } {
	global script_path
	set file $script_path/images/$image_file
	set image [ image create photo -format GIF -file $file ]

	button $path -image $image	-command $command -bd 0 -relief flat -highlightthickness 0

	pack $path -anchor nw -side left -padx 1 -pady 3
	bind_popup $path $tooltip
}


proc command_text_button { name text command tooltip } {

	set path .root.top.$name
	ttk::button $path -text $text -command $command
	pack $path -side left -padx 5
	bind_popup $path $tooltip
}




proc create_listbox { name var_name } {
	# Background frame
	frame $name -borderwidth 1 -relief sunken

	set list_path [ join [ list $name list ] "." ]
	set vscroll_path [ join [ list $name vscroll ] "." ]


	# Scrollbar.
	ttk::scrollbar $vscroll_path -command "$list_path yview" -orient vertical

	# Listbox.
	listbox $list_path -yscrollcommand "$vscroll_path set" -bd 0 -highlightthickness 0 -listvariable $var_name

	# Put the diagram list and its scrollbar together.
	grid columnconfigure $name 1 -weight 1
	grid rowconfigure $name 1 -weight 1
	grid $list_path -row 1 -column 1 -sticky nswe
	grid $vscroll_path -row 1 -column 2 -sticky ns

	return $list_path
}

proc set_status { text } {
	variable status
	$status configure -text $text
}

proc set_status2 { text } {
	variable status2
	$status2 configure -text $text
}

proc acc { button } {
	if { [ ui::is_mac ] } {
		return ""
	} else {
		return "Ctrl-$button"
	}
}

proc my_message {tt} {
tk_messageBox -icon info -message "$tt"
}

proc create_ui { } {
	variable diagram_list
	variable canvas
	variable dia_desc
	variable dia_edit_butt
	variable status
	variable status2
	variable search_main
	variable show_search
	variable needle_entry
	variable current_text
	variable search_result

	variable errors_main
	variable errors_listbox

	variable error_label


	create_main_font

	wm title . "DRAKON Editor"
	wm iconbitmap . "images/drakosha1.ico"
	wm iconbitmap . -default "images/drakosha1.ico"

	############################################
	wm state . zoomed


	# Window-wide frame
	ttk::frame .root
	pack .root -fill both -expand 1

	# Vertical splitter
	ttk::panedwindow .root.pnd -orient horizontal
	pack .root.pnd -fill both -expand 1


	# Frame at the left pane
	ttk::frame .root.pnd.left -padding "3 0 0 0"
	.root.pnd add .root.pnd.left

	# Status bar
	set status [ ttk::label .root.pnd.left.status -text "" ]
	pack $status -fill x -side bottom
	
	set status2 [ ttk::label .root.pnd.left.status2 -text "" ]
	pack $status2 -fill x -side bottom


	ttk::frame .root.pnd.left.nav
	pack .root.pnd.left.nav -anchor n -side top -fill x

	set back [ button .root.pnd.left.nav.back -image [ load_gif back.gif ] \
		-command back::come_back -bd 3 -relief flat -highlightthickness 0 ]
	bind_popup $back [ mc2 "Back" ]

	set forward [ button .root.pnd.left.nav.forward -image [ load_gif forward.gif ] \
		-command back::go_forward -bd 3 -relief flat -highlightthickness 0 ]
	bind_popup $forward [ mc2 "Forward" ]
	pack $forward -side right
	pack $back -side right

	command_button .root.pnd.left.nav.descr description.gif mwc::file_description [ mc2 "File description" ]
	ttk::button .root.pnd.left.nav.dia -text [ mc2 "New diagram" ] -command mwc::new_dia
	ttk::button .root.pnd.left.nav.folder -text [ mc2 "Folder" ] -command mwc::new_folder
	pack .root.pnd.left.nav.dia -side left
	pack .root.pnd.left.nav.folder -side left


	# Diagram list.
	set main_tree [ mtree::create .root.pnd.left.dialist mwc::current_dia_changed ]
	pack .root.pnd.left.dialist -fill both -expand 1

	# Current object description edit.
	set description_frame [ ttk::frame .root.pnd.left.description_frame ]
	set dia_edit_butt5 [ button $description_frame.dia_edit_butt5 -command { mw::change_dia_lock } -relief flat -highlightthickness 0 ]
	.root.pnd.left.description_frame.dia_edit_butt5 configure -image [ mw::load_gif shift_unpressed.gif ]	
	pack $dia_edit_butt5 -pady 1 -side left
	set dia_desc_label [ ttk::label $description_frame.dia_desc_label -text [ mc2 "Description:" ] ]
	set dia_edit_butt [ ttk::button $description_frame.dia_edit_butt -text [ mc2 "Edit..." ] -command mwc::dia_properties ]
	pack $description_frame -fill x
	pack $dia_desc_label -pady 3 -side left
	pack $dia_edit_butt -pady 3 -side right

##############################################################################################################
	if { $mwc::my_trace == 1 } {
		set dia_edit_butt3 [ ttk::button $description_frame.dia_edit_butt3 -text "REM" -command {mwc::my_rem} ]
		pack $dia_edit_butt3 -pady 1 -side right
		set dia_edit_butt4 [ ttk::button $description_frame.dia_edit_butt4 -text "DEMO" -command {mwc::my_rem2} ]
		pack $dia_edit_butt4 -pady 1 -side right
	
		set dia_edit_butt2 [ ttk::button $description_frame.dia_edit_butt2 -text "*" -command {mwc::my_list} ]
		pack $dia_edit_butt2 -pady 1 -side right
		#set dia_edit_butt5 [ ttk::button $description_frame.dia_edit_butt5 -text "!" -command {mwc::my_libs} ]	
		#pack $dia_edit_butt5 -pady 1 -side left
	} 

	set recfiles [ button .root.pnd.left.nav.recfiles -image [ load_gif recfiles.gif ] \
		-command recent::recent_files_dialog -bd 3 -relief flat -highlightthickness 0 ]
	pack $recfiles -pady 1 -side right

	set recstart [ button .root.pnd.left.nav.recstart -image [ load_gif recstart.gif ] \
		-command gen::generate -bd 3 -relief flat -highlightthickness 0 ]
	pack $recstart -pady 1 -side right

############recent::recent_files_dialog

	set dia_desc [ text .root.pnd.left.description -width 10 -height 10 \
		-highlightthickness 0 -borderwidth 1 -relief sunken -state disabled -font main_font -wrap word ]
	pack $dia_desc -fill both


	# Right pane: horizontal splitter
	ttk::panedwindow .root.pnd.right -orient vertical
	.root.pnd add .root.pnd.right

	# Right pane: list of errors
	set errors_main [ ttk::frame .root.pnd.right.errors -relief sunken -padding "1 1 1 1" ]
	set errors_info [ ttk::frame $errors_main.info -padding "3 3 3 3" -height 10 ]
	set errors_listbox [ create_listbox $errors_main.list mw::error_list ]
	$errors_listbox configure -height 8
	
	bind $errors_listbox <<ListboxSelect>> { mw::error_selected %W }

	pack $errors_info -side top -fill x  
	pack $errors_main.list -side top -fill both -expand 1

	ttk::button $errors_info.verify -text [ mc2 "Verify" ] -command mw::verify
	ttk::button $errors_info.verify_all -text [ mc2 "Verify All" ] -command mw::verify_all
	ttk::button $errors_info.hide -text [ mc2 "Hide" ] -command mw::hide_errors
	set error_label [ label $errors_info.message -textvariable mw::error_message ]
	pack $errors_info.verify -side left
	pack $errors_info.verify_all -side left
	pack $errors_info.message -side left -fill x -expand 1
	pack $errors_info.hide -side right

	# Right pane: search panel
	set search_main [ ttk::frame .root.pnd.right.search -relief sunken -padding "1 1 1 1" ] 

	ttk::frame $search_main.criteria -padding "3 3 3 3"
	grid rowconfigure $search_main 0 -weight 1
	grid columnconfigure $search_main 1 -weight 1
	grid $search_main.criteria -row 0 -column 0 -sticky nw

	set needle_label [ ttk::label $search_main.criteria.needle_label -text [ mc2 "Find:" ] ]
	set needle_entry [ ttk::entry $search_main.criteria.needle_entry -textvariable  mw::s_needle ]
	bind $needle_entry <Escape> mw::hide_search
	bind $needle_entry <Return> mw::find_all

	set replace_label [ ttk::label $search_main.criteria.replace_label -text [ mc2 "Replace:" ] ]
	set replace_entry [ ttk::entry $search_main.criteria.replace_entry -textvariable mw::s_replace ]
	bind $replace_entry <Escape> mw::hide_search

	set find_button [ ttk::button $search_main.criteria.find_button -text [ mc2 "Find All" ] -command mw::find_all ]
	set replace_all_button [ ttk::button $search_main.criteria.replace_all_button -text [ mc2 "Replace All" ] \
		-command mw::replace_all ]

	set case_check [ ttk::checkbutton $search_main.criteria.case_check -text [ mc2 "Case sensitive" ] -variable mw::s_case ]
	set whole_check [ ttk::checkbutton $search_main.criteria.whole_check -text [ mc2 "Whole word only" ] -variable mw::s_whole_word ]

	set current_radio [ ttk::radiobutton $search_main.criteria.current_radio -text [ mc2 "Current diagram" ] -variable mw::s_current_only -value current ]
	set all_radio [ ttk::radiobutton $search_main.criteria.all_radio -text [ mc2 "Entire file" ] -variable mw::s_current_only -value all ]

	grid $needle_label -row 0 -column 0 -sticky w
	grid $needle_entry -row 1 -column 0 -sticky we -columnspan 2
	grid $find_button -row 1 -column 2 -padx 3 -sticky we
	grid $replace_label -row 2 -column 0 -sticky w
	grid $replace_entry -row 3 -column 0 -sticky we -columnspan 2
	grid $replace_all_button -row 3 -column 2 -padx 3 -sticky we

	grid $case_check -row 4 -column 0 -sticky w
	grid $whole_check -row 5 -column 0 -sticky w
	grid $current_radio -row 4 -column 1 -sticky w
	grid $all_radio -row 5 -column 1 -sticky w

	set current_text [ text $search_main.criteria.current_text -height 1 -width 50 \
		-highlightthickness 0 -borderwidth 5 -relief sunken -state disabled -font main_font -wrap word ]
	grid $current_text -row 6 -column 0 -columnspan 3 -sticky nwse

	set previous_button [ ttk::button $search_main.criteria.previous_button -text [ mc2 "Previous" ] -command mw::find_previous ]
	set replace_button [ ttk::button $search_main.criteria.replace_button -text [ mc2 "Replace" ] -state disabled -command mw::replace ]
	set next_button [ ttk::button $search_main.criteria.next_button -text [ mc2 "Next" ] -command mw::find_next ]
	set hide_button [ ttk::button $search_main.criteria.hide_button -text [ mc2 "Hide" ] -command mw::hide_search ]
	grid $previous_button -row 7 -column 0 -sticky w -padx 3 -pady 3
	grid $replace_button -row 7 -column 1 -padx 3 -pady 3
	grid $next_button -row 7 -column 2 -sticky e -padx 3 -pady 3
	grid $hide_button -row 8 -column 2 -sticky e -padx 3 -pady 3

	set search_result [ create_listbox $search_main.result mw::search_result_list ]
	grid $search_main.result -row 0 -column 1 -sticky nwes
	bind $search_result <<ListboxSelect>> { mw::search_select %W }

	# Right pane: canvas
	set canvas [ canvas .root.pnd.right.canvas -bg $colors::canvas_bg -relief sunken -bd 1 -highlightthickness 0 -cursor crosshair -borderwidth 2]
	.root.pnd.right add $canvas -weight 4
	#-weight 500
	#bind_popup $canvas $::ds::myhelp
####################################################################################


	variable picture_visible
	if {$picture_visible==1} {
		set myimage [image create photo -file ./siriuloc.gif]
		set dia_desc_label2 [ ttk::label .root.pnd.right.dia_desc_label2 -image $myimage ]
		pack $dia_desc_label2 -anchor nw
	}

	# Configure the canvas.
	$canvas configure -xscrollincrement 1 -yscrollincrement 1

########################################################### addon right start
	set panel [ttk::frame .root.pnd.text -padding "3 0 0 0"]
	$panel configure -borderwidth 2 -relief sunken -width 0 
	.root.pnd add $panel 
	#pack $panel  -side right -fill y
	
	set serial .root.pnd.text.serial
	frame $serial -borderwidth 1 -relief sunken -height 10
	pack $serial -side top -expand 0 -fill x

	set name .root.pnd.text.blank
	frame $name -borderwidth 1 -relief sunken -height 1000
	pack $name -side top -expand yes -fill both 
	
	set text_path [ join [ list $name description ] "." ]
	set vscroll_path [ join [ list $name vscroll ] "." ]

	ttk::scrollbar $vscroll_path -command "$text_path yview" -orient vertical
	text $text_path -yscrollcommand "$vscroll_path set" -undo 1 -bd 0 -highlightthickness 0 -font main_font -wrap word 
	
	pack $vscroll_path -expand 0 -fill both -side right
	pack $text_path -expand 1 -fill both -side right
	
	#Хороший пример кода: http://zetcode.com/gui/tcltktutorial/menustoolbars/
	set m [menu .popupMenu  -tearoff 0 ]
	menu $m.cas -tearoff 0
	
	$m.cas add command -label "Сбросить счетчик шагов"	-underline 0 -command { set mw::generated_step 1; } 
	$m.cas add separator
	$m.cas add command -label "Счетчик шагов +1"		-underline 0 -command { incr mw::generated_step 1; } 
	$m.cas add command -label "Счетчик шагов -1"		-underline 0 -command { incr mw::generated_step -1; } 
	$m.cas add separator
	$m.cas add command -label "Отправить в COM6" -command { 
		catch { set ser [open COM6 r+]; fconfigure $ser -mode "115200,n,8,1" -blocking 0 -buffering line;}
		set data [.root.pnd.text.blank.description get 1.0 {end -1c}]
		puts $ser $data 
		return
		}
	
	$m add command -label "Копировать 	Ctrl-C" -command { tk_textCopy  .root.pnd.text.blank.description }
	$m add command -label "Вырезать		Ctrl-X" -command { tk_textCut   .root.pnd.text.blank.description }
	$m add command -label "Вставить		Ctrl-V" -command { tk_textPaste .root.pnd.text.blank.description }
	$m add separator
	$m add cascade -label "Настройки шагов " -menu $m.cas -underline 0
	$m add command -label "Создать Действие" -command { 
		tk_textCut   .root.pnd.text.blank.description 
		if {[catch {clipboard get} contents]} {
			tk_messageBox -message "There were no clipboard contents at all"
		}
		set block [ clipboard get -type STRING ]
		set ret_block "$block"
		clipboard clear ; 	clipboard append $ret_block
		tk_textPaste .root.pnd.text.blank.description
		mwc::do_create_named_item "action" "\/\/Выполнить Шаг$mw::generated_step\n$block" 
		incr mw::generated_step 1
		clipboard clear
		mwc::adjust_sizes
		mw::textSearch .root.pnd.text.blank.description "$block" search
		}
	$m add command -label "Создать Диаграмму" -command { 
		tk_textCopy   .root.pnd.text.blank.description 
		if {[catch {clipboard get} contents]} {
			tk_messageBox -message "There were no clipboard contents at all"
		}
		set block [ clipboard get -type STRING ]
		mw::textSearch .root.pnd.text.blank.description "$block" search2
		set action $block 
		set f1 [expr {[string length $action]-[string length [string map {"\{" ""} $action]]} ]
		set f2 [expr {[string length $action]-[string length [string map {"\}" ""} $action]]} ]
		set l1 [string first "\n" $block] ; decr l1
		set block [string trimleft $block]
		set block [string range $block 0 $l1 ]
		set block [string map {"\{" ""} $block ]
		set block [string map {"\{" ""} $block ]
		set type [lindex $block 0]
		if { $type == "void" } { set type ""} else { set type "($type) "}
		set b1 [string first " " $block] ; incr b1
		set b2 [string first "(" $block] ; decr b2
		set s1 [string first "(" $block] ; incr s1
		set s2 [string last ")" $block] ; decr s2
		set name  [string range $block $b1 $b2 ]
		set param [string range $block $s1 $s2 ]
		set param [string map {"," "\n"} $param ]
		set param [string trimleft $param ]
		set a1 [string first "\{" $action] ; incr a1
		set a2 [string last "\}" $action] ; decr a2
		set action [string range $action $a1 $a2 ]
		set parametries "{4 action {$param} {} {} 1 430 50 50 20 0 0} {5 horizontal {} {} {} 1 120 50 310 0 0 0}  "
		if { [string length [string trim $param]] == 0 } { set parametries ""}
		set installation "{6 action {\/\/Выполнить действия\n\n$action} {} {} 1 120 110 50 20 0 0}"

		if { $f1 != $f2 } { 
			set installation ""
			tk_messageBox -message "Тело функции не перенесено: \'N \{\' не равно \'N \}\'";
			}
		set blank "DRAKON 1.26 nodes {{
			{2 {$type$name} {0 0} {} 100.0 {
				{1 beginend {$type$name} {} {} 0 120 50 70 20 60 0} 
				{2 beginend Конец {} {} 0 120 170 50 20 60 0} 
				{3 vertical {} {} {} 0 120 70 0 80 0 0} 
				$parametries
				$installation
				} {}}} 
			{{2 0 item {} 2}}}" 
		clipboard clear ; clipboard append $blank
		mwc::paste_tree_kernel 0
		mwc::adjust_sizes
		clipboard clear
		}

	bind $text_path <ButtonRelease-3> { tk_popup .popupMenu %X %Y }
	
	ttk::entry $serial.port  -textvariable mw::serial_port
	$serial.port configure -foreground "#0000ff" -width 7
	
	ttk::button $serial.port_switch -text "." -width 1 -command {
		set port [.root.pnd.text.serial.port get ]
		if { $mw::com == "" } {
			set mw::com [open $port r+]; fconfigure $mw::com -mode "115200,n,8,1" -blocking 0 -buffering line; 
			fileevent $mw::com readable [list mw::serial_receiver $mw::com]
			.root.pnd.text.serial.port_switch configure  -text "*"
			} else {
			close $mw::com; set mw::com "";
			.root.pnd.text.serial.port_switch configure  -text "." 
		}
	}
	pack $serial.port_switch	-side left
	pack $serial.port 			-side left -fill x -expand 0
	
	ttk::entry $serial.entry
	$serial.entry configure -foreground "#0000ff"
	pack $serial.entry 			-side left -fill x -expand 1
	bind $serial.entry <Return> {
		if { [catch { puts $mw::com [.root.pnd.text.serial.entry get] } err ] } { 
			tk_messageBox -message "Канал связи не подключен!" -icon error ; logg "Доступные каналы: [com_list]"
		}
	}

	ttk::button $serial.send -text "Send" -command {
		if { [catch { puts $mw::com [.root.pnd.text.serial.entry get] } err ] } { 
			tk_messageBox -message "Канал связи не подключен!" -icon error ; logg "Доступные каналы: [com_list]"
		}
	}
	pack $serial.send 			-side right

			
	ttk::entry $panel.entry
	$panel.entry configure -foreground "#0000ff"
	pack $panel.entry -side left -fill x -expand 1
	
	ttk::button .root.pnd.text.start -text "Start as UTF" -command {
		set hfile [.root.pnd.text.entry get]
		set fileid [open $hfile w]
		fconfigure $fileid  -encoding utf-8
		set data [.root.pnd.text.blank.description get 1.0 {end -1c}]
		puts -nonewline $fileid  $data
		close $fileid
	
		set command "[auto_execok start] {} [list $hfile]"
		if { $command == {} } { return }
		if { [ catch {exec {*}$command &} err ] } {
			tk_messageBox -icon error -message "error '$err' with\n'$command'"
		}
	}
	pack .root.pnd.text.start -side right
	
	ttk::button .root.pnd.text.start2 -text "Start as ANSI" -command {
		set hfile [.root.pnd.text.entry get]
		set fileid [open $hfile w]
		set data [.root.pnd.text.blank.description get 1.0 {end -1c}]
		puts -nonewline $fileid  $data
		close $fileid
	
		set command "[auto_execok start] {} [list $hfile]"
		if { $command == {} } { return }
		if { [ catch {exec {*}$command &} err ] } {
			tk_messageBox -icon error -message "error '$err' with\n'$command'"
		}
	}
	pack .root.pnd.text.start2 -side right
	
	set panel2 [ttk::frame .root.pnd.right.text2]
	$panel2 configure -borderwidth 2 -relief sunken -height 30 
	.root.pnd.right add $panel2 
	pack $panel2 -side bottom 
	#-fill x
	
	ttk::button .root.pnd.right.text2.tree_btn -text "Text" -command {
		if {$mw::tree_hide == 0} {
			.root.pnd.right.text2.tree_btn configure -text "Tree"
			set mw::tree_hide 1
		} else {
			.root.pnd.right.text2.tree_btn configure -text "Text"
			tk_messageBox -message "[ mw::wlist . ]";
			set mw::tree_hide 0
		} ; 
	}
	
	ttk::entry $panel2.probe_view 
	$panel2.probe_view configure -foreground "#0000ff" 
	
	ttk::button $panel2.probe_btn -text "Probe" -command {
		if {$mw::repeat_probe == 0} {
			.root.pnd.right.text2.probe_btn configure -text "Stop"
			set mw::repeat_probe 1;
			mw::repeat_expr 
		} else {
			.root.pnd.right.text2.probe_btn configure -text "Probe"
			set mw::repeat_probe 0
		} ; 
	}
	

	ttk::combobox $panel2.probe_line -values $mw::values_probe 
	
	#$panel2.probe_line configure 
	#-font  -15-courier-*-*-normal-sans-*-120-*
	bind $panel2.probe_line <<ComboboxSelected>> {
		catch {
			set info1 "[expr [.root.pnd.right.text2.probe_line get]]";
		} error_message 
		if { $error_message != "" } {
			.root.pnd.right.text2.probe_view delete 0  end ;
			.root.pnd.right.text2.probe_view insert 0  $error_message   ;
		}
	}

	bind $panel2.probe_line <Return> {
		catch {
			variable db
			set diagram_id [ mwc::editor_state $mwc::db current_dia ]
			lassign [ $mwc::db eval { select item_id, type from items where diagram_id = :diagram_id and selected = 1 } ] item_id type
			set count [ llength item_selected ]

			#unset val;
			gdb eval { select * from vertices } val { set vert($val(vertex_id)) [array get val] }; unset val;
			gdb eval { select * from links where direction != "short" } val { set src($val(dst)) $val(src) }; unset val ; 
			gdb eval { select * from links where direction == "short" } val { set srt($val(dst)) $val(src) }; unset val ; 
			gdb eval { select * from vertices } val { set i2v($val(item_id)) $val(vertex_id) }; unset val; 
			gdb eval { select * from vertices } val { set v2i($val(vertex_id)) $val(item_id) }; unset val; 

   			set info1 "[expr [.root.pnd.right.text2.probe_line get]]";
   			.root.pnd.right.text2.probe_view delete 0  end ;
			.root.pnd.right.text2.probe_view insert 0  $info1  ;
			if {[.root.pnd.right.text2.probe_line get ] ni $mw::values_probe} {
				lappend  mw::values_probe [.root.pnd.right.text2.probe_line get ]
			}
			.root.pnd.right.text2.probe_line  configure -values $mw::values_probe
		} error_message 
		if { $error_message != "" } {
			.root.pnd.right.text2.probe_view delete 0  end ;
			.root.pnd.right.text2.probe_view insert 0  $error_message   ;
		}
	}
	$panel2.probe_line configure -width 100
	$panel2.probe_view configure -width 50 
	pack .root.pnd.right.text2.probe_btn -side right
	pack .root.pnd.right.text2.probe_line -side right -fill x -expand 1
	pack .root.pnd.right.text2.probe_view -side right -fill x -expand 0
	pack .root.pnd.right.text2.tree_btn -side left
	
	after 1000 { 
		pack forget .root.pnd.right.text2
		.root.pnd sashpos 1 3000 ; # Прячем панель файлов
	}
	#1100 .root.pnd.right forget $errors_main 
########################################################### addon right end
#	wm geometry . 1000x600

	# Magic command before creating menus
	#option add *tearOff 0
	# Create a context menu for the diagram list.
	menu .diapop -tearoff 0

	# Create a context menu for the canvas.
	menu .canvaspop -tearoff 0
	menu .canvaspop.inserts -tearoff 0
	menu .canvaspop.more -tearoff 0
	menu .canvaspop.more0 -tearoff 0
	menu .canvaspop.more2 -tearoff 0
	menu .canvaspop.more3 -tearoff 0
	menu .canvaspop.more4 -tearoff 0
	menu .canvaspop.links -tearoff 0

	# Main menu
	menu .mainmenu -tearoff 0
	menu .mainmenu.file -tearoff 0
	menu .mainmenu.edit -tearoff 0
	menu .mainmenu.insert -tearoff 0
	menu .mainmenu.view -tearoff 0
	menu .mainmenu.drakon -tearoff 0
	menu .mainmenu.generate -tearoff 0
	menu .mainmenu.help -tearoff 0


	.mainmenu add cascade -label [ mc2 "File" ] -underline 0 -menu .mainmenu.file
	.mainmenu add cascade -label [ mc2 "Edit" ] -underline 0 -menu .mainmenu.edit
	.mainmenu add cascade -label [ mc2 "Insert" ] -underline 0 -menu .mainmenu.insert
	.mainmenu add cascade -label [ mc2 "View" ] -underline 0 -menu .mainmenu.view
	.mainmenu add cascade -label [ mc2 "DRAKON" ] -underline 0 -menu .mainmenu.drakon
	.mainmenu add cascade -label [ mc2 "Help" ] -underline 0 -menu .mainmenu.help

	.mainmenu.help add command -label [ mc2 "About..." ] -underline 0 -command ui::show_about

	# File submenu
	.mainmenu.file add command -label [ mc2 "New..." ] -underline 0 -command mwc::create_file
	.mainmenu.file add command -label [ mc2 "Open..." ] -underline 0 -command mwc::open_file -accelerator [ acc O ]
	.mainmenu.file add command -label [ mc2 "Save as..." ] -underline 0 -command mwc::save_as
	.mainmenu.file add command -label [ mc2 "Open recent..." ] -underline 5 -command recent::recent_files_dialog
	.mainmenu.file add command -label [ mc2 "Добавить библиотеку..." ] -underline 0 -command mwc::open_lib
	.mainmenu.file add separator
	.mainmenu.file add command -label [ mc2 "File description..." ] -underline 0 -command mwc::file_description
	.mainmenu.file add command -label [ mc2 "File properties..." ] -underline 5 -command fprops::show_dialog
	.mainmenu.file add separator
	.mainmenu.file add command -label [ mc2 "Global settings..." ] -underline 0 -command gprops::show_dialog
	.mainmenu.file add separator
	.mainmenu.file add command -label [ mc2 "Export to PDF..." ] -underline 0 -command export_pdf::export
	.mainmenu.file add command -label [ mc2 "Export to PNG..." ] -underline 12 -command export_png::export
	.mainmenu.file add separator
	.mainmenu.file add command -label [ mc2 "Quit" ] -underline 0 -command exit

	# Edit submenu
	.mainmenu.edit add command -label [ mc2 "Undo" ] -underline 0 -command mwc::undo  -accelerator [ acc Z ]
	.mainmenu.edit add command -label [ mc2 "Redo" ] -underline 0 -command mwc::redo -accelerator [ acc Y ]
	.mainmenu.edit add separator
	.mainmenu.edit add command -label [ mc2 "Copy" ] -underline 0 -command { mwc::copy ignored }  -accelerator [ acc C ]
	.mainmenu.edit add command -label [ mc2 "Cut" ] -underline 1 -command { mwc::cut ignored }  -accelerator [ acc X ]
	.mainmenu.edit add command -label [ mc2 "Paste" ] -underline 0 -command { mwc::paste ignored } -accelerator [ acc V ]
	.mainmenu.edit add command -label "Дубль" -underline 0 -command { mwc::double ignored } -accelerator [ acc = ]
	.mainmenu.edit add separator
	.mainmenu.edit add command -label [ mc2 "Delete" ] -underline 0 -command { mwc::delete ignored }  -accelerator Backspace
	.mainmenu.edit add command -label [ mc2 "Tidy up all diagrams" ] -underline 3 -command { mwc::adjust_icon_sizes }
	.mainmenu.edit add command -label [ mc2 "Tidy up" ] -underline 0 -command { mwc::adjust_icon_sizes_current } -accelerator [ acc T ]

	.mainmenu.edit add separator
	.mainmenu.edit add command -label [ mc2 "Diagram description..." ] -underline 10 -command mwc::dia_properties  -accelerator [ acc D ]
	.mainmenu.edit add command -label [ mc2 "Select all" ] -underline 7 -command mwc::select_all  -accelerator [ acc A ]
	.mainmenu.edit add separator
	.mainmenu.edit add command -label [ mc2 "Find" ] -underline 0 -command mw::show_search  -accelerator [ acc F ]
	.mainmenu.edit add command -label [ mc2 "Go to diagram..." ] -underline 0 -command mwc::goto  -accelerator [ acc G ]
	.mainmenu.edit add command -label [ mc2 "Go to item..." ] -underline 6 -command mwc::goto_item  -accelerator [ acc I ]
	.mainmenu.edit add command -label [ mc2 "Go to branch..." ] -underline 6 -command mwc::go_to_branch  -accelerator [ acc B ]
	.mainmenu.edit add command -label [ mc2 "Call hierarchy..." ] -underline 7 -command hie::show -accelerator [ acc E ]

	# Insert submenu
	.mainmenu.insert add command -label [ mc2 "New diagram..." ] -underline 0 -command mwc::new_dia  -accelerator [ acc N ]
	.mainmenu.insert add command -label [ mc2 "New folder..." ] -underline 1 -command mwc::new_folder


	# View submenu
	.mainmenu.view add command -label [ mc2 "Zoom out" ] -underline 5 -command mw::zoomout -accelerator [ acc Down ]
	.mainmenu.view add command -label [ mc2 "Zoom 100%" ] -underline 5 -command mw::zoom100
	.mainmenu.view add command -label [ mc2 "Zoom in" ] -underline 5 -command mw::zoomin -accelerator [ acc Up ]
	.mainmenu.view add command -label [ mc2 "Apply zoom to all diagrams" ] -underline 0 -command mw::apply_zoom_to_all
	.mainmenu.view add separator
	.mainmenu.view add command -label [ mc2 "Home" ] -underline 2 -command mw::zoom_home
	.mainmenu.view add command -label [ mc2 "See all" ] -underline 0 -command mw::zoom_see_all
	.mainmenu.view add separator
	.mainmenu.view add command -label "TCL-терминал" -underline 0 -command { 
		if { $mw::terminal_mode == 1 } { 
			pack forget .root.pnd.right.text2 
			set mw::terminal_mode 0 
		} else  {			
			pack .root.pnd.right.text2 -side bottom -fill x 
			set mw::terminal_mode 1 
		}
	} -accelerator [ acc W ]
	.mainmenu.view add command -label "SHIFT-locker" -underline 0 -command { mw::change_dia_lock } -accelerator [ acc S ]
	.mainmenu.view add command -label "Wide border"   -underline 0 -command { ttk::style configure Sash -sashthickness 20 } 

	# DRAKON submenu
	.mainmenu.drakon add command -label [ mc2 "Verify" ] -underline 0 -command mw::verify -accelerator [ acc R ]
	.mainmenu.drakon add command -label [ mc2 "Verify All" ] -underline 7 -command mw::verify_all
	.mainmenu.drakon add separator
	.mainmenu.drakon add command -label "Просмотр кода" 		-underline 0 -command { 
		set mw::gen_mode 1 ; gen::generate; 
		if {[winfo width .] < [expr [.root.pnd sashpos 1] + 30 ] } { .root.pnd sashpos 1 [expr [.root.pnd sashpos 1] - 400 ] }
		} -accelerator [ acc M ]
	.mainmenu.drakon add command -label [ mc2 "Generate code" ] -underline 0 -command { set mw::gen_mode 0 ; gen::generate; } -accelerator [ acc B ]
	

	. configure -menu .mainmenu


	# Bind events

	#bind .mainmenu <<MenuSelect>> mw::update_menu
	#bind . <FocusIn> mw::main_focus_in
	#bind . <Destroy> mwc::save_view
	bind $main_tree [ right_up_event ] { mw::dia_popup %W %X %Y }
	bind $main_tree <Double-ButtonPress-1> { mwc::rename_dia }
	bind $dia_desc <Double-ButtonPress-1> { mwc::dia_properties }
	bind $dia_desc <Motion> {
		if { $mw::dia_lock==0} { .root.pnd.left.description_frame.dia_edit_butt5 configure -image [ mw::load_gif shift_unpressed.gif ]}
	}
###########################################################################################################
		bind $main_tree <ButtonPress-1> { 
			set mw::picture_my 1
			variable mwc::db
			set mw::old_dia [ mwc::editor_state $mwc::db current_dia]
			set mw::new_node "" 
			
		}
		bind $main_tree <Leave> { 
			if { $mw::picture_my == 1 } { 
				#mw::set_status "Переменная (leave): $mw::picture_my"
				set mw::picture_my 0
			}
		}
		bind $main_tree <ButtonRelease-1> { 
			set selection [ mtree::get_selection ]
			if { [ llength $selection ] != 1 } { return }

			set xnode_id [ lindex $selection 0 ]
			lassign [ mwc::get_node_info $xnode_id ] parent type foo diagram_id
			set xold [ mwc::get_node_text $xnode_id ]

			variable db ; graph::verify_all $mwc::db
			lassign [ $mwc::db eval {
				select type, name, diagram_id, parent
				from tree_nodes
				where node_id = :xnode_id } ] type name diagram_id parent

			#logg "node :$xnode_id \"[ mwc::get_node_text $xnode_id]\""
			#logg "type :$type"
			#logg "dia  :$diagram_id; old_dia: $mw::old_dia; "
			#logg "new_dia: $mw::new_dia; new_node: $mw::new_node"
			#logg "mark :$mark"
			#logg ""

			set x %x
			set y %y
			set W %W
			set s %s
			lassign [ insp::canvas_rect ] left top right bottom
			set cx [ expr { $x - [ winfo width .root.pnd.left ] } ] 
			set cy [ expr { $y + 36 } ] 
			set cx [ mwc::unzoom_value $cx ]
			set cy [ mwc::unzoom_value $cy ]
			set cx [ expr { $cx + $left } ] 
			set cy [ expr { $cy + $top} ] 
			insp::remember $cx $cy 
			place forget .root.ico
			
			if { $x > [winfo width .root.pnd.left] && $mw::picture_my == 3 } {
				set new [ mwc::get_node_text $mw::new_node]
				# Убрать определение типов, если есть
				if {[string first "(" $new 0 ] >=0 } {
					set s1 [string first "(" $new] ; incr s1
					set s2 [string last ")" $new] ; decr s2
					set vartype [string range $new $s1 $s2 ]
					set vartype [string trimleft $vartype  " " ]
					set new [lindex [split $new ")" ] 1 ]
					set new [string trimleft $new " " ]
					set new [string map {" " "\n"} $new]
					mwc::do_create_named_item "action" "$vartype data=$new"
					mwc::convert2input foo
					mwc::adjust_icon_sizes_current
				} else {
					set new [string map {" " "\n"} $new]
					mwc::do_create_named_item "insertion" "$new"
					mwc::adjust_icon_sizes_current
				}
				mwc::change_current_dia $mw::new_dia $mw::old_dia 1 1
			}
			set mw::picture_my 0
			mwc::current_dia_changed 
			focus .root.pnd.right.canvas
			}
		
		set mw::dia_tree $main_tree
		bind $main_tree <Motion> { 
			if { $mw::dia_lock==0} { .root.pnd.left.description_frame.dia_edit_butt5 configure -image [ mw::load_gif shift_unpressed_l.gif ]}
		
			set s %s
			set x %x
			set y %y
			set LBM_pressed [ expr {$s & 256 } ]
			
			if { $mw::picture_my>0 && $LBM_pressed == 0 } {
				set mw::picture_my 0
				place forget .root.ico
				return
			} 
			
			set external_id [mtree::get_selection]]
			if { [catch { set type [ mtree::map.get_type [mtree::get_selection]] } err ] } {
				set type ""
			}
			

			if { $mw::picture_my == 1 && $type == "item" } { 
				variable mwc::db
				set selection [ mtree::get_selection ]
				if { [ llength $selection ] == 1 } {
					set diagram_id_old [ mwc::editor_state $mwc::db current_dia ]
					set node_id [ lindex $selection 0 ]
					lassign [ mwc::get_node_info $node_id] parent type foo diagram_id
					if { $diagram_id_old == $diagram_id } { break }
					set mw::picture_my 2	
					place forget .root.ico
					after 10 {
						place .root.ico -x $x -y $y
						set mw::new_dia "$diagram_id" 
						set mw::new_node "$node_id" 
						set mw::picture_my 3
					}
				}
				set selection [ mtree::get_selection ]
			}
			if { $mw::picture_my == 3 } { 
				incr x -15
				incr y 15
				place .root.ico -x $x -y $y
			}
		}
	bind_popup $dia_desc [ mc2 "Double click to edit" ]
	#bind .popup.frame.label  <Motion> { set $ds::myhelpCounter 0 }

	bind $canvas <Configure> { mw::on_canvas_configure %w %h }
	bind $canvas <Motion> {  
			#mw::set_status2 "%x %y %s %t"
			#1		Shift
			#2 		CapsLock
			#4		Ctrl
			#8 		NumLock
			#32 	ScrollLock
			#256 	Left Button
			#512 	Middle Button
			#1024 	Right Button
			#131072 Alt
			#if { $mw::dia_lock==0} { .root.pnd.left.description_frame.dia_edit_butt5 configure -image [ mw::load_gif shift_unpressed_r.gif ]}
			catch { after cancel $mw::longpress_timer }
			set mw::longpress_timer {}

			mw::canvas_motion %W %x %y %s 
			#set mwc::shift_active [ expr {%s & 131072 }  ]
		}
	bind $canvas <ButtonPress-4> {
		set mw::longpress_timer {}
		event generate %W [ mw::right_up_event ] -x %x -y %y
	}
	bind $canvas <ButtonRelease-4> {
		#tk_messageBox -message "!!!!!!!!!!!!!!!";
		set mw::longpress_timer {}
	}

	bind $canvas <ButtonPress-1> { 
		if { $mw::empty_double == 1 } { mw::canvas_mdown %W %x %y %s; return }
		#%W configure -background  blue
		set mw::longpress_timer [after 900 {
			#event generate %W <ButtonPress-4> -x %x -y %y
			event generate %W [ mw::right_down_event ]  -x %x -y %y
			event generate %W [ mw::right_up_event ] -x %x -y %y
		}]

		wm withdraw .popup 
		mw::canvas_ldown %W %x %y %s 
		}
	bind $canvas <ButtonRelease-1> { 
		if { $mw::empty_double == 1 } { mw::canvas_scrolled %W ; return }
		#catch {
		if {![llength $mw::longpress_timer]} {
			event generate %W <ButtonRelease-4>
			#break
		}
		after cancel $mw::longpress_timer
		set mw::longpress_timer {}
		#}
		set $ds::myhelpCounter 0
		set mw::variant_vertex ""
		set mw::variant_vertex_ordinal 1
		mw::canvas_lup %W %x %y 
		graph::verify_all $mwc::db 
		set diagram_id [ mwc::editor_state $mwc::db current_dia ]
		set item_selected [ $mwc::db eval { select item_id from items where diagram_id = :diagram_id and selected = 1 } ]
		if { $item_selected != ""} { 
			lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex2
			if {[ gdb onecolumn { select count(*) from links where src = $vertex2 } ] > 1 } {
				set mw::variant_vertex $vertex2
				set mw::variant_vertex_ordinal 1
			}
		}
	}
	bind $canvas [ right_down_event ] 	{ mw::canvas_rdown %W %x %y }
	bind $canvas [ right_up_event ] 	{ mw::canvas_popup %W %X %Y %x %y }
	if { [ ui::is_windows ] || [ ui::is_mac ] } {
		bind $canvas <MouseWheel> { mw::canvas_wheel %W %D %s }
	} else {
		bind $canvas <Button-4> { mw::canvas_wheel %W 50 %s }
		bind $canvas <Button-5> { mw::canvas_wheel %W -50 %s }
	}
	bind $canvas [ middle_down_event ] { mw::canvas_mdown %W %x %y %s }
	bind $canvas [ middle_up_event ] { mw::canvas_scrolled %W }
	bind $canvas <Down> { mw::select_next_item_on_canvas ; break }
	bind $canvas <Up> 	{ mw::select_prev_item_on_canvas ; break }
	bind $canvas <Right> 	{ mw::select_right_item_on_canvas ; break}
	bind $canvas <Left> 	{ mw::select_left_item_on_canvas ; break}
	bind $canvas <Return> 	{ mw::edit_selected_item_on_canvas }

	bind $canvas <KeyPress> { mw::canvas_key_press %W %K %N %k 	}
	bind $canvas <Shift-KeyPress> { mw::canvas_shift_key_press %W %K %N %k }

	bind $canvas <Double-ButtonPress-1> { mw::canvas_dclick %W %x %y }
	if { [ ui::is_mac ] } {
		bind $canvas <Double-ButtonPress-3> { mw::zoom_see_all }
	} else {
		bind $canvas <Double-ButtonPress-2> { mw::zoom_see_all }
	}
	bind $canvas <Leave> insp::reset

	bind_shortcut . mw::shortcut_handler
	bind_shortcut $canvas mw::canvas_shortcut_handler
	if { [ ui::is_mac ] } {
		bind . <Command-Shift-KeyPress> { mw::shift_ctrl_handler %k }
	}
	
	canvas .root.ico -width 31 -height 16 -bg $colors::canvas_bg -relief flat -bd 0 -highlightthickness 0
	.root.ico create image 15 8 -image [ load_gif insertion_dragged.gif ] 
	bind .root.ico <ButtonRelease-1>   { set mw::picture_my 0 ; place forget .root.ico }
	
}

proc repeat_expr {} {
	if { $mw::repeat_probe == 1 } {
		catch {
			variable db
			set diagram_id [ mwc::editor_state $mwc::db current_dia ]
			lassign [ $mwc::db eval { select item_id, type from items where diagram_id = :diagram_id and selected = 1 } ] item_id type
			set count [ llength item_selected ]

			gdb eval { select * from vertices } val { set vert($val(vertex_id)) [array get val] }; unset val;
			gdb eval { select * from links where direction != "short" } val { set src($val(dst)) $val(src) }; unset val ; 
			gdb eval { select * from links where direction == "short" } val { set srt($val(dst)) $val(src) }; unset val ; 
			gdb eval { select * from vertices } val { set i2v($val(item_id)) $val(vertex_id) }; unset val; 
			gdb eval { select * from vertices } val { set v2i($val(vertex_id)) $val(item_id) }; unset val; 

   			set info1 "[expr [.root.pnd.right.text2.probe_line get]]";
   			.root.pnd.right.text2.probe_view delete 0  end ;
			.root.pnd.right.text2.probe_view insert 0  $info1  ;
		} error_message 
		if { $error_message != "" } {
			.root.pnd.right.text2.probe_view delete 0  end ;
			.root.pnd.right.text2.probe_view insert 0  $error_message   ;
		}
		after 300 mw::repeat_expr	
	}
}

proc get_filename { } {
  variable filename_tail
  return $filename_tail
}

proc title { filename } {
  variable filename_tail
	set filename_tail [ file tail $filename ]
	wm title . "$filename_tail - DRAKON Editor \(experimental\)"
}


proc main_font_measure { text } {
	return [ font measure main_font $text ]
}

### Private ###

# Previous mouse position
variable mouse_x0 0
variable mouse_y0 0

# The list of diagrams.
variable diagram_list { }

array set names {}


variable canvas <bad-canvas>
variable dia_desc <bad-dia_desc>
variable dia_edit_butt <bad-dia_edit_butt>
variable status <bad-status>
variable status2 <bad-status>
variable filename_tail
variable search_result <bad-list>
variable search_result_list {}
variable current_text <bad-current-text>
variable s_needle ""
variable s_replace ""
variable s_case 0
variable s_whole_word 0
variable s_current_only current
variable s_on 0
variable search_main
variable show_search
variable needle_entry

variable current_name ""

variable error_list {}
variable error_message ""
variable errors_visible 0
variable errors_main
variable errors_listbox
variable error_label

proc replace_all { } {
	variable s_needle
	variable s_case
	variable s_whole_word
	variable s_current_only
	variable search_result_list
	variable search_result
	variable s_replace

	if { $s_needle == "" } {
		set_status [ mc2 "Search string is empty." ]
		return
	}

	if { [ string trim $s_needle ] == "" && $s_whole_word } {
		set_status [ mc2 "Search string is empty." ]
		return
	}
	mwc::save_view

	set db $mwc::db
	set diagram_id [ mwc::editor_state $db current_dia ]
	if { $s_current_only == "current" } {
		set current_only 1
	} else {
		set current_only 0
	}

	set ignore_case [ expr { !$s_case } ]
	search::init $db
	set count [ search::replace_all $db $s_needle $diagram_id $current_only \
		 $s_whole_word $ignore_case $s_replace ]
	set search_result_list {}

	if { $count == 0 } {
		set message [ mc2 "Nothing found." ]
	} elseif { $count == 1 } {
		set message [ mc2 "1 match replaced." ]
	} else {
		set message [ mc2 "\$count replacements done." ]
	}
	set_status [ mc2 "\$message \(Diagram names were not changed.\)" ]
	show_result_line ""
}

proc find_references { } {
	variable s_needle
	variable s_case
	variable s_whole_word
	variable s_current_only

	set selection [ mtree::get_selection ]
	set node_id [ lindex $selection 0 ]
	set name [ mwc::get_node_text $node_id ]
	show_search

	set s_needle $name
	set s_case 1
	set s_whole_word 1
	set s_current_only all

	find_all
}

proc find_all { } {
	variable s_needle
	variable s_case
	variable s_whole_word
	variable s_current_only
	variable search_result_list
	variable search_result

	if { $s_needle == "" } {
		set_status [ mc2 "Search string is empty." ]
		return
	}

	if { [ string trim $s_needle ] == "" && $s_whole_word } {
		set_status [ mc2 "Search string is empty." ]
		return
	}
	mwc::save_view

	set db $mwc::db
	set diagram_id [ mwc::editor_state $db current_dia ]
	if { $s_current_only == "current" } {
		set current_only 1
	} else {
		set current_only 0
	}

	set ignore_case [ expr { !$s_case } ]
	search::init $db
	if { ![ search::find_all $db $s_needle $diagram_id $current_only $s_whole_word $ignore_case ] } { return }

	set search_result_list [ search::get_list ]
	set count [ search::get_match_count ]

	if { $count == 0 } {
		set_status [ mc2 "Nothing found." ]
	} elseif { $count == 1 } {
		set_status [ mc2 "1 match found." ]
	} else {
		set_status [ mc2 "\$count matches found." ]
	}

	if { $count != 0 } {
		select_listbox_item $search_result 0
		show_match
		make_alternate_lines $search_result
	} else {
		show_result_line ""
	}

}

proc replace { } {
	variable s_replace
	set match [ search::get_current_match ]
	if { $match == "" } {
		set_status [ mc2 "Nothing to replace." ]
		return
	}
	set success [ search::replace $s_replace ]
	if { $success } {
		if { ![ find_next ] } {
			show_result_line ""
		}
	} else {
		set_status [ mc2 "Nothing replaced." ]
	}
}

proc find_next { } {
	variable search_result
	if { [ search::next ] } {
		set ordinal [ search::get_current_list_item ]
		select_listbox_item $search_result $ordinal
		show_match
		return 1
	}
	return 0
}

proc find_previous { } {
	variable search_result
	if { [ search::previous ] } {
		set ordinal [ search::get_current_list_item ]
		select_listbox_item $search_result $ordinal
		show_match
	}
}

proc show_match { } {
	set match [ search::get_current_match ]
	if { $match != "" } {
		set match_object [ search::get_match_object ]
		lassign $match_object type id
		if { $type == "icon" || $type == "secondary" } {
			mwc::switch_to_item $id
		} elseif { $type == "diagram_name" || $type == "diagram_description" } {
			mwc::switch_to_dia $id
		}
	}
	update
	show_result_line $match
}

proc show_result_line { match } {
	variable current_text
	variable search_main

	$current_text configure -state normal
	$current_text  delete 1.0 end

	if { $match != "" } {
		set text [ lindex $match 0 ]

		$current_text  insert 1.0 $text

		set active [ lindex $match 1 ]
		if { [ llength $active ] != 0 } {
			lassign $active start length
			set end [ expr { $start + $length } ]
			set middle [ expr { $start + $length / 2 } ]

			$current_text tag add active 1.$start 1.$end
			$current_text tag configure active -background "#ffaa00"
			$current_text see 1.$middle
		}

		set back [ lindex $match 2 ]
		foreach item $back {
			lassign $item start length
			set end [ expr { $start + $length } ]

			$current_text tag add back 1.$start 1.$end
			$current_text tag configure back -background "#cacaff"
		}

		$search_main.criteria.replace_button configure -state normal
	} else {
		$search_main.criteria.replace_button configure -state disabled
	}

	$current_text configure -state disabled
}

proc search_select { w } {
	variable current_text

	set current [ $w curselection ]
	if { $current == "" } { return }

	search::set_current_list_item $current
	show_match
}

proc hide_search { } {
	variable search_main
	variable s_on
	variable show_search

	set s_on 0
	.root.pnd.right forget $search_main
	#$show_search configure -text "Search"
}

proc show_search { } {
	variable search_main
	variable s_on
	variable show_search
	variable needle_entry

	if { !$s_on } {
		set s_on 1
		.root.pnd.right insert 0 $search_main -weight 30
		#$show_search configure -text "Hide search"
		update
		focus $needle_entry
	}
}

proc show_hide_search { } {
	variable search_main
	variable s_on
	variable show_search
	variable needle_entry

	if { $s_on } {
		hide_search
	} else {
		show_search
	}

}


# Color the list backgrounds with color stripes.
proc make_alternate_lines { list } {
	set last [ expr [ $list index end ] - 1 ]
	for { set i $last } { $i >= 0 } { incr i -1 } {
		$list itemconfigure $i -background "#ffffff"
	}
	for { set i $last } { $i >= 0 } { incr i -2 } {
		$list itemconfigure $i -background "#f0f0ff"
	}
}


proc bind_shortcut { window handler } {
	if { [ ui::is_mac ] } {
		set event <Command-KeyPress>
	} else {
		set event <Control-KeyPress>
	}
	bind $window $event [ list $handler $window %k %K ]
}


proc shift_ctrl_handler { code } {
	array set codes [ ui::key_codes ]
	if { $code == $codes(z) || $code == 393306 } {
		mwc::redo
	}
}

proc shortcut_handler { window code key } {
######################################
	set db $mwc::db
	set diagram_id [ mwc::editor_state $db current_dia ]
	set items_data [ mwc::get_items_to_copy $diagram_id 1 ]
	set key [ string tolower $key ]
	array set codes [ ui::key_codes ]
	#BackSpace
	if { $code == $codes(y) || $key == "y"} {
		mwc::redo
	} elseif { $code == $codes(z) || $key == "z" } {
		mwc::undo
	} elseif { $code == $codes(f) || $key == "f" } {
		show_hide_search
	} elseif { $code == $codes(r) || $key == "r" } {
		verify
	} elseif { $code == $codes(Up) } {
		zoomin
	} elseif { $code == $codes(Down) } {
		zoomout
	} elseif { $code == $codes(Left) } {
		back::come_back
	} elseif { $code == $codes(Right) } {
		back::go_forward
	} elseif { $code == $codes(n) || $key == "n" } {
		mwc::new_dia
	} elseif { $code == $codes(o) || $key == "o" } {
		mwc::open_file
	} elseif { $code == $codes(d) || $key == "d" } {
		if { [ llength $items_data ] != 0 } {
			mwc::double {}
		} else {
			mwc::dia_properties
		}
	} elseif { $code == $codes(g) || $key == "q" } {
		mwc::convert2magic_all {}
	} elseif { $code == $codes(g) || $key == "g" } {
		mwc::goto
	} elseif { $code == $codes(i) || $key == "i" } {
		mwc::goto_item
	} elseif { $code == $codes(e) || $key == "e" } {
		hie::show
	} elseif { $code == $codes(b) || $key == "b" } {
		set mw::gen_mode 1 ; gen::generate;
	} elseif { $code == $codes(m) || $key == "m" } {
		set mw::gen_mode 1 ; gen::generate;
	} elseif { $code == $codes(t) || $key == "t" } {
		mwc::adjust_icon_sizes_current
	} elseif { $code == $codes(t) || $key == "w" } {
		pack .root.pnd.right.text2 -side bottom -fill x 
		set mw::terminal_mode 1 
	} elseif { $code == $codes(t) || $key == "s" } {
		mw::change_dia_lock
	}
}

proc canvas_shortcut_handler { window code key } {
	set key [ string tolower $key ]
	array set codes [ ui::key_codes ]
	if { $code == $codes(a) || $key == "a" } {
		mwc::select_all
	} elseif { $code == $codes(x) || $key == "x"  } {
		mwc::cut foo
	} elseif { $code == $codes(c) || $key == "c"  } {
		mwc::copy foo
	} elseif { $code == $codes(v) || $key == "v"  } {
		mwc::paste foo
	}
}


###	 Keyboard and mouse state queries ###

proc normalize_wheel { raw_delta } {
	global tcl_platform
	if { ![ ui::is_mac ] } {
		set amount [ expr -$raw_delta ]
	} else {
		set amount [ expr -$raw_delta * 50 ]
	}
	return $amount
}

proc right_down_event { } {
	global tcl_platform
	if { ![ ui::is_mac ] } {
		return <ButtonPress-3>
	} else {
		return <ButtonPress-2>
	}
}

proc right_up_event { } {
	global tcl_platform
	if { ![ ui::is_mac ] } {
		return <ButtonRelease-3>
	} else {
		return <ButtonRelease-2>
	}
}


proc middle_down_event { } {
	global tcl_platform
	if { ![ ui::is_mac ] } {
		return <ButtonPress-2>
	} else {
		return <ButtonPress-3>
	}
}

proc middle_up_event { } {
	global tcl_platform
	if { ![ ui::is_mac ] } {
		return <ButtonRelease-2>
	} else {
		return <ButtonRelease-3>
	}
}


proc left_button_pressed { state } {
	return [ flag_on $state 256 ]
}

proc control_pressed { state } {
	log $state
	if { [ ui::is_windows ] } {
		return [ expr { $state == 12 } ]
	} else {
		return [ expr { $state == 4 || $state == 8 || $state == 20 } ]
	}
}



proc right_button_pressed { state } {
	global tcl_platform
	if { ![ ui::is_mac ] } {
		set button 1024
	} else {
		set button 512
	}
	return [ flag_on $state $button ]
}

proc middle_button_pressed { state } {
	global tcl_platform
	if { ![ ui::is_mac ] } {
		set button 512
	} else {
		set button 1024
	}
	return [ flag_on $state $button ]
}

proc shift_pressed { state } {
	return [ flag_on $state 1 ]
}

proc remember_mouse { x y } {
	variable mouse_x0
	variable mouse_y0
	set mouse_x0 $x
	set mouse_y0 $y
}

proc get_dx { x } {
	variable mouse_x0
	return [ expr { $x - $mouse_x0 } ]
}

proc get_dy { y } {
	variable mouse_y0
	return [ expr { $y - $mouse_y0 } ]
}

proc change_description { new replay } {
	variable dia_desc


	$dia_desc configure -state normal
	$dia_desc  delete 1.0 end
	$dia_desc  insert 1.0 $new
	$dia_desc configure -state disabled
}

proc update_menu { } {
	set copy 3
	set cut 4
	set paste 5
	set delete 7
	set edit 9
	set all 10
	if { [ can_paste_items ] } {
		.mainmenu.edit entryconfigure $paste -state normal
	} else {
		.mainmenu.edit entryconfigure $paste -state disable
	}

	if { [ mwc::has_selection ] } {
		.mainmenu.edit entryconfigure $copy -state normal
		.mainmenu.edit entryconfigure $cut -state normal
		.mainmenu.edit entryconfigure $delete -state normal
	} else {
		.mainmenu.edit entryconfigure $copy -state disabled
		.mainmenu.edit entryconfigure $cut -state disabled
		.mainmenu.edit entryconfigure $delete -state disabled
	}

	if { [ mwc::get_current_dia ] == "" } {
		.mainmenu.edit entryconfigure $edit -state disabled
		.mainmenu.edit entryconfigure $all -state disabled
	} else {
		.mainmenu.edit entryconfigure $edit -state normal
		.mainmenu.edit entryconfigure $all -state normal
	}
}

proc add_insert_item { menu name text } {
	global script_path
	set image .ins.$name
	set file $script_path/images/$name.gif
	image create photo $image -format GIF -file $file


	set command [ list mwc::do_create_item $name ]
	$menu add command -label $text -command $command -image $image -compound left
}

####################################################################################
proc add_insert_named_item { menu name text } {
	global script_path
	set image .ins.$name
	set file $script_path/images/$name.gif
	image create photo $image -format GIF -file $file

	set command [ list mwc::do_create_named_item $name $text]
	$menu add command -label $text -command $command -image $image -compound left
}



proc canvas_popup { window x_world y_world x y } {
	variable right_moved
	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]
	if { [ focus ] == "" } {
		return
	}

	if { $right_moved > 3 } { return }

	.canvaspop delete 0 1000
	.canvaspop.inserts delete 0 1000
	.canvaspop.more delete 0 1000
	.canvaspop.more0 delete 0 1000
	.canvaspop.more2 delete 0 1000
	.canvaspop.more3 delete 0 1000
	.canvaspop.more4 delete 0 1000
	.canvaspop.links delete 0 1000



	lassign [ mwc::get_context_inserts ] inserts more more0 more2
	#tk_messageBox -message "<inserts>$inserts<more>$more<more2>$more2"
	set commands [ mwc::get_context_commands $cx $cy ]
	if { [ llength $commands ] == 0 } { return }

	.canvaspop add cascade -label [ mc2 "Insert" ] -underline 0 -menu .canvaspop.inserts
	.canvaspop add cascade -label [ mc2 "Insert more" ] -underline 0 -menu .canvaspop.more
	foreach insert $inserts {
		lassign $insert type icon_type text
		if { $type == "separator" } {
			.canvaspop.inserts add separator
		} else {
			add_insert_item .canvaspop.inserts $icon_type $text
		}

	}

##############################################################################################
	set nn 0
	foreach insert $more {
		lassign $insert type icon_type text
		if { $type == "separator" } {
			.canvaspop.more add separator
		} else {
			add_insert_item .canvaspop.more $icon_type $text
			if {$nn == 0} {
				#tk_messageBox -message "hit_type !$icon_type<text>$text<nn>$nn<more2>$more2<ins>$insert "
				.canvaspop.more add cascade -label "$text с именем" -underline 0 -menu .canvaspop.more$nn
				foreach insert $more0 {
					lassign $insert type icon_type text
					if { $type == "separator" } {
						.canvaspop.more$nn add separator
					} else {
						add_insert_named_item .canvaspop.more$nn $icon_type $text
					}
				}
 			}
			incr nn
		}

	}


	foreach command $commands {
		set type [ lindex $command 0 ]
		if { $type == "separator" } {
			.canvaspop add separator
		} else {
			set text [ lindex $command 1 ]
			set state [ lindex $command 2 ]
			set procedure [ lindex $command 3 ]
			set proc_arg [ lindex $command 4 ]

			set callback [ list $procedure $proc_arg ]
			.canvaspop add command -label $text -state $state -command $callback
		}
	}
	.canvaspop add separator
	.canvaspop add command -label [ mc2 "Home" ] -command mw::zoom_home
	.canvaspop add command -label [ mc2 "Zoom 100%" ] -command mw::zoom100
	.canvaspop add command -label [ mc2 "See all" ] -command  mw::zoom_see_all


	set links [ mwc::get_links $cx $cy ]

	if { $links != {} } {
		.canvaspop add cascade -label [ mc2 "Links" ] -underline 0 -menu .canvaspop.links
		foreach link $links {
			.canvaspop.links add command -label $link -command [ list mw::run_url $link ]
		}
	}


	lassign [ adjust_popup_pos $window .canvaspop $x_world $y_world $x $y ] \
		x2 y2

	tk_popup .canvaspop $x2 $y2
}

proc run_url { url } {
	if { [ ui::is_mac ] } {
		set command [ list open $url ]
	} elseif { [ ui::is_windows ] } {
		set command "[auto_execok start] {} [list $url]"
	} else {
		set command [ list xdg-open $url ]
	}

	if { $command == {} } { return }
	if { [ catch {exec {*}$command &} err ] } {
	  tk_messageBox -icon error -message "error '$err' with\n'$command'"
	}
}

proc adjust_popup_pos { window popup x_world y_world x y } {
	update
	set p_width [ winfo reqwidth $popup ]
	set p_height [ winfo reqheight $popup ]

	set w_width [ winfo width $window ]
	set w_height [ winfo height $window ]

	set p_bottom [ expr { $y + $p_height } ]
	if { $p_bottom > $w_height } {
		set y_out [ expr { $y_world - $p_height } ]
	} else {
		set y_out $y_world
	}
	return [ list $x_world $y_out ]
}

proc dia_popup { window x_world y_world } {
	if { [ focus ] == "" } { return }
	.diapop delete 0 1000

	set selection [ mtree::get_selection ]
	set count [ llength $selection ]
	set has_selection [ expr { $count > 0 } ]
	set one [ expr { $count == 1 } ]

	set diagram_selected 0
	if { $one } {
		set node_id [ lindex $selection 0 ]
		lassign [ mwc::get_node_info $node_id ] parent type name diagram_id
		if { [ mwc::is_diagram $type ] } {
			set diagram_selected 1
		}
	}

	set paste [ can_paste_nodes ]


	if { $one } {
		if { $diagram_selected } {
			.diapop add command -label [ mc2 "Find all references" ] -command mw::find_references
		} else {
			.diapop add command -label [ mc2 "Collapse" ] -command mtree::collapse
			.diapop add separator
			.diapop add command -label [ mc2 "New diagram inside this folder..." ] -command mwc::new_dia_here
			.diapop add command -label [ mc2 "New folder inside this folder..." ] -command mwc::new_folder_here
		}
	}

	.diapop add command -label [ mc2 "New diagram..." ] -command mwc::new_dia
	.diapop add command -label [ mc2 "New folder..." ] -command mwc::new_folder
	######################################################################################## go dedit
	.diapop add command -label [ mc2 "New Library..." ] -command mwc::new_library

	if { $has_selection } {
		.diapop add separator
		.diapop add command -label [ mc2 "Copy" ] -command mwc::copy_tree
		.diapop add command -label [ mc2 "Cut" ] -command mwc::cut_tree
	}

	if { $paste } {
		.diapop add command -label [ mc2 "Paste" ] -command mwc::paste_tree
		if { $one && !$diagram_selected } {
			.diapop add command -label [ mc2 "Paste inside this folder" ] -command mwc::paste_tree_here
		}
	}


	if { $diagram_selected } {
		.diapop add separator
		.diapop add command -label [ mc2 "Description..." ] -command mwc::dia_properties
	}

	if { $one } {
		if { !$diagram_selected } {
			.diapop add separator
		}
		.diapop add command -label [ mc2 "Rename..." ] -command mwc::rename_dia
	}

	if { $has_selection } {
		.diapop add separator
		.diapop add command -label [ mc2 "Delete" ] -command mwc::delete_tree_items
	}

	if { $diagram_selected } {
		.diapop add separator
		.diapop add command -label [ mc2 "Export to PDF..." ] -command export_pdf::export
		.diapop add command -label [ mc2 "Export to PNG..." ] -command export_png::export
	}

	if { $has_selection } {
		.diapop add command -label [ mc2 "Copy diagram names" ] -command mwc::copy_dia_names
	}

	if { $one } {
#		.diapop add separator
#		.diapop add command -label [ mc2 "Копировать 'Вставка'" ] -command mwc::copy_dia_names2
#		.diapop add command -label [ mc2 "Копировать 'Ввод'" ] -command mwc::copy_dia_names4
#		.diapop add command -label [ mc2 "Копировать 'Вывод'" ] -command mwc::copy_dia_names3
	}

	tk_popup .diapop $x_world $y_world
}

proc edit { } {
	puts edit
}

proc canvas_scrolled { window } {
	set x [ $window canvasx 0 ]
	set y [ $window canvasy 0 ]
	mwc::scroll $x $y
}

proc scroll { scr replay } {
	variable canvas

	if { $replay } {
		set x [ lindex $scr 0 ]
		set y [ lindex $scr 1 ]

		set x0 [ $canvas canvasx 0 ]
		set y0 [ $canvas canvasy 0 ]
		set dx [ expr { int($x - $x0) } ]
		set dy [ expr { int($y - $y0) } ]

		$canvas xview scroll $dx units
		$canvas yview scroll $dy units
	}
}


proc update_cursor { cursor } {
  variable canvas
  switch $cursor {
    "item" {
      set c fleur
    }
    "handle" {
      set c hand2
    }
	"box" {
      set c draped_box
    }
    "icon" {
      set c icon
    }
    default {
      set c arrow
    }
  }
  $canvas configure -cursor $c
}

proc canvas_motion { window x y s } {
	variable right_moved
	global g_loaded
	if { !$g_loaded } { return }
	set dx [ mw::get_dx $x ]
	set dy [ mw::get_dy $y ]
	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]

	mw::remember_mouse $x $y

	set args [ list $x $y $cx $cy $dx $dy ]

	set shift [ shift_pressed $s ]
	if { [ mw::left_button_pressed $s ] } {
		if { [ mw::right_button_pressed $s ] || $mw::empty_double == 1 } {
			set movement [ expr { abs($dx) + abs($dy) } ]
			incr right_moved $movement
			scroll_canvas $window $dx $dy
		} else {
			mwc::lmove $args
		}
	} elseif { [ mw::middle_button_pressed $s ] } {
		scroll_canvas $window $dx $dy
	} elseif { [ mw::left_button_pressed $s ] && $mw::empty_double == 1 } {
		scroll_canvas $window $dx $dy
	} elseif { ![ mw::right_button_pressed $s ] } {
		mwc::hover $cx $cy $shift
	}
}

proc scroll_canvas { canvas dx dy } {
	$canvas xview scroll [ expr -$dx ] units
	$canvas yview scroll [ expr -$dy ] units
}

proc canvas_rect { } {
	variable canvas_width
	variable canvas_height
	variable canvas
	set left [ $canvas canvasx 0 ]
	set top [ $canvas canvasy 0 ]
	set right [ expr { $left + $canvas_width } ]
	set bottom [ expr { $top + $canvas_height } ]

	return [ list $left $top $right $bottom ]
}

proc canvas_shift_key_press { window k n code } {
	array set codes [ ui::key_codes ]

	if { $code == $codes(Up) } {

	} elseif { $code == $codes(Down) } {

	} elseif { $code == $codes(Left) } {

	} elseif { $code == $codes(Right) } {

	}
}

proc canvas_key_press { window k n code } {

	set items {
		a action
		n insertion
		g beginend
		v vertical
		h horizontal
		i if
		r arrow
		l loopstart
		e loopend
		s select
		c case
		b branch
		d address
		f shelf
		p pause
		o output
		u input
	}

	set low [ string tolower $k ]

	if { [ dict exists $items $low ] } {
		set command [ dict get $items $low ]
		mwc::do_create_item $command
		return
	}


	array set codes [ ui::key_codes ]
	if { $k == "Delete" } {
		mwc::delete foo
	} elseif { $k == "BackSpace" } {
		mwc::delete foo
	} elseif { $k == "Escape" } {
		back::come_back
	} elseif { $k == "Home" } {
		mw::zoom_home
	} elseif { $k == "End" } {
		mw::zoom_see_all
	} else {
		if { $code == $codes(Up) } {

		} elseif { $code == $codes(Down) } {

		} elseif { $code == $codes(Left) } {

		} elseif { $code == $codes(Right) } {

		} elseif { $code == $codes(F2) } {
			mwc::request_text_change 1
		} elseif { $code == $codes(F3) } {
			mwc::request_text_change 0
		} elseif { $code == $codes(space) } {

		}

		foreach { shortcut command } $items {
			if { $code == $codes($shortcut) } {
				mwc::do_create_item $command
				return
			}
		}
	}
}

proc unpack_items { content expected_type } {
	if { [ llength $content ] != 4 } { return {} }
	lassign $content signature version type items_data
	if { $signature != "DRAKON" } { return {} }
	if { $version != [ version_string ] } { return {} }
	if { $type != $expected_type } { return {} }
	return $items_data
}


proc can_paste { expected_type } {
	if { [catch {
		set content [ clipboard get -type STRING ]
		set items_data [ unpack_items $content $expected_type ]
		} catch_result ]} {
		return 0
	}

	return [ llength $items_data ]
}


proc clipboard_type { } {
	return UTF8_STRING
}

proc put_to_clipboard { items_data type } {
	set content_list [ list DRAKON [ version_string ] $type $items_data ]
	set content " $content_list "
	clipboard clear
	clipboard append -type STRING -format [ clipboard_type ] -- $content
}

proc put_text_to_clipboard { text } {
	set content "$text"
	clipboard clear
	clipboard append -type STRING -format [ clipboard_type ] -- $content
}

proc take_from_clipboard { type } {
	if {[catch {
		set content [ clipboard get -type STRING ]
		set items_data [ unpack_items $content $type ]  } catch_result ] } {
		return {}
	}
	return $items_data
}

proc put_items_to_clipboard { items_data } {
	put_to_clipboard $items_data "items"
}


proc take_items_from_clipboard { } {
	return [ take_from_clipboard "items" ]
}

proc can_paste_items { } {
	return [ can_paste "items" ]
}

proc put_nodes_to_clipboard { node_data } {
	put_to_clipboard $node_data "nodes"
}


proc take_nodes_from_clipboard { } {
	return [ take_from_clipboard "nodes" ]
}

proc can_paste_nodes { } {
	return [ can_paste "nodes" ]
}


proc canvas_dclick { window x y } {
	focus $window
	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]

	mwc::double_click $cx $cy
}

proc canvas_mdown { window x y s } {
	focus $window
	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]

	mw::remember_mouse $x $y
}

proc is_in_right_bottom { x y } {
	variable canvas_width
	variable canvas_height

	set xd [ expr { $canvas_width - $x } ]
	set yd [ expr { $canvas_height - $y } ]


	if { $xd < 20 && $yd < 20 } { return 1 }

	return 0
}

proc canvas_ldown { window x y s } {

	global g_loaded
	if { !$g_loaded } { return }

	if { [ is_in_right_bottom $x $y ] } { return }

	focus $window
	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]

	mw::remember_mouse $x $y

	set args [ list $x $y $cx $cy ]
	set ctrl [ control_pressed $s ]
	set shift [ shift_pressed $s ]
	mwc::ldown $args $ctrl $shift
}

proc canvas_rdown { window x y } {
	variable right_moved
	global g_loaded


	set right_moved 0

	if { !$g_loaded } { return }


	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]

	mwc::rdown $cx $cy
}

proc canvas_lup { window x y } {
	
	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]

	set args [ list $x $y $cx $cy ]
	mwc::lup $args

}

proc canvas_rclick { window x y }	 {
	variable right_moved

	if { $right_moved } { return }

	set cx [ $window canvasx $x ]
	set cy [ $window canvasy $y ]

	set args [ list $x $y $cx $cy ]
	mwc::rclick $args
}

proc on_canvas_configure { w h } {
	variable canvas_width
	variable canvas_height
	set canvas_width $w
	set canvas_height $h
}

proc main_focus_in { } {
	set current [ mwc::get_current_dia ]
	if { $current != "" } {
		select_dia $current 1
	}
}

proc zoomin { } {
	variable canvas_width
	variable canvas_height
	mwc::change_zoom_up $canvas_width $canvas_height
	insp::reset
}

proc zoomout { } {
	variable canvas_width
	variable canvas_height
	mwc::change_zoom_down $canvas_width $canvas_height
	insp::reset
}

proc zoom100 { } {
	variable canvas_width
	variable canvas_height
	mwc::change_zoom_to $canvas_width $canvas_height 100
	insp::reset
}

proc apply_zoom_to_all { } {
	mwc::apply_zoom_to_all
	insp::reset
}

proc zoom_see_all { } {
	variable canvas_width
	variable canvas_height
	mwc::zoom_see_all $canvas_width $canvas_height
	insp::reset
}

proc zoom_home { } {
	mwc::zoom_home
	insp::reset
}


proc canvas_wheel { window delta s } {
	variable canvas_width
	variable canvas_height
	set amount [ normalize_wheel $delta ]
	set x0 [ $window canvasx 0 ]
	set y0 [ $window canvasy 0 ]

	if { [ shift_pressed $s ] } {
		set x1 [ expr { $x0 + $amount } ]
		set y1 $y0
		$window xview scroll $amount units
		mwc::scroll $x1 $y1
	} elseif { [ control_pressed $s ] } {
		set cw $canvas_width
		set ch $canvas_height
		if { $amount > 0 } {
			mwc::change_zoom_down $cw $ch
		} else {
			mwc::change_zoom_up $cw $ch
		}
	} else {
		set x1 $x0
		set y1 [ expr { $y0 + $amount } ]
		$window yview scroll $amount units
		mwc::scroll $x1 $y1
	}

	insp::reset
}

proc verify { } {
	show_errors


	set db $mwc::db
	set diagram_id [ mwc::editor_state $db current_dia ]
	if { $diagram_id == "" } { return }

	graph::verify_one $db $diagram_id

	get_errors
}

proc show_red_result {} {
	variable error_label
	variable error_message
	set error_message [ mc2 "Some errors found." ]
	$error_label configure -bg "#ffd0d0"
}


proc show_green_result {} {
	variable error_label
	variable error_message
	set error_message [ mc2 "Your drawing looks good." ]
	$error_label configure -bg "#d0ffd0"
	after 3000 mw::hide_errors
}


proc get_errors { } {
	variable error_list
	variable errors_listbox

	set error_list [ graph::get_error_list ]
	make_alternate_lines $errors_listbox
	if { [ llength $error_list ] == 0 } {
		show_green_result
		return 1
	} else {
		show_red_result
		return 0
	}
}

proc verify_all { } {
	show_errors

	set db $mwc::db

	graph::verify_all $db

	return [ get_errors ]
}


proc error_selected { listbox } {
	set current [ $listbox curselection ]
	if { $current == "" } { return }

	set error_info [ graph::get_error_info $current ]
	if { $error_info == "" } { return }

	lassign $error_info diagram_id items

	if { [ llength $items ] == 0 } {
		mwc::switch_to_dia $diagram_id
	} else {
		set item [ lindex $items 0 ]
		mwc::switch_to_item $item
	}
}

proc show_errors { } {
	variable errors_visible
	variable errors_main
	variable error_list
	variable error_message
	variable error_label

	set error_list {}
	set error_message ""
	$error_label configure -bg "#ffffff"


	if { $errors_visible } { return }
	set errors_visible 1


	.root.pnd.right add $errors_main

	mwc::save_view
}

proc hide_errors { } {
	variable errors_visible
	variable errors_main

	if { !$errors_visible } { return }
	set errors_visible 0
	.root.pnd.right forget $errors_main
}

proc select_next_item_on_canvas {  } {
	variable db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	set item_selected [ get_selected_item $diagram_id ]
	
	if { $item_selected != ""} { 
	
	if { [catch {
		lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		} fid ] } { 
			graph::verify_all $mwc::db 
			lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		}
		
		set vertex2	[ mw::next_item_on_canvas $vertex_id] 
		lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2

		if { $item2 == "" } {
			set vertex2	[ mw::next_item_on_canvas $vertex2] 
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}
		if { $item2 == "" } {
			set vertex2	[ mw::next_item_on_canvas $vertex2] 
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}

		if { $item2 == "" } {
			set vertex2	[ mw::next_item_on_canvas $vertex2] 
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}
		if { $item2 == "" } {
			lassign [ gdb eval { select dst from links where src = $vertex_id } ] vertex2
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
			set mw::variant_vertex ""
			set mw::variant_vertex_ordinal 1
		}
		#	set vertex2 [gen::p.next_on_skewer gdb $vertex_id ]
		#	lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		#	set mw::variant_vertex_ordinal 1
		
		#mw::set_status2 "it:$item_selected vx:$vertex_id vx2:$vertex2 it2:$item2 ::[graph::p.get_info $vertex2]"
		#mw::set_status  "$mw::variant_vertex $mw::variant_vertex_ordinal ::[ gdb eval { select * from links where src = $vertex2 } ]"
		if { $item2 != "" } {
			set mw::previous_vertex $vertex_id
			mwc::push_unselect_items $diagram_id
			mwc::push_select_item $item2
			if {[ gdb onecolumn { select count(*) from links where src = $vertex2 } ] > 1 } {
				set mw::variant_vertex $vertex2
				set mw::variant_vertex_ordinal 1
			}
			return { $vertex2, $item2 }
		}
	} 
} 

proc select_prev_item_on_canvas {  } {
	variable db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	set item_selected [ get_selected_item $diagram_id ]
	
	if { $item_selected != ""} { 
		
	if { [catch {
		lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		} fid ] } { 
			graph::verify_all $mwc::db 
			lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		}
	
		set vertex2	[ mw::prev_item_on_canvas $vertex_id] 
		lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		
		if { $item2 == "" } {
			set vertex2	[ mw::prev_item_on_canvas $vertex2] 
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}
		if { $item2 == "" } {
			set vertex2	[ mw::prev_item_on_canvas $vertex2] 
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}
		if { $item2 == "" } {
			lassign [ gdb eval { select src from links where dst = $vertex_id AND ordinal > 1 } ] vertex2
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}
		if { $item2 == "" } {
			lassign [ gdb eval { select src from links where dst = $vertex_id AND ordinal == 1 } ] vertex2
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}
		if { $item2 != "" } {
			mwc::push_unselect_items $diagram_id
			mwc::push_select_item $item2
			if {[ gdb onecolumn { select count(*) from links where src = $vertex2 } ] > 1 } {
				set mw::variant_vertex $vertex2
				set mw::variant_vertex_ordinal 1
			}
			if { $mw::variant_vertex == $vertex_id } {
				set mw::variant_vertex ""
			}
		}
	} 
} 

proc select_right_item_on_canvas {  } {
	variable db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	set item_selected [ get_selected_item $diagram_id ]
	
	if { $item_selected != ""} { 
	if { [catch {
		lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		} fid ] } { 
			graph::verify_all $mwc::db 
			lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		}
		
		lassign [ gdb eval { select type from vertices where vertex_id=$vertex_id } ] type
		set vertex2	[ mw::right_item_on_canvas $vertex_id] 
		lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2 
		
		if { $type == "branch"} { 
			next_branch_on_canvas $vertex_id
		}
 
 		if { $item2 == "" } {
			set mw::variant_vertex_ordinal [ incr mw::variant_vertex_ordinal 1 ] 
			lassign [ gdb eval { select dst from links where src = $vertex_id AND ordinal == 2 } ] vertex2
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		}
		
		if { $item2 == "" } {
			lassign [ gdb eval { select dst from links where src = $mw::variant_vertex AND ordinal == $mw::variant_vertex_ordinal } ] vertex2
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
			if { $item2 == "" } { set mw::variant_vertex_ordinal [ incr mw::variant_vertex_ordinal -1 ] }
		}
		if { $item2 != "" } {
			mwc::push_unselect_items $diagram_id
			mwc::push_select_item $item2
			if {[ gdb onecolumn { select count(*) from links where src = $vertex2 } ] > 1 } {
				set mw::variant_vertex $vertex2
				set mw::variant_vertex_ordinal 1
			}
		}
	} 
} 

proc select_left_item_on_canvas {  } {
	variable db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	set item_selected [ get_selected_item $diagram_id ]
	if { $item_selected != ""} { 
	if { [catch {
		lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		} fid ] } { 
			graph::verify_all $mwc::db 
			lassign [ gdb eval { select vertex_id from vertices where item_id= $item_selected } ] vertex_id  
		}
		
		lassign [ gdb eval { select type from vertices where vertex_id=$vertex_id } ] type
		set vertex2	[ mw::left_item_on_canvas $vertex_id ] 
		lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
		
		if { $type == "branch"} { 
			prev_branch_on_canvas $vertex_id
		}

		if { $item2 == "" && $mw::variant_vertex_ordinal > 1} {
			set mw::variant_vertex_ordinal [ incr mw::variant_vertex_ordinal -1 ] 
			lassign [ gdb eval { select dst from links where src = $mw::variant_vertex AND ordinal == $mw::variant_vertex_ordinal } ] vertex2
			lassign [ gdb eval { select item_id from vertices where vertex_id=$vertex2 } ] item2
			if { $item2 == "" } { set mw::variant_vertex_ordinal [ incr mw::variant_vertex_ordinal 1 ] }
		}
		if { $item2 != "" } {
			mwc::push_unselect_items $diagram_id
			mwc::push_select_item $item2
			if {[ gdb onecolumn { select count(*) from links where src = $vertex2 } ] > 1 } {
				set mw::variant_vertex $vertex2
				set mw::variant_vertex_ordinal 1
			}
		}
	} 
} 

proc get_selected_item { diagram_id } {
	variable db
	#set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	set item_selected [ $mwc::db eval { select item_id from items where diagram_id = :diagram_id and selected = 1 } ]
	set count [ llength item_selected ]
	if { $diagram_id != "" && $count==1 } { return $item_selected }
	else { return "" }
}

proc prev_item_on_canvas { vertex_id } {
	return	[lindex [graph::p.get_info $vertex_id] 2]
} 

proc next_item_on_canvas { vertex_id } {
	return	[lindex [graph::p.get_info $vertex_id] 5]
} 

proc right_item_on_canvas { vertex_id } {
	return	[lindex [graph::p.get_info $vertex_id] 4]
}

proc left_item_on_canvas { vertex_id } {
	return	[lindex [graph::p.get_info $vertex_id] 3]
}

proc next_branch_on_canvas { vertex_id } {
	set type ""
	gdb eval { select * from vertices } val { set vert($val(vertex_id)) [array get val] }; unset val;
	gdb eval { select * from links where direction != "short" } val { set src($val(src)) $val(dst) }; unset val ; 
	gdb eval { select * from links where direction == "short" } val { set srt($val(src)) $val(dst) }; unset val ; 
	#catch {
	while { $type !="branch" && $vertex_id != "" } {
		if { [catch { 
			set vertex_id $src($vertex_id); 
			} err ] } { 
			set vertex_id $srt($vertex_id); 
		}
		array set val $vert($vertex_id); set type $val(type)
	}
	mwc::push_unselect_items $val(diagram_id)
	mwc::push_select_item $val(item_id)
	#} err
	return 0
}

proc prev_branch_on_canvas { vertex_id } {
	set type ""
	variable db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	set item_selected [ $mwc::db eval { select item_id from items where diagram_id = :diagram_id and selected = 1 } ]
	set count [ llength item_selected ]
	if { $count!=1 } { return 0 }
	gdb eval { select * from vertices where diagram_id = :diagram_id } val { set v2i($val(vertex_id)) $val(item_id) }; unset val; 
	set branches [gdb eval { select vertex_id from vertices where diagram_id=$diagram_id and type="branch" order by x } ]
	set nom [lsearch $branches $vertex_id]
	if { $nom > 0} { incr nom -1}
	set vertex_id [ lindex $branches $nom ]
	mwc::push_unselect_items $diagram_id
	mwc::push_select_item $v2i($vertex_id)
	return 0
}


proc edit_selected_item_on_canvas { } {
	variable db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]

	lassign [ $mwc::db eval { select item_id, type from items where diagram_id = :diagram_id and selected = 1 } ] item_selected type
	if { $item_selected == "" } { return }
	set count [ llength item_selected ]
	#if { $type == "address" } { return }
	if { $type == "_insertion" } {
		set referenced [ mwc::find_referenced_diagrams $item_selected ]
		foreach dia $referenced {
			lassign $dia ref_id ref_name
			if { $ref_id != $diagram_id } {
				mwc::switch_to_dia $ref_id
				return -1
			}
		}
	}
	if { $diagram_id != "" && $count==1 } { 
		#Центруем холст
		#mwc::center_on $item_selected  
		#Редактируем
		if { $type == "address" || $type == "insertion" } { 
			after 100 {
				$ui::tw_text configure -state disabled -background #E5E5E5 
				#wm title $ui::tw_text "Просмотр: $item_selected"
				} 
		}
		mwc::show_change_text_dialog $item_selected 0
		set im [image create photo -file "images/$type.gif"]
		wm iconphoto .twindow $im
	}
}

proc wlist {{W .}} {
   set list [list $W]
   foreach w [winfo children $W] {
      set list [concat $list [wlist $w]]
   }
   return $list
}

#textSearch .text $searchString search
proc textSearch {w string tag} {
  # Remove all tags
  #$w tag remove search 0.0 end
  # If string empty, do nothing
  if {$string == ""} {return}
  # Current position of 'cursor' at first line, before any character
  set cur 1.0
  # Search through the file, for each matching word, apply the tag 'search'
  while 1 {
    set cur [$w search -count length $string $cur end]
    if {$cur eq ""} {break}
    $w tag add $tag $cur "$cur + $length char"
    set cur [$w index "$cur + $length char"]
  }
  # For all the tagged text, apply the below settings
  .root.pnd.text.blank.description tag configure search -background white -foreground #7F7F7F \
		-selectbackground blue -selectforeground #7F7F7F
  .root.pnd.text.blank.description tag configure search2 -background white -foreground #90EE90 \
		-selectbackground blue -selectforeground #90EE90
}

proc shaker {  } {
	#"Контроль касания икон: [graph2::import $mwc::db $diagram_id; graph2::icons.dont.touch] $graph2::errors"
	set db $mwc::db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	graph2::import $db $diagram_id
	mw::set_status2 ""
	if { ![graph2::icons.dont.touch]} {
		mw::set_status2 $graph2::errors 
		#push_change_type $hit_item "loopstart"
		set val ""
		foreach err $graph2::errors  {	
			set old ""
			set new ""
			set item_id [lindex $err 0]
			#lappend val $item_id
			#lassign [ $mwc::db eval { select x, y, w, h, a, b from items where item_id = :item_id } ]  oldx oldy oldw oldh olda oldb
			lassign [ alt::get_item $item_id ] oldx oldy oldw oldh olda oldb
			set x $oldx
			set y $oldx 
			incr y 5
			set w $oldx
			set h $oldx
			set a $oldx
			set b $oldx
			mwc::change_ypos_q $item_id $y
		}
	}
	after 1500 mw::shaker
} ; # [mw::shaker]

proc sel_right {  } {
	set type ""
	variable db
	set diagram_id [ mwc::editor_state $mwc::db current_dia ]
	set item_id [ $mwc::db eval { select item_id from items where diagram_id = :diagram_id and selected = 1 } ]
	lassign [ alt::get_item $item_id ] x y w h a b
	
	lassign [ $mwc::db eval { select item_id, x from items where y/20 = :y/20 order by x } ] i1 y1 i2 y2 i3 y3
	mw::set_status "[ alt::get_item $item_id ]     $i1:$y1 $i2:$y2 $i3:$y3";
} 

proc change_dia_lock {  } {
	if { $mw::dia_lock==0} {
			set mw::dia_lock 1 ; .root.pnd.left.description_frame.dia_edit_butt5 configure -image [ mw::load_gif shift_pressed.gif ]
		} else {
			set mw::dia_lock 0 ; .root.pnd.left.description_frame.dia_edit_butt5 configure -image [ mw::load_gif shift_unpressed.gif ]	
		}
}

 proc serial_receiver { chan } {
     if { [eof $chan] } {
         logg "Closing $chan"
         catch {close $chan}
         return
     }
     set data [read $chan]
     set size [string length $data]
     #logg "received $size bytes: $data"
     logs $data
 }

}
