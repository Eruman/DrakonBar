; Autogenerated with DRAKON Editor 1.23
; AutoHotkey_L beta v1.7 code generator used


return ;This "return" is here to prevent unintended execution of code.
DoCheckDoLoop(a) {
    Loop, {
        ; item 6
        line := FileRead(a)
        ; item 7
        if (line = 0) {
            break
        } else {
            
        }
        ; item 10
        PrintLine(line)
    }
    return
}


