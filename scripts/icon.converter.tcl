
namespace eval mv {

proc converter.switch { } {
	return ""
}

proc converter.create { item_id diagram_id x y } {
	return [ list insert items				\
		item_id				$item_id		\
		diagram_id		$diagram_id	\
		type					'converter'		\
		text					converter		\
		selected				1					\
		x						$x					\
		y						$y					\
		w						60					\
		h						60					\
		a						20					\
		b						20		 ]
}

proc converter.lines { x y w h a b } {
	return {}
}

proc converter.fit { tw th tw2 th2 x y w h a b } {
	return [ output.fit $tw $th $tw2 $th2 $x $y $w $h $a $b ]
}

proc converter.box { x y w h a b } {
	return [ action.box $x $y $w $h $a $b ]
}

proc converter.is_top { mx my x y w h a b } {
	set top [ expr { $y - $h } ]
	set boundary [ expr { $y + $h - 40 } ]
	if { $my > $boundary } {
		return 0
	} else {
		return 1
	}
}

proc converter.icons { text text2 color x y w h a b } {
	set s1 [string first "(" $text2] ; incr s1
	set s2 [string last ")" $text2] ; decr s2
	set param [string range $text2 $s1 $s2 ]
	decr s1 2
	set conv [string range $text2 0 $s1 ]

	lassign [ get_colors $color $colors::action_bg ] fg bg tc
	### Описание координат прямоугольника для конвертера
	set hm [ expr { $h / 3 } ]
	set left1 [ expr { $x - $w + 10 } ]
	set top1 [ expr { $y - $h + 40 } ]
	set right1 [ expr { $x + $w - 5 } ]
	set bottom1 [ expr { $y +$h - 40 } ]

	set w1 [ expr { ($right1 - $left1)/2 } ]
	set h1 [ expr { ($bottom1 - $top1)/2 } ]
	set x1 [ expr { $left1 + $w1 } ]
	set y1 [ expr { $top1 + $h1 } ]

	### Описание координат прямоугольника для источника left+10 was
	set left2 [ expr { $x - $w  } ]
	set top2 [ expr { $y - $h } ]
	set right2 [ expr { $x + $w - 5 } ]
	set bottom2 [ expr { $top2 + 40 } ]
	set xa [ expr { $left2 + 15 } ]
	set ya [ expr { ($top2 + $bottom2) / 2 } ]

	set h2 [ expr { 20 } ]
	set w2 $w1
	set x2 [ expr { $x + 10 } ]
	set y2 [ expr { $top2 + $h2 } ]
	
	### Описание координат прямоугольника для приемника 
	set left3 $left1
	set top3 $bottom1
	set right3 [ expr { $x + $w - 5 } ]
	set bottom3 [ expr { $y + $h } ]
	set xb [ expr { $right3 + 10 } ]
	set yb [ expr { ($top3 + $bottom3) / 2 } ]

	set w3 [ expr { ($right3 - $left3)/2 } ]
	set h3 [ expr { ($bottom3 - $top3)/2 } ]
	set x3 [ expr { $left3 + $w3 } ]
	set y3 [ expr { $top3 + $h3 } ]

	### Контур источника
	set coords2 [ list $left2 $top2 $right2 $top2 $right2 $bottom2 $left2 $bottom2 $xa $ya ]
	### Контур приемника
	set coords3 [ list $left3 $top3 $right3 $top3 $xb $yb $right3 $bottom3 $left3 $bottom3]

	### Контур converter
	set rect_coords1 [ list $left1 $top1 $right1 $bottom1 ]
	### Контур всей иконы
	set rect_coords [ list $left2 $top2 $right2 $bottom3 ]
	set cdbox [ add_handle_border $rect_coords ]
	set rect [ make_prim main rectangle $rect_coords1 "" $fg #FFFFc9 $cdbox ]
	set top [ expr { $y - $h } ]
	
	set text_prim [ create_text_left $x2 $y2 $w2 $h2 $param $tc ]
	set text_prim2 [ create_text_left $x1 $y1 $w1 $h1 $conv $tc third ]
	set text_prim3 [ create_text_left $x3 $y3 $w3 $h3 $text $tc secondary ]
	set back [ make_prim back polygon $coords2 "" $fg $bg $cdbox ]
	#					 role type 	  coords text line fill rect
	set dest [ make_prim dest polygon $coords3 "" $fg $bg $cdbox ]
	#return [ list $back $rect $text_prim $text_prim2 ]

	set filepath [file dirname $ds::my_filename ]
	set x4 [ expr { $x - $w } ]
	set coords4 [ list $x4 $top ]
	set i [string first "(" $text2]
	decr i 
	set text2 [string range $text2 0 $i ]
	set text2 [string trimright $text2 " "]
	set figack [ make_prim figack image $coords4 "$filepath/$text2.png" $fg $bg $cdbox ]
	return [ list $figack $back $rect $dest $text_prim $text_prim3 $text_prim2]
}


proc converter.handles { x y w h a b } {
	return [ action.handles $x $y $w $h $a $b ]
}

proc converter.nw { dx dy x y w h a b } {
	return [ action.nw $dx $dy $x $y $w $h $a $b ]
}

proc converter.n { dx dy x y w h a b } {
	return [ action.n $dx $dy $x $y $w $h $a $b ]
}

proc converter.ne { dx dy x y w h a b } {
	return [ action.ne $dx $dy $x $y $w $h $a $b ]
}

proc converter.e { dx dy x y w h a b } {
	return [ action.e $dx $dy $x $y $w $h $a $b ]
}

proc converter.sw { dx dy x y w h a b } {
	return [ action.sw $dx $dy $x $y $w $h $a $b ]
}

proc converter.s { dx dy x y w h a b } {
	return [ action.s $dx $dy $x $y $w $h $a $b ]
}

proc converter.se { dx dy x y w h a b } {
	return [ action.se $dx $dy $x $y $w $h $a $b ]
}

proc converter.w { dx dy x y w h a b } {
	return [ action.w $dx $dy $x $y $w $h $a $b ]
}

}
