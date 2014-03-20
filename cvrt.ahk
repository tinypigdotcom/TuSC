#SingleInstance force

passwd=

get_one()
{
    Random, oneIndex, 65, 90
    Random, lowCase, 0, 1
    if(lowCase)
    {
        oneIndex+=32
    }
    Transform, newChar, Chr, oneIndex

    return %newChar%
}

make_normal(input)
{
    StringSplit, inputLetters, input
    output=
    good=0
    Loop, %inputLetters0%
    {
        this_letter := inputLetters%a_index%
        if(good)
        {
            output := output . this_letter
            good=0
        }
        else
        {
            good=1
        }
    }
    return %output%
}

pass_gen(length=8)
{
    global
    Loop, %length%
    {
        newIndex := get_one()
        Transform, newChar, Chr, newIndex
        passwd = %passwd%%newChar%
    }
}

;pass_gen(20)
;MsgBox, %passwd%

Gui, Add, Edit, x66 y17 w300 h20 vNormalPhrase, Edit
Gui, Add, Edit, x66 y57 w300 h20 vBusyPhrase, Edit
Gui, Add, Text, x16 y17 w40 h20 , &Normal
Gui, Add, Button, x376 y17 w80 h20 gMakeBusy, &Convert
Gui, Add, Button, x376 y57 w80 h20 gMakeNormal, C&onvert
Gui, Add, Text, x16 y57 w40 h20 , &Busy
; Generated using SmartGUI Creator 4.0
Gui, Show, x353 y138 h97 w483, New GUI Window
Return

MakeNormal:
    GuiControlGet, BusyPhrase

    output := make_normal(BusyPhrase)

    GuiControl, ,NormalPhrase, %output%
return

MakeBusy:
    GuiControlGet, NormalPhrase

    output := get_one()
    StringSplit, NormalLetters, NormalPhrase
    Loop, %NormalLetters0%
    {
        this_letter := NormalLetters%a_index%
        next_letter := get_one()
        output = %output%%this_letter%%next_letter%
    }

    GuiControl, ,BusyPhrase, %output%
return

GuiClose:
GuiEscape:
    ExitApp
return

