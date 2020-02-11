
namespace eval mv {

proc arrow.switch { } {
	return [ mc2 "Flip horizontally" ]
}

proc arrow.create { item_id diagram_id x y } {
	set x [ expr { $x + 60 } ]
	return [ list insert items				\
		item_id				$item_id		\
		diagram_id		$diagram_id	\
		type					'arrow'			\
		text					""					\
		selected				1					\
		x						$x					\
		y						$y					\
		w						60					\
		h						100				\
		a						40					\
		b						0		 ]
}

proc arrow.fit { tw th tw2 th2 x y w h a b } {
	return [ list $x $y $w $h $a $b ]
}


proc make_head { x y w b } {
	set aw 20
	set ah 5
	
	if { $b == 0 } {
		set left [ expr { $x - $w } ]
		set right [ expr { $left + $aw } ]
		set top [ expr { $y - $ah } ]
		set bottom [ expr { $y + $ah } ]
		set coords [ list $left $y  $right $top  $right $bottom  $left $y ]
	} else {
		set right [ expr { $x + $w } ]
		set left [ expr { $right - $aw } ]
		
		set top [ expr { $y - $ah } ]
		set bottom [ expr { $y + $ah } ]
		set coords [ list $left $bottom  $left $top  $right $y  $left $bottom ]
	}
	
	set cdbox [ list $left $top $right $bottom ]
	set rect [ make_prim head polygon $coords "" $colors::line_fg $colors::line_fg $cdbox ]
	return $rect
}

proc make_line { role x0 y0 x1 y1 fg } {
	set coords [ list $x0 $y0 $x1 $y1 ]
	set cdbox [ add_handle_border $coords ]
	set line [ make_prim $role line $coords "" "" $fg $cdbox ]
	return $line
}


proc arrow.box { x y w h a b } {
	set top $y
	set bottom [ expr { $y + $h } ]
	if { $b == 0 } {
		set leftb [ expr { $x - $a } ]
		set leftt [ expr { $x - $w } ]
		if { $leftb < $leftt } {
			set left $leftb
		} else {
			set left $leftt
		}
		set right $x
	} else {
		set left $x
		set rightb [ expr { $x + $a } ]
		set rightt [ expr { $x + $w } ]
		if { $rightb < $rightt } {
			set right $rightt
		} else {
			set right $rightb
		}
	}
	return [ list $left $top $right $bottom ]
}


proc arrow.lines { x y w h a b } {
	set fg $colors::line_fg
	set bottom [ expr { $y + $h } ]
	
	set arrow_style $mw::arrow_style
	if { $b == 0 } {
		# �������������� ������� (����)
		set leftb [ expr { $x - $a } ]
		set leftt [ expr { $x - $w } ]
		if { $arrow_style > 0} {
			set line1 [ make_line line1 $leftb $bottom [ expr $x - 14 ] $bottom $fg ]
			set line2 [ make_line line2 $x [ expr $y + 14 ] $x [ expr $bottom - 14 ] $fg ]
			set line3 [ make_line line3 $leftt $y [ expr $x - 14 ] $y $fg ]
		} else {
			set line1 [ make_line line1 $leftb $bottom $x $bottom $fg ]
			set line2 [ make_line line2 $x $y $x $bottom $fg ]
			set line3 [ make_line line3 $leftt $y $x $y $fg ]
		}
		set number [ segments_from_height $h ]
		set coords [ arrow_rounded_outline3 $x $y 31 32 $number]
		set bend1 [ make_prim main2 line $coords "" "" $fg ""]
		set coords [ arrow_rounded_outline4 $x [ expr { $y + $h } ] 31 32 $number]
		set bend2 [ make_prim main3 line $coords "" "" $fg ""]
	} else {
		# ������������� ������� (������)
		set rightb [ expr { $x + $a } ]
		set rightt [ expr { $x + $w } ]
		if { $arrow_style > 0} {
		# ������ �����
		set line1 [ make_line line1 [ expr $x + 15 ] $bottom $rightb $bottom $fg ]  
		# ������������ �����
		set line2 [ make_line line2 $x [ expr $y + 15 ] $x [ expr $bottom - 14] $fg ]
		# ������� �����
		set line3 [ make_line line3 [ expr $x + 15 ] $y $rightt $y $fg ]
		} else {
			set line1 [ make_line line1 $x $bottom $rightb $bottom $fg ]  
			set line2 [ make_line line2 $x $y $x $bottom $fg ]
			set line3 [ make_line line3 $x $y $rightt $y $fg ]
		}

		set number [ segments_from_height $h ]
		set coords [ arrow_rounded_outline1 $x $y 31 31 $number]
		set bend1 [ make_prim main2 line $coords "" "" $fg ""]
		set coords [ arrow_rounded_outline2 $x [ expr { $y + $h } ] 30 30 $number]
		set bend2 [ make_prim main3 line $coords "" "" $fg ""]
	}
	set head [ make_head $x $y $w $b ]
	if { $arrow_style > 0} {
		return [ list $bend1 $bend2 $line1 $line2 $line3 $head ]
	} else {
		return [ list $line1 $line2 $line3 $head ]
	}
}

proc arrow_rounded_outline1 { left top width height number } {
	set nw [ arc_nw $left $top $height $number ]
	set x1 [ expr $left + $height / 2.0 ]
	set leto [ list $x1 $top ]
	set result [ concat $nw $leto ]
}

proc arrow_rounded_outline2 { left top width height number } {
	set sw [ arc_sw $left [ expr $top - $height ] $height $number ]
	set x2 [ expr $left + $width - $height / 2.0 ]
	set ribo [ list $x2 $top ]
	set result [ concat $ribo  $sw ]
}

proc arrow_rounded_outline3 { left top width height number } {
	set ne [ arc_ne [ expr $left - $width ] $top $width $height $number ]
	set result [ concat $ne ]
}

proc arrow_rounded_outline4 { left top width height number } {
	set se [ arc_se [ expr $left - $width ] [ expr $top - $height ] $width $height $number ]
	set result [ concat $se]
}


proc arrow.icons { text text2 color x y w h a b } {
	return {}
}


proc arrow.handles { x y w h a b } {
	set result {}
	if { $b == 0 } {
		set leftu [ expr { $x - $w } ]
		set leftd [ expr { $x - $a } ]
		set bottom [ expr { $y + $h } ]
		lappend result [ make_vertex nw $leftu $y ]
		lappend result [ make_vertex ne $x $y ]
		lappend result [ make_vertex se $x $bottom ]
		lappend result [ make_vertex sw $leftd $bottom ]
	} else {
		set rightu [ expr { $x + $w } ]
		set rightd [ expr { $x + $a } ]
		set bottom [ expr { $y + $h } ]
		lappend result [ make_vertex ne $rightu $y ]
		lappend result [ make_vertex nw $x $y ]
		lappend result [ make_vertex sw $x $bottom ]
		lappend result [ make_vertex se $rightd $bottom ]
	}
	return $result
}


proc arrow.nw { dx dy x y w h a b } {
	if { $b == 0 } {
		set y2 [ expr { $y + $dy } ]
		set h2 [ expr { $h - $dy } ]
		if { $h2 < 30 } { set h2 30 }
		set w2 [ expr { $w - $dx } ]
		if { $w2 < 30 } { set w2 30 }
		return [ list $x $y2 $w2 $h2 $a $b ]
	} else {
		set x2 [ expr { $x + $dx } ]
		set y2 [ expr { $y + $dy } ]
		set h2 [ expr { $h - $dy } ]
		if { $h2 < 30 } { set h2 30 }
		set w2 [ expr { $w - $dx } ]
		if { $w2 < 30 } { set w2 30 }
		set a2 [ expr { $a - $dx } ]
		if { $a2 < 30 } { set a2 30 }
		
		return [ list $x2 $y2 $w2 $h2 $a2 $b ]
	}
}


proc arrow.ne { dx dy x y w h a b } {
	if { $b == 0 } {
		set x2 [ expr { $x + $dx } ]
		set y2 [ expr { $y + $dy } ]
		set h2 [ expr { $h - $dy } ]
		if { $h2 < 30 } { set h2 30 }
		set w2 [ expr { $w + $dx } ]
		if { $w2 < 30 } { set w2 30 }
		set a2 [ expr { $a + $dx } ]
		if { $a2 < 30 } { set a2 30 }
		return [ list $x2 $y2 $w2 $h2 $a2 $b ]
	} else {
		set y2 [ expr { $y + $dy } ]
		set h2 [ expr { $h - $dy } ]
		if { $h2 < 30 } { set h2 30 }
		set w2 [ expr { $w + $dx } ]
		if { $w2 < 30 } { set w2 30 }
		return [ list $x $y2 $w2 $h2 $a $b ]	
	}
	
	
}


proc arrow.sw { dx dy x y w h a b } {
	if { $b == 0 } {
		set a2 [ expr { $a - $dx } ]
		if { $a2 < 30 } { set a2 30 }
		set h2 [ expr { $h + $dy } ]
		if { $h2 < 30 } { set h2 30 }
		return [ list $x $y $w $h2 $a2 $b ]
	} else {
		set x2 [ expr { $x + $dx } ]
		set h2 [ expr { $h + $dy } ]
		if { $h2 < 30 } { set h2 30 }
		set w2 [ expr { $w - $dx } ]
		if { $w2 < 30 } { set w2 30 }
		set a2 [ expr { $a - $dx } ]
		if { $a2 < 30 } { set a2 30 }
		
		return [ list $x2 $y $w2 $h2 $a2 $b ]	
	}
}

proc arrow.se { dx dy x y w h a b } {
	if { $b == 0 } {
		set x2 [ expr { $x + $dx } ]
		set h2 [ expr { $h + $dy } ]
		if { $h2 < 30 } { set h2 30 }
		set w2 [ expr { $w + $dx } ]
		if { $w2 < 30 } { set w2 30 }
		set a2 [ expr { $a + $dx } ]
		if { $a2 < 30 } { set a2 30 }
		
		return [ list $x2 $y $w2 $h2 $a2 $b ]
	} else {
		set a2 [ expr { $a + $dx } ]
		if { $a2 < 30 } { set a2 30 }
		set h2 [ expr { $h + $dy } ]
		if { $h2 < 30 } { set h2 30 }
		return [ list $x $y $w $h2 $a2 $b ]
	}

}

}
