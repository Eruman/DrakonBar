
namespace eval mv {

proc input.switch { } {
	return ""
}

proc input.create { item_id diagram_id x y } {
	return [ list insert items				\
		item_id				$item_id		\
		diagram_id		$diagram_id	\
		type					'input'		\
		text					input		\
		selected				1					\
		x						$x					\
		y						$y					\
		w						60					\
		h						30					\
		a						20					\
		b						0		 ]
}

proc input.lines { x y w h a b } {
	return {}
}

proc input.fit { tw th tw2 th2 x y w h a b } {
	return [ output.fit $tw $th $tw2 $th2 $x $y $w $h $a $b ]
}

proc input.box { x y w h a b } {
	return [ action.box $x $y $w $h $a $b ]
}



proc input.is_top { mx my x y w h a b } {
	return [ output.is_top $mx $my $x $y $w $h $a $b ]
}

proc input.icons { text text2 color x y w h a b } {
	lassign [ get_colors $color $colors::action_bg ] fg bg tc
	### Описание координат прямоугольника для значения
	set left1 [ expr { $x - $w } + 10 ]
	set top1 [ expr { $y - $h + $a } ]
	set right1 [ expr { $x + $w } ]
	set bottom1 [ expr { $y + $h } ]

	set w1 [ expr { ($right1 - $left1)/2 } ]
	set h1 [ expr { ($bottom1 - $top1)/2 } ]
	set x1 [ expr { $left1 + $w1 } ]
	set y1 [ expr { $top1 + $h1 } ]

	### Описание координат прямоугольника для источника left+10 was
	set left2 [ expr { $x - $w  } ]
	set top2 [ expr { $y - $h } ]
	set right2 [ expr { $x + $w - 10 } ]
	set bottom2 [ expr { $top2 + $a + 10 } ]
	set xa [ expr { $left2 + 15 } ]
	set ya [ expr { ($top2 + $bottom2) / 2 } ]

	set x2 [ expr { $x + 10 } ]
	set y2 [ expr { $top2 + $a / 2 } ]
	set h2 [ expr { $a / 2 } ]
	set w2 $w1


	set coords2 [ list $left2 $top2 $right2 $top2 $right2 $bottom2 $left2 $bottom2 $xa $ya ]


	set rect_coords1 [ list $left1 $top1 $right1 $bottom1 ]
	set rect_coords [ list $left1 $top2 $right2 $bottom1 ]
	set cdbox [ add_handle_border $rect_coords ]
	set rect [ make_prim main rectangle $rect_coords1 "" $fg $bg $cdbox ]
	set top [ expr { $y - $h } ]
	set bottom [ expr { $y + $h } ]
	set text_prim [ create_text_left $x1 $y1 $w1 $h1 $text $tc ]
	set text_prim2 [ create_text_left $x2 $y2 $w2 $h2 $text2 $tc secondary ]
	set back [ make_prim back polygon $coords2 "" $fg $bg $cdbox ]
	#return [ list $back $rect $text_prim $text_prim2 ]

	set filepath [file dirname $ds::my_filename ]
	set x3 [ expr { $x - $w } ]
	set coords3 [ list $x3 $top ]
	set figack [ make_prim figack image $coords3 "$filepath/$text2.png" $fg $bg $cdbox ]
	return [ list $figack $back $rect $text_prim $text_prim2 ]

}


proc input.handles { x y w h a b } {
	return [ action.handles $x $y $w $h $a $b ]
}

proc input.nw { dx dy x y w h a b } {
	return [ action.nw $dx $dy $x $y $w $h $a $b ]
}

proc input.n { dx dy x y w h a b } {
	return [ action.n $dx $dy $x $y $w $h $a $b ]
}

proc input.ne { dx dy x y w h a b } {
	return [ action.ne $dx $dy $x $y $w $h $a $b ]
}

proc input.e { dx dy x y w h a b } {
	return [ action.e $dx $dy $x $y $w $h $a $b ]
}

proc input.sw { dx dy x y w h a b } {
	return [ action.sw $dx $dy $x $y $w $h $a $b ]
}

proc input.s { dx dy x y w h a b } {
	return [ action.s $dx $dy $x $y $w $h $a $b ]
}

proc input.se { dx dy x y w h a b } {
	return [ action.se $dx $dy $x $y $w $h $a $b ]
}

proc input.w { dx dy x y w h a b } {
	return [ action.w $dx $dy $x $y $w $h $a $b ]
}


}
