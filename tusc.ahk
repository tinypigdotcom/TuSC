;Scaffolding_section <-- A quick shortcut to whatever part I'm currently working on
;____Approximate_middle_of_table_of_contents
/*

==============================
  TuSC: Total System Control
==============================

Table_of_Contents
-----------------
Capslock_menu_section
Clipboard_section
Control_j_menu_section
Favorites_section
Function_section
GUI_section
____Approximate_middle_of_table_of_contents
gui_toolbar_section
Initialization_section
Mouse_mode_section
Outlook_section
ReceiveMessage
Timestamp_section
Volume_section

+================+
| WINDOWS 7 NOTE |
+================+
To make everything* work on Windows 7, find the autohotkey executable (typically
C:\Program Files\AutoHotkey\AutoHotkey.exe) and right-click on it. Select
Properties and then the Compatibility tab.  Make sure "Run this program as an
administrator." is checked.

*everything: Not everything**  Mostly the hotkeys working when there is no
active window.  It seems to take administrator privileges to allow receiving of
hotkeys in that case.

**Not everything: maybe not anything.  It's still being pretty flaky with no
active window.

Credits:
--------
David M. Bradford, tinypig.com

Additional code:
Volume - Rajat
Favorites - savage, ChrisM, Rajat
Usernames in the credits are from the AutoHotKey forums - http://www.autohotkey.com/forum/
GUIs Generated using SmartGUI Creator 4.0


TODO
----

 * if flash video is in focus, many remapped keys such as volume controls don't work
 * some flakiness still with activewindow.  happens at least on directories selection
 * add option to erase copy history
 * Snooze routine for Work Log Reminders
 * programmatically add things like links
 * Eliminate mixed notation := vs = and if vs if()
 * re-check section headings/comments now that script is put back together
 * clean up code
     * refactor duplicate or similar lines and routines
 * add front end menu options where it is feasible
 * Either eliminate external file dependencies or document them

DONE
----
 * fix freecommander without using "ask"
 * TuSC should beep on volume set
 * privacy mode
 * NOTHING runs only at startup because when values are gathered, they can ALWAYS change
 * Improve debug system for levels of detail or temporary on/off controls
 * get rid of sleeps where appropriate - use timers instead.  This includes
 waits in WinActivate and such

WON'T DO
--------
 * ignore work todo entries or separate from work log completely

Example macros:

        ;_({say: "HEY!"})
        say({ param1: "HEY!", linenumber: A_LineNumber })

            becomes

        say({ param1: "HEY!", linenumber: A_LineNumber })


        ;_({debug: "hi", debug_level: 1})
        debug({ param1: "hi", debug_level: 1, linenumber: A_LineNumber })

            becomes

        debug({ param1: "hi", debug_level: 1, linenumber: A_LineNumber })

This will work with any function with a param1, including:
    * attention()
    * debug()
    * say()
    * warn()

But NOT die() because die tries to keep everything "primative" since after
all, script is dying.

*/


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Initialization_section                                                   |
;                                                                             |
;=============================================================================+

#Warn All, OutputDebug
#SingleInstance ignore
#WinActivateForce

do_macros()

StringReplace, B_ProgramFiles, A_ProgramFiles, %A_Space%(x86)
X_ProgramFiles = %B_ProgramFiles% (x86)
TypeList = exe|lnk
PathList = %A_StartMenuCommon%|%A_StartMenu%|%A_Desktop%|%A_DesktopCommon%|%A_ProgramsCommon%|%B_ProgramFiles%|%X_ProgramFiles%
fileArray := { }
winList := { }
vimList := { }

VERSION=pyrite ;vv
;chrysocolla
;quartz, tourmaline, carnelian, sugilite
;malachite, rose quartz, snowflake obsidian, ruby
;jasper, amethyst, lapis lazuli
;previous version names: tigerseye

prog = TuSC %VERSION%
compname = %A_ComputerName%

Loading_Progress(10)

OnExit, ExitSub

SplitPath, A_ScriptName,,, f_FileExt, f_FileNoExt

ini_file_nopath = %f_FileNoExt%.ini
ini_file = %A_ScriptDir%\%ini_file_nopath%
IfNotExist, %ini_file%
    Gosub, build_ini

custom_dir := f_IniRead({ filename:   ini_file
                        , category:   "settings"
                        , variable:   "customization_dir"
                        , linenumber: A_LineNumber })

my_ini_file_nopath = my_%f_FileNoExt%.ini
my_ini_file = %custom_dir%\my_%ini_file_nopath%
IfNotExist, %my_ini_file%
    Gosub, build_my_ini

;new_file_code
file_file = %custom_dir%\files.ini
IfNotExist, %file_file%
    Gosub, build_file_file

dir_file = %A_ScriptDir%\directories.ini
IfNotExist, %dir_file%
    Gosub, build_dir_file

if f_FileExt = Exe
{
    f_FavoritesFile = %A_ScriptDir%\tusc.ahk
    f_MainMenuFile = %A_ScriptDir%\tusc.ahk
    f_ReadFile = %A_ScriptDir%\tusc.ahk
}
else
{
    f_FavoritesFile = %A_ScriptFullPath%
    f_MainMenuFile = %A_ScriptFullPath%
    f_ReadFile = %A_ScriptFullPath%
}

Loading_Progress(20)

; How Debug works:
; ================
; Default level for debug statements is 2.  Debug statements will only print if
; Master Debug Level >= statement level.  So, if you create a level 1 debug
; statement and set Master Debug Level to 1, only that one will print.  Setting
; Master Debug Level to 2 will trigger a lot of debug output.
;
; tscdebug.txt is created in script directory with all debug output
;
; Template debug statement:
;
; E-CINT: Counter-intuitive - spaces between dot are significant, ex: ."text" is
; an empty string. Solve with concat()!
;


on_windows_7=0
if(A_OSVersion = "WIN_7")
{
    on_windows_7++
}

RM_suspend_state=0
rm4_vbox_suspended=0
;debug("0:rm4_vbox_suspend")
rm4_is_alive=1
rm4_is_alive1=1
rm4_is_alive2=0

switch_back_flag=0
reminder_count=0
timeout=5
q_window_found=0
private_gui_start=50

olt_hidden=1
olt_Title=O Toolbar

tdt_hidden=1
tdt_Title=Todo Toolbar

PROGRESS_POKER=2

SHOWTIP_JMENU=2
SHOWTIP_DEBUG=3
SHOWTIP_BIG=4
SHOWTIP_SAY=5
SHOWTIP_MODE=6
SHOWTIP_ERR=7

SHOWTIP_BIG_X=0
SHOWTIP_BIG_Y=50

SHOWTIP_ERR_X=0
SHOWTIP_ERR_Y=60

SHOWTIP_JMENU_X=0
SHOWTIP_JMENU_Y=30

SHOWTIP_SAY_X=500
SHOWTIP_SAY_Y=0

SHOWTIP_MODE_X=0
SHOWTIP_MODE_Y=0

mouse_step0=100
mouse_step1=33
mouse_step2=6
mouse_esc=0
mouse_margin=0
mouse_move_speed=6

shimmy_step=0
shimmy_timer=250
shimmy_amt=1
shimmy_speed=100

outlook_esc=0
volume_esc =0
outlook_x=139
outlook_y_init=125
outlook_y := outlook_y_init
outlook_step=20
outlook_folders=8
outlook_current_folder=1

side_note=
(
***************************


  Mouse Mode %mouse_step%

  hjkl = movement
  `; = change amount to move
  u = left click
  i = right click
  m = left drag
  , = right drag
  . = center screen
  HML = high medium low
  0 = leftmost
  $ = rightmost

***************************
)

notes_list=
save_notes_list=
notes_list := f_IniRead({ filename:   ini_file
                        , category:   "settings"
                        , variable:   "notes_list"
                        , linenumber: A_LineNumber })

save_notes_list=%notes_list%

pbw=20 ; Private Button Width
bw=130 ; Button Width
mw=146 ; Menu Width
mh=587 ; Menu Height
bopt=Left ; Menu Button control options

left_status=U
right_status=U

vol_setting=0
vol_max_keys := 60

Loading_Progress(30)

EnvGet, sys_drive, SystemDrive

ImageDir=%A_ScriptDir%\image
prog_icon = %ImageDir%\%f_FileNoExt%.ico
mute_icon = %ImageDir%\%f_FileNoExt%_mute.ico

cb_dir = %A_ScriptDir%\cb

Gosub, read_settings

FileRead, cb_index, %cb_dir%\CB_index
if ErrorLevel = 1
    cb_index=0

cb_prefix = CB
Gosub, cb_init
cb_prefix = ECB
Gosub, cb_init

Gosub, starttusc_init

Loading_Progress(40)

CoordMode, Menu
CoordMode, ToolTip, Screen
SetFormat, float, 0.0

vol_Master_save := f_IniRead({ filename:   ini_file
                             , category:   "state"
                             , variable:   "sound"
                             , linenumber: A_LineNumber })

SoundGet, vol_j, Master
process_volume_icon(vol_j)

StringLen, cb_max, cb_key_legal
StringLen, cb_rotate_max, cb_key_rotate
StringLen, cb_static_max, cb_key_static

Loading_Progress(50)


debug({ param1: "started", linenumber: A_LineNumber })

ohide_msecs=500
process_ohide()

toolbar_update_msecs=1000
gvim_update_msecs=100

ocred_msecs=2000
process_ocred()

poker_msecs=15000
poker_msecs=300000
process_poker()

eye_rest_msecs=1200000
process_eye_rest()

Gosub, initialize_volume

Loading_Progress(60)

SetBatchLines, 10ms

Gosub, initialize_favorites

Loading_Progress(70)

Gosub, init_gui_toolbar

private_on := f_IniRead({ filename:   ini_file
                        , category:   "state"
                        , variable:   "private_on"
                        , linenumber: A_LineNumber })
private_on := private_on ? 0 : 1 ; so subsequent toggle will switch back to desired state
Gosub, private_nohide

Loading_Progress(90)
Clear_Loading_Progress()

Gosub, init_guis

SetTimer,toolbar_update,%toolbar_update_msecs%
SetTimer,oneify_gvim_windows,%gvim_update_msecs%

OnMessage(0x1001,"ReceiveMessage")

OnMessage(0x200, "WM_MOUSEMOVE")

;OnMessage(0x201, "WM_LBUTTONDOWN")

return

ReceiveMessage(Message) {
    if (Message = 1)
        ExitApp
    Else if (Message = 2)
        Gosub Mainmenu
    Else if (Message = 3)
        Gosub Firefox
    Else if (Message = 5)
        Gosub Home
    Else if (Message = 6)
        Gosub RestartScript
    Else if (Message = 7)
        Gosub TotalKill
    Else if (Message = 8)
        Gosub PrivateToggle
    Else if (Message = 9)
        Gosub Scratch
    Else if (Message = 10)
        Gosub Explore
    Else if (Message = 11)
        Gosub RM_is_suspended
    Else if (Message = 12)
        Gosub RM_is_not_suspended
    Else if (Message = 13)
        Gosub Remote
}

;------------------------------------------------------------------------------
WM_MOUSEMOVE() ; WM_MOUSEMOVE:
;------------------------------------------------------------------------------
{
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ShowTip command below.
    CurrControl := A_GuiControl
    CurrControl := RegExReplace(CurrControl, "\W", "")
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ClearTip()
        SetTimer, DisplayThisTip, 1000
        PrevControl := CurrControl
    }
    return

    DisplayThisTip:
    If (not InStr(CurrControl, "."))
    {
        SetTimer, DisplayThisTip, Off
        ShowTip(%CurrControl%_TT)
        SetTimer, RemoveThisTip, 3000
    }
    return

    RemoveThisTip:
    SetTimer, RemoveThisTip, Off
    ClearTip()
    return
}


;------------------------------------------------------------------------------
WM_LBUTTONDOWN(wParam, lParam) ; WM_LBUTTONDOWN:
;------------------------------------------------------------------------------
{
; SubStr(String, StartingPos [, Length])
; JKLMVEPRYZITUJJ
    X := lParam & 0xFFFF
    Y := lParam >> 16
    WinGetTitle, OutputVar
    IfInString, OutputVar, Jmenu
    {
        num := ( ( Y - 70 ) / 13 ) + 1
        SendInput % SubStr("JKLMVEPRYZITUJJ", num, 1)
    }
;    if ( num = 15 )
;        SendInput, j
;    IfInString, OutputVar, Jmenu
;        ShowTip("You left-clicked in Gui window at client coordinates " . X . "x" . Y . "." . num)
}


;new_file_code
;------------------------------------------------------------------------------
build_file_file:
;------------------------------------------------------------------------------
FileAppend,
(
hosts&c | %sys_drive%\WINDOWS\system32\drivers\etc\hosts
), %file_file%
return


;------------------------------------------------------------------------------
build_dir_file:
;------------------------------------------------------------------------------
FileAppend,
(
&C | C:\
C&ygwin home | C:\cygwin\home\dave
Des&ktop | C:\Users\dave\Desktop
&Docs | C:\docs
Do&wnloads | C:\Users\dave\Downloads
Dr&opbox | C:\Dropbox
&MMNTS | C:\docs\MMNTS
P&rogram Files | C:\Program Files
Program Files (&x86) | C:\Program Files (x86)
&Project, current | C:\Dropbox
&Shared | C:\Shared
&TuSC | C:\TuSC
), %dir_file%
return


;------------------------------------------------------------------------------
build_ini:
;------------------------------------------------------------------------------
    default_notes=Gray|Green|Gold|Black|White
;    f_iniwrite({ filename:  ini_file
;               , section:   "settings"
;               , key_value: {                 notes_list: default_notes
;                            , rotate_tray_icon_when_mute: 1
;                            ,          run_poker_routine: 0
;                            ,          run_ohide_routine: 0
;                            ,          run_ocred_routine: 0
;                            ,       run_eye_rest_routine: 0
;                            ,          customization_dir: A_ScriptDir }})

    IniWrite, %default_notes%, %ini_file%, settings, notes_list
    IniWrite, 1,               %ini_file%, settings, rotate_tray_icon_when_mute
    IniWrite, 0,               %ini_file%, settings, run_poker_routine
    IniWrite, 0,               %ini_file%, settings, run_ohide_routine
    IniWrite, 0,               %ini_file%, settings, run_ocred_routine
    IniWrite, 0,               %ini_file%, settings, run_eye_rest_routine
    IniWrite, %A_ScriptDir%,   %ini_file%, settings, customization_dir

    IniWrite, 1,               %ini_file%, state,  sound
    IniWrite, 1,               %ini_file%, state,  private_on
return


;------------------------------------------------------------------------------
build_my_ini:
;------------------------------------------------------------------------------
    IniWrite, one,         %my_ini_file%, string, mystring1
    IniWrite, two,         %my_ini_file%, string, mystring2
    IniWrite, three,       %my_ini_file%, string, mystring3
    IniWrite, four,        %my_ini_file%, string, mystring4
    IniWrite, five,        %my_ini_file%, string, mystring5
    IniWrite, six,         %my_ini_file%, string, mystring6
    IniWrite, seven,       %my_ini_file%, string, mystring7
    IniWrite, eight,       %my_ini_file%, string, mystring8
    IniWrite, nine,        %my_ini_file%, string, mystring9
    IniWrite, ten,         %my_ini_file%, string, mystring0

    IniWrite, %A_Space%,   %my_ini_file%, settings, selected_item
return


; E-DTT - difficult to troubleshoot. For some reason, calls to refresh toolbar
; routine wipe out calls to lib_warn, lib_say. It may have something to do
; with a hide_gui or assigning a progress number or "channel"
; 8:05pm assigning a different progress number fixed it because there was
;        indeed a Progress, Off in the toolbar_update routine
;--------------------
     eye_rest:      ; Tell the user to rest his eyes
;--------------------
    debug({ param1: "eye_rest", linenumber: A_LineNumber })

    if(!private_on)
    {
;        say_("Eye Rest!")
        say({ param1: "Eye Rest!", linenumber: A_LineNumber })
    }
    else
    {
        GuiControl, 11:Hide, PrivateOn
        Sleep, 250
        GuiControl, 11:Show, PrivateOn
    }
return


;--------------------
     poker:         ; Show Work Log reminder xtimer
;--------------------
    debug({ param1: "poker", linenumber: A_LineNumber })
    nwidth := f_width() - 310
    nheight := f_height() - 150

    nwidth := nwidth - (reminder_count * 10)
    nheight := nheight - (reminder_count * 10)

    reminder_count++
    if(reminder_count > 5)
        GuiControl, 11:Show, Exclaim
    GuiControl, 11:, NoteCount, OK (%reminder_count%)
    if(!private_on)
    {
        Progress, %PROGRESS_POKER%:x%nwidth% y%nheight% h100 cwFFFF00 m2 b fs28 zh0, Work Log, , , Courier New
        SetTimer, DisablePoker, -5000
    }
    else
    {
        GuiControl, 11:Hide, PrivateOn
        Sleep, 250
        GuiControl, 11:Show, PrivateOn
    }
return


;--------------------
     DisablePoker:  ;
;--------------------
    Progress, %PROGRESS_POKER%:Off
return


;---------------------
     OptionsB:       ;
;---------------------
    gui_hide()
    Gosub, read_settings
    Gosub, init_gui_options
    Gui, 9:Show, h341 w450, Options %prog% %compname%
    Gui, 9:+AlwaysOnTop
return

9ButtonOK:
9GuiClose:
    Gui, 9:Submit  ; Save each control's contents to its associated variable.
    IniWrite, %SettingRotate%,  %ini_file%, settings, rotate_tray_icon_when_mute
    IniWrite, %SettingPoker%,   %ini_file%, settings, run_poker_routine
    IniWrite, %SettingOhide%,   %ini_file%, settings, run_ohide_routine
    IniWrite, %SettingOcred%,   %ini_file%, settings, run_ocred_routine
    IniWrite, %SettingEyeRest%, %ini_file%, settings, run_eye_rest_routine
    process_volume_icon()
    process_poker()
    process_ohide()
    process_ocred()
    process_eye_rest()
9ButtonCancel:
9GuiEscape:
    Gui, Hide
return


;-------------------------
     read_settings:      ;
;-------------------------

    SettingRotate  := f_IniRead({ filename:   ini_file
                                , category:   "settings"
                                , variable:   "rotate_tray_icon_when_mute"
                                , linenumber: A_LineNumber })

    SettingPoker   := f_IniRead({ filename:   ini_file
                                , category:   "settings"
                                , variable:   "run_poker_routine"
                                , linenumber: A_LineNumber })

    SettingOhide   := f_IniRead({ filename:   ini_file
                                , category:   "settings"
                                , variable:   "run_ohide_routine"
                                , linenumber: A_LineNumber })

    SettingOcred   := f_IniRead({ filename:   ini_file
                                , category:   "settings"
                                , variable:   "run_ocred_routine"
                                , linenumber: A_LineNumber })

    SettingEyeRest := f_IniRead({ filename:   ini_file
                                , category:   "settings"
                                , variable:   "run_eye_rest_routine"
                                , linenumber: A_LineNumber })
return


;--------------------
     ohide:         ; Hide annoying windows xtimer
;--------------------
    WinHide, Mozilla Thunderbird
    WinHide, Microsoft Visual C++ Runtime Library ahk_class #32770
    WinClose, Fences Update Available
return


;--------------------
     re_show:       ;
;--------------------
    WinShow, Mozilla Thunderbird
    WinShow, Microsoft Visual C++ Runtime Library ahk_class #32770
return


;--------------------
    toolbar_update: ; Update the toolbar with time/date and debug info xtimer
;--------------------

    MouseGetPos, OutputVarX, OutputVarY, OutputVarWin, OutputVarControl
    if(CurrentGuiWin and OutputVarWin <> CurrentGuiWin)
        Gui, %CurrentGui%:Hide

;    rm4_is_alive2 := rm4_is_alive1
    ra := rm4_is_alive
    ra1 := rm4_is_alive1
    rm4_is_alive1 := rm4_is_alive

    ; Update toolbar display of RM4 icon based on whether or not it's running
    if(rm4_is_alive1 or rm4_is_alive)
        GuiControl, 11:Hide, ROff
    else
        GuiControl, 11:Show, ROff

    rm4_is_alive=0
    PostMessage("Radial menu - message receiver", 52)

    Gosub, perform_incr_virtualbox_check ; This is a potential problem: it should have its own timer xtimer

    ; From the doc:

    ; If a second thread is started -- such as by pressing another hotkey while the
    ; previous is still running -- the current thread will be interrupted
    ; (temporarily halted) to allow the new thread to become current. If a third
    ; thread is started while the second is still running, both the second and first
    ; will be in a dormant state, and so on.

    ; When the current thread finishes, the one most recently interrupted will be
    ; resumed, and so on, until all the threads finally finish.

    SetTitleMatchMode, 2
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    if(posx=0 and posy=0)
    {
;        WinShow, my_tips
;        WinActivate, my_tips
        if(!note_shown)
        {
;            Progress, c00 m2 b zh0 x0 y0, %side_note%, , , Courier New
            note_shown=1
        }
    }
    else
    {
;        WinHide, my_tips
;        Progress, Off
        note_shown=0
    }

    Gosub, ShowHideTodoToolbar
    Gosub, ShowHideOutlookToolbar

    tb_keys=

    GetKeyState, state, Insert, T
    if state = D
        tb_keys := tb_keys . " InsertOn"

    GetKeyState, state, ScrollLock, T
    if state = D
        tb_keys := tb_keys . " ScrollLockOn"

    GetKeyState, state, CapsLock, T
    if state = D
        tb_keys := tb_keys . " CapsLockOn"

    GetKeyState, state, NumLock, T
    if state = D
        tb_keys := tb_keys . " NumLockOn"

    GetKeyState, state, Insert
    if state = D
        tb_keys := tb_keys . " Insert"

    GetKeyState, state, ScrollLock
    if state = D
        tb_keys := tb_keys . " ScrollLock"

    GetKeyState, state, CapsLock
    if state = D
        tb_keys := tb_keys . " CapsLock"

    GetKeyState, state, NumLock
    if state = D
        tb_keys := tb_keys . " NumLock"

    GetKeyState, state, LWin
    if state = D
        tb_keys := tb_keys . " LWin"

    GetKeyState, state, RWin
    if state = D
        tb_keys := tb_keys . " RWin"

    GetKeyState, state, LCtrl
    if state = D
        tb_keys := tb_keys . " LCtrl"

    GetKeyState, state, RCtrl
    if state = D
        tb_keys := tb_keys . " RCtrl"

    GetKeyState, state, LShift
    if state = D
        tb_keys := tb_keys . " LShift"

    GetKeyState, state, RShift
    if state = D
        tb_keys := tb_keys . " RShift"

    GetKeyState, state, LAlt
    if state = D
        tb_keys := tb_keys . " LAlt"

    GetKeyState, state, RAlt
    if state = D
        tb_keys := tb_keys . " RAlt"

    FormatTime, TimeString, ,hh:mm tt    ddd MMM d, yyyy
    Gui, 11:Show, x%toolbar_offset% y0 h20 w%toolbar_width% NoActivate, %A_Space%   %TimeString%      %prog%      Host: %compname%

    directory_refresh()
    ;new_file_code
    file_refresh()

return


perform_incr_virtualbox_check:
    if(check_for_virtualbox())
        Gosub rm4_vbox_suspend
    else
        Gosub rm4_vbox_unsuspend
return


;------------------------------------------------------------------------------
directory_refresh() ; file_refresh:
;------------------------------------------------------------------------------
{
    global

    f_target = %A_ScriptDir%\directories.ini

    FileGetAttrib,attribs,%f_target%
    IfInString,attribs,A
    {
        FileSetAttrib,-A,%f_target%
        Gui 15:Destroy
        Gui 65:Destroy
        directory_array_built=0
        debug({ param1: "set directories to rebuild", linenumber: A_LineNumber })
    }
    return
}


;new_file_code
;------------------------------------------------------------------------------
file_refresh() ; file_refresh:
;------------------------------------------------------------------------------
{
    global

    f_target = %A_ScriptDir%\files.ini

    FileGetAttrib,attribs,%f_target%
    IfInString,attribs,A
    {
        FileSetAttrib,-A,%f_target%
        Gui 17:Destroy
        Gui 67:Destroy
        file_array_built=0
        debug({ param1: "set files to rebuild", linenumber: A_LineNumber })
    }
    return
}


;--------------------
     ocred:         ; Auto-enter credentials xtimer
;--------------------

    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen

    PX1=61
    ;PY1=825
    PY1=810
    PX2=162
    ;PY2=852
    PY2=836

    ; This is flaky as HELL.
    ImageSearch, FoundX, FoundY, PX1, PY1, PX2, PY2, *2 %ImageDir%\newpwd.png
    EL := ErrorLevel

    if(!EL)
    {
        refresh_ini_value("mystring9", "string")
        FoundX += 50
        MouseClick, ,%FoundX%, %FoundY%
        SendInput, %mystring9%
        SendInput, {enter}
    }

    IfWinExist, Connect ahk_class #32770, Password
    {
        refresh_ini_value("mystring0", "string")
        Gosub, esc_key
        WinActivate
        SendInput, !uitservices\db5170
        SendInput, !p{Raw}%mystring0%
        SendInput, {enter}
    }
    IfWinExist, Enterprise Messenger ahk_class SunAwtDialog
    {
        if (!q_window_found)
        {
            refresh_ini_value("mystring6", "string")
            Gosub, esc_key
            WinActivate
            SendInput, {Raw}%mystring6%
            SendInput, {enter}
            q_window_found++
        }
    }
    else
    {
        q_window_found=0
    }
return


;------------------------------------------------------------------------------
CenterMouse:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    MouseMove % f_cwidth(), f_cheight(), 0
return


;------------------------------------------------------------------------------
&JustQuit:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
M&aximizeCurrent:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
    WinMaximize, A
return


;------------------------------------------------------------------------------
MinimizeAll:
    gui_hide()
;------------------------------------------------------------------------------
    SendInput, #m
return


;------------------------------------------------------------------------------
Hibernate:
;------------------------------------------------------------------------------
    gui_hide()
    SoundBeep,700,700
    MsgBox, 4099, ,Hibernating in 5 seconds unless you cancel..., 5
    IfMsgBox No
        return
    IfMsgBox Cancel
        return
    DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
return


;------------------------------------------------------------------------------
Lock:
;------------------------------------------------------------------------------
    gui_hide()

    Gosub, CenterMouse
    Sleep, 1000

    if running_on_guest()
        FileAppend, Text, S:\lock_computer.sig
    else
        DllCall("user32.dll\LockWorkStation")
return


;------------------------------------------------------------------------------
1ify:
;------------------------------------------------------------------------------
    gui_hide()

    WinActivate ahk_id %lastwin%
    SendInput, ^!1
return


;------------------------------------------------------------------------------
Close_Tab_W:
;------------------------------------------------------------------------------
    gui_hide()

    SendInput, ^w
return


;------------------------------------------------------------------------------
New_Tab_Z:
;------------------------------------------------------------------------------
    gui_hide()

    SendInput, ^t
return


;------------------------------------------------------------------------------
Close:
Close_4:
;------------------------------------------------------------------------------
    gui_hide()

    WinClose ahk_id %lastwin%
return


;------------------------------------------------------------------------------
Maximize:
Maximize_2:
;------------------------------------------------------------------------------
    gui_hide()

    WinActivate ahk_id %lastwin%
    WinMaximize, A
return


;------------------------------------------------------------------------------
Minimize:
Minimize_3:
;------------------------------------------------------------------------------
    gui_hide()

    WinActivate ahk_id %lastwin%
    WinMinimize, A
return


;------------------------------------------------------------------------------
CMD:
;------------------------------------------------------------------------------
    gui_hide()
    Run, cmd
    WinWait, ahk_class ConsoleWindowClass,,%timeout%
    WinActivate
return


;------------------------------------------------------------------------------
FindWindow(title,exclude_title,text="",exclude_text="",ask=0) ; FindWindow:
;------------------------------------------------------------------------------
{
    DetectHiddenWindows, Off
    WinGet, id, list, %title%, %text%, %exclude_title%, %exclude_text%
    if id = 0
        return 0
    Loop, %id%
    {
        StringTrimRight, this_id, id%a_index%, 0
        WinGetClass, x_class, ahk_id %this_id%
        IfNotInString, x_class, tooltip
        {
            WinActivate ahk_id %this_id%
            If ask
            {
                this_flag := Question("This one?")
                if this_flag = 1
                {
                    debug({ param1: concat(["FindWindow found id by asking: ", this_id]), linenumber: A_LineNumber })
                    return %this_id%
                }
            }
            else
            {
                debug({ param1: concat(["FindWindow found id: ", this_id]), linenumber: A_LineNumber })
                return %this_id%
            }
        }
    }
    ClearTip()
    return 0
}


; Usage:
; yes_flag := Question(text)
;------------------------------------------------------------------------------
Question(text,h_axis=0) ; Question:
;------------------------------------------------------------------------------
{
    answer_flag=0
    MsgBox, 4132, Question, %text%
    IfMsgBox Yes
        answer_flag++
    return %answer_flag%
}


;GoApp: parameters
;    Parameter             Default      Explain
;                                       --------------------------------------
;    =========             ============ =======
; 1. unique_identifier                  This can be any string as long as it
;                                       doesn't match any other application's
;                                       unique identifier.
; 2. search_text                        Each open window will have its title
;                                       checked for the search text.
; 3. command                            If the window can't be located, the
;                                       program will be launched.
; 4. title_match_mode      0            If 0, search_text can be found
;                                       anywhere in the window's title.  For
;                                       example, "pad" will match "Notepad".
;                                       If 1, search_text has to match the
;                                       beginning of the window's title.
; 5. parameters            empty string Parameters to pass to the program in
;                                       "command".
; 6. dont_maximize         empty string Do not maximize the window after
;                                       launching the program.
; 7. exclude_text          empty string Do NOT match the window if the title
;                                       contains this text.
; 8. working_directory     empty string Provide a working directory for the
;                                       program in "command".
; 9. alternate_search_text empty string Alternate text to use to try to find
;                                       a match in a window's title.
;10. ask_user_which_one    0            This is useful if more than one
;                                       window might match.  If this is set
;                                       to 1, when the user tries to activate
;                                       the window, each window that matches
;                                       will be presented to the user, and the
;                                       user will be asked if this is the
;                                       window being searched for.  If none
;                                       match, the program in "command" will
;                                       be launched.

;------------------------------------------------------------------------------
GoApp(unique_identifier
,search_text
,command
,title_match_mode=0
,parameters=""
,dont_maximize=""
,exclude_text=""
,working_directory=""
,alternate_search_text=""
,ask_user_which_one=0
,always_start_new=0)
;------------------------------------------------------------------------------
{
    global

    save_windows()

    max=
    dont_maximize=1 ;forcing for now
    If !dont_maximize
        max=Max
    Transform, id, deref, `%%unique_identifier%_id`%
    IfWinExist, ahk_id %id%
    {
        debug({ param1: concat(["I already have this window ID: ", id]), linenumber: A_LineNumber })
        WinActivate
    }
    else
    {
        SplitPath, command, rfile, rdir
        If !working_directory
            working_directory=%rdir%

        if title_match_mode = 0
            SetTitleMatchMode, 2
        else
            SetTitleMatchMode, 1

        Loop
        {
            debug({ param1: concat(["Trying to find window via search_text: ", search_text]), linenumber: A_LineNumber })
            if(!always_start_new)
            {
                fw_id := FindWindow(search_text,exclude_text,"","",ask_user_which_one)
                if fw_id
                {
                    debug({ param1: "Found window via search_text. Activating.", linenumber: A_LineNumber })
                    WinActivate ahk_id %fw_id%
                    id=%fw_id%
                    break
                }

                if(alternate_search_text)
                {
                    debug({ param1: concat(["Trying to locate window via alternate_search_text: ", alternate_search_text]), linenumber: A_LineNumber })
                    IfWinExist, %alternate_search_text%,,%exclude_text%
                    {
                        debug({ param1: "Found via alternate_search_text. Activating.", linenumber: A_LineNumber })
                        WinActivate
                        WinGet, id, ID, A
                        break
                    }
                }
            }

            debug({ param1: "Could not find window.  Launching.", linenumber: A_LineNumber })
            Run, %command% %parameters%,%working_directory%,%max%
            If dont_maximize
            {
                SetTimer,oneify_new_window,100
            }
            else
            {
                WinWait, %search_text%,,%timeout%
                if !ErrorLevel
                {
                    WinActivate
                    WinMaximize
                }
            }
            break
        }
    }
    if id
        Transform, %unique_identifier%_id, deref, %id%
    return 0
}


;------------------------------------------------------------------------------
running_on_guest() ; running_on_guest:
;------------------------------------------------------------------------------
{
    DriveGet, label, label, S:

    IfInString, label, shared
        return 1
    else
        return 0
}


;------------------------------------------------------------------------------
QuickStart:
;------------------------------------------------------------------------------
   gui_hide()
   Run, %A_ScriptDir%\320mph.ahk
;    SendInput, {pause}
;    SendInput, #{F10}
return


;------------------------------------------------------------------------------
GaimWin:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("pidgin")
    GoApp("gaim", "ahk_class gdkWindowToplevel", target, 0)
return


;------------------------------------------------------------------------------
Setvi:
;------------------------------------------------------------------------------
    gui_hide()
    vi_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetCygwin:
;------------------------------------------------------------------------------
    gui_hide()
    cygw_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetExplore:
;------------------------------------------------------------------------------
    gui_hide()
    fcx_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetFirefox:
;------------------------------------------------------------------------------
    gui_hide()
    fox_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetRemote:
;------------------------------------------------------------------------------
    gui_hide()
    wksh_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetOutlook:
;------------------------------------------------------------------------------
    gui_hide()
    outl_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetrTemp:
;------------------------------------------------------------------------------
    gui_hide()
    rtm_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetScratch:
;------------------------------------------------------------------------------
    gui_hide()
    scr_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetGaimWin:
;------------------------------------------------------------------------------
    gui_hide()
    gaim_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
^!f::
Firefox:
Chrome:
;------------------------------------------------------------------------------
    gui_hide()
;    target := find_link("Mozilla Firefox")
;    GoApp("fox", "Mozilla Firefox", target, 0)
    target := find_link("Chrome")
    GoApp("chr", "Chrome", target, 0)
return


;------------------------------------------------------------------------------
Remote:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("cygwin terminal")
    GoApp("wksh","ahk_class mintty", target, 0)
return


;------------------------------------------------------------------------------
Cygwin:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("cygwin terminal")
    GoApp("cygw","ahk_class mintty", target, 0,,,,,,,1)
return


;------------------------------------------------------------------------------
RadialMenu:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("radial menu")
    GoApp("vrm","rm4", target, 0)
return


;------------------------------------------------------------------------------
Paint:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("PaintDotNet")
    GoApp("pnt","Paint.NET",target,0,"",1)
return


;------------------------------------------------------------------------------
Calculator:
;------------------------------------------------------------------------------
    gui_hide()
    GoApp("clc","Calculator","calc",0,"",1)
return


;------------------------------------------------------------------------------
SmartGUI:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("SmartGUI")
    GoApp("smg","SmartGUI",target,0,"",1)
return


;------------------------------------------------------------------------------
VPN:
;------------------------------------------------------------------------------
    gui_hide()
return


;------------------------------------------------------------------------------
oldRemote:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("putty")
    refresh_ini_value("mystring3", "string")
    GoApp("wksh","ahk_class PuTTY",remote,0,"-load redcloud -pw " . mystring3,"","","","xrm",1)
return


;------------------------------------------------------------------------------
Outlook:
;------------------------------------------------------------------------------
    gui_hide()
    SetTitleMatchMode, 2
    target := find_link("outlook")

    outlook_key_flag=0
    IfWinExist, Outlook
    {
        outlook_key_flag++
    }

    GoApp("outl","Outlook",target,0)

    If outlook_key_flag
    {
        Gosub, outlook_keys
    }
return


;------------------------------------------------------------------------------
IE:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("internet explorer")
    GoApp("ie", "Internet Explorer", target, 0)
return


;------------------------------------------------------------------------------
Loading_Progress(load_progress=10,re="") ; Loading_Progress:
;------------------------------------------------------------------------------
{
    global
    Progress, b w250, , %re%Loading %prog% %compname%
    Progress, %load_progress%
    return
}


;------------------------------------------------------------------------------
Clear_Loading_Progress() ; Clear_Loading_Progress:
;------------------------------------------------------------------------------
{
    Progress, Off
    return 0
}


;------------------------------------------------------------------------------
TempR:
;------------------------------------------------------------------------------
    gui_hide()
    Gosub, eye_rest
return


;------------------------------------------------------------------------------
vi:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("gvim")
    GoApp("vi","GVIM",target,0,,,,,,,1)
return


;------------------------------------------------------------------------------
Scratch:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("gvim")
    scratch = %custom_dir%\scratch.txt
    GoApp("scr","scratch",target,0,scratch)
return


;new_file_code
;------------------------------------------------------------------------------
Do_file:
;------------------------------------------------------------------------------
    Gui, Hide
    key=%A_GuiControl%
    f_path := files[key,"file"]
    f_param := key
    Gosub, Gofile
return


;------------------------------------------------------------------------------
Do_Dir:
;------------------------------------------------------------------------------
    Gui, Hide
    key=%A_GuiControl%
    f_path := directories[key,"dir"]
    f_param := key . " - FreeCommander"
    Gosub, GoDirectory
return


;------------------------------------------------------------------------------
Home:
;------------------------------------------------------------------------------
    gui_hide()
    f_path = %A_ScriptFullPath%
    f_param = %A_ScriptName%
    ;new_file_code
    Gosub, Gofile
return


;new_file_code
;------------------------------------------------------------------------------
Gofile:
;------------------------------------------------------------------------------
    If f_path =
        return

    SplitPath, f_path, f_basename

    DetectHiddenWindows, off

    IfWinExist, %f_basename%
    {
        WinActivate
        return
    }
;    Run, "%f_path%" ; open in windows explorer. don't forget winactivate
    Transform, f_path, deref, %f_path%
    target := find_link("gvim")
    Run, %target% "%f_path%"
    WinWait, %f_basename%,,%timeout%
    WinActivate
    Send ^!1
return


;------------------------------------------------------------------------------
GoDirectory:
;------------------------------------------------------------------------------
    If f_path =
        return
    IfWinExist, %f_param%
    {
        WinActivate
        return
    }
;    Run, "%f_path%" ; open in windows explorer. don't forget winactivate
    target := find_link("freecommander xe")
    Run, %target% /C /L="%f_path%"

    text=FreeCommander
    WinWait, %text%,,%timeout%
    WinActivate
    Send ^!1
;    MsgBox, 0, , here, 1
return


;------------------------------------------------------------------------------
GoF&ile:
;------------------------------------------------------------------------------
    StringTrimLeft, f_path, f_pathFile%A_ThisMenuItemPos%, 0
    If f_path =
        return
    StringTrimLeft, f_param, f_paramFile%A_ThisMenuItemPos%, 0
    IfWinExist, %f_param%
    {
        WinActivate
        return
    }
    target := find_link("gvim")
    Run, %target% "%f_path%"
    WinWait, %f_param%,,%timeout%
    WinActivate
return


;------------------------------------------------------------------------------
GoLi&nk:
;------------------------------------------------------------------------------
    StringTrimLeft, f_path, f_pathLink%A_ThisMenuItemPos%, 0
    If f_path =
        return
    StringTrimLeft, f_param, f_paramLink%A_ThisMenuItemPos%, 0
    StringSplit, link_in, f_param, `,
    link_enter =%link_in1%
    link_delay =%link_in2%
    link_in1=
    link_in2=
    link_in3=
    GoLink(f_path,link_enter,0,link_delay)
return


;------------------------------------------------------------------------------
GoLink(f_path,link_enter=1,tab_number=0,link_delay=0) ; GoLink:
;------------------------------------------------------------------------------
{
    global

    If f_path =
        return

    If f_path = a
    {
        f_path =
    }


    if !link_enter
    {
        link_delay=50
        InputBox, temp_input, %f_path%, Enter query string,,,,,,,,%link_input%
        If ErrorLevel
            return
        link_input=%temp_input%
    }
    if tab_number = 0
    {
        SendInput, ^9
    }
    else
    {
        SendInput, ^%tab_number%
    }
    Sleep, 500
    SetKeyDelay, link_delay
    SetKeyDelay, 0
    SendInput, ^l
    Sleep, 500
    SendInput, {Raw}%f_path%
    Sleep, 500
    if !link_enter
    {
        SendInput, %link_input%
    }
    SendInput, {enter}
    return 0
}


;------------------------------------------------------------------------------
Explore:
;------------------------------------------------------------------------------
    gui_hide()
    target := find_link("freecommander xe")
    GoApp("fcx","reeComm",target,0)
return


;------------------------------------------------------------------------------
ShowTip(text="",posx="",posy="",channel=1) ; ShowTip:
;------------------------------------------------------------------------------
{
    ToolTip %text%, %posx%, %posy%, %channel%
    return
}


;------------------------------------------------------------------------------
ClearTip(channel=1) ; ClearTip:
;------------------------------------------------------------------------------
{
    ToolTip,,,,%channel%
    return
}


;------------------------------------------------------------------------------
gui_hide() ; gui_hide:
;------------------------------------------------------------------------------
{
    global lastwin
    if(A_Gui <> 11 and A_Gui <> "Todo" and A_Gui <> "OTool")
        Gui, Hide
    MouseMove, 1, 0,,R
    WinActivate ahk_id %lastwin%
    return
}


;------------------------------------------------------------------------------
RM4SuspendToggle:
;------------------------------------------------------------------------------
    debug({ param1: "RM4SuspendToggle", linenumber: A_LineNumber })
    rm4_vbox_suspended=0
debug({ param1: concat(["1:rm4_vbox_suspended", rm4_vbox_suspended]), linenumber: A_LineNumber })
    if(!rm4_is_alive)
    {
        Gosub, RadialMenu
    }
    else
    {
        if(RM_suspend_state)
            Gosub, SuspendOffRM
        else
            Gosub, SuspendOnRM
    }
return

rm4_vbox_suspend:
    debug({ param1: "rm4_vbox_suspend", linenumber: A_LineNumber })
    rm4_vbox_suspended=1
    debug({ param1: concat(["2:rm4_vbox_suspended", rm4_vbox_suspended]), linenumber: A_LineNumber })
    line2=RM_suspend_state=%RM_suspend_state%      rm4_vbox_suspended=%rm4_vbox_suspended%      rm4_is_alive=%ra%      rm4_is_alive1=%ra1%      rm4_vbox_suspended=%rm4_vbox_suspended%
    debug({ param1: line2, linenumber: A_LineNumber })
    Gosub, SuspendOnRM
return

rm4_vbox_unsuspend:
    debug({ param1: "rm4_vbox_unsuspend", linenumber: A_LineNumber })
    if(rm4_vbox_suspended)
    {
        Gosub, SuspendOffRM
        rm4_vbox_suspended=0
        debug({ param1: concat(["3:rm4_vbox_suspended", rm4_vbox_suspended]), linenumber: A_LineNumber })
    line2=RM_suspend_state=%RM_suspend_state%      rm4_vbox_suspended=%rm4_vbox_suspended%      rm4_is_alive=%ra%      rm4_is_alive1=%ra1%      rm4_vbox_suspended=%rm4_vbox_suspended%
        debug({ param1: line2, linenumber: A_LineNumber })
    }
return

RM_is_suspended:
    debug({ param1: "RM_is_suspended", linenumber: A_LineNumber })
    rm4_is_alive=1
    RM_suspend_state=1
    Gosub show_rm4_suspend_indicator
return

RM_is_not_suspended:
    debug({ param1: "RM_is_not_suspended", linenumber: A_LineNumber })
    rm4_is_alive=1
    RM_suspend_state=0
    Gosub hide_rm4_suspend_indicator
return

hide_rm4_suspend_indicator:
    debug({ param1: "hide_rm4_suspend_indicator", linenumber: A_LineNumber })
    GuiControl, 11:Hide, RSus
return

show_rm4_suspend_indicator:
    debug({ param1: "show_rm4_suspend_indicator", linenumber: A_LineNumber })
    GuiControl, 11:Show, RSus
return


;------------------------------------------------------------------------------
PrivateToggle:
    gui_hide()
private_nohide:
;------------------------------------------------------------------------------
    if(private_on)
    {
        private_on=0
        IniWrite, %private_on%, %ini_file%, state, private_on
        GuiControl, 11:Hide, PrivateOn
        GuiControl, 11:Show, NoteText
        GuiControl, 11:Show, SettingSave
        GuiControl, 11:Show, NoteCount
        GuiControl, 11:Show, Snoozer
    }
    else
    {
        private_on=1
        IniWrite, %private_on%, %ini_file%, state, private_on
        GuiControl, 11:Show, PrivateOn
        GuiControl, 11:Hide, NoteText
        GuiControl, 11:Hide, SettingSave
        GuiControl, 11:Hide, NoteCount
        GuiControl, 11:Hide, Snoozer
    }
return


;------------------------------------------------------------------------------
SuspendOffRM:
;------------------------------------------------------------------------------
    debug({ param1: "SuspendOffRM", linenumber: A_LineNumber })
    if(RM_suspend_state)
    {
        PostMessage("Radial menu - message receiver", 30)
        Gosub, hide_rm4_suspend_indicator
    }
return


;------------------------------------------------------------------------------
SuspendOnRM:
;------------------------------------------------------------------------------
    debug({ param1: "SuspendOnRM", linenumber: A_LineNumber })
    if(!RM_suspend_state)
    {
; Disabling for now as it is annoying
;        PostMessage("Radial menu - message receiver", 31)
        Gosub, show_rm4_suspend_indicator
    }
return


;------------------------------------------------------------------------------
ToggleSuspendRM:
;------------------------------------------------------------------------------
    debug({ param1: "ToggleSuspendRM", linenumber: A_LineNumber })
    gui_hide()
    PostMessage("Radial menu - message receiver", 32)
return


;------------------------------------------------------------------------------
PostMessage(Receiver,Message) {
;------------------------------------------------------------------------------
    oldTMM := A_TitleMatchMode, oldDHW := A_DetectHiddenWindows
    SetTitleMatchMode, 3
    DetectHiddenWindows, on
    PostMessage, 0x1001,%Message%,,,%Receiver% ahk_class AutoHotkeyGUI
    SetTitleMatchMode, %oldTMM%
    DetectHiddenWindows, %oldDHW%
}


;------------------------------------------------------------------------------
TotalKill:
;------------------------------------------------------------------------------
    gui_hide()
    SendInput, ^!j
    Sleep, 1000
    Gosub, KillScript
return


;------------------------------------------------------------------------------
RestartScript:
;------------------------------------------------------------------------------
    Loading_Progress(25,"RE")
    Reload
return


;------------------------------------------------------------------------------
DumpSTDERR:
;------------------------------------------------------------------------------
    gui_hide()
    WinActivate ahk_id %lastwin%
    SendInput, print STDERR "\n\ndmb_file:",__FILE__,' dmb_line:',__LINE__,':',Data{:}{:}Dumper{:}{:}Dumper();{esc}{left}i
return


;------------------------------------------------------------------------------
EjectAll:
;------------------------------------------------------------------------------
    gui_hide()
    drive=65
    Loop,25
    {
        Transform,name,Chr,%drive%
        Drive, Eject, %name%:
        drive+=1
    }
return


;------------------------------------------------------------------------------
PrintSTDERR:
;------------------------------------------------------------------------------
    gui_hide()
    WinActivate ahk_id %lastwin%
    SendInput, print STDERR "\n\ndmb_file:",__FILE__," dmb_line:",__LINE__,':{{}',$,"{}}\n";{esc}{left 6}i
return


;------------------------------------------------------------------------------
Madeit:
;------------------------------------------------------------------------------
    gui_hide()
    WinActivate ahk_id %lastwin%
    SendInput, print STDERR "\n\ndmb_file:",__FILE__," dmb_line:",__LINE__,":made it\n";
return


;------------------------------------------------------------------------------
UseDataDumper:
;------------------------------------------------------------------------------
    gui_hide()
    WinActivate ahk_id %lastwin%
    SendInput, use Data{:}{:}Dumper ();
return


;------------------------------------------------------------------------------
Compile:
;------------------------------------------------------------------------------
    gui_hide()
    WinActivate ahk_id %lastwin%
;    SendInput, {esc}{:}{!}perl -I'.' -I'..' -TWc `% 2>&1 | head{enter}
    SendInput, {esc}{:}{!}perl -c `% 2>&1 | head{enter}
return


;------------------------------------------------------------------------------
esc_key:
;------------------------------------------------------------------------------
    SetTimer, esc_key, Off
    If volume_esc
    {
        Gosub, vol_BarOff
        Hotkey, 0, Off
        Hotkey, 1, Off
        Hotkey, 2, Off
        Hotkey, 3, Off
        Hotkey, 4, Off
        Hotkey, 5, Off
        Hotkey, 6, Off
        Hotkey, 7, Off
        Hotkey, 8, Off
        Hotkey, 9, Off
        Hotkey, WheelDown, Off
        Hotkey, WheelUp, Off
        Hotkey, h, Off
        Hotkey, j, Off
        Hotkey, k, Off
        Hotkey, l, Off
        Hotkey, esc, Off
        Hotkey, Enter, Off
        volume_esc =0
    }
    If mouse_esc
    {
        SetTimer,mouse_shimmy,Off
        ClearTip()
        Hotkey, u, Off
        Hotkey, i, Off
        Hotkey, 1, Off
        Hotkey, 3, Off
        Hotkey, 7, Off
        Hotkey, 9, Off
        Hotkey, j, Off
        Hotkey, k, Off
        Hotkey, l, Off
        Hotkey, h, Off
        Hotkey, m, Off
        Hotkey, 0, Off
        Hotkey, +h, Off
        Hotkey, +l, Off
        Hotkey, +m, Off
        Hotkey, `., Off
        Hotkey, `,, Off
        Hotkey, `;, Off
        Hotkey, +4, Off
        Hotkey, esc, Off
        If left_status = D
        {
            left_status = U
            MouseClick,,,,,,U
        }
        If right_status = D
        {
            right_status = U
            MouseClick,R,,,,,U
        }
        mouse_esc =0
    }
    If outlook_esc
    {
        ClearTip(SHOWTIP_MODE)
        Hotkey, r, Off
        Hotkey, e, Off
        Hotkey, w, Off
        Hotkey, q, Off
        Hotkey, a, Off
        Hotkey, s, Off
        Hotkey, d, Off
        Hotkey, ^b, Off
        Hotkey, ^f, Off
        Hotkey, f, Off
        Hotkey, g, Off
        Hotkey, j, Off
        Hotkey, +j, Off
        Hotkey, k, Off
        Hotkey, +k, Off
        Hotkey, l, Off
        Hotkey, z, Off
        Hotkey, x, Off
        Hotkey, t, Off
        Hotkey, c, Off
        Hotkey, b, Off
        Hotkey, v, Off
        Hotkey, `;, Off
        Hotkey, esc, Off
        outlook_esc =0
    }
return


;------------------------------------------------------------------------------
err_tip:
;------------------------------------------------------------------------------
    ShowTip("`n           " . show_tip . "           `n `n", SHOWTIP_ERR_X, SHOWTIP_ERR_Y, SHOWTIP_ERR)
return


;------------------------------------------------------------------------------
big_tip:
;------------------------------------------------------------------------------
    ShowTip("`n           " . show_tip . "           `n `n", SHOWTIP_BIG_X, SHOWTIP_BIG_Y, SHOWTIP_BIG)
return


;------------------------------------------------------------------------------
mode_tip:
;------------------------------------------------------------------------------
    ShowTip("`n" . mode . " MODE`n ", SHOWTIP_MODE_X, SHOWTIP_MODE_Y, SHOWTIP_MODE)
return


Do_Jmenu_a:
    gui_hide()
    SendInput {F2}
    Sleep, 100
    SendInput {home}{right}{bs}A{enter}
return

Do_Jmenu_b:
    gui_hide()
    SendInput {F2}
    Sleep, 100
    SendInput {home}{right}{bs}B{enter}
return

Do_Jmenu_c:
    gui_hide()
    SendInput {F2}
    Sleep, 100
    SendInput {home}{right}{bs}C{enter}
return

Do_Jmenu_d:
    gui_hide()
    SendInput {F2}
    Sleep, 100
    SendInput {home}{right}{bs}D{enter}
return


Do_Jmenu_x:
    gui_hide()
    SendInput {F2}
    Sleep, 100
    SendInput {home}X_{enter}
return


Do_Jmenu_Complete:
    gui_hide()

    clipboardSaved := clipboard
    clipboard =
    Send ^c
    clipwait
    source_path = %clipboard%
    clipboard := clipboardSaved
    clipboardSaved =

    FileMove, %source_path%, M:\complete, 1
return


;------------------------------------------------------------------------------
#1::
;------------------------------------------------------------------------------
    Send, ^!1
return


;------------------------------------------------------------------------------
;!F12::F12
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
;$F12::
;------------------------------------------------------------------------------
;    if(check_for_virtualbox())
;        return
;
;    Send {Volume_Up 1}
;    Send {Volume_Down 1}
;    Gosub, vol_display
;    volume_esc=1
;    Gosub, vol_setting0
;return


;------------------------------------------------------------------------------
starttusc_init:
;------------------------------------------------------------------------------
FileDelete, %A_ScriptDir%\starttusc.ahk
FileAppend,
(
#NoTrayIcon
#SingleInstance force

#j::
    if(check_for_virtualbox())
        return

    Run, %A_ScriptDir%\tusc.ahk
return

^!j::
    if(check_for_virtualbox())
        return

    MsgBox, 0, , starttusc shutting down, 1
    ExitApp
return

check_for_virtualbox()
{
    SetTitleMatchMode, 2
    IfWinActive, VLC media player
        return 0

    WinGetClass, class, A
    If class = QWidget
        return 1
    else
        return 0
}
), %A_ScriptDir%\starttusc.ahk
Run, %A_ScriptDir%\starttusc.ahk
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    GUI_section                                                              |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
init_guis:
;------------------------------------------------------------------------------
    ; formatting is for ease of reading and does not matter to the parser
    Gui 66:Show, w300 h40 hide, TuSC - message receiver

;        Main,            Maximize_&2       ; Maximize_2
;        Main,            Minimize_&3       ; Minimize_3
;        Main,            &Outlook,         ; Outlook
    buttons =
    (
        Main,            &1-ify,           ; 1ify
        Main,            Close_&4          ; Close_4
        Main,            Close_Tab_&W      ; Close_Tab_W
        Main,            &AeroView,        ; AeroView
        Main,            Applica&tions,    ; Applications
          Applications,  &Calculator,      ; Calculator
          Applications,  C&MD,             ; CMD
          Applications,  P&aint,           ; Paint
          Applications,  &RadialMenu,      ; RadialMenu
          Applications,  &SmartGUI,        ; SmartGUI
          Applications,  V&PN,             ; VPN
        Main,            C&hrome,          ; Chrome
        Main,            &Cygwin,          ; Cygwin
        Main,            &Directories,     ; Directories
        Main,            F&ilies,          ; Filies
        Main,            E&xplore,         ; Explore
        Main,            &Firefox,         ; Firefox
        Main,            F&unctions,       ; Functions
          Functions,     &Compile,         ; Compile
          Functions,     &DumpSTDERR,      ; DumpSTDERR
          Functions,     &EjectAll,        ; EjectAll
          Functions,     &Madeit,          ; Madeit
          Functions,     &GamKeys,         ; GamKeys
            GamKeys,     Set&GaimWin,      ; SetGaimWin
            GamKeys,     Set&Cygwin,       ; SetCygwin
            GamKeys,     SetE&xplore,      ; SetExplore
            GamKeys,     Set&Firefox,      ; SetFirefox
            GamKeys,     SetRe&mote,       ; SetRemote
            GamKeys,     Set&Outlook,      ; SetOutlook
            GamKeys,     Set&rTemp,        ; SetrTemp
            GamKeys,     Set&Scratch,      ; SetScratch
            GamKeys,     Set&vi,           ; Setvi
          Functions,     &PrintSTDERR,     ; PrintSTDERR
          Functions,     &UseDataDumper,   ; UseDataDumper
        Main,            &GaimWin,         ; GaimWin
        Main,            I&E,              ; IE
        Main,            &Links,           ; Links
          Links,         &Google,          ; Google
          Links,         &IMDB,            ; IMDB
          Links,         &RottenTom,       ; RottenTom
          Links,         &TheGoogle,       ; TheGoogle
          Links,         Wi&kipedia,       ; Wikipedia
        Main,            New_Tab_&Z        ; New_Tab_Z
        Main,            &Note             ; Note
        Main,            Options &B,       ; OptionsB
        Main,            &QuickStart,      ; QuickStart
        Main,            Re&mote,          ; Remote
        Main,            &Scratch,         ; Scratch
        Main,            Scri&pt,          ; Script
          Script,        Edit &Ini,        ; EditIni
          Script,        &Edit Script,     ; EditScript
          Script,        &Kill Script,     ; KillScript
          Script,        &Private Toggle,  ; PrivateToggle
          Script,        &Restart Script,  ; RestartScript
          Script,        &Toggle Suspend RM, ; ToggleSuspendRM
          Script,        &Total Kill,      ; TotalKill
        Main,            Temp &R,          ; TempR
        Main,            &Vi,              ; Vi
        Main,            Wor&kstation,     ; Workstation
          Workstation,   &Hibernate,       ; Hibernate
          Workstation,   &Lock,            ; Lock
          Workstation,   M&ouseKeys,       ; MouseKeys
          Workstation,   M&inimizeAll,     ; MinimizeAll
          Workstation,   &Mute,            ; Mute
          Workstation,   Vol&ume,          ; Volume
    )

    menus := Array()

    index=0
    Loop, parse, buttons, `n, `r
    {
        this_line=%A_LoopField%
        this_line := RegExReplace(this_line, "\s*;[^;]*$", "")


        StringSplit, ButtonArray, this_line, `,
        gui_name = %ButtonArray1%
        gui_label := gui_name
        label = %ButtonArray2%
        routine = %ButtonArray3%
        slabel=

        if(!routine)
        {
            routine=%label%
            routine := "g" . RegExReplace(routine, "[\W]", "")
        }

        FoundPos := RegExMatch(label, "&(.)", UnquotedOutputVar)
        if(FoundPos)
        {
            StringUpper, OutputVar, UnquotedOutputVar1
            label := label . " ( " . OutputVar . " )"
            slabel := "&" . OutputVar
        }
        menus[gui_name,index,"routine"] := routine
        menus[gui_name,index,"slabel"] := slabel
        menus[gui_name,index,"label"] := label
        index++
    }
return


;------------------------------------------------------------------------------
Show_GUI:
;------------------------------------------------------------------------------
    if(!gui_name)
        gui_name=Main

    gui_label := gui_name
    if(private_on)
        gui_label := gui_label . "_p"

    Gui %gui_label%:Default
    CurrentGui=%gui_label%

    Gui +LastFoundExist
    IfWinNotExist
    {
        ; +Owner must be used after the window's owner is created but before the
        ; owned window is created (that is, before commands such as Gui Add).
        Gui +Owner
        xx=6
        yy=7

        For key, value in menus[gui_name]
        {
            label := menus[gui_name,key,"label"]
            routine := menus[gui_name,key,"routine"]
            slabel :=  menus[gui_name,key,"slabel"]
            if(private_on)
            {
                Gui, Add, Button, x%xx% y%yy% w%pbw% h20 %bopt% %routine%, %slabel%
                xx+=20
                if(xx > 86)
                {
                    xx=6
                    yy+=20
                }
            }
            else
            {
                Gui, Add, Button, x%xx% y%yy% w%bw%  h20 %bopt% %routine%, %label%
                yy+=20
            }
        }

;        if(gui_name = "Main")
;        {
;            if(private_on)
;                Gui, Add, Button, x86 y87 w20 h20 gNEO_Jmenu vJustQuit, &J ; Jmenu
;            else
;            {
;                yy+=10
;                Gui, Add, Button, x%xx% y%yy% w%bw% h20 %bopt% gNEO_Jmenu vJustQuit, &Jmenu ( J ) ; Jmenu
;            }
;        }
;        else
;        {
            if(private_on)
                Gui, Add, Button, x86 y87 w20 h20 gDo_Just_Quit vJustQuit, &J ; Do_Just_Quit
            else
            {
                yy+=10
                Gui, Add, Button, x%xx% y%yy% w%bw% h20 %bopt% gDo_Just_Quit vJustQuit, &JustQuit ( J ) ; Do_Just_Quit
            }
;        }

    }
    Gui, +ToolWindow
    if(private_on)
    {
        Gui, Show, h119 w117, %gui_name%
    }
    else
    {
        Gui, Show, h%mh% w%mw%, %gui_name%
    }
    Gui, +AlwaysOnTop
    ; From the documentation: "GuiControl, Focus: Sets keyboard focus to the
    ; control. To be effective, the window generally must not be minimized or
    ; hidden."
    GuiControl, Focus, JustQuit

    Gui +LastFound
    CurrentGuiWin := WinExist()
return


;------------------------------------------------------------------------------
All_Menus:
;------------------------------------------------------------------------------
Applications:
Functions:
GamKeys:
Links:
Script:
Window:
Workstation:

    gui_hide()
    gui_name=%A_ThisLabel%
    Gosub, Show_GUI
return


;new_file_code
;------------------------------------------------------------------------------
show_gui_files_17:
;------------------------------------------------------------------------------
    Gui 17:Default
    Gui +LastFoundExist
    IfWinNotExist
    {
        Gui +Owner
        Gosub, build_file_array
        opt=Left
        yy=7
        For key, value in files
        {
            label := files[key,"label"]
            Gui, Add, Button, x6 y%yy% w130 h20 %opt% gDo_file v%key%, %label%  ; Do_file
            yy+=20
        }
        yy+=10
        Gui, Add, Button, x6 y%yy% w130 h20 %opt% default gAdd_file, &Add ( A )   ; Add_file
        yy+=30
        Gui, Add, Button, x6 y%yy% w130 h20 %opt% default gEdit_files, &Edit ( E )   ; Edit_files
        yy+=30
        Gui, Add, Button, x6 y%yy% w130 h20 %opt% default gDo_Just_Quit vJustQuit, &JustQuit ( J )   ; Do_Just_Quit
    }
    Gui, +ToolWindow
    Gui, Show, h%mh% w146, Files
    Gui, +AlwaysOnTop
    GuiControl, Focus, JustQuit
return


;new_file_code
;------------------------------------------------------------------------------
show_gui_files_67:
;------------------------------------------------------------------------------
    Gui 67:Default

    Gui +LastFoundExist
    IfWinNotExist
    {
        Gui +Owner
        Gosub, build_file_array
        opt=Left
        xx=6
        yy=7
        For key, value in files
        {
            slabel := files[key,"slabel"]
            Gui, Add, Button, x%xx% y%yy% w20 h20 %opt% gDo_file v%key%, %slabel%  ; Do_file
            xx+=20
            if(xx > 86)
            {
                xx=6
                yy+=20
            }
        }
        Gui, Add, Button, x86 y87 w20 h20 gDo_Just_Quit vJustQuit, &J ; Do_Just_Quit
    }
    Gui, +ToolWindow
    Gui, Show, h119 w117, files
    Gui, +AlwaysOnTop
    GuiControl, Focus, JustQuit
return


;------------------------------------------------------------------------------
show_gui_directories_15:
;------------------------------------------------------------------------------
    Gui 15:Default
    Gui +LastFoundExist
    IfWinNotExist
    {
        Gui +Owner
        Gosub, build_directory_array
        opt=Left
        yy=7
        For key, value in directories
        {
            label := directories[key,"label"]
            Gui, Add, Button, x6 y%yy% w130 h20 %opt% gDo_Dir v%key%, %label%  ; Do_Dir
            yy+=20
        }
        yy+=10
        Gui, Add, Button, x6 y%yy% w130 h20 %opt% default gAdd_Directory, &Add ( A )   ; Add_Directory
        yy+=30
        Gui, Add, Button, x6 y%yy% w130 h20 %opt% default gEdit_Directories, &Edit ( E )   ; Edit_Directories
        yy+=30
        Gui, Add, Button, x6 y%yy% w130 h20 %opt% default gDo_Just_Quit vJustQuit, &JustQuit ( J )   ; Do_Just_Quit
    }
    Gui, +ToolWindow
    Gui, Show, h%mh% w146, Directories
    Gui, +AlwaysOnTop
    GuiControl, Focus, JustQuit
return


;------------------------------------------------------------------------------
show_gui_directories_65:
;------------------------------------------------------------------------------
    Gui 65:Default

    Gui +LastFoundExist
    IfWinNotExist
    {
        Gui +Owner
        Gosub, build_directory_array
        opt=Left
        xx=6
        yy=7
        For key, value in directories
        {
            slabel := directories[key,"slabel"]
            Gui, Add, Button, x%xx% y%yy% w20 h20 %opt% gDo_Dir v%key%, %slabel%  ; Do_Dir
            xx+=20
            if(xx > 86)
            {
                xx=6
                yy+=20
            }
        }
        Gui, Add, Button, x86 y87 w20 h20 gDo_Just_Quit vJustQuit, &J ; Do_Just_Quit
    }
    Gui, +ToolWindow
    Gui, Show, h119 w117, Directories
    Gui, +AlwaysOnTop
    GuiControl, Focus, JustQuit
return


;new_file_code
build_file_array:
    files   := Array()
    files_L := Array()
    if(!file_array_built) {
        Loop, read, %A_ScriptDir%\files.ini
        {
            thisline=%A_LoopReadLine%
            IfInString, thisline, |
            {
                StringSplit, fileArray, thisline, |
                label = %fileArray1%
                orig = %label%
                key := RegExReplace(label, "\W", "")
                slabel=
                FoundPos := RegExMatch(label, "&(.)", UnquotedOutputVar)
                if(FoundPos)
                {
                    StringUpper, OutputVar, UnquotedOutputVar1
                    label := label . " ( " . OutputVar . " )"
                    slabel := "&" . OutputVar
                }
                file = %fileArray2%
                files[key,"orig"] := orig
                files[key,"label"] := label
                files[key,"slabel"] := slabel
                files[key,"file"] := file

                files_L[label,"file"] := file
            }
        }
    }
return


build_directory_array:
    directories   := Array()
    directories_L := Array()
    if(!directory_array_built) {
        Loop, read, %A_ScriptDir%\directories.ini
        {
            thisline=%A_LoopReadLine%
            IfInString, thisline, |
            {
                StringSplit, DirArray, thisline, |
                label = %DirArray1%
                orig = %label%
                key := RegExReplace(label, "\W", "")
                slabel=
                FoundPos := RegExMatch(label, "&(.)", UnquotedOutputVar)
                if(FoundPos)
                {
                    StringUpper, OutputVar, UnquotedOutputVar1
                    label := label . " ( " . OutputVar . " )"
                    slabel := "&" . OutputVar
                }
                dir = %DirArray2%
                directories[key,"orig"] := orig
                directories[key,"label"] := label
                directories[key,"slabel"] := slabel
                directories[key,"dir"] := dir

                directories_L[label,"dir"] := dir
            }
        }
    }
return


;------------------------------------------------------------------------------
init_gui_options:
;------------------------------------------------------------------------------
    if(!gui_options_built) {
        Gui, 9:Add, Button, default x236 y307 w100 h30 , OK
        Gui, 9:Add, Button, x346 y307 w100 h30 , Cancel
        Gui, 9:Add, Tab, x6 y7 w440 h290 , Settings|Other
        Gui, 9:Add, Checkbox, x26 y47 w370 h30 vSettingRotate Checked%SettingRotate%, &Rotate tray icon when mute  ; SettingRotate
        Gui, 9:Add, Checkbox, x26 y87 w370 h30 vSettingPoker Checked%SettingPoker%, Run &Work Log Reminder routine ; SettingPoker
        Gui, 9:Add, Checkbox, x26 y127 w370 h30 vSettingOhide Checked%SettingOhide%, Run O&hide routine            ; SettingOhide
        Gui, 9:Add, Checkbox, x26 y167 w370 h30 vSettingOcred Checked%SettingOcred%, Run &Ocred routine            ; SettingOcred
        Gui, 9:Add, Checkbox, x26 y207 w370 h30 vSettingEyeRest Checked%SettingEyeRest%, Run &Eye Rest routine     ; SettingEyeRest
        Gui, 9:Tab, Other
        Gui, 9:Add, Radio, x26 y47 w390 h20 , Radio
        Gui, 9:Add, Radio, x26 y77 w390 h20 , Radio
        Gui, 9:Add, Radio, x26 y107 w390 h20 , Radio
        gui_options_built++
    }
return


;------------------------------------------------------------------------------
show_gui_jmenu_10:
;------------------------------------------------------------------------------
    if(!gui_jmenu_10_built) {
        Gui, 10:Add, Text,     x6   y7   w70 h20,                      Set Priority
        Gui, 10:Add, Button,   x106 y7   w20 h20  gJ_action, &1
        Gui, 10:Add, Button,   x126 y7   w20 h20  gJ_action, &2
        Gui, 10:Add, Button,   x146 y7   w20 h20  gJ_action, &3
        Gui, 10:Add, Button,   x86  y27  w20 h20  gJ_action, &a
        Gui, 10:Add, Button,   x106 y27  w20 h20  gJ_action, &b
        Gui, 10:Add, Button,   x126 y27  w20 h20  gJ_action, &c
        Gui, 10:Add, Button,   x146 y27  w20 h20  gJ_action, &d
        Gui, 10:Add, Button,   x166 y27  w20 h20  gJ_action, &x
        Gui, 10:Add, Button,   x186 y27  w20 h20  gJ_action, &z
        Gui, 10:Add, Button,   x86  y7   w20 h20  gJ_action, &0
        Gui, 10:Add, Button,   x166 y7   w20 h20  gJ_action, &4
        Gui, 10:Add, Button,   x186 y7   w20 h20  gJ_action, &5
        Gui, 10:Add, Button,   x206 y7   w20 h20  gJ_action, &6
        Gui, 10:Add, Button,   x226 y7   w20 h20  gJ_action, &7
        Gui, 10:Add, Button,   x246 y7   w20 h20  gJ_action, &8
        Gui, 10:Add, Button,   x266 y7   w20 h20  gJ_action, &9

        Gui, 10:Add, Button,   x6   y47  w70 h20  gJ_action, &Private
        Gui, 10:Add, Button,   x6   y67  w70 h20  gJ_action, &Kill
        Gui, 10:Add, Button,   x6   y87  w70 h20  gJ_action, &Restart
        Gui, 10:Add, Button,   x6   y107 w70 h20  gJ_action, &Total Kill

        Gui, 10:Add, Button,   x86  y47  w70 h20  gJ_action, Recall Bu&ffer
        Gui, 10:Add, Button,   x86  y67  w70 h20  gJ_action, paste (&V)
        Gui, 10:Add, Button,   x86  y87  w70 h20  gJ_action, paste 2 (&E)
        Gui, 10:Add, Button,   x86  y107 w70 h20  gJ_action, save to &Y

        Gui, 10:Add, Button,   x166 y67  w70 h20  gJ_action, T&imestamp
        Gui, 10:Add, Button,   x166 y87  w70 h20  gJ_action, &Lock

        Gui, 10:Add, Button,   x246 y67  w70 h20  gJ_action, &Mute
        Gui, 10:Add, Button,   x246 y87  w70 h20  gJ_action, Vol&ume

        Gui, 10:Add, Button,   x256 y117 w70 h20  gJ_action, &Just quit
        Gui, 10:Add, GroupBox, x2 y29 w80 h107 , Script
        gui_jmenu_10_built++
    }
    Gui, 10:Show, x0 y0 h146 w337 NoActivate, J %prog% %compname%
    Gui, 10:+AlwaysOnTop
return


J_action:
    CurrControl := A_GuiControl
    FoundPos := RegExMatch(CurrControl, "&(.)", UnquotedOutputVar)
    if(FoundPos)
    {
        SendInput % UnquotedOutputVar1
    }
    else
    {
        StringRight, outputvar, CurrControl, 1
        FoundPos := RegExMatch(outputvar, "\d", UnquotedOutputVar)
        if(FoundPos)
        {
            outputvar++
            StringMid, outputvar, current_cb_list, %outputvar%, 1
        }
        SendInput % outputvar
    }
return


;------------------------------------------------------------------------------
show_gui_jmenu_60:
;------------------------------------------------------------------------------
    if(!gui_jmenu_60_built) {
        Gui, 60:Add, Button, x22   y7  w20 h20 gJ_action,       &1
        Gui, 60:Add, Button, x42   y7  w20 h20 gJ_action,       &2
        Gui, 60:Add, Button, x62   y7  w20 h20 gJ_action,       &3
        Gui, 60:Add, Button, x2    y37 w20 h20 gJ_action,       &a
        Gui, 60:Add, Button, x22   y37 w20 h20 gJ_action,       &b
        Gui, 60:Add, Button, x42   y37 w20 h20 gJ_action,       &c
        Gui, 60:Add, Button, x62   y37 w20 h20 gJ_action,       &d
        Gui, 60:Add, Button, x82   y37 w20 h20 gJ_action,       &x
        Gui, 60:Add, Button, x102  y37 w20 h20 gJ_action,       &z
        Gui, 60:Add, Button, x122  y37 w20 h20 gJ_action,       &p
        Gui, 60:Add, Button, x2    y7  w20 h20 gJ_action,       &0
        Gui, 60:Add, Button, x82   y7  w20 h20 gJ_action,       &4
        Gui, 60:Add, Button, x102  y7  w20 h20 gJ_action,       &5
        Gui, 60:Add, Button, x122  y7  w20 h20 gJ_action,       &6
        Gui, 60:Add, Button, x142  y7  w20 h20 gJ_action,       &7
        Gui, 60:Add, Button, x162  y7  w20 h20 gJ_action,       &8
        Gui, 60:Add, Button, x182  y7  w20 h20 gJ_action,       &9

        Gui, 60:Add, Button, x2    y67 w20 h20 gJ_action,       &K
        Gui, 60:Add, Button, x22   y67 w20 h20 gJ_action,       &R
        Gui, 60:Add, Button, x42   y67 w20 h20 gJ_action,       &T
        Gui, 60:Add, Button, x62   y67 w20 h20 gJ_action,       &V
        Gui, 60:Add, Button, x82   y67 w20 h20 gJ_action,       &E
        Gui, 60:Add, Button, x102  y67 w20 h20 gJ_action,       &Y
        Gui, 60:Add, Button, x122  y67 w20 h20 gJ_action,       &I
        Gui, 60:Add, Button, x142  y67 w20 h20 gJ_action,       &M
        Gui, 60:Add, Button, x162  y67 w20 h20 gJ_action,       &U
        Gui, 60:Add, Button, x182  y67 w20 h20 gJ_action,       &J
        gui_jmenu_60_built++
    }
    Gui, 60:Show, x0 y0 h96 w207 NoActivate, J %prog% %compname%
    Gui, 60:+AlwaysOnTop
return


;------------------------------------------------------------------------------
;gui_toolbar_section
init_gui_toolbar:
;------------------------------------------------------------------------------
    ; close together = 3 pixel difference
    ; separate group = 10 pixel difference *target
    if(!gui_toolbar_built) {
; $F;lDA gF;llxj
; Moved to column 1 for more space
Gui, 11:+Owner
Gui, 11:Add, Picture,   x3   y1 w19 h19 gTotalKill                          , %ImageDir%\bkillicon.png     ; TotalKill
Gui, 11:Add, Picture,   x296 y1 w19 h19 gTB_RM4SuspendToggle                , %ImageDir%\rm4.png           ; TB_RM4SuspendToggle
Gui, 11:Add, Picture,   x296 y1 w19 h19 Hidden gTB_RM4SuspendToggle vRSus   , %ImageDir%\rm4s.png          ; TB_RM4SuspendToggle RSus
Gui, 11:Add, Picture,   x296 y1 w19 h19 Hidden gTB_RM4SuspendToggle vROff   , %ImageDir%\rm4off.png        ; TB_RM4SuspendToggle ROff
Gui, 11:Add, Picture,   x318 y1 w19 h19 gTB_PrivateToggle                   , %ImageDir%\privateoff.png    ; TB_PrivateToggle
Gui, 11:Add, Picture,   x318 y1 w19 h19 Hidden gTB_PrivateToggle vPrivateOn , %ImageDir%\privateon.png     ; TB_PrivateToggle PrivateOn
Gui, 11:Add, Picture,   x370 y1 w19 h19 gKillScript                         , %ImageDir%\bexiticon.png     ; KillScript
Gui, 11:Add, Picture,   x392 y1 w19 h19 gRestartScript                      , %ImageDir%\breloadicon.png   ; RestartScript
Gui, 11:Add, Picture,   x414 y1 w19 h19 gTB_OptionsB                        , %ImageDir%\bsettingsicon.png ; TB_OptionsB
Gui, 11:Add, Picture,   x443 y1 w60 h20 gTB_NEO_Jmenu vJmenuButton          , %ImageDir%\jbutton.png       ; TB_NEO_Jmenu JmenuButton
Gui, 11:Add, Picture,   x513 y1 w60 h20 gTB_MainMenu    vMainMenu           , %ImageDir%\bmain.png         ; TB_MainMenu MainMenu
Gui, 11:Add, Picture,   x583 y1 w19 h19 gTB_Volume                          , %ImageDir%\bvolumeicon.png   ; TB_Volume
Gui, 11:Add, Picture,   x605 y1 w19 h19 gTB_Mute                            , %ImageDir%\bmuteicon.png     ; TB_Mute
Gui, 11:Add, Picture,   x634 y1 w19 h19 gTB_Lock                            , %ImageDir%\blockicon.png     ; TB_Lock
;WARNING: Double clicking text with a gLabel on a gui puts the text on the clipboard
;On Vista+, WM_NCLBUTTONDBLCLK and WM_LBUTTONDBLCLK on static text controls will copy the static text to the clipboard.
Gui, 11:Add, Picture,   x663 y1 w19 h19 gTB_BuffCopy                        , %ImageDir%\bcopyicon.png     ; TB_BuffCopy
Gui, 11:Add, Picture,   x685 y1 w19 h19 gTB_NEO_Pastev                      , %ImageDir%\bpasteicon.png    ; TB_Pastev
Gui, 11:Add, Picture,   x707 y1 w19 h19 gTB_NEO_Paste2                      , %ImageDir%\bpaste2icon.png   ; TB_Paste2
;Gui, 11:Add, Text,      x736 y1 w320 h20                                    , See Grindstone
Gui, 11:Add, ComboBox,  x736 y1 w320    vNoteText                           , %notes_list%                 ; NoteText
Gui, 11:Add, CheckBox, x1066 y1 w50 h20 vSettingSave gSaveCheck             , &Save                        ; SaveCheck SettingSave
Gui, 11:Add, Button,   x1126 y1 w48 h20 Default gNoteSubmit vNoteCount      , OK                           ; NoteSubmit NoteCount
Gui, 11:Add, Picture,  x1180 y1 w20 h20                                     , %ImageDir%\exclbw.png        ;
Gui, 11:Add, Picture,  x1180 y1 w20 h20 Hidden vExclaim                     , %ImageDir%\excl.png          ; Exclaim
Gui, 11:Add, Picture,  x1206 y1 w19 h19 gTB_Snooze vSnoozer                 , %ImageDir%\bsnooze.png       ; TB_Snooze Snoozer

Gui, 11:+ToolWindow
        MainMenu_TT := "Display main menu"
        JmenuButton_TT := "Display alternate menu"
        toolbar_margin=6
        toolbar_offset=70
        toolbar_width := A_ScreenWidth - toolbar_offset - toolbar_margin
        SelectedItem := f_IniRead({ filename:   my_ini_file
                                  , category:   "settings"
                                  , variable:   "selected_item"
                                  , linenumber: A_LineNumber })
        ; SELECTED item to be followed by two pipes to indicate it is selected
        StringReplace, notes_list, notes_list, %SelectedItem%, %SelectedItem%|
        ; First pipe says replace list, second pipe in case last item is selected item
        ; E-CINT: Counter-intuitive - to indicate replace, lead with a pipe.
        ; Changing the variable value to control the path through the code
        notes_list := "|" . notes_list . "|"
        ; E-CINT: Counter-intuitive - I have to specify GUI# to get to
        ; variable name even if there is only one variable named that.
        ; E-FQUI: Fails quietly - although it would respond to try-catch, and
        ; sets ErrorLevel, if it fails to update a control for whatever
        ; reason, it won't tell you, and even with try-catch, it doesn't tell
        ; you why
        GuiControl, 11:, NoteText, %notes_list%
        Gosub, toolbar_update
        gui_toolbar_built++
    }
return


TB_PrivateToggle:
TB_RM4SuspendToggle:
TB_OptionsB:
TB_MainMenu:
TB_NEO_Jmenu:
TB_Volume:
TB_Mute:
TB_Lock:
TB_BuffCopy:
TB_NEO_Pastev:
TB_NEO_Paste2:
TB_NoteA:
TB_Snooze:
    switch_back(1)
    this_label := A_ThisLabel
    this_label := RegExReplace(this_label, "TB_", "")
    Gosub, %this_label%
return


Snooze: ;not yet implemented
return


;------------------------------------------------------------------------------
show_gui_todo:
;------------------------------------------------------------------------------
    Gui ToDo:Default

    Gui +LastFoundExist
    IfWinNotExist
    {
        Gui, +Owner

        gui, font, s7, Tahoma
        Gui, Add, Button,    x25  y1  w48 h15 gTDT_Do_Jmenu_1,          1
        Gui, Add, Button,    x75  y1  w48 h15 gTDT_Do_Jmenu_2,          2
        Gui, Add, Button,    x125 y1  w48 h15 gTDT_Do_Jmenu_3,          3
        Gui, Add, Button,    x175 y1  w48 h15 gTDT_Do_Jmenu_A,          A
        Gui, Add, Button,    x225 y1  w48 h15 gTDT_Do_Jmenu_Complete,   Complete

        Gui, +ToolWindow
    }
    Gui, Show, x239 y36 h16 w400 NoActivate, %tdt_Title%
    Gui, +AlwaysOnTop
    tdt_hidden=0
return


;-----------------------------
     ShowHideTodoToolbar:    ;
;-----------------------------
return
    TodoTitle=todo_
    If WinActive(TodoTitle)
    {
        if(tdt_hidden)
        {
            Gosub, show_gui_todo
        }
    }
    else
    {
        IfWinNotActive, %tdt_Title%
        {
            if(!tdt_hidden)
            {
                Gui, Todo:Hide
                tdt_hidden=1
            }
        }
    }
return


TDT_Do_Jmenu_1:
TDT_Do_Jmenu_2:
TDT_Do_Jmenu_3:
TDT_Do_Jmenu_A:
TDT_Do_Jmenu_B:
TDT_Do_Jmenu_Complete:
    WinActivate %TodoTitle%
    this_label := A_ThisLabel
    this_label := RegExReplace(this_label, "TDT_", "")
    Gosub, %this_label%
return


;------------------------------------------------------------------------------
show_gui_outlook:
;------------------------------------------------------------------------------
    Gui OTool:Default

    Gui +LastFoundExist
    IfWinNotExist
    {
        Gui, +Owner

        Gui, font, s7, Tahoma  ; Set 10-point Verdana.
        Gui, Add, Button,    x25  y1  w48 h15 gOLT_oDMZ,                DMZ
        Gui, Add, Button,    x75  y1  w48 h15 gOLT_oToDo,               To Do
        Gui, Add, Button,    x125 y1  w48 h15 gOLT_oSent,               Sent
        Gui, Add, Button,    x175 y1  w48 h15 gOLT_oSelectAll,          Select All
        Gui, Add, Button,    x225 y1  w48 h15 gOLT_oArchive,            Archive
        Gui, Add, Button,    x275 y1  w48 h15 gOLT_oReplyAll,           ReplyAll
        Gui, Add, Button,    x325 y1  w48 h15 gOLT_oNewMail,            NewMail

        Gui, +ToolWindow
    }
    Gui, Show, x239 y36 h16 w400 NoActivate, %olt_Title%
    Gui, +AlwaysOnTop
    olt_hidden=0
return


;-----------------------------
     ShowHideOutlookToolbar: ;
;-----------------------------
    OutlookTitle=Microsoft Outlook
    If WinActive("ahk_class Net UI Tool Window") or WinActive(OutlookTitle)
    {
        if(olt_hidden)
        {
            Gosub, show_gui_outlook
        }
    }
    else
    {
        IfWinNotActive, %olt_Title%
        {
            if(!olt_hidden)
            {
                Gui, OTool:Hide
                olt_hidden=1
            }
        }
    }
return


OLT_oDMZ:
OLT_oToDo:
OLT_oSent:
OLT_oSelectAll:
OLT_oArchive:
OLT_oReplyAll:
OLT_oNewMail:
    WinActivate %OutlookTitle%
    this_label := A_ThisLabel
    this_label := RegExReplace(this_label, "OLT_", "")
    Gosub, %this_label%
return


oDMZ:
    WinActivate %OutlookTitle%
    SendInput, ^a^+1
Return

oToDo:
    WinActivate %OutlookTitle%
    SendInput, ^+2
Return

oSelectAll:
    WinActivate %OutlookTitle%
    SendInput, ^a
Return

oSent:
    WinActivate %OutlookTitle%
    SendInput, ^a^+3
Return

oArchive:
    WinActivate %OutlookTitle%
    SendInput, ^+4
Return

oReplyAll:
    WinActivate %OutlookTitle%
    SendInput, !l
Return

oNewMail:
    WinActivate %OutlookTitle%
    SendInput, ^n
Return


;------------------------------------------------------------------------------
show_gui_timestamp_12:
;------------------------------------------------------------------------------
    if(!gui_timestamp_12_built) {
        Gui, 12:Add, Button, x155 y6   w40  h30 gJ_action, &A
        Gui, 12:Add, Button, x155 y46  w40  h30 gJ_action, &F
        Gui, 12:Add, Button, x155 y86  w40  h30 gJ_action, &K
        Gui, 12:Add, Button, x155 y126 w40  h30 gJ_action, &E
        Gui, 12:Add, Button, x155 y166 w40  h30 gJ_action, &X
        Gui, 12:Add, Button, x96  y207 w100 h30 gJ_action, &Just Quit
        gui, 12:add, text,   x5   y16  w140 h20 , wednesday`, april 13`, 2011
        Gui, 12:Add, Text,   x5   y56  w140 h20 , 11:06 PM 4/13/2011
        Gui, 12:Add, Text,   x5   y96  w140 h20 , 2011-04-13
        Gui, 12:Add, Text,   x5   y136 w140 h20 , 2011-04-13 23:06
        Gui, 12:Add, Text,   x5   y176 w140 h20 , 2011-04-13 Wednesday
        gui_timestamp_12_built++
    }
    Gui, 12:Show, x0 y0 h247 w207 NoActivate, Timestamp
    Gui, 12:+AlwaysOnTop
return


;------------------------------------------------------------------------------
show_gui_timestamp_62:
;------------------------------------------------------------------------------
    if(!gui_timestamp_62_built) {
        Gui, 62:Add, Button, x6  y7  w20 h20 gJ_action, &A
        Gui, 62:Add, Button, x26 y7  w20 h20 gJ_action, &F
        Gui, 62:Add, Button, x46 y7  w20 h20 gJ_action, &K
        Gui, 62:Add, Button, x66 y7  w20 h20 gJ_action, &E
        Gui, 62:Add, Button, x86 y7  w20 h20 gJ_action, &X
        Gui, 62:Add, Button, x6  y27 w20 h20 gJ_action, &J
        gui_timestamp_62_built++
    }
    Gui, 62:Show, x0 y0 h119 w117 NoActivate, Timestamp
    Gui, 62:+AlwaysOnTop
return


;------------------------------------------------------------------------------
init_gui_paste:
;------------------------------------------------------------------------------
    if(!gui_paste_built) {
        Gui, 13:Add, Button, x6   y7   w340 h20 Left gJ_action vPasteButton0, &0 ; PasteButton0
        Gui, 13:Add, Button, x6   y27  w340 h20 Left gJ_action vPasteButton1, &1 ; PasteButton1
        Gui, 13:Add, Button, x6   y47  w340 h20 Left gJ_action vPasteButton2, &2 ; PasteButton2
        Gui, 13:Add, Button, x6   y67  w340 h20 Left gJ_action vPasteButton3, &3 ; PasteButton3
        Gui, 13:Add, Button, x6   y87  w340 h20 Left gJ_action vPasteButton4, &4 ; PasteButton4
        Gui, 13:Add, Button, x366 y7   w340 h20 Left gJ_action vPasteButton5, &5 ; PasteButton5
        Gui, 13:Add, Button, x366 y27  w340 h20 Left gJ_action vPasteButton6, &6 ; PasteButton6
        Gui, 13:Add, Button, x366 y47  w340 h20 Left gJ_action vPasteButton7, &7 ; PasteButton7
        Gui, 13:Add, Button, x366 y67  w340 h20 Left gJ_action vPasteButton8, &8 ; PasteButton8
        Gui, 13:Add, Button, x366 y87  w340 h20 Left gJ_action vPasteButton9, &9 ; PasteButton9

        Gui, 13:Add, Button, x16  y147 w340 h20 Left gJ_action vPasteButtona, &A ; PasteButtona
        Gui, 13:Add, Button, x16  y167 w340 h20 Left gJ_action vPasteButtonb, &B ; PasteButtonb
        Gui, 13:Add, Button, x16  y187 w340 h20 Left gJ_action vPasteButtonc, &C ; PasteButtonc
        Gui, 13:Add, Button, x16  y207 w340 h20 Left gJ_action vPasteButtond, &D ; PasteButtond
        Gui, 13:Add, Button, x16  y227 w340 h20 Left gJ_action vPasteButtone, &E ; PasteButtone
        Gui, 13:Add, Button, x16  y247 w340 h20 Left gJ_action vPasteButtonf, &F ; PasteButtonf
        Gui, 13:Add, Button, x16  y267 w340 h20 Left gJ_action vPasteButtong, &G ; PasteButtong
        Gui, 13:Add, Button, x16  y287 w340 h20 Left gJ_action vPasteButtonh, &H ; PasteButtonh
        Gui, 13:Add, Button, x16  y307 w340 h20 Left gJ_action vPasteButtoni, &I ; PasteButtoni
        Gui, 13:Add, Button, x16  y327 w340 h20 Left gJ_action vPasteButtonk, &K ; PasteButtonk
        Gui, 13:Add, Button, x16  y347 w340 h20 Left gJ_action vPasteButtonl, &L ; PasteButtonl
        Gui, 13:Add, Button, x16  y367 w340 h20 Left gJ_action vPasteButtonm, &M ; PasteButtonm
        Gui, 13:Add, Button, x376 y147 w340 h20 Left gJ_action vPasteButtonn, &N ; PasteButtonn
        Gui, 13:Add, Button, x376 y167 w340 h20 Left gJ_action vPasteButtono, &O ; PasteButtono
        Gui, 13:Add, Button, x376 y187 w340 h20 Left gJ_action vPasteButtonp, &P ; PasteButtonp
        Gui, 13:Add, Button, x376 y207 w340 h20 Left gJ_action vPasteButtonq, &Q ; PasteButtonq
        Gui, 13:Add, Button, x376 y227 w340 h20 Left gJ_action vPasteButtonr, &R ; PasteButtonr
        Gui, 13:Add, Button, x376 y247 w340 h20 Left gJ_action vPasteButtons, &S ; PasteButtons
        Gui, 13:Add, Button, x376 y267 w340 h20 Left gJ_action vPasteButtont, &T ; PasteButtont
        Gui, 13:Add, Button, x376 y287 w340 h20 Left gJ_action vPasteButtonu, &U ; PasteButtonu
        Gui, 13:Add, Button, x376 y307 w340 h20 Left gJ_action vPasteButtonw, &W ; PasteButtonw
        Gui, 13:Add, Button, x376 y327 w340 h20 Left gJ_action vPasteButtonx, &X ; PasteButtonx
        Gui, 13:Add, Button, x376 y347 w340 h20 Left gJ_action vPasteButtony, &Y ; PasteButtony
        Gui, 13:Add, Button, x376 y367 w340 h20 Left gJ_action vPasteButtonz, &Z ; PasteButtonz

        Gui, 13:Add, GroupBox, x6 y117 w750 h310 , Permanent buffers

        Gui, 13:Add, Button, x656 y437 w100 h30 gJ_action, &Just Quit
        Gui, 13:Add, Button, x546 y437 w100 h30 , Most Recent &V
        Gui, 13:+AlwaysOnTop
        gui_paste_built++
    }
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Function_section                                                         |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
f_width() ; f_width:
;------------------------------------------------------------------------------
{
    return A_ScreenWidth  - 1
}


;------------------------------------------------------------------------------
f_height() ; f_height:
;------------------------------------------------------------------------------
{
    return A_ScreenHeight - 1
}


;------------------------------------------------------------------------------
f_cwidth() ; f_cwidth:
;------------------------------------------------------------------------------
{
    retval := A_ScreenWidth / 2
    Transform, retval, Round, %retval%
    return retval
}


;------------------------------------------------------------------------------
f_cheight() ; f_cheight:
;------------------------------------------------------------------------------
{
    retval := A_ScreenHeight / 2
    Transform, retval, Round, %retval%
    return retval
}


;------------------------------------------------------------------------------
f_sheight() ; f_sheight:
;------------------------------------------------------------------------------
{
    retval := A_ScreenHeight / 2 - 300
    Transform, retval, Round, %retval%
    return retval
}


;------------------------------------------------------------------------------
f_swidth() ; f_swidth:
;------------------------------------------------------------------------------
{
    retval  := A_ScreenWidth  / 2 - 90
    Transform, retval,  Round, %retval%
    return retval
}


;------------------------------------------------------------------------------
make_normal(input) ; make_normal:
;------------------------------------------------------------------------------
{
    global
    StringSplit, inputLetters, input
    output=
    good=0
    this_letter=
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


;------------------------------------------------------------------------------
refresh_ini_value(var, section) ; refresh_ini_value:
;------------------------------------------------------------------------------
{
    global
    varvalue := f_IniRead({ filename:   my_ini_file
                          , category:   section
                          , variable:   var
                          , linenumber: A_LineNumber })
    StringLeft, OutputVar, var, 8
    If OutputVar = mystring
    {
        varvalue := make_normal(varvalue)
    }

    %var% = %varvalue%
    return
}


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Control_j_menu_section                                                   |
;                                                                             |
;=============================================================================+

::ahh::autohotkey

::pq::postgresql

#z::Goto NEO_Jmenu

;------------------------------------------------------------------------------
^j::
NEO_Jmenu:
;------------------------------------------------------------------------------
    if(check_for_virtualbox())
        return

    if(A_ThisLabel = "NEO_Jmenu")
        gui_hide()

    j_show_tip=

    CoordMode, Mouse, Screen
    WinGet, lastwin, ID, A
    debug({ param1: concat(["lastwin=", lastwin]), linenumber: A_LineNumber })

    Gosub, esc_key

    this_gui := 10 + private_on * private_gui_start

    Gosub, show_gui_jmenu_%this_gui%

    Input, buffer_key, L1T60, {esc}

    Gui, %this_gui%:Hide

    if buffer_key = 0
        Gosub, Do_Jmenu_0
    else if buffer_key = 1
        Gosub, Do_Jmenu_1
    else if buffer_key = 2
        Gosub, Do_Jmenu_2
    else if buffer_key = 3
        Gosub, Do_Jmenu_3
    else if buffer_key = 4
        Gosub, Do_Jmenu_4
    else if buffer_key = 5
        Gosub, Do_Jmenu_5
    else if buffer_key = 6
        Gosub, Do_Jmenu_6
    else if buffer_key = 7
        Gosub, Do_Jmenu_7
    else if buffer_key = 8
        Gosub, Do_Jmenu_8
    else if buffer_key = 9
        Gosub, Do_Jmenu_9
    else if buffer_key = a
        Gosub, Do_Jmenu_a
    else if buffer_key = b
        Gosub, Do_Jmenu_b
    else if buffer_key = c
        Gosub, Do_Jmenu_c
    else if buffer_key = d
        Gosub, Do_Jmenu_d
    else if buffer_key = e
        Gosub, NEO_Paste2
    else if buffer_key = f
        Gosub, NEO_RecallBuffer
    else if buffer_key = i
        Gosub, NEO_Timestamp
    else if buffer_key = j
        j_show_tip=
    else if buffer_key = k
        Gosub, KillScript
    else if buffer_key = l
        Gosub, Lock
    else if buffer_key = m
        Gosub, Mute
    else if buffer_key = p
        Gosub, PrivateToggle
    else if buffer_key = r
        Gosub, RestartScript
    else if buffer_key = t
        Gosub, TotalKill
    else if buffer_key = u
        Gosub, Volume
    else if buffer_key = v
        Gosub, NEO_Pastev
    else if buffer_key = x
        Gosub, Do_Jmenu_x
    else if buffer_key = y
        Gosub, NEO_Save_to_Y
    else if buffer_key = z
        Gosub, NEO_Do_Jmenu_z
    else if buffer_key =
        j_show_tip=Timeout
    else
        j_show_tip=No such option.

    if(j_show_tip)
    {
        show_tip := j_show_tip
        Gosub, err_tip
        SetTimer,clear_err_tip,-1000
    }
return


;new_file_code
;------------------------------------------------------------------------------
Add_file:
;------------------------------------------------------------------------------
    gui_hide()
    FileSelectFile, file_path, 3
    if file_path <>
    {
        default_label := RegExReplace(file_path, ".*\\", "")
        InputBox, label, Enter Label, Enter a label for %file_path%.,,,,,,,,&%default_label%
        if !ErrorLevel
        {
            add_file(label,file_path)
        }
    }
return


;new_file_code
;------------------------------------------------------------------------------
add_file(label,org) ; add_file:
;------------------------------------------------------------------------------
{
    global

    key := RegExReplace(label, "\W", "")
    files[key,"orig"] := label
    files[key,"file"] := org
    write_files_file()
    return
}


;new_file_code
;------------------------------------------------------------------------------
write_files_file() ; write_files_file
;------------------------------------------------------------------------------
{
    global

    this_file=tmporg.ini
    f_path = %A_ScriptDir%\%this_file%

    FileDelete, %f_path%

    For key, value in files
    {
        label := files[key,"orig"]
        org := files[key,"file"]
        FileAppend, %label% | %org%`n,%f_path%
    }

    f_target = %A_ScriptDir%\files.ini

    FileMove, %f_path%, %f_target%, 1

    return
}


;new_file_code
;------------------------------------------------------------------------------
Edit_files:
;------------------------------------------------------------------------------
    gui_hide()
    this_file=files.ini
    f_path = %A_ScriptDir%\%this_file%
    f_param = %this_file%
    Gosub, Gofile
return


;------------------------------------------------------------------------------
Add_Directory:
;------------------------------------------------------------------------------
    gui_hide()
    FileSelectFolder, folder_path, , 3
    if folder_path <>
    {
        default_label := RegExReplace(folder_path, ".*\\", "")
        InputBox, label, Enter Label, Enter a label for %folder_path%.,,,,,,,,&%default_label%
        if !ErrorLevel
        {
            add_directory(label,folder_path)
        }
    }
return


;------------------------------------------------------------------------------
EditIni:
;------------------------------------------------------------------------------
    gui_hide()
    f_path = %ini_file%
    f_param = %ini_file_nopath%
    ;new_file_code
    Gosub, Gofile
return


;------------------------------------------------------------------------------
EditScript:
;------------------------------------------------------------------------------
    gui_hide()
    f_path = %A_ScriptFullPath%
    f_param = %A_ScriptName%
    ;new_file_code
    Gosub, Gofile
return


;------------------------------------------------------------------------------
add_directory(label,dir) ; add_directory:
;------------------------------------------------------------------------------
{
    global

    key := RegExReplace(label, "\W", "")
    directories[key,"orig"] := label
    directories[key,"dir"] := dir
    write_directories_file()
;    this_file=directories.ini
;    f_path = %A_ScriptDir%\%this_file%
;    FileAppend, %label% | %dir%`n,%f_path%
    return
}


;------------------------------------------------------------------------------
write_directories_file() ; write_directories_file
;------------------------------------------------------------------------------
{
    global

    this_file=tmpdir.ini
    f_path = %A_ScriptDir%\%this_file%

    FileDelete, %f_path%

    For key, value in directories
    {
        label := directories[key,"orig"]
        dir := directories[key,"dir"]
        FileAppend, %label% | %dir%`n,%f_path%
    }

    f_target = %A_ScriptDir%\directories.ini

    FileMove, %f_path%, %f_target%, 1

    return
}


;------------------------------------------------------------------------------
Edit_Directories:
;------------------------------------------------------------------------------
    gui_hide()
    this_file=directories.ini
    f_path = %A_ScriptDir%\%this_file%
    f_param = %this_file%
    ;new_file_code
    Gosub, Gofile
return


;------------------------------------------------------------------------------
KillScript:
;------------------------------------------------------------------------------
    gui_hide()
    ExitApp
return


;------------------------------------------------------------------------------
clear_err_tip:
;------------------------------------------------------------------------------
    ClearTip(SHOWTIP_ERR)
return


;------------------------------------------------------------------------------
clear_big_tip:
;------------------------------------------------------------------------------
    ClearTip(SHOWTIP_BIG)
return


;------------------------------------------------------------------------------
Do_Just_Quit:
;------------------------------------------------------------------------------
    gui_hide()
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
NEO_Paste2:
;------------------------------------------------------------------------------
    cb_prefix = ECB
Goto, NEO_paste_routine


; This routine runs upon script exit, so any necessary cleanup can happen here
;------------------------------------------------------------------------------
ExitSub:
;------------------------------------------------------------------------------
    Gosub, re_show
    ExitApp
return


;------------------------------------------------------------------------------
NEO_RecallBuffer:
;------------------------------------------------------------------------------
    no_paste=1
    cb_prefix = CB
    Goto, NEO_paste_routine


;------------------------------------------------------------------------------
^!v::
NEO_Pastev:
;------------------------------------------------------------------------------
    cb_prefix = CB
    Goto, NEO_paste_routine


;------------------------------------------------------------------------------
NEO_perm_copy_routine:
;------------------------------------------------------------------------------
    cb_routine=PermaCopy
    Gosub, NEO_BYank
return


;------------------------------------------------------------------------------
NEO_Save_to_Y:
;------------------------------------------------------------------------------
    cb_prefix = CB
    Goto, NEO_perm_copy_routine


;------------------------------------------------------------------------------
NEO_Do_Jmenu_z:
;------------------------------------------------------------------------------
    IfWinActive, todo
    {
        SendInput {F2}
        Sleep, 100
        SendInput {home}{right}{bs}Z{enter}
    }
    else
    {
        cb_prefix = ECB
        Goto, NEO_perm_copy_routine

    }
return


;------------------------------------------------------------------------------
Do_Jmenu_0:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring0", "string")
    SendInput, {Raw}%mystring0%
return


;------------------------------------------------------------------------------
Do_Jmenu_1:
;------------------------------------------------------------------------------
    IfWinActive, todo
    {
        SendInput {F2}
        Sleep, 100
        SendInput {home}{right}{bs}1{enter}
    }
    else
    {
        refresh_ini_value("mystring1", "string")
        SendInput, {Raw}%mystring1%
    }
return


;------------------------------------------------------------------------------
Do_Jmenu_2:
;------------------------------------------------------------------------------
    IfWinActive, todo
    {
        SendInput {F2}
        Sleep, 100
        SendInput {home}{right}{bs}2{enter}
    }
    else
    {
        refresh_ini_value("mystring2", "string")
        SendInput, {Raw}%mystring2%
    }
return


;------------------------------------------------------------------------------
Do_Jmenu_3:
;------------------------------------------------------------------------------
    IfWinActive, todo
    {
        SendInput {F2}
        Sleep, 100
        SendInput {home}{right}{bs}3{enter}
    }
    else
    {
        refresh_ini_value("mystring3", "string")
        SendInput, {Raw}%mystring3%
    }
return


;------------------------------------------------------------------------------
Do_Jmenu_4:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring4", "string")
    SendInput, {Raw}%mystring4%
return


;------------------------------------------------------------------------------
Do_Jmenu_5:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring5", "string")
    SendInput, {Raw}%mystring5%
return


;------------------------------------------------------------------------------
Do_Jmenu_6:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring6", "string")
    SendInput, {Raw}%mystring6%
return


;------------------------------------------------------------------------------
Do_Jmenu_7:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring7", "string")
    SendInput, {Raw}%mystring7%
return


;------------------------------------------------------------------------------
Do_Jmenu_8:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring8", "string")
    SendInput, {Raw}%mystring8%
return


;------------------------------------------------------------------------------
Do_Jmenu_9:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring9", "string")
    SendInput, {Raw}%mystring9%
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Capslock_menu_section                                                    |
;                                                                             |
;=============================================================================+

NumpadAdd::
^'::
    SendInput, ``
return


;------------------------------------------------------------------------------
$`::
Mainmenu:
;------------------------------------------------------------------------------
    if(check_for_virtualbox())
        return

    CoordMode, Mouse, Screen

    WinGet, lastwin, ID, A
    debug({ param1: concat(["lastwin=", lastwin]), linenumber: A_LineNumber })

    Gosub, esc_key

    Gosub, CenterMouse

    gui_name=Main
    Gosub, Show_GUI
return


ApplicationsGuiEscape:
ApplicationsGuiClose:
FunctionsGuiEscape:
FunctionsGuiClose:
GamKeysGuiEscape:
GamKeysGuiClose:
LinksGuiEscape:
LinksGuiClose:
ScriptGuiEscape:
ScriptGuiClose:
WorkstationGuiEscape:
WorkstationGuiClose:
MainGuiEscape:
MainGuiClose:
    gui_hide()
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
IMDB:
;------------------------------------------------------------------------------
    gui_hide()
    GoLink("http://www.imdb.com/find?q=",0)
return


;------------------------------------------------------------------------------
RottenTom:
;------------------------------------------------------------------------------
    gui_hide()
    GoLink("http://www.rottentomatoes.com/search/?search=",0)
return


;------------------------------------------------------------------------------
Google:
;------------------------------------------------------------------------------
    gui_hide()
    GoLink("http://www.google.com/#q=",0)
return


;------------------------------------------------------------------------------
TheGoogle:
;------------------------------------------------------------------------------
    gui_hide()
    GoLink("http://www.google.com",1)
return


;------------------------------------------------------------------------------
Wikipedia:
;------------------------------------------------------------------------------
    gui_hide()
    GoLink("http://en.wikipedia.org/w/index.php?search=",0)
return


;new_file_code
;---------------------------
Filies:               ;
;---------------------------
    debug({ param1: "2Buttonfiles", linenumber: A_LineNumber })
    gui_hide()
    this_gui := 17 + private_on * private_gui_start
    Gosub, show_gui_files_%this_gui%
return

17ButtonOK:
17GuiClose:
    Gui, 17:Submit
17ButtonCancel:
17GuiEscape:
17ButtonJustQuit:
    Gui, Hide
return


;---------------------------
Directories:               ;
;---------------------------
    debug({ param1: "2ButtonDirectories", linenumber: A_LineNumber })
    gui_hide()
    this_gui := 15 + private_on * private_gui_start
    Gosub, show_gui_directories_%this_gui%
return

15ButtonOK:
15GuiClose:
    Gui, 15:Submit
15ButtonCancel:
15GuiEscape:
15ButtonJustQuit:
    Gui, Hide
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Clipboard_section                                                        |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
^o::
BuffCopy:
;------------------------------------------------------------------------------
    if(check_for_virtualbox())
        return

    cb_prefix = CB
    WinGetClass, cb_winclass, A
    Gosub, oYank
return


;------------------------------------------------------------------------------
cb_init:
;------------------------------------------------------------------------------
    FileCreateDir, %cb_dir%

    cb_key_static=ABCDEFGHIKLMNOPQRSTUWXYZ

    cb_key_rotate=0123456789
    cb_key_legal=%cb_key_static%%cb_key_rotate%

    Loop, Parse, cb_key_static
    {
        FileRead, cb_buf_%cb_prefix%_%A_LoopField%, %cb_dir%\%cb_prefix%_%A_LoopField%
        FileRead, cb_label_%cb_prefix%_%A_LoopField%, %cb_dir%\%cb_prefix%_L_%A_LoopField%
    }

    Loop, Parse, cb_key_rotate
    {
        FileRead, cb_buf_%cb_prefix%_%A_LoopField%, %cb_dir%\%cb_prefix%_%A_LoopField%
        FileRead, cb_label_%cb_prefix%_%A_LoopField%, %cb_dir%\%cb_prefix%_L_%A_LoopField%
    }
return


;------------------------------------------------------------------------------
NEO_paste_routine:
;------------------------------------------------------------------------------
    cb_routine=Paste
    Gosub, NEO_GetKey
    IfInString, cb_key_legal, %buffer_key%
    {
        ClipBoard := cb_buf_%cb_prefix%_%buffer_key%
        StringReplace, clipboard, clipboard, `r, , All
        if(no_paste)
        {
            no_paste=0
            show_tip=Recalled %ClipBoard%
            Gosub, big_tip
            SetTimer,clear_big_tip,-1000
        }
        else
        {
            SendInput {Raw}%ClipBoard%
        }
    }
return


;------------------------------------------------------------------------------
NEO_GetKey:
;------------------------------------------------------------------------------
    gui_hide()
    Gosub, init_gui_paste

    max_len=45
    if(private_on)
    {
        max_len=2
    }

    cb_tip_text=
    cb_loop_index=%cb_index%
;    If cb_prefix = CB
;    {
      jj=0
      current_cb_list=
      tmp_cb_prefix = CB
      Loop, %cb_rotate_max%
      {
        StringMid, cb_index_letter, cb_key_rotate, %cb_loop_index%, 1
        cb_add := cb_buf_%tmp_cb_prefix%_%cb_index_letter%
        StringReplace, cb_add, cb_add, `r`n, , All
        StringReplace, cb_add, cb_add, %A_Space%, , All
        StringReplace, cb_add, cb_add, %A_Tab%, , All
        StringLeft, cb_add, cb_add, %max_len%
        cb_tip_text = %cb_tip_text%%cb_index_letter%. %cb_add%`r`n
        current_cb_list=%current_cb_list%%cb_index_letter%
        GuiControl, 13:, PasteButton%jj%, &%cb_index_letter%         %cb_add%
        If cb_prefix <> CB
        {
            GuiControl, 13:Disable, PasteButton%jj%
        }
        cb_loop_index--
        jj++
        if(cb_loop_index < 1)
          cb_loop_index=%cb_rotate_max%
      }
;    }
    cb_tip_text = %cb_tip_text%`r`nPermanent buffers:`r`n
    cb_loop_index=1
    Loop, %cb_static_max%
    {
      StringMid, cb_index_letter, cb_key_static, %cb_loop_index%, 1
      cb_add := cb_label_%cb_prefix%_%cb_index_letter%
      cb_tip_text = %cb_tip_text%%cb_index_letter%. %cb_add%`r`n
      StringReplace, cb_add, cb_add, `r`n, , All
      StringLeft, cb_add, cb_add, %max_len%
      GuiControl, 13:, PasteButton%cb_index_letter%, &%cb_index_letter%         %cb_add%
      cb_loop_index++
    }
    WinGetClass, cb_winclass, A
    show_tip=%cb_routine% - Select buffer`r`n%cb_tip_text%
    gui_title=%cb_routine% - Select buffer
    Gui, 13:Show, x0 y0 h481 w767 NoActivate, %gui_title%
    Gui, 13:+AlwaysOnTop

    buffer_key=
    Input, buffer_key, L1T20
    Gui, 13:Hide
    if buffer_key=v
    {
        StringMid, cb_index_letter, cb_key_rotate, %cb_index%, 1
        buffer_key=%cb_index_letter%
    }
    cb_flag=0
    if ErrorLevel = Timeout
        cb_flag=1
    IfNotInString, cb_key_legal, %buffer_key%
        cb_flag=1
    if(cb_flag = 1)
    {
        ClearTip(SHOWTIP_BIG)
        show_tip=Operation Canceled
        Gosub, big_tip
        SetTimer,clear_big_tip,-1000
    }
return


;------------------------------------------------------------------------------
GetIndex:
;------------------------------------------------------------------------------
    cb_index+=1
    if(cb_index > cb_rotate_max)
        cb_index=1
    FileDelete, %cb_dir%\%cb_prefix%_index
    FileAppend, %cb_index%, %cb_dir%\%cb_prefix%_index
    StringMid, cb_index_letter, cb_key_rotate, %cb_index%, 1
return


;------------------------------------------------------------------------------
oYank:
;------------------------------------------------------------------------------
    if(ClipBoard)
    {
        ClipBoard = %ClipBoard%
        cb_in=%ClipBoard%
        Gosub, GetIndex
        FileDelete, %cb_dir%\%cb_prefix%_%cb_index_letter% ; Because it is a copy/cut, not append
        FileAppend, %cb_in%,%cb_dir%\%cb_prefix%_%cb_index_letter%
        cb_buf_%cb_prefix%_%cb_index_letter%=%cb_in%
        cb_add := cb_buf_%cb_prefix%_%cb_index_letter%
        if(private_on)
        {
            StringLeft, cb_add, cb_add, 2
        }
        show_tip=Copied %cb_add%
        Gosub, big_tip
        SetTimer,clear_big_tip,-1000
    }
    else
    {
        show_tip=Nothing in clipboard!
        Gosub, big_tip
        SetTimer,clear_big_tip,-1000
    }
    switch_back()
return


;------------------------------------------------------------------------------
switch_back(switch_back_now=0) ; switch_back:
;------------------------------------------------------------------------------
{
    global
    if(switch_back_flag or switch_back_now)
    {
        Send, !{Esc} ; Activate previous window
        switch_back_flag=0
        WinGet, lastwin, ID, A
    }
    return
}


;------------------------------------------------------------------------------
NEO_BYank:
;------------------------------------------------------------------------------
    if(ClipBoard)
    {
        cb_in=%ClipBoard%
        cb_default_label=%ClipBoard%
        Gosub, NEO_GetKey
        IfInString, cb_key_legal, %buffer_key%
        {
            cb_default_label := cb_label_%cb_prefix%_%buffer_key%
            InputBox, key_label, Key Label, Enter key label,,,,,,,,%cb_default_label%
            If ErrorLevel
                return
            FileDelete, %cb_dir%\%cb_prefix%_%buffer_key% ; Because it is a copy/cut, not append
            FileAppend, %cb_in%, %cb_dir%\%cb_prefix%_%buffer_key%
            FileDelete, %cb_dir%\%cb_prefix%_L_%buffer_key%
            FileAppend, %key_label%, %cb_dir%\%cb_prefix%_L_%buffer_key%
            cb_buf_%cb_prefix%_%buffer_key%=%cb_in%
            cb_label_%cb_prefix%_%buffer_key%=%key_label%
            cb_add := cb_buf_%cb_prefix%_%buffer_key%
            if(private_on)
            {
                StringLeft, cb_add, cb_add, 2
            }
            show_tip=Copied %cb_add%
            Gosub, big_tip
            SetTimer,clear_big_tip,-1000
        }
    }
    else
    {
        show_tip=Nothing in clipboard!
        Gosub, big_tip
        SetTimer,clear_big_tip,-1000
    }
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Timestamp_section                                                        |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
NEO_Timestamp:
;------------------------------------------------------------------------------
    gui_hide()
    CoordMode, Mouse, Screen
    WinGet, lastwin, ID, A
    debug({ param1: concat(["lastwin=", lastwin]), linenumber: A_LineNumber })

    Gosub, esc_key

    debug({ param1: "timestamp_gui", linenumber: A_LineNumber })

    this_gui := 12 + private_on * private_gui_start
    Gosub, show_gui_timestamp_%this_gui%

    Input, buffer_key, L1T60

    Gui, %this_gui%:Hide

    if buffer_key = a
        Gosub, timestamp_a
    else if buffer_key = f
        Gosub, timestamp_f
    else if buffer_key = e
        Gosub, timestamp_e
    else if buffer_key = k
        Gosub, timestamp_k
    else if buffer_key = x
        Gosub, timestamp_x
return


12ButtonOK:
12GuiClose:
    Gui, 12:Submit  ; Save each control's contents to its associated variable.
12ButtonCancel:
12GuiEscape:
12ButtonJustQuit:
    gui_hide()
return


;------------------------------------------------------------------------------
timestamp_a:
;------------------------------------------------------------------------------
    FormatTime, TimeString,, dddd, MMMM d, yyyy
    SendInput, %TimeString%
return


;------------------------------------------------------------------------------
timestamp_f:
;------------------------------------------------------------------------------
    FormatTime, TimeString,, h:mm tt M/d/yyyy
    SendInput, %TimeString%
return


;------------------------------------------------------------------------------
timestamp_k:
;------------------------------------------------------------------------------
    FormatTime, TimeString,, yyyy-MM-dd
    SendInput, %TimeString%
return


;------------------------------------------------------------------------------
timestamp_e:
;------------------------------------------------------------------------------
    FormatTime, TimeString,, yyyy-MM-dd HH:mm
    SendInput, %TimeString%
return


;------------------------------------------------------------------------------
timestamp_x:
;------------------------------------------------------------------------------
    FormatTime, TimeString,, yyyy-MM-dd dddd
    SendInput, %TimeString%
return


;=============================================================================+
;                                                                             |
;    Volume_section                                                           |
;                                                                             |
;=============================================================================+

; Volume On-Screen-Display (OSD) -- by Rajat
;------------------------------------------------------------------------------
initialize_volume:
;------------------------------------------------------------------------------
    vol_Step = 4
    vol_DisplayTime = 2000
    vol_CBM = Red
    vol_CBW = Blue
    vol_CW = Silver
    vol_PosX = -1
    vol_PosY = -1
    vol_Width = 150
    vol_Thick = 12
    vol_BarOptionsMaster = 1:B ZH%vol_Thick% ZX0 ZY0 W%vol_Width% CB%vol_CBM% CW%vol_CW%
    vol_BarOptionsWave   = 2:B ZH%vol_Thick% ZX0 ZY0 W%vol_Width% CB%vol_CBW% CW%vol_CW%
    if vol_PosX >= 0
    {
        vol_BarOptionsMaster = %vol_BarOptionsMaster% X%vol_PosX%
        vol_BarOptionsWave   = %vol_BarOptionsWave% X%vol_PosX%
    }
    if vol_PosY >= 0
    {
        vol_BarOptionsMaster = %vol_BarOptionsMaster% Y%vol_PosY%
        vol_PosY_wave = %vol_PosY%
        vol_PosY_wave += %vol_Thick%
        vol_BarOptionsWave = %vol_BarOptionsWave% Y%vol_PosY_wave%
    }
return


;------------------------------------------------------------------------------
Volume:
;------------------------------------------------------------------------------
    gui_hide()
    Send {Volume_Up 1}
    Send {Volume_Down 1}
    volume_keys:
    Gosub, vol_display
    Hotkey, 0, vol_setting0
    Hotkey, 1, vol_setting1
    Hotkey, 2, vol_setting2
    Hotkey, 3, vol_setting3
    Hotkey, 4, vol_setting4
    Hotkey, 5, vol_setting5
    Hotkey, 6, vol_setting6
    Hotkey, 7, vol_setting7
    Hotkey, 8, vol_setting8
    Hotkey, 9, vol_setting9
    Hotkey, WheelDown, vol_WheelDown
    Hotkey, WheelUp, vol_WheelUp
    Hotkey, h, vol_MasterDown
    Hotkey, j, vol_WaveDown
    Hotkey, k, vol_WaveUp
    Hotkey, l, vol_MasterUp
    Hotkey, esc, esc_key
    Hotkey, Enter, esc_key
    Hotkey, 0, On
    Hotkey, 1, On
    Hotkey, 2, On
    Hotkey, 3, On
    Hotkey, 4, On
    Hotkey, 5, On
    Hotkey, 6, On
    Hotkey, 7, On
    Hotkey, 8, On
    Hotkey, 9, On
    Hotkey, WheelDown, On
    Hotkey, WheelUp, On
    Hotkey, h, On
    Hotkey, j, On
    Hotkey, k, On
    Hotkey, l, On
    Hotkey, esc, On
    Hotkey, Enter, On
    volume_esc=1
return


;------------------------------------------------------------------------------
vol_setting0:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=0
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting1:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 2
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=11
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
do_vol_setting:
;------------------------------------------------------------------------------
    SoundSet, %vol_setting%, Wave
    SoundSet, %vol_setting%
    if volume_esc
        Gosub, vol_display
    else
        Gosub, Volume
return


;------------------------------------------------------------------------------
vol_WheelDown:
;------------------------------------------------------------------------------
    Gosub, vol_WaveDown
    Gosub, vol_MasterDown
return


;------------------------------------------------------------------------------
vol_WheelUp:
;------------------------------------------------------------------------------
    Gosub, vol_WaveUp
    Gosub, vol_MasterUp
return


;------------------------------------------------------------------------------
vol_WaveUp:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Up %vol_Step%}
    }
    else
    {
        SoundSet, +%vol_Step%, Wave
    }
    Gosub, vol_display
return


;------------------------------------------------------------------------------
vol_WaveDown:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_Step%}
    }
    else
    {
        SoundSet, -%vol_Step%, Wave
    }
    Gosub, vol_display
return


;------------------------------------------------------------------------------
vol_MasterUp:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Up %vol_Step%}
    }
    else
    {
        SoundSet, +%vol_Step%
        menu,tray,icon,%prog_icon%
    }
    Gosub, vol_display
return


;------------------------------------------------------------------------------
vol_MasterDown:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_Step%}
    }
    else
    {
        SoundSet, -%vol_Step%
    }
    Gosub, vol_display
return


;--------------------
     vol_display:    ;
;--------------------
    SoundPlay, %A_ScriptDir%\sound\ding.wav
    if (on_windows_7)
    {
        Gosub, vol_notice
    }
    else
    {
        Gosub, vol_ShowBars
    }
return


;--------------------
     vol_notice:    ;
;--------------------
    nwidth := f_width() - 310
    nheight := f_height() - 102
    Progress, x550 y250 cwYellow m2 b fs18 zh0, Set Volume, , , Courier New
    WinMove, Clipboard, , 0, 0  ; Move the splash window to the top left corner.
    Gosub, vol_reset_timer
return


;----------------------
     vol_reset_timer: ;
;----------------------
    SetTimer, esc_key, Off
    SetTimer, esc_key, %vol_DisplayTime%
return


;------------------------------------------------------------------------------
Mute:
    gui_hide()
vol_MasterMute:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Mute}
    }
    else
    {
        SoundGet, vol_j, Master
        if(vol_j)
        {
            vol_Master_save=%vol_j%
            IniWrite, %vol_Master_save%, %ini_file%, state, sound
            SoundSet, 0
        }
        else
        {
            SoundSet, %vol_Master_save%
        }
        process_volume_icon(0)
    }
    Gosub, volume_keys
return


;------------------------------------------------------------------------------
process_volume_icon(volume=-1) ; process_volume_icon:
;------------------------------------------------------------------------------
{
    global
    debug({ param1: "process_volume_icon", linenumber: A_LineNumber })
    debug({ param1: concat(["    volume: ", volume]), linenumber: A_LineNumber })
    if(volume=-1)
    {
        SoundGet, volume, Master
    }
    debug({ param1: concat(["    volume: ", volume]), linenumber: A_LineNumber })
    debug({ param1: concat(["    SettingRotate: ", SettingRotate]), linenumber: A_LineNumber })
    if(volume or !SettingRotate)
    {
        debug({ param1: concat(["    setting prog icon:", prog_icon]), linenumber: A_LineNumber })
        menu,tray,icon,%prog_icon%
    }
    else
    {
        debug({ param1: concat(["    setting mute icon:", mute_icon]), linenumber: A_LineNumber })
        menu,tray,icon,%mute_icon%
    }
    return
}


;------------------------------------------------------------------------------
check_for_virtualbox() ; check_for_virtualbox:
;------------------------------------------------------------------------------
{
    oldTMM := A_TitleMatchMode

    SetTitleMatchMode, 2
    IfWinActive, VLC media player
        return 0

    SetTitleMatchMode, 3
    IfWinActive, Oracle VM VirtualBox Manager ; ignore the manager window itself
        return 0

    WinGetClass, class, A
    If class = QWidget
        return 1
    else
        return 0

    SetTitleMatchMode, %oldTMM%
}


;------------------------------------------------------------------------------
process_ohide(ohide_status=-1) ; process_ohide:
;------------------------------------------------------------------------------
{
    global
    debug({ param1: "process_ohide", linenumber: A_LineNumber })
    debug({ param1: concat(["    ohide_status: ", ohide_status]), linenumber: A_LineNumber })
    if(ohide_status=-1)
    {
        SettingOhide := f_IniRead({ filename:   ini_file
                                  , category:   "settings"
                                  , variable:   "run_ohide_routine"
                                  , linenumber: A_LineNumber })
        ohide_status := SettingOhide
    }
    debug({ param1: concat(["    ohide_status: ", ohide_status]), linenumber: A_LineNumber })
    debug({ param1: concat(["    SettingOhide: ", SettingOhide]), linenumber: A_LineNumber })
    if(ohide_status)
    {
        debug({ param1: "    enabling ohide", linenumber: A_LineNumber })
        SetTimer,ohide,%ohide_msecs%
    }
    else
    {
        debug({ param1: "    disabling ohide", linenumber: A_LineNumber })
        SetTimer,ohide,Off
        Gosub, re_show
    }
    return
}


;------------------------------------------------------------------------------
process_ocred(ocred_status=-1) ; process_ocred:
;------------------------------------------------------------------------------
{
    global
    debug({ param1: "process_ocred", linenumber: A_LineNumber })
    debug({ param1: concat(["    ocred_status: ", ocred_status]), linenumber: A_LineNumber })
    if(ocred_status=-1)
    {
        SettingOcred := f_IniRead({ filename:   ini_file
                                  , category:   "settings"
                                  , variable:   "run_ocred_routine"
                                  , linenumber: A_LineNumber })
        ocred_status := SettingOcred
    }
    debug({ param1: concat(["    ocred_status: ", ocred_status]), linenumber: A_LineNumber })
    debug({ param1: concat(["    SettingOcred: ", SettingOcred]), linenumber: A_LineNumber })
    if(ocred_status)
    {
        debug({ param1: "    enabling ocred", linenumber: A_LineNumber })
        SetTimer,ocred,%ocred_msecs%
    }
    else
    {
        debug({ param1: "    disabling ocred", linenumber: A_LineNumber })
        SetTimer,ocred,Off
    }
    return
}


;------------------------------------------------------------------------------
process_eye_rest(eye_rest_status=-1) ; process_eye_rest:
;------------------------------------------------------------------------------
{
    global
    debug({ param1: "process_eye_rest", linenumber: A_LineNumber })
    debug({ param1: concat(["    eye_rest_status: ", eye_rest_status]), linenumber: A_LineNumber })
    if(eye_rest_status=-1)
    {
        SettingEyeRest := f_IniRead({ filename:   ini_file
                                    , category:   "settings"
                                    , variable:   "run_eye_rest_routine"
                                    , linenumber: A_LineNumber })
        eye_rest_status := SettingEyeRest
    }
    debug({ param1: concat(["    eye_rest_status: ", eye_rest_status]), linenumber: A_LineNumber })
    debug({ param1: concat(["    SettingEyeRest: ", SettingEyeRest]), linenumber: A_LineNumber })
    if(eye_rest_status)
    {
        debug({ param1: "    enabling eye_rest", linenumber: A_LineNumber })
        SetTimer,eye_rest,%eye_rest_msecs%
    }
    else
    {
        debug({ param1: "    disabling eye_rest", linenumber: A_LineNumber })
        SetTimer,eye_rest,Off
    }
    return
}


;------------------------------------------------------------------------------
process_poker(poker_status=-1) ; process_poker:
;------------------------------------------------------------------------------
{
    global
    debug({ param1: "process_poker", linenumber: A_LineNumber })
    debug({ param1: concat(["    poker_status: ", poker_status]), linenumber: A_LineNumber })
    if(poker_status=-1)
    {
        SettingPoker := f_IniRead({ filename:   ini_file
                                  , category:   "settings"
                                  , variable:   "run_poker_routine"
                                  , linenumber: A_LineNumber })
        poker_status := SettingPoker
    }
    debug({ param1: concat(["    poker_status: ", poker_status]), linenumber: A_LineNumber })
    debug({ param1: concat(["    SettingPoker: ", SettingPoker]), linenumber: A_LineNumber })
    if(poker_status)
    {
        debug({ param1: "    enabling poker", linenumber: A_LineNumber })
        SetTimer,poker,%poker_msecs%
    }
    else
    {
        debug({ param1: "    disabling poker", linenumber: A_LineNumber })
        SetTimer,poker,Off
    }
    return
}


;------------------------------------------------------------------------------
vol_ShowBars:
;------------------------------------------------------------------------------
    IfWinNotExist, vol_Wave
        Progress, %vol_BarOptionsWave%, , , vol_Wave
    IfWinNotExist, vol_Master
    {
        if vol_PosY < 0
        {
            WinGetPos, , vol_Wave_Posy, , , vol_Wave
            vol_Wave_Posy -= %vol_Thick%
            Progress, %vol_BarOptionsMaster% Y%vol_Wave_Posy%, , , vol_Master
        }
        else
            Progress, %vol_BarOptionsMaster%, , , vol_Master
    }
    SoundGet, vol_Master, Master
    SoundGet, vol_Wave, Wave
    Progress, 1:%vol_Master%
    Progress, 2:%vol_Wave%
    process_volume_icon(vol_Master)
    SetTimer, esc_key, Off
    SetTimer, esc_key, %vol_DisplayTime%
return


;------------------------------------------------------------------------------
vol_BarOff:
;------------------------------------------------------------------------------
    Progress, 1:Off
    Progress, 2:Off
return


;------------------------------------------------------------------------------
vol_setting2:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 3
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=22
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting3:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 4
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=33
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting4:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 5
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=44
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting5:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 7
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=55
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting6:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 8
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=66
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting7:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 9
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=77
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting8:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 10
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=88
        Gosub, do_vol_setting
    }
return


;------------------------------------------------------------------------------
vol_setting9:
;------------------------------------------------------------------------------
    if (on_windows_7)
    {
        Send {Volume_Down %vol_max_keys%}
        Gosub, vol_reset_timer
        this_vol_Step := vol_Step * 13
        Send {Volume_Up %this_vol_Step%}
        Gosub, vol_display
    }
    else
    {
        vol_setting=100
        Gosub, do_vol_setting
    }
return


;-----------------------------------------------------------------------------
f_OpenFavorite:
;------------------------------------------------------------------------------
    f_path := directories_L[A_ThisMenuItem,"dir"]
    if f_path =
        return
    if f_class in #32770 ; In Explorer, switch folders.
    {
        if f_Edit1Pos <>   ; And it has an Edit1 control.
        {
            WinActivate ahk_id %f_window_id%
            ControlGetText, f_text, Edit1, ahk_id %f_window_id%
            ControlSetText, Edit1, %f_path%, ahk_id %f_window_id%
            ControlSend, Edit1, {Enter}, ahk_id %f_window_id%
            Sleep, 100  ; It needs extra time on some dialogs or in some cases.
            ControlSetText, Edit1, %f_text%, ahk_id %f_window_id%
            return
        }
    }
    else if f_class in ExploreWClass,CabinetWClass  ; In Explorer, switch folders.
    {
        if f_Edit1Pos <>   ; And it has an Edit1 control.
        {
            ControlSetText, Edit1, %f_path%, ahk_id %f_window_id%
            ControlSend, Edit1, {Right}{Enter}, ahk_id %f_window_id%
            return
        }
    }
    else if f_class in gdkWindowToplevel
    {
        WinActivate, ahk_id %f_window_id%
        SendInput, !s%f_path%{enter}{enter}!f{down}{up}{down}{up}
        return
    }
    else if f_class in bosa_sdm_Mso96
    {
        WinActivate, ahk_id %f_window_id%
        SendInput, !n%f_path%{enter}{enter}
        return
    }
    else if f_class = PuTTY
    {
        WinActivate, ahk_id %f_window_id%
        SetKeyDelay, 0  ; This will be in effect only for the duration of this thread.
        IfInString, f_path, :  ; It contains a drive letter
        {
            StringLeft, f_path_drive, f_path, 1
            Send %f_path_drive%:{enter}
        }
        SendInput, cd %f_path%{Enter}
        return
    }
    else if f_class in ConsoleWindowClass,mintty
    {
        WinActivate, ahk_id %f_window_id%
        WinGetActiveTitle, window_title
        SendInput, {bs 8}cd{space}"
        SendInput, %f_path%"{Enter}
        return
    }
    Run, Explorer %f_path%
return


;------------------------------------------------------------------------------
f_DisplayMenu:
;------------------------------------------------------------------------------
    WinGet, f_window_id, ID, A
    WinGetClass, f_class, ahk_id %f_window_id%
    if f_class in #32770,ExploreWClass,CabinetWClass ; Dialog or Explorer.
        ControlGetPos, f_Edit1Pos,,,, Edit1, ahk_id %f_window_id%
    if f_AlwaysShowMenu = n  ; The menu should be shown only selectively.
    {
        if f_class in #32770,ExploreWClass,CabinetWClass ; Dialog or Explorer.
        {
            if f_Edit1Pos =  ; The control doesn't exist, so don't display the menu
                return
        }
        else if f_class not in ConsoleWindowClass,mintty,PuTTY,bosa_sdm_Mso96,gdkWindowToplevel
            return ; Since it's some other window type, don't display menu.
    }
    Menu, Favorites, show, f_swidth(), f_sheight()
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Outlook_section                                                          |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
outlook_keys:
;------------------------------------------------------------------------------
    mode=OUTLOOK
    Gosub, mode_tip
    Hotkey, r, o_r_key
    Hotkey, e, o_e_key
    Hotkey, w, o_w_key
    Hotkey, q, o_q_key
    Hotkey, a, o_a_key
    Hotkey, s, o_s_key
    Hotkey, d, o_d_key
    Hotkey, ^b, o_cb_key
    Hotkey, ^f, o_cf_key
    Hotkey, f, o_f_key
    Hotkey, g, o_g_key
    Hotkey, j, o_j_key
    Hotkey, +j, o_sj_key
    Hotkey, k, o_k_key
    Hotkey, +k, o_sk_key
    Hotkey, l, o_l_key
    Hotkey, z, o_z_key
    Hotkey, x, o_x_key
    Hotkey, t, o_t_key
    Hotkey, c, o_c_key
    Hotkey, b, o_b_key
    Hotkey, v, o_v_key
    Hotkey, `;, esc_key
    Hotkey, esc, esc_key
    Hotkey, r, On
    Hotkey, e, On
    Hotkey, w, On
    Hotkey, q, On
    Hotkey, a, On
    Hotkey, s, On
    Hotkey, d, On
    Hotkey, ^b, On
    Hotkey, ^f, On
    Hotkey, f, On
    Hotkey, g, On
    Hotkey, j, On
    Hotkey, +j, On
    Hotkey, k, On
    Hotkey, +k, On
    Hotkey, l, On
    Hotkey, z, On
    Hotkey, x, On
    Hotkey, t, On
    Hotkey, c, On
    Hotkey, b, On
    Hotkey, v, On
    Hotkey, `;, On
    Hotkey, esc, On
    outlook_esc =1
return


;------------------------------------------------------------------------------
o_cb_key:
;------------------------------------------------------------------------------
    o_param={pgup}~^b
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_cf_key:
;------------------------------------------------------------------------------
    o_param={pgdn}~^f
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_r_key:
;------------------------------------------------------------------------------
    o_param=!r~r
    Gosub, o_send
Goto esc_key


;------------------------------------------------------------------------------
o_e_key:
;------------------------------------------------------------------------------
    o_param=!l~e
    Gosub, o_send
Goto esc_key


;------------------------------------------------------------------------------
o_w_key:
;------------------------------------------------------------------------------
    o_param=!w~w
    Gosub, o_send
Goto esc_key


;------------------------------------------------------------------------------
o_q_key:
;------------------------------------------------------------------------------
    o_param=^n~q
    Gosub, o_send
Goto esc_key


;------------------------------------------------------------------------------
o_a_key:
;------------------------------------------------------------------------------
    o_param=^q~a
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_s_key:
;------------------------------------------------------------------------------
    o_param=!en~s
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_d_key:
;------------------------------------------------------------------------------
    SendInput,^+2
;    Gosub, o_a_key
;    Suspend, On
;    SendInput,+^v
;    Sleep, 750
;    SendInput,y
;    Sleep, 750
;    SendInput,{enter}
;    Suspend, Off
return


;------------------------------------------------------------------------------
o_f_key:
;------------------------------------------------------------------------------
    SendInput,^+4
;    Gosub, o_a_key
;    Suspend, On
;    SendInput,+^v
;    Sleep, 750
;    SendInput,z
;    Sleep, 750
;    SendInput,{enter}
;    Suspend, Off
return


;------------------------------------------------------------------------------
o_g_key:
;------------------------------------------------------------------------------
    Hotkey, i, Off
    o_param=+^g!c{down}{up}~g
    Gosub, o_send
    Sleep, 500
    o_param=+^vi{enter}
    Gosub, o_send
    Hotkey, i, On
return


;------------------------------------------------------------------------------
o_j_key:
;------------------------------------------------------------------------------
    o_param=^.{down}~j
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_sj_key:
;------------------------------------------------------------------------------
    o_param=^.+{down}~+j
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_k_key:
;------------------------------------------------------------------------------
    o_param=^,{up}~k
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_sk_key:
;------------------------------------------------------------------------------
    o_param=^,+{up}~+k
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_l_key:
;------------------------------------------------------------------------------
    o_param=^{home}~l
    Gosub, o_send
return


;------------------------------------------------------------------------------
o_z_key:
;------------------------------------------------------------------------------
    IfWinActive, ahk_class rctrl_renwnd32
    {
        Gosub, go_Inbox
        outlook_y := outlook_y_init
    }
    else
    {
        Gosub, esc_key
        SendInput, z
    }
return


go_Inbox:
    SendInput, ^+i
return


;------------------------------------------------------------------------------
o_t_key:
;------------------------------------------------------------------------------
    IfWinActive, ahk_class rctrl_renwnd32
    {
        Suspend, On
        SendInput, ^y
        Sleep, 100
        SendInput, !f\\Personal Folders\B Task List{enter}
        Suspend, Off
    }
    else
    {
        Gosub, esc_key
        SendInput, b
    }
return


;------------------------------------------------------------------------------
o_x_key:
;------------------------------------------------------------------------------
    IfWinActive, ahk_class rctrl_renwnd32
    {
        Gosub, go_Inbox
        outlook_y := outlook_y - outlook_step
        outlook_current_folder := outlook_current_folder - 1
        if(outlook_current_folder < 1)
        {
            outlook_current_folder := outlook_folders
            outlook_y := outlook_y_init - outlook_step + outlook_step * outlook_folders
        }
        CoordMode, Mouse, Screen
        Click,%outlook_x%,%outlook_y%
    }
    else
    {
        Gosub, esc_key
        SendInput, x
    }
return


;------------------------------------------------------------------------------
o_c_key:
;------------------------------------------------------------------------------
    IfWinActive, ahk_class rctrl_renwnd32
    {
        Gosub, go_Inbox
        outlook_y := outlook_y + outlook_step
        outlook_current_folder := outlook_current_folder + 1
        if(outlook_current_folder > outlook_folders)
        {
            outlook_current_folder=1
            outlook_y := outlook_y_init
        }
        CoordMode, Mouse, Screen
        Click,%outlook_x%,%outlook_y%
    }
    else
    {
        Gosub, esc_key
        SendInput, c
    }
return


;------------------------------------------------------------------------------
o_b_key:
;------------------------------------------------------------------------------
    IfWinActive, ahk_class rctrl_renwnd32
    {
        Hotkey, c, Off
        Hotkey, o, Off
        SendInput, ^y{home}com{enter}
        Hotkey, c, On
        Hotkey, o, On
    }
    else
    {
        Gosub, esc_key
        SendInput, b
    }
return


;------------------------------------------------------------------------------
o_v_key:
;------------------------------------------------------------------------------
    IfWinActive, ahk_class rctrl_renwnd32
    {
        Hotkey, d, Off
        SendInput, ^y{home}d{enter}
        empty_flag := Question("Empty?",1024)
        if empty_flag = 1
        {
            SendInput, !tyy
            Sleep, 500
            Gosub, o_x_key
        }
        Hotkey, d, On
    }
    else
    {
        Gosub, esc_key
        SendInput, v
    }
return


;------------------------------------------------------------------------------
o_send:
;------------------------------------------------------------------------------
    StringSplit, in_outlook, o_param, ~
    outlook_send=%in_outlook1%
    non_outlook_send=%in_outlook2%
    IfWinActive, ahk_class rctrl_renwnd32
    {
        SendInput, %outlook_send%
    }
    else
    {
        Gosub, esc_key
        SendInput, %non_outlook_send%
    }
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Mouse_mode_section                                                       |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
mouse_shimmy:
;------------------------------------------------------------------------------
    if (A_TimeIdlePhysical > 250)
    {
        If shimmy_step = 0
        {
            MouseMove, %shimmy_amt%, %shimmy_amt%, %shimmy_speed%, R
            shimmy_step++
        }
        else if shimmy_step = 1
        {
            MouseMove, 0, -%shimmy_amt%, %shimmy_speed%, R
            shimmy_step++
        }
        else if shimmy_step = 2
        {
            MouseMove, -%shimmy_amt%, %shimmy_amt%, %shimmy_speed%, R
            shimmy_step++
        }
        else
        {
            MouseMove, 0, -%shimmy_amt%, %shimmy_speed%, R
            shimmy_step = 0
        }
    }
return


;------------------------------------------------------------------------------
MouseKeys:
;------------------------------------------------------------------------------
    gui_hide()
    SetTimer,mouse_shimmy,%shimmy_timer%
    mouse_speed=0
    mouse_step := mouse_step%mouse_speed%
    Gosub, mouse_menu
    Hotkey, 1, mouse_1
    Hotkey, 3, mouse_3
    Hotkey, 7, mouse_7
    Hotkey, 9, mouse_9
    Hotkey, u, mouse_click
    Hotkey, i, mouse_click_r
    Hotkey, j, mouse_d
    Hotkey, k, mouse_u
    Hotkey, l, mouse_r
    Hotkey, h, mouse_l
    Hotkey, m, mouse_clickB
    Hotkey, 0, mouse_BOL
    Hotkey, +h, mouse_high
    Hotkey, +l, mouse_low
    Hotkey, +m, mouse_mid
    Hotkey, `., CenterMouse
    Hotkey, `,, mouse_click_rB
    Hotkey, `;, mouse_toggle
    Hotkey, +4, mouse_EOL
    Hotkey, esc, esc_key
    Hotkey, u, On
    Hotkey, i, On
    Hotkey, 1, On
    Hotkey, 3, On
    Hotkey, 7, On
    Hotkey, 9, On
    Hotkey, j, On
    Hotkey, k, On
    Hotkey, l, On
    Hotkey, h, On
    Hotkey, m, On
    Hotkey, 0, On
    Hotkey, +h, On
    Hotkey, +l, On
    Hotkey, +m, On
    Hotkey, `., On
    Hotkey, `,, On
    Hotkey, `;, On
    Hotkey, +4, On
    Hotkey, esc, On
    mouse_esc =1
return


;------------------------------------------------------------------------------
mouse_center:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    MouseMove,%scr_mid_x%,%scr_mid_y%
return


;------------------------------------------------------------------------------
mouse_high:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    MouseMove,%posx%,0
return


;------------------------------------------------------------------------------
mouse_low:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    MouseMove,%posx%,%A_ScreenHeight%
return


;------------------------------------------------------------------------------
mouse_mid:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    MouseMove % %posx%, f_cheight()
return


;------------------------------------------------------------------------------
mouse_BOL:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    MouseMove,0,%posy%
return


;------------------------------------------------------------------------------
mouse_EOL:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    MouseMove,%A_ScreenWidth%,%posy%
return


;------------------------------------------------------------------------------
mouse_u:
;------------------------------------------------------------------------------
    MyMouseMove(0,-mouse_step)
return


;------------------------------------------------------------------------------
mouse_l:
;------------------------------------------------------------------------------
    MyMouseMove(-mouse_step,0)
return


;------------------------------------------------------------------------------
mouse_click:
;------------------------------------------------------------------------------
    MouseClick
return


;------------------------------------------------------------------------------
mouse_click_r:
;------------------------------------------------------------------------------
    MouseClick,R
return


;------------------------------------------------------------------------------
mouse_clickB:
;------------------------------------------------------------------------------
    If left_status = D
        left_status = U
    else
        left_status = D
    MouseClick,,,,,,%left_status%
return


;------------------------------------------------------------------------------
mouse_click_rB:
;------------------------------------------------------------------------------
    If right_status = D
        right_status = U
    else
        right_status = D
    MouseClick,R,,,,,%right_status%
return


;------------------------------------------------------------------------------
mouse_r:
;------------------------------------------------------------------------------
    MyMouseMove(mouse_step,0)
return


;------------------------------------------------------------------------------
mouse_dl:
;------------------------------------------------------------------------------
    MyMouseMove(-mouse_step,mouse_step)
return


;------------------------------------------------------------------------------
mouse_1:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    Gosub, CenterMouse
    MouseMove, %mouse_margin%, %mouse_margin%, %mouse_move_speed%
return


;------------------------------------------------------------------------------
mouse_3:
;------------------------------------------------------------------------------
    x_temp := A_ScreenWidth - mouse_margin
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    Gosub, CenterMouse
    MouseMove, %x_temp%, %mouse_margin%, %mouse_move_speed%
return


;------------------------------------------------------------------------------
mouse_7:
;------------------------------------------------------------------------------
    y_temp := A_ScreenHeight - mouse_margin
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    Gosub, CenterMouse
    MouseMove, %mouse_margin%, %y_temp%, %mouse_move_speed%
return


;------------------------------------------------------------------------------
mouse_9:
;------------------------------------------------------------------------------
    x_temp := A_ScreenWidth - mouse_margin
    y_temp := A_ScreenHeight - mouse_margin
    CoordMode, Mouse, Screen
    MouseGetPos, posx, posy
    Gosub, CenterMouse
    MouseMove, %x_temp%, %y_temp%, %mouse_move_speed%
return


;------------------------------------------------------------------------------
mouse_d:
;------------------------------------------------------------------------------
    MyMouseMove(0,mouse_step)
return


;------------------------------------------------------------------------------
mouse_toggle:
;------------------------------------------------------------------------------
    mouse_speed++
    If mouse_speed = 3
        mouse_speed = 0
    mouse_step := mouse_step%mouse_speed%
    Gosub, mouse_menu
return


;------------------------------------------------------------------------------
MyMouseMove(xx,yy=0) ; MyMouseMove:
;------------------------------------------------------------------------------
{
    CoordMode, Mouse, Screen
    MouseMove,%xx%,%yy%,%mouse_move_speed%,R
    return 0
}


;------------------------------------------------------------------------------
mouse_menu:
;------------------------------------------------------------------------------
    text_speed=(fast)
    If mouse_speed = 1
        text_speed=(slow)
/*
j_menu=
(
***************************


  Mouse Mode %mouse_step%

  hjkl = movement
  `; = change amount to move
  u = left click
  i = right click
  m = left drag
  , = right drag
  . = center screen
  HML = high medium low
  0 = leftmost
  $ = rightmost

***************************
)
*/
j_menu=Mouse Mode %mouse_step%
    ShowTip(j_menu, 0, 0)
return


;------------------------------------------------------------------------------
AeroView:
;------------------------------------------------------------------------------
    gui_hide()
    SendInput, ^#{TAB}
return


;------------------------------------------------------------------------------
Note:
;------------------------------------------------------------------------------
    if(check_for_virtualbox())
        return

    gui_hide()

    WinGet, lastwin, ID, A
    debug({ param1: concat(["lastwin=", lastwin]), linenumber: A_LineNumber })

    Gui, 11:Show
    GuiControl, 11:, SettingSave, 0
    GuiControl, 11:Focus, NoteText
return


;------------------------------------------------------------------------------
SaveCheck:
;------------------------------------------------------------------------------
    GuiControl, 11:Focus, NoteText
return


;    FileAppend, `n%timestamp%: %last_note%`n,%sys_drive%\docs\notes.txt
;------------------------------------------------------------------------------
note_cont:
;------------------------------------------------------------------------------
    last_note=%NoteText%

    now := A_Now
    FormatTime, timestamp, %now%, yyyy_MM_dd_HH_mm_ss

    StringGetPos, pos, last_note, %A_Space%

    if pos >= 0
    {
        StringLeft, out_file, last_note, pos
        StringMid, out_text, last_note, pos + 2

        If (out_file <> "wt" and out_file <> "wl")
        {
            out_file := "wl"
            out_text := last_note
        }
    }
    else
    {
        out_file := "wl"
        out_text := last_note
    }

    if(out_file = "wt")
    {
        out_file = M:\todo_priority_1\%out_text%.txt
        FileAppend, `nCreated:%timestamp%`n,%out_file%
    }
    else if(out_file = "wl")
    {
        RegExMatch(out_text, "\s+\+(\d+)\s*$", m)

        if(m1)
        {
            out_text := RegExReplace(out_text, "\s+\+\d+\s*$", "")
            NoteText := RegExReplace(NoteText, "\s+\+\d+\s*$", "")
            now += -%m1%, minutes
            FormatTime, timestamp, %now%, yyyy_MM_dd_HH_mm_ss
        }

        out_file = %A_ScriptDir%\file\%out_file%_%timestamp%.txt
        FileAppend, `n%out_text%`n,%out_file%
    }
    else
    {
        out_file = %A_ScriptDir%\notes\%out_file%_%timestamp%.txt
        FileAppend, `n%out_text%`n,%out_file%
    }
    notes_list=%notes_list%|%NoteText%
    Sort, notes_list, CL U D|
    GuiControl, 11:, NoteText, |%notes_list%
    GuiControl, 11:Text, NoteText, %NoteText%
    IniWrite, %NoteText%, %my_ini_file%, settings, selected_item
    if(SettingSave)
    {
        save_notes_list=%save_notes_list%|%NoteText%
        Sort, save_notes_list, CL U D|
        IniWrite, %save_notes_list%,  %ini_file%, settings, notes_list
    }
return


;------------------------------------------------------------------------------
NoteSubmit:
;------------------------------------------------------------------------------
    switch_back(1)
    Gui, 11:Submit,NoHide  ; Save each control's contents to its associated variable.
    reminder_count=0
    GuiControl, 11:, NoteCount, OK
    GuiControl, 11:Hide, Exclaim
    GuiControl, 11:, SettingSave, 0
    Gosub, note_cont
return


find_link(filename)
{
    global

    val := fileArray[filename]
    IfExist, %val%
    {
        return %val%
    }

    val := f_IniRead({ filename:       ini_file
                     , not_found_ok:   1
                     , category:       "linkcache"
                     , variable:       filename
                     , linenumber:     A_LineNumber })

    IfExist, %val%
    {
        fileArray[filename] := val
        return %val%
    }

    SplashTextOn, 300, 50, %filename%, Searching for link...
    DriveList=
    DriveGet, mylist, List
    Loop, Parse, mylist
    {
        DriveGet, mystatus, Status, %A_LoopField%:
        if mystatus = Ready
        {
            DriveList = %DriveList%%A_LoopField%
        }
    }

    Extensions = lnk,exe
    Loop, parse, Extensions, `,
    {
        Ext = %A_LoopField%.
        Loop, Parse, PathList, |
        {
            path = %A_LoopField%
            Loop, Parse, DriveList
            {
                StringMid, searchpath, path, 2
                searchpath = %A_LoopField%%searchpath%
                IfNotExist, %searchpath%
                    Continue
                Loop, %searchpath%\%filename%.%Ext%, 0, 1
                {
                    fileArray[filename] := A_LoopFileFullPath
                    IniWrite, %A_LoopFileFullPath%, %ini_file%, linkcache, %filename%
                    SplashTextOff
                    return %A_LoopFileFullPath%
                }
            }
        }
    }
    SplashTextOff
    MsgBox, Failed to find %filename%.
}


oneify_gvim_windows:
    WinGet, lastwin, ID, A
    update_flag=0
    WinGet, id, list, ahk_exe gvim.exe
    Loop, %id%
    {
        this_id := id%A_Index%
        save_id := "X" . this_id ; avoid conversion to decimal
        if ( !vimList[save_id] )
        {
            WinGetTitle, Title, ahk_id %this_id%
            if(Title) {
                vimList[save_id] := 1
                WinActivate ahk_id %this_id%
                Send, ^!1
                update_flag++
            }
        }
    }
    If update_flag
        WinActivate ahk_id %lastwin%
return


save_windows()
{
    global
    winList := {A:"B"}

    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        this_id := id%A_Index%
        save_id := "X" . this_id ; avoid conversion to decimal
        winList[save_id] := 1
    }
}


find_new_window()
{
    global

    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        this_id := id%A_Index%
        save_id := "X" . this_id ; avoid conversion to decimal
        id_lookup := winList[save_id]
        if(!id_lookup)
            return this_id
    }
}

oneify_new_window:
    id := find_new_window()
    if(id)
    {
        WinActivate ahk_id %id%
        SendInput, ^!1
        SetTimer, oneify_new_window, Off
    }
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

Hotkey, %f_Hotkey%, f_DisplayMenu
StringLeft, f_HotkeyFirstChar, f_Hotkey, 1
if f_HotkeyFirstChar = ~  ; Show menu only for certain window types.
    f_AlwaysShowMenu = n
else
    f_AlwaysShowMenu = y

Gosub, build_directory_array

For key, value in directories
{
    label := directories[key,"label"]
    Menu, Favorites, Add, %label%, f_OpenFavorite
}
return

