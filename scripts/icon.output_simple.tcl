
namespace eval mv {

proc output_simple.switch { } {
	return ""
}

proc output_simple.create { item_id diagram_id x y } {
	return [ list insert items				\
		item_id				$item_id		\
		diagram_id		$diagram_id	\
		type					'output_simple'		\
		text					output_simple		\
		selected				1					\
		x						$x					\
		y						$y					\
		w						60					\
		h						20					\
		a						0					\
		b						0		 ]
}

proc output_simple.lines { x y w h a b } {
	return {}
}

proc output_simple.fit { tw th tw2 th2 x y w h a b } {
	if { $tw < 50 } { set tw 50 }
	return [ list $x $y $tw $th $a $b ]
}

proc output_simple.box { x y w h a b } {
	return [ action.box $x $y $w $h $a $b ]
}

proc output_simple.icons { text text2 color x y w h a b } {
	lassign [ get_colors $color $colors::action_bg ] fg bg tc
	set left [ expr { $x - $w } ]
	set bottom [ expr { $y + $h } ]
	set top [ expr { $y - $h } ]
	set right [ expr { $x + $w } ]

	set xa [ expr { $right - 15 } ]
	set ya [ expr { ($top + $bottom) / 2 } ]

	set coords2 [ list $left $top $xa $top $right $ya $xa $bottom $left $bottom ]
	set rect_coords [ list $left $top $right $bottom ]
	set cdbox [ add_handle_border $rect_coords ]
	set rect [ make_prim main polygon $coords2 "" $fg $bg $cdbox ]

	set text_prim [ create_text_left $x $y $w $h $text $tc ]

	set filepath [file dirname $ds::my_filename ]
	set x3 [ expr { $x - $w } ]
	set coords3 [ list $x3 $top ]
	set figack [ make_prim figack image $coords3 "$filepath/output_simple.png" $fg $bg $cdbox ]
	return [ list $figack $rect $text_prim ]
}


proc output_simple.handles { x y w h a b } {
	return [ action.handles $x $y $w $h $a $b ]
}

proc output_simple.nw { dx dy x y w h a b } {
	return [ action.nw $dx $dy $x $y $w $h $a $b ]
}

proc output_simple.n { dx dy x y w h a b } {
	return [ action.n $dx $dy $x $y $w $h $a $b ]
}

proc output_simple.ne { dx dy x y w h a b } {
	return [ action.ne $dx $dy $x $y $w $h $a $b ]
}

proc output_simple.e { dx dy x y w h a b } {
	return [ action.e $dx $dy $x $y $w $h $a $b ]
}

proc output_simple.sw { dx dy x y w h a b } {
	return [ action.sw $dx $dy $x $y $w $h $a $b ]
}

proc output_simple.s { dx dy x y w h a b } {
	return [ action.s $dx $dy $x $y $w $h $a $b ]
}

proc output_simple.se { dx dy x y w h a b } {
	return [ action.se $dx $dy $x $y $w $h $a $b ]
}

proc output_simple.w { dx dy x y w h a b } {
	return [ action.w $dx $dy $x $y $w $h $a $b ]
}


}
