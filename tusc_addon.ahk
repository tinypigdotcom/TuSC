;------------------------------------------------------------------------------
E&ventLog:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
    SendInput, "David Bradford" <davembradford@gmail.com>, {tab}
    SendInput, Event Log{space}
    Gosub, timestamp_x
    SendInput, {space}xeventlog x
    Gosub, timestamp_l
    SendInput, {space}xvn{tab}
    SendInput, Event Log{enter}
    SendInput, ---------------{enter}
    SendInput, * David:{space}this_is_blank{enter}
    SendInput, * Extended family members:{space}{enter}
    SendInput, * Blurb:{space}{enter}{enter}
    SendInput, Things to track:{enter}
    SendInput, ----------------------{enter}
    SendInput, * Exercise{enter}
    SendInput, * Health{enter}
    SendInput, {space}{space}{space}{space}* Hospital{enter}
    SendInput, {space}{space}{space}{space}* Doctor{enter}
    SendInput, {space}{space}{space}{space}* Dentist{enter}
    SendInput, * School{enter}
    SendInput, * Car{enter}
    SendInput, * Purchases{enter}
    SendInput, * Other important event{enter}

return


;------------------------------------------------------------------------------
GoFooBar&dev:
;------------------------------------------------------------------------------
    StringTrimLeft, f_path, f_pathFooBar%A_ThisMenuItemPos%, 0
    If f_path =
        return
    StringTrimLeft, f_param, f_paramFooBar%A_ThisMenuItemPos%, 0
    GoLink(f_path,1,f_param)
return


;------------------------------------------------------------------------------
^!n::
&aNote:
;------------------------------------------------------------------------------
    InputBox, temp_input, Note, Enter note,,,,,,,,%last_note%
    If ErrorLevel
        return
    last_note=%temp_input%
    FormatTime, timestamp, %A_Now%, yyyy MM dd HH mm ss
    FileAppend, `n%timestamp%: %last_note%`n,%sys_drive%\barbaz\notes.txt

    single_space := " "

    StringGetPos, pos, last_note, %single_space%

    if pos >= 0
    {
        StringLeft, out_file, last_note, pos
        StringMid, out_text, last_note, pos + 2

        out_file = %sys_drive%\barbaz\text\%out_file%.txt

        FileAppend, `n%timestamp%: %out_text%`n,%out_file%
    }
return


;------------------------------------------------------------------------------
initialize_main_menu:
;------------------------------------------------------------------------------

/* Main Menu Data
START_LIST;F&ile
&Home                  ; %A_ScriptFullPath% ; %A_ScriptName%
hosts&c                ; %sys_drive%\WINDOWS\system32\drivers\etc\hosts ; hosts
&log                   ; %A_ScriptDir%\tscdebug.txt; debug
START_LIST;Li&nk
Ga&meFaqs              ; http://www.gamefaqs.com/search/index.html?game=; 0
&Google                ; http://www.google.com/#q=; 0
&IMDB                  ; http://www.imdb.com/find?q=; 0
&RottenTomatoes        ; http://www.rottentomatoes.com/search/?search= ; 0
&TheGoogle             ; http://www.google.com ; 1
Ti&nypig               ; http://www.tinypig.com/ ; 1
Wi&kipedia             ; http://en.wikipedia.org/w/index.php?search= ; 0
START_LIST;&WorkLink
&Administration        ; https://www.joben.com/; 1

&View                  ; https://jobenjoben.net ; 0
END_ALL_LISTS
*/

;    menu, man, add, &C
;    menu, man, add, &M
;    menu, man, add, &P

    menu, applications, add, &Calculator
    menu, applications, add, C&MD
    menu, applications, add, P&aint
    menu, applications, add, V&PN
    menu, applications, add
    menu, applications, add, &JustQuit

    menu, workst, add, &Hibernate
    menu, workst, add, &Lock
    menu, workst, add, M&ouseKeys
    menu, workst, add, M&inimizeAll
    menu, workst, add, &Mute
    menu, workst, add, &Volume
    menu, workst, add
    menu, workst, add, &JustQuit

    menu, script, add, &Exit
    menu, script, add, &Reload
    menu, script, add
    menu, script, add, &JustQuit

    menu, gamey, add, Set&GaimWin
    menu, gamey, add, Set&Cygwin
    menu, gamey, add, SetE&xplore
    menu, gamey, add, Set&Firefox
    menu, gamey, add, SetRe&mote
    menu, gamey, add, Set&Outlook
    menu, gamey, add, Set&RTM
    menu, gamey, add, SetRemin&ders
    menu, gamey, add, Set&Scratch
    menu, gamey, add, Set&vi
    menu, gamey, add
    menu, gamey, add, &JustQuit

    menu, functions, add, &Compile
    menu, functions, add, &DumpSTDERR
    menu, functions, add, &EjectAll
    menu, functions, add, E&ventLog
    menu, functions, add, &Madeit
    menu, functions, add, &GamKeys, :gamey
    menu, functions, add, &PrintSTDERR
    menu, functions, add, &UseDataDumper
    menu, functions, add
    menu, functions, add, &JustQuit

    menu, main, add, Wor&kstation, :workst
    menu, main, add, &aNote
    menu, main, add
    menu, main, add, C&hrome
    menu, main, add, &Cygwin
    menu, main, add, E&xplore
    menu, main, add, &Firefox
    menu, main, add, &GaimWin
    menu, main, add, Re&mote
    menu, main, add, &Outlook
    menu, main, add, Options&b
    menu, main, add, &QuickStart
    menu, main, add, &RTM
    menu, main, add, Remin&ders
    menu, main, add, &Scratch
    menu, main, add, Internet&Explorer
    menu, main, add, &vi
    menu, main, add
    menu, main, add, Scri&pt, :script
    menu, main, add, F&unctions, :functions
    menu, main, add, Applica&tions, :applications
    menu, main, add

    menu, tray, add
    menu, tray, add, Capslock

    menu, FooBar&dev, add

    f_AtStartingPos = n
    Loop, Read, %A_LineFile%
    {
        If A_LoopReadLine = END_ALL_LISTS
        {
            If f_AtStartingPos = y
            {
                menu, %menu_choice%, add
                menu, %menu_choice%, add, &JustQuit
            }
            break
        }
        IfInString, A_LoopReadLine, START_LIST
        {
            If f_AtStartingPos = y
            {
                menu, %menu_choice%, add
                menu, %menu_choice%, add, &JustQuit
            }
            f_AtStartingPos = y
            StringSplit, h_line, A_LoopReadLine, `;
            menu_choice = %h_line2%
            StringReplace, menu_var, menu_choice, `&,,1
            menu, %menu_choice%, add
            f_MenuItemCount = 1
            menu, main, add, %menu_choice%, :%menu_choice%
            continue
        }
        If f_AtStartingPos = n
            continue
        f_MenuItemCount++
        If A_LoopReadLine =
            menu, %menu_choice%, add
        else
        {
            StringSplit, f_line, A_LoopReadLine, `;
            f_line1 = %f_line1%
            f_line2 = %f_line2%
            f_line3 = %f_line3%
            Transform, f_path%menu_var%%f_MenuItemCount%, deref, %f_line2%
            Transform, f_param%menu_var%%f_MenuItemCount%, deref, %f_line3%
            Transform, f_line1, deref, %f_line1%
            If f_line2 =
                Menu, %menu_choice%, Add, %f_line1%
            else
                Menu, %menu_choice%, Add, %f_line1%, Go%menu_choice%
            If menu_choice = &WorkLink
            {
                IfInString, f_line2, joben
                {
                  StringReplace, f_line2, f_line2, joben.com, jobenjoben.net, 1
                }
                Transform, f_pathFooBar%f_MenuItemCount%, deref, %f_line2%
                f_paramFooBar%f_MenuItemCount%=2
                If f_line2 =
                    Menu, FooBar&dev, Add, %f_line1%
                else
                    Menu, FooBar&dev, Add, %f_line1%, GoFooBar&dev
            }
        }
    }

    menu, FooBar&dev, add
    menu, FooBar&dev, add, &JustQuit

    menu, &WorkLink, add
    menu, &WorkLink, add, FooBar&dev, :FooBar&dev

    menu, main, add
    menu, main, add, &JustQuit

    menu, tray, click, 1
    menu, tray, default, Capslock

return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Favorites_section                                                        |
;                                                                             |
;=============================================================================+

;------------------------------------------------------------------------------
initialize_favorites:
;------------------------------------------------------------------------------

f_Hotkey = ~!Up

/*
ITEMS IN FAVORITES MENU <-- Do not change this string.
C              ; %sys_drive%\
dmb            ; %sys_drive%\dmb
K Desktop      ; %UserProfile%\Desktop
My Documents   ; %UserProfile%\My Documents
O Dropbox      ; %sys_drive%\dropbox
R Program Files; %ProgramFiles%
Y Cygwin       ; %sys_drive%\dropbox\Dave
U Music        ; %sys_drive%\mp3
W Downloads    ; %UserProfile%\My Documents\Downloads
*/

Hotkey, %f_Hotkey%, f_DisplayMenu
StringLeft, f_HotkeyFirstChar, f_Hotkey, 1
if f_HotkeyFirstChar = ~  ; Show menu only for certain window types.
    f_AlwaysShowMenu = n
else
    f_AlwaysShowMenu = y

f_AtStartingPos = n
f_MenuItemCount = 0
Loop, Read, %A_LineFile%
{
    if f_FileExt <> Exe
    {
        ; Since the menu items are being read directly from this
        ; script, skip over all lines until the starting line is
        ; arrived at.
        if f_AtStartingPos = n
        {
            IfInString, A_LoopReadLine, ITEMS IN FAVORITES MENU
                f_AtStartingPos = y
            continue  ; Start a new loop iteration.
        }
        ; Otherwise, the closing comment symbol marks the end of the list.
        if A_LoopReadLine = */
            break  ; terminate the loop
    }
    ; Menu separator lines must also be counted to be compatible
    ; with A_ThisMenuItemPos:
    f_MenuItemCount++
    if A_LoopReadLine =  ; Blank indicates a separator line.
        Menu, Favorites, Add
    else
    {
        StringSplit, f_line, A_LoopReadLine, `;
        f_line1 = %f_line1%  ; Trim leading and trailing spaces.
        f_line2 = %f_line2%  ; Trim leading and trailing spaces.
        ; Resolve any references to variables within either field, and
        ; create a new array element containing the path of this favorite:
        Transform, f_path%f_MenuItemCount%, deref, %f_line2%
        Transform, f_line1, deref, %f_line1%
        Menu, Favorites, Add, %f_line1%, f_OpenFavorite
    }
}

IniRead, SettingStartup, %ini_file%, settings, run_startup_routine, 0
if (SettingStartup)
{
    MsgBox , 3, Startup, Run Startup?, 120
    IfMsgBox Yes
        Gosub, Startup
    else IfMsgBox Timeout
        Gosub, Startup
}
return
