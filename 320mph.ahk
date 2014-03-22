/*
___________________________________________
              320MPH by Rajat
        Ultra Fast Anything-Launcher
Order of Results:
    - Recently used items
    - Items with name starting with search querry
    - Items with search querry anywhere in their name
    - Items with search querry anywhere in their path
___________________________________________
*/

AutoTrim, Off
SetBatchLines, -1
MainWnd = 320MPH -- Rajat
SetKeyDelay, 0

;___________________________________________
IniFile = %A_ScriptDir%\320MPH.ini
IfNotExist, %IniFile%
    Gosub, build_ini

;Reading Settings
IniRead, PathList, %IniFile%, Settings, PathList, %A_MyDocuments%|%A_ProgramFiles%
IniRead, TypeList, %IniFile%, Settings, TypeList, exe|lnk|ahk|url|mp3
IniRead, ExcludeList, %IniFile%, Settings, ExcludeList, about|history|readme|remove|uninstall|license
IniRead, AlwaysScan, %IniFile%, Settings, AlwaysScan, %UserProfile%\Recent|%A_StartMenuCommon%|%A_StartMenu%|%A_Desktop%
IniRead, MaxLastUsed, %IniFile%, Settings, MaxLastUsed, 50
IniRead, WaitTime, %IniFile%, Settings, WaitTime, 100
IniRead, ShowIcons, %IniFile%, Settings, ShowIcons, 1
IniRead, MinLen, %IniFile%, Settings, MinLen, 2
IniRead, ListFile, %IniFile%, Settings, ListFile, RunList.txt
IniRead, ShellIntegration, %IniFile%, Settings, ShellIntegration, 1
IniRead, GuiWMinus, %IniFile%, Settings, GuiWMinus, 20
IniRead, GuiHMinus, %IniFile%, Settings, GuiHMinus, 250
IniRead, UsedList, %IniFile%, Settings, UsedList, |

LastUsedList = %UsedList%
GuiW := A_ScreenWidth - GuiWMinus
GuiH := A_ScreenHeight - GuiHMinus
AlwaysScan := ExpandVars(AlwaysScan)
PathList := ExpandVars(PathList)
StringRight, ExtChk, A_ScriptFullPath, 4
IfEqual, ExtChk, .exe
IfEqual, ShellIntegration, 1
{
    RegWrite, REG_SZ, HKCR, *\Shell\320MPH\Command,, "%A_ScriptFullPath%" "`%1"
    RegWrite, REG_SZ, HKCR, Folder\shell\320MPH\command,, "%A_ScriptFullPath%" "`%1"
}
Else
{
    RegDelete, HKCR, *\Shell\320MPH,
    RegDelete, HKCR, Folder\Shell\320MPH,
}
RParam = %1%
IniRead, UsedList, %IniFile%, Settings, UsedList
IfEqual, UsedList, ERROR
    UsedList =
UsedList0 =
Loop, Parse, UsedList, |
{
    IfNotExist, %A_LoopField%, Continue
    UsedList0 = %UsedList0%|%A_LoopField%
}
UsedList = %UsedList0%

;___________________________________________
;create scanned result list on first run
IfExist, %A_ScriptDir%\%ListFile%
{
    ItemList =
    Loop, Read, %A_ScriptDir%\%ListFile%
    {
        IfEqual, A_LoopReadLine,, Continue
        ItemList = %ItemList%|%A_LoopReadLine%
    }
}
Else
    Gosub, ButtonScan

;scan always updated list
Loop, Parse, AlwaysScan, |
{
    Loop, %A_LoopField%\*.*, 0, 1
    {
        SplitPath, A_LoopFileFullPath, FName, FDir, FExt, FNameNoExt, FDrive
        ;only filetypes defined are added
        IfNotInString, TypeList, %FExt%, Continue

        ;excluding items based on ExcludeList
        Cont = 0
        Loop, Parse, ExcludeList, |
        {
            IfInString, FName, %A_LoopField%
            {
                Cont = 1
                Break
            }
        }

        IfEqual, Cont, 1
            Continue

        ;reaching here means that file is not to be excluded and
        ;has a desired extension

        RecentList = %RecentList%|%A_LoopFileFullPath%
    }
}

StringTrimLeft, RecentList, RecentList, 1
ItemList = %RecentList%%ItemList%
LVGuiW := GuiW - 12
LVGuiH := GuiH - 64
StatusY := GuiH - 25
Gui, -Caption +Border
Gui, Add, Text, x6 y7 w40 h20, Search:
Gui, Add, Edit, x46 y5 w150 h20 vCurrText gGetText,
Gui, Add, Text, x210 y7 w40 h20, Params:
Gui, Add, Edit, x250 y5 w250 h20 vRParam, %RParam%
Gui, Add, ListView, x6 y35 w%LVGuiW% h%LVGuiH% vSelItem HScroll gSelection AltSubmit, Name|Ext|Folder
Gui, Add, Button, 0x8000 x516 y5 w50 h20 Default, &Open
Gui, Add, Button, 0x8000 x576 y5 w50 h20, &Scan
Gui, Add, Text, x6 y%StatusY% w120 h20 vResults,
Gui, Font, S10 CDefault Italic Bold, Verdana
Gui, Add, Text, x450 y%StatusY% w150 h20 Right, %MainWnd%
LV_ModifyCol(1, 100)
LV_ModifyCol(2, 60)
LV_ModifyCol(3, 250)
Gui, Show, h%GuiH% w%GuiW%, %MainWnd%
LastText = fadsfSDFDFasdFdfsadfsadFDSFDf
;SetTimer, GetText, 200
Gosub, GetText
;Sleep, 200
Control, Choose, 1, SysListView321, %MainWnd%
Return

Up::
    IfWinNotActive, %MainWnd%,
    {
        Send, {Up}
        Return
    }
    ControlGetFocus, CurrCtrl, %MainWnd%
    IfEqual, CurrCtrl, Edit1
        ControlSend, SysListView321, {Up}, %MainWnd%
Return

Down::
    IfWinNotActive, %MainWnd%,
    {
        Send, {Down}
        Return
    }
    ControlGetFocus, CurrCtrl, %MainWnd%
    IfEqual, CurrCtrl, Edit1
        ControlSend, SysListView321, {Down}, %MainWnd%
Return

^Del::
    IfWinNotActive, %MainWnd%,, Return
    ControlGetText, CurrText, Edit1, %MainWnd%
    IfNotEqual, CurrText,, Return
    SelItem := LV_GetNext()
    LV_GetText(FName, SelItem, 1)
    LV_GetText(FExt, SelItem, 2)
    LV_GetText(FDir, SelItem, 3)
    IfEqual, FExt,
        Pth = %FDir%\%FName%
    IfNotEqual, FExt,
        Pth = %FDir%\%FName%.%FExt%
    StringReplace, UsedList, UsedList, |%pth%,, A
    IniWrite, %UsedList%, %IniFile%, Settings, UsedList
    LastText = x
    Goto, GetText
Return

GetText:
    ControlGetText, CurrText, Edit1, %MainWnd%
    IfEqual, CurrText, %LastText%, Return
    StringLen, Check, CurrText
    IfGreater, Check, 0
    IfLess, Check, %MinLen%
        Return

    LastText = %CurrText%
    ;from last used_____________________________
    IfEqual, CurrText,
    {
        IfEqual, ShowIcons, 1
        {
            IL_Destroy(ImageListID1)

            ; Create an ImageList so that the ListView can display some icons:
            ImageListID1 := IL_Create(5, 10)
            ; Attach the ImageLists to the ListView so that it can later display the icons:
            LV_SetImageList(ImageListID1)
        }

        LV_Delete()
        Count =
        StringTrimLeft, UsedList0, UsedList, 1
        Loop, Parse, UsedList0, |
        {
            ;check for change in search querry
            ControlGetText, CurrText, Edit1, %MainWnd%
            IfNotEqual, CurrText, %LastText%, Goto, GetText
            SplitPath, A_LoopField, FName, FDir, FExt, FNameNoExt
            Count ++
            IfGreater, Count, %MaxLastUsed%, Break
            IfEqual, ShowIcons, 1
            {
                hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, A_LoopField, UShortP, iIndex)
                DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon)
                DllCall("DestroyIcon", Uint, hIcon)
            }
            LV_Add("Icon" Count, FNameNoExt, FExt, FDir )
            ;select first item
            IfEqual, A_Index, 1
                ControlSend, SysListView321, {Down}, %MainWnd%
        }
    }

    ;from all items_____________________________
    IfNotEqual, CurrText,
    {
        IfInString, ItemList, %CurrText%
            IfEqual, ShowIcons, 1
            {
                IL_Destroy(ImageListID1)

                ; Create an ImageList so that the ListView can display some icons:
                ImageListID1 := IL_Create(20, 50)
                ; Attach the ImageLists to the ListView so that it can later display the icons:
                LV_SetImageList(ImageListID1)
            }
        LV_Delete()
        ;___________________________________________
        ; Advanced Search
        MatchPList1 =
        MatchPList2 =
        MatchPList3 =
        Count =

        ;earliest in searh results are recently used items
        SearchList = %UsedList%%ItemList%
        Loop, Parse, SearchList, |
        {
            ;check for change in search querry
            ControlGetText, CurrText, Edit1, %MainWnd%
            IfNotEqual, CurrText, %LastText%, Goto, GetText
            CurrItem = %A_LoopField%
            ;remove duplicate entry that exists both in usedlist and itemlist
            CheckList = %MatchPList1%%MatchPList2%%MatchPList3%|
            IfInString, CheckList, |%CurrItem%|, Continue
            SplitPath, CurrItem, FName, FDir, FExt, FNameNoExt, FDrive
            StringLen, Len, CurrText
            StringLeft, LText, FName, %Len%
            ;Matching leftmost text
            IfEqual, LText, %CurrText%
            {
                MatchPList1 = %MatchPList1%|%CurrItem%
                Continue
            }
            ;Matching file name only
            ;fuzzy search
            MatchFound = Y
            Loop, Parse, CurrText, %A_Space%
                IfNotInString, FName, %A_LoopField%
                    MatchFound = N
            IfEqual, MatchFound, Y
            {
                MatchPList2 = %MatchPList2%|%CurrItem%
                Continue
            }
            ;search everywhere
            ;fuzzy search
            MatchFound = Y

            Loop, Parse, CurrText, %A_Space%
                IfNotInString, CurrItem, %A_LoopField%
                    MatchFound = N

            IfEqual, MatchFound, Y
            {
                MatchPList3 = %MatchPList3%|%CurrItem%
                Continue
            }
        }

        MatchPList = %MatchPList1%%MatchPList2%%MatchPList3%

        StringTrimLeft, MatchPList, MatchPList, 1

        Loop, Parse, MatchPList, |
        {
            ;check for change in search querry
            ControlGetText, CurrText, Edit1, %MainWnd%
            IfNotEqual, CurrText, %LastText%, Goto, GetText
            Count ++
            SplitPath, A_LoopField, FName, FDir, FExt, FNameNoExt, FDrive
            IfEqual, ShowIcons, 1
            {
                hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, A_LoopField, UShortP, iIndex)
                DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon)
                DllCall("DestroyIcon", Uint, hIcon)
            }
            LV_Add("Icon" Count, FNameNoExt, FExt, FDir )
            ;select first item
            IfEqual, A_Index, 1
                ControlSend, SysListView321, {Down}, %MainWnd%
        }

        IfEqual, Count,
            LV_Delete()
    }
    ;post results
    Results := LV_GetCount()
    GuiControl,, Results, Results = %Results%
    LV_ModifyCol()
Return

ButtonScan:
    SplashImage,, W190 H30 B1,, Scanning..,
    FileDelete, %A_ScriptDir%\%ListFile%

    ;generating file list
    Loop, Parse, PathList, |
    {
        IfNotExist, %A_LoopField%, Continue

        Loop, %A_LoopField%\*.*, 0, 1
        {
            SplitPath, A_LoopFileFullPath, FName, FDir, FExt, FNameNoExt, FDrive
            ;only filetypes defined are added
            IfNotInString, TypeList, %FExt%, Continue
            ;excluding items based on ExcludeList
            Cont = 0
            Loop, Parse, ExcludeList, |
            {
                IfInString, FName, %A_LoopField%
                {
                    Cont = 1
                    Break
                }
            }
            IfEqual, Cont, 1
                Continue
            ;reaching here means that file is not to be excluded and
            ;has a desired extension
            FileAppend, %A_LoopFileFullPath%`n, %A_ScriptDir%\%ListFile%
        }
    }
    ItemList =
    Loop, Read, %A_ScriptDir%\%ListFile%
    {
        IfEqual, A_LoopReadLine,, Continue
        ItemList = %ItemList%|%A_LoopReadLine%
    }

    ItemList = %RecentList%%ItemList%
    LastText =

    SplashImage, Off
Return

ButtonOpen:
    Gui, Submit, NoHide
    GetKeyState, ShKey, Shift
    GetKeyState, CtKey, Control
    ControlFocus, SysListView321, %MainWnd%
    SelItem := LV_GetNext()
    IfEqual, SelItem, 0
        RunSearch = 1
    IfEqual, CtKey, D
        RunSearch = 1
    IfEqual, RunSearch, 1
    {
        RunItem = %CurrText%
        ;run unrecognised cmd
        IfNotExist, %CurrText%
        {
            FileExist = 0
            Goto, AddToList
        }
    }
    ;running a found file/folder
    IfNotEqual, RunSearch, 1
    Loop
    {
        LV_GetText(FName, SelItem, 1)
        LV_GetText(FExt, SelItem, 2)
        LV_GetText(FDir, SelItem, 3)
        IfEqual, FExt,
            RunItem = %FDir%\%FName%
        IfNotEqual, FExt,
            RunItem = %FDir%\%FName%.%FExt%
        IfExist, %RunItem%
        {
            FileExist = 1
            Break
        }
    }

    ;remove the last \ from a launched folder's name
    StringRight, check, RunItem, 1
    IfEqual, check, \
        StringTrimRight, RunItem, RunItem, 1

    ;add the \ back if the target is a drive path
    StringLen, check, RunItem
    IfLess, check, 3
        RunItem = %RunItem%\
    Add2History = %RunItem%
    ;get real file path from shortcut
    StringRight, check, RunItem, 4
    IfEqual, check, .lnk
    {
        FileGetShortcut, %RunItem%, LnkTarget
        IfNotInString, LnkTarget, {
        IfNotInString, LnkTarget, }
            RunItem = %LnkTarget%
    }
    SplitPath, RunItem, FName, FDir, FExt, FNameNoExt, FDrive
    ;shift key down opens host folder
    IfEqual, ShKey, D
    {
        Run, Explorer %FDir%,, UseErrorLevel
        ExitApp
    }
    AddToList:
    ;simple run
    IfEqual, RParam,
        Run, %RunItem%, %FDir%, UseErrorLevel
    ;runtime param
    IfNotEqual, RParam,
        Run, %RunItem% "%RParam%", %FDir%, UseErrorLevel

    IfEqual, FileExist, 1
        StringReplace, UsedList, UsedList, |%Add2History%,, A

    ;leave only max items in list
    StringSplit, UsedItem, UsedList, |
    UsedList =
    Loop, %MaxLastUsed%
    {
        CurrItem := UsedItem%A_Index%
        IfEqual, CurrItem,, Continue
        UsedList = %UsedList%|%CurrItem%
    }
    IniWrite, |%Add2History%%UsedList%, %IniFile%, Settings, UsedList
    IniWrite, %LastUsedList%, %IniFile%, Settings, LastUsedList
ExitApp

Selection:
  SelItem := LV_GetNext()
    LV_GetText(0FName, SelItem, 1)
    LV_GetText(0FExt, SelItem, 2)
    LV_GetText(0FDir, SelItem, 3)
    Pth = %0FDir%\%0FName%.%0FExt%
    IfEqual, FExt, lnk
    {
        WinGetPos, wX, wY, wW, wH, %MainWnd%
        FileGetShortcut, %Pth%, FTarget
        ToShow = %FTarget%
        ToolTip, %ToShow%, 0, %wH%
    }
    Else
        ToolTip
  IfEqual, A_GuiControlEvent, DoubleClick
    GoTo, ButtonOpen
Return

GuiEscape:
GuiClose:
    ExitApp
;Chris made this long ago!
ExpandVars(Var)
{
    var_new = %var%
    in_reference = n
    Loop, parse, var_new, `%
    {
        if in_reference = n
        {
            in_reference = y
            continue
        }
        ; Otherwise, A_LoopField is a variable reference:
        StringTrimLeft, ref_contents, %A_LoopField%, 0
        StringReplace, var_new, var_new, `%%A_LoopField%`%, %ref_contents%, all
        in_reference = n
    }
    Return, var_new
}

;------------------------------------------------------------------------------
build_ini:
;------------------------------------------------------------------------------
    IniWrite, %A_StartMenuCommon%|%A_StartMenu%|%A_Desktop%|%A_DesktopCommon%|%A_ProgramsCommon%, %IniFile%, Settings, PathList
    IniWrite, exe|lnk|ahk|au3|url|mp3|doc|xls|bat|rdp|js, %IniFile%, Settings, TypeList
    IniWrite, about|history|readme|remove|uninstall|license, %IniFile%, Settings, ExcludeList
    IniWrite, %UserProfile%\Recent, %IniFile%, Settings, AlwaysScan
    IniWrite, 100, %IniFile%, Settings, MaxLastUsed
    IniWrite, 100, %IniFile%, Settings, WaitTime
    IniWrite, 1, %IniFile%, Settings, ShowIcons
    IniWrite, 2, %IniFile%, Settings, MinLen
    IniWrite, RunList.txt, %IniFile%, Settings, ListFile
    IniWrite, 0, %IniFile%, Settings, ShellIntegration
    IniWrite, 600, %IniFile%, Settings, GuiWMinus
    IniWrite, 600, %IniFile%, Settings, GuiHMinus
    IniWrite, |, %IniFile%, Settings, UsedList
return

