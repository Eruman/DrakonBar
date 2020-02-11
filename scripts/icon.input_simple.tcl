
namespace eval mv {

proc input_simple.switch { } {
	return ""
}

proc input_simple.create { item_id diagram_id x y } {
	return [ list insert items				\
		item_id				$item_id		\
		diagram_id		$diagram_id	\
		type					'input_simple'		\
		text					input_simple		\
		selected				1					\
		x						$x					\
		y						$y					\
		w						60					\
		h						20					\
		a						0					\
		b						0		 ]
}

proc input_simple.lines { x y w h a b } {
	return {}
}

proc input_simple.fit { tw th tw2 th2 x y w h a b } {
	return [ output_simple.fit $tw $th $tw2 $th2 $x $y $w $h $a $b ]
}

proc input_simple.box { x y w h a b } {
	return [ action.box $x $y $w $h $a $b ]
}

proc input_simple.icons { text text2 color x y w h a b } {
	lassign [ get_colors $color $colors::action_bg ] fg bg tc
	set left [ expr { $x - $w } ]
	set bottom [ expr { $y + $h } ]
	set top [ expr { $y - $h } ]
	set right [ expr { $x + $w } ]

	set x1 [ expr { $x + 15 } ]
	set xa [ expr { $left + 15 } ]
	set ya [ expr { ($top + $bottom) / 2 } ]

	set coords2 [ list $left $top $right $top $right $bottom $left $bottom $xa $ya ]
	set rect_coords [ list $left $top $right $bottom ]
	set cdbox [ add_handle_border $rect_coords ]
	set rect [ make_prim main polygon $coords2 "" $fg $bg $cdbox ]

	set text_prim [ create_text_left $x1 $y $w $h $text $tc ]

	set filepath [file dirname $ds::my_filename ]
	set x3 [ expr { $x - $w } ]
	set coords3 [ list $x3 $top ]
	set figack [ make_prim figack image $coords3 "$filepath/output_simple.png" $fg $bg $cdbox ]
	return [ list $figack $rect $text_prim ]
}


proc input_simple.handles { x y w h a b } {
	return [ action.handles $x $y $w $h $a $b ]
}

proc input_simple.nw { dx dy x y w h a b } {
	return [ action.nw $dx $dy $x $y $w $h $a $b ]
}

proc input_simple.n { dx dy x y w h a b } {
	return [ action.n $dx $dy $x $y $w $h $a $b ]
}

proc input_simple.ne { dx dy x y w h a b } {
	return [ action.ne $dx $dy $x $y $w $h $a $b ]
}

proc input_simple.e { dx dy x y w h a b } {
	return [ action.e $dx $dy $x $y $w $h $a $b ]
}

proc input_simple.sw { dx dy x y w h a b } {
	return [ action.sw $dx $dy $x $y $w $h $a $b ]
}

proc input_simple.s { dx dy x y w h a b } {
	return [ action.s $dx $dy $x $y $w $h $a $b ]
}

proc input_simple.se { dx dy x y w h a b } {
	return [ action.se $dx $dy $x $y $w $h $a $b ]
}

proc input_simple.w { dx dy x y w h a b } {
	return [ action.w $dx $dy $x $y $w $h $a $b ]
}


}
