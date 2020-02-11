
namespace eval mv {

proc insertion.switch { } {
	return ""
}

proc insertion.create { item_id diagram_id x y } {
	return [ list insert items				\
		item_id				$item_id		\
		diagram_id		$diagram_id	\
		type					'insertion'		\
		text					insertion		\
		selected				1					\
		x						$x					\
		y						$y					\
		w						60					\
		h						20					\
		a						60					\
		b						0		 ]
}

proc insertion.lines { x y w h a b } {
	return {}
}

proc insertion.fit { tw th tw2 th2 x y w h a b } {
	return [ action.fit $tw $th 0 0 $x $y $w $h $a $b ]
}

proc insertion.box { x y w h a b } {
	return [ action.box $x $y $w $h $a $b ]
}


proc insertion.icons { text text2 color x y w h a b } {
	lassign [ get_colors $color $colors::action_bg ] fg bg tc
	set rect_coords [ make_rect $x $y $w $h ]
	set cdbox [ add_handle_border $rect_coords ]
	set rect [ make_prim main rectangle $rect_coords "" $fg $bg $cdbox ]
	set x0 [ expr { $x - $w + 5 } ]
	set x1 [ expr { $x + $w - 5 } ]
	set top [ expr { $y - $h } ]
	set bottom [ expr { $y + $h } ]
	set left [ make_line left $x0 $top $x0 $bottom $fg ]
	set right [ make_line right $x1 $top $x1 $bottom $fg ]
	#set text_prim [ create_text_left $x $y $w $h $text $tc ]
	#####################################################################################
	if {$mw::rem_visible == 0} {
		set text_prim [ create_text_left $x $y $w $h $text $tc ]
	} else {
		set text_prim [ create_text_left $x $y $w $h "$text2\n--------\n$text" $tc ]
	}
	#return [ list $rect $left $right $text_prim ]
	set filepath [file dirname $ds::my_filename ]
	#mw::set_status "Color: $filepath/$text.gif"
	set x2 [ expr { $x - $w } ]
	set coords3 [ list $x2 $top ]
	set figack [ make_prim figack image $coords3 "$filepath/$text.png" $fg $bg $cdbox ]
	return [ list $figack $rect $left $right $text_prim ]

}


proc insertion.handles { x y w h a b } {
	return [ action.handles $x $y $w $h $a $b ]
}

proc insertion.nw { dx dy x y w h a b } {
	return [ action.nw $dx $dy $x $y $w $h $a $b ]
}

proc insertion.n { dx dy x y w h a b } {
	return [ action.n $dx $dy $x $y $w $h $a $b ]
}

proc insertion.ne { dx dy x y w h a b } {
	return [ action.ne $dx $dy $x $y $w $h $a $b ]
}

proc insertion.e { dx dy x y w h a b } {
	return [ action.e $dx $dy $x $y $w $h $a $b ]
}

proc insertion.sw { dx dy x y w h a b } {
	return [ action.sw $dx $dy $x $y $w $h $a $b ]
}

proc insertion.s { dx dy x y w h a b } {
	return [ action.s $dx $dy $x $y $w $h $a $b ]
}

proc insertion.se { dx dy x y w h a b } {
	return [ action.se $dx $dy $x $y $w $h $a $b ]
}

proc insertion.w { dx dy x y w h a b } {
	return [ action.w $dx $dy $x $y $w $h $a $b ]
}


}
