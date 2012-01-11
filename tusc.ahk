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
____Approximate_middle_of_table_of_contents
Initialization_section
Mouse_mode_section
Outlook_section
Timestamp_section
Volume_section

Credits:
--------
David M. Bradford, tinypig.com

Additional code:
Volume - Rajat
Favorites - savage, ChrisM, Rajat
Credits usernames are from the AutoHotKey forums - http://www.autohotkey.com/forum/


TODO
----

 * NOTHING runs only at startup because when values are gathered, they can ALWAYS change
 * add snooze option to "annoy"
 * re-check section headings/comments now that script is split up
 * clean up code
     * refactor duplicate lines
 * add front end menu options where it is feasible, like enabling "annoy"
 * Either eliminate external file dependencies or document them
 * Document needed external software
     * Launchy

TODO, Older
-----------

 * fix freecommander without using "ask"

DONE
----
 * get rid of sleeps where appropriate - use timers instead

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

SplitPath, A_ScriptName,,, f_FileExt, f_FileNoExt

ini_file = %A_ScriptDir%\%f_FileNoExt%.ini
IfNotExist, %ini_file%
    Gosub, build_ini

if f_FileExt = Exe
{
    f_FavoritesFile = %A_ScriptDir%\Favorites.ini
    f_MainMenuFile = %A_ScriptDir%\Main_menu.ini
}
else
{
    f_FavoritesFile = %A_ScriptFullPath%
    f_MainMenuFile = %A_ScriptFullPath%
}


debug_on=0
debug_text=

clicktooltip=0
disabled_flag=0
game_mode=0
timeout=20
z_flag=0

mouse_step0=100
mouse_step1=33
mouse_step2=6
mouse_esc=0
mouse_margin=0
mouse_move_speed=6

outlook_esc=0
volume_esc =0

shimmy_step=0
shimmy_timer=250
shimmy_amt=1
shimmy_speed=100
shimmy_save_x=0
shimmy_save_y=0

left_status=U
right_status=U

corner_counter=0

locker_count=0
locker_display=0
locker_touched=0

vol_setting=0

EnvGet, home_path, HomePath
EnvGet, sys_drive, SystemDrive

prog_icon = %A_ScriptDir%\%f_FileNoExt%.ico
mute_icon = %A_ScriptDir%\%f_FileNoExt%_mute.ico

cb_dir = %A_ScriptDir%\cb
shortcuts_dir = %A_ScriptDir%\shortcuts

Gosub, read_settings

Hotkey, CapsLock, Capslock, on

FileRead, cb_index, %cb_dir%\CB_index
if ErrorLevel = 1
  cb_index=0

cb_prefix = CB
Gosub, cb_init
cb_prefix = ECB
Gosub, cb_init

Gosub, menufocus_init
Gosub, starttusc_init

CoordMode, Menu
CoordMode, ToolTip, Screen
SetFormat, float, 0.0

IniRead, vol_Master_save, %ini_file%, state, sound, 1

SoundGet, vol_j, Master
process_volume_icon(vol_j)

StringLen, cb_max, cb_key_legal
StringLen, cb_rotate_max, cb_key_rotate
StringLen, cb_static_max, cb_key_static

debug_y_offset = 0

Debug("started")

ocred_msecs=500
SetTimer,ocred,%ocred_msecs%

annoy_msecs=500
;SetTimer,annoy,%annoy_msecs%

locker_msecs=500
SetTimer,locker,%locker_msecs%

corner_menu_msecs=500
;SetTimer,corner_menu,%corner_menu_msecs%

Gosub, initialize_main_menu

Gosub, initialize_volume

SetBatchLines, 10ms

Gosub, initialize_favorites

return


;------------------------------------------------------------------------------
build_ini:
;------------------------------------------------------------------------------
    IniWrite, 1,           %ini_file%, settings, rotate_tray_icon_when_mute
    IniWrite, 0,           %ini_file%, settings, run_startup_routine
    IniWrite, 0,           %ini_file%, settings, run_annoy_routine

    IniWrite, 1,           %ini_file%, state,  sound

    IniWrite, one,         %ini_file%, string, mystring1
    IniWrite, two,         %ini_file%, string, mystring2
    IniWrite, three,       %ini_file%, string, mystring3
    IniWrite, four,        %ini_file%, string, mystring4
    IniWrite, five,        %ini_file%, string, mystring5
    IniWrite, six,         %ini_file%, string, mystring6
    IniWrite, seven,       %ini_file%, string, mystring7
    IniWrite, eight,       %ini_file%, string, mystring8
    IniWrite, nine,        %ini_file%, string, mystring9
    IniWrite, ten,         %ini_file%, string, mystring0
return



;--------------------
     locker:        ;
;--------------------
CoordMode, Mouse, Screen
MouseGetPos, posx, posy
;ID := WinExist("A")
;Debug("Active window ID: " . ID)
;Debug("posx: " . posx)
;Debug("posy: " . posy)
if(posx = f_width() and posy = f_height())
{
    if(!double_lock_prevention)
    {
        GetKeyState, state, LButton
        if(state = "D")
            return
        GetKeyState, state, RButton
        if(state = "D")
            return
        locker_touched++
        if(!locker_display)
        {
            locker_display++
            Progress, m2 b fs18 zh0, Hotspot Activated`nComputer will lock soon., , , Courier New
            WinMove, Clipboard, , 0, 0  ; Move the splash window to the top left corner.
        }
        locker_count++
        if(locker_count > 5)
        {
            locker_count=0
            locker_display=0
            locker_touched=0
            Progress, Off
            double_lock_prevention++
            Gosub, &Lock
        }
    }
}
else
{
    double_lock_prevention=0
    if(locker_touched)
    {
        locker_touched=0
        locker_count=0
        locker_display=0
        Progress, Off
    }
}
return


;--------------------
     corner_menu:   ;
;--------------------
CoordMode, Mouse, Screen
MouseGetPos, posx, posy
if(posx = 0 and posy = 0)
{
    corner_counter++
    if(corner_counter > 1)
    {
        corner_counter=0
        Gosub, GoCappy
    }
}
else
{
    corner_counter=0
}
return


;---------------------
     options_gui:    ;
;---------------------
    Gosub, read_settings
    Gui, Add, Button, default x236 y307 w100 h30 , OK
    Gui, Add, Button, x346 y307 w100 h30 , Cancel
    Gui, Add, Tab, x6 y7 w440 h290 , Settings|Other
    Gui, Add, Checkbox, x26 y47 w370 h30 vSettingRotate Checked%SettingRotate%, &Rotate tray icon when mute
    Gui, Add, Checkbox, x26 y87 w370 h30 vSettingStartup Checked%SettingStartup%, Run &Startup routine
    Gui, Add, Checkbox, x26 y127 w370 h30 vSettingAnnoy Checked%SettingAnnoy%, Run "&Annoy" routine
    Gui, Tab, Other
    Gui, Add, Radio, x26 y47 w390 h20 , Radio
    Gui, Add, Radio, x26 y77 w390 h20 , Radio
    Gui, Add, Radio, x26 y107 w390 h20 , Radio
    ; Generated using SmartGUI Creator 4.0
    Gui, Show, x131 y91 h341 w450, TuSC Options
return

ButtonOK:
GuiClose:
    Gui, Submit  ; Save each control's contents to its associated variable.
    IniWrite, %SettingRotate%,  %ini_file%, settings, rotate_tray_icon_when_mute
    IniWrite, %SettingStartup%, %ini_file%, settings, run_startup_routine
    IniWrite, %SettingAnnoy%,   %ini_file%, settings, run_annoy_routine
    process_volume_icon()
    process_annoy()
ButtonCancel:
GuiEscape:
    Gui Destroy  ; Destroy the Gui.
return


;-------------------------
     read_settings:      ;
;-------------------------
    IniRead, SettingRotate,  %ini_file%, settings, rotate_tray_icon_when_mute, 0
    IniRead, SettingStartup, %ini_file%, settings, run_startup_routine,        0
    IniRead, SettingAnnoy,   %ini_file%, settings, run_annoy_routine,          0
return


;--------------------
     ocred:         ;
;--------------------
SetKeyDelay, 25
WinHide, Microsoft Visual C++ Runtime Library ahk_class #32770
IfWinExist, Connect to mail.sfdc.sbc.com ahk_class #32770
{
    Gosub, esc_key
    WinActivate
    refresh_ini_value("mystring0", "string")
    Send, !p%mystring0%
    Send, {enter}
}
IfWinExist, Connecting to my.web.att.com ahk_class #32770
{
    Gosub, esc_key
    WinActivate
    Send, !uitservices\db5170
    refresh_ini_value("mystring0", "string")
    Send, !p%mystring0%
    Send, {enter}
}
return

;--------------------
     annoy:         ;
;--------------------
SetTitleMatchMode, 2
FormatTime, nowmins, , mmss
if(nowmins = 0000 or nowmins = 1500 or nowmins = 3000 or nowmins = 4500)
{
    Loop
    {
        InputBox, temp_input, ToDo, Enter work comment.  Type 'ok' to continue., , , , , , , 120
        If temp_input = ok
        {
            Gosub, &aNote
            break
        }
    }
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
M&inimizeAll:
;------------------------------------------------------------------------------
    SendInput, #m
return


;------------------------------------------------------------------------------
&Hibernate:
;------------------------------------------------------------------------------
    Sleep, 5000
    DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
return


;------------------------------------------------------------------------------
&Lock:
;------------------------------------------------------------------------------
    Sleep, 1000
    DllCall("user32.dll\LockWorkStation")
return


;------------------------------------------------------------------------------
Remin&ders:
;------------------------------------------------------------------------------
    SetTitleMatchMode, 2
    act_param=rmdr,Reminder
Goto, ActApp


;------------------------------------------------------------------------------
C&MD:
;------------------------------------------------------------------------------
    Run, cmd
    WinWait, ahk_class ConsoleWindowClass,,%timeout%
    WinActivate
return


;------------------------------------------------------------------------------
FindWindow(title,exclude_title,text="",exclude_text="",ask=0)
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
                    Debug("FindWindow found id by asking: " . this_id)
                    return %this_id%
                }
            }
            else
            {
                Debug("FindWindow found id: " . this_id)
                return %this_id%
            }
         }
    }
    ToolTip
    return 0
}


;------------------------------------------------------------------------------
Startup:
;------------------------------------------------------------------------------
    app_delay=2000
    Gosub, &Outlook
    Sleep, %app_delay%
    SendInput, {esc}
    Gosub, &Firefox
return


; Usage:
; yes_flag := Question(text)
;------------------------------------------------------------------------------
Question(text,h_axis=0)
;------------------------------------------------------------------------------
{
    answer_flag=0
    MsgBox, 4132, Question, %text%
    IfMsgBox Yes
        answer_flag++
    return %answer_flag%
}


;------------------------------------------------------------------------------
Debug(dtext)
;------------------------------------------------------------------------------
{
    global debug_on
    global debug_text
    global lastwin

    debug_x := A_ScreenWidth  - 400
    debug_y := A_ScreenHeight - 75

    FormatTime, TimeString,, yyyy-MM-dd HH:mm
    if debug_on
    {
        diagnostic_info=%TimeString% %A_ScriptName%
        FileAppend, %diagnostic_info%: %dtext%`r`n, %A_ScriptDir%\tscdebug.txt
        if debug_text
        {
            debug_text = %debug_text%`n.    %dtext%
        }
        else
        {
            debug_text = .    %dtext%
        }
        debug_y_offset += 12
        tmp_debug_y := debug_y - debug_y_offset
        ToolTip,%debug_text%    `n, %debug_x%, %tmp_debug_y%,3
        SetTimer, DisableDebugToolTip, 9000
    }
    return
}

DisableDebugToolTip:
{
    debug_text=
    debug_y_offset = 0
    SetTimer, DisableDebugToolTip, Off
    ToolTip, , , ,3
    return
}

;GoApp parameters
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
,ask_user_which_one=0)
;------------------------------------------------------------------------------
{
    global
    max=
    If !dont_maximize
        max=Max
    Transform, id, deref, `%%unique_identifier%_id`%
    IfWinExist, ahk_id %id%
    {
        Debug("I already have this window ID: " . id)
        WinActivate
    }
    else
    {
        SplitPath, command, rfile, rdir
        If !working_directory
            working_directory=%rdir%
        if title_match_mode > 0
            SetTitleMatchMode, 2
        Loop
        {
            Debug("Trying to find window via search_text: " . search_text)
            fw_id := FindWindow(search_text,exclude_text,"","",ask_user_which_one)
            if fw_id
            {
                Debug("Found window via search_text. Activating.")
                WinActivate ahk_id %fw_id%
                id=%fw_id%
                break
            }

            if(alternate_search_text)
            {
                Debug("Trying to locate window via alternate_search_text: " . alternate_search_text)
                IfWinExist, %alternate_search_text%,,%exclude_text%
                {
                    Debug("Found via alternate_search_text. Activating.")
                    WinActivate
                    WinGet, id, ID, A
                    break
                }
            }

            Debug("Could not find window.  Launching.")
            Run, %command% %parameters%,%working_directory%,%max%
            If !dont_maximize
            {
                WinWait, %search_text%,,%timeout%
                WinActivate
                WinMaximize
            }
            break
        }
    }
    if id
        Transform, %unique_identifier%_id, deref, %id%
    return 0
}


;NOT FINISHED
;IDEA: go through a list of all unmatched ids every second or so and try to
;locate them based on their initial parameters
FindPostLaunch:
    SplitPath, run, rfile, rdir
    If !dir
        dir=%rdir%
    if mode > 0
        SetTitleMatchMode, 2
    Loop
    {
        Debug("Trying to find window via text: " . text)
        fw_id := FindWindow(text,excl,"","",ask)
        if fw_id
        {
            Debug("Found window via text. Activating.")
            WinActivate ahk_id %fw_id%
            id=%fw_id%
            break
        }

        if(alt_text)
        {
            Debug("Trying to locate window via alt_text: " . alt_text)
            IfWinExist, %alt_text%,,%excl%
            {
                Debug("Found via alt_text. Activating.")
                WinActivate
                WinGet, id, ID, A
                break
            }
        }
    }
    if id
        Transform, %ident%_id, deref, %id%
return


;Usage:
;act_param=ident,text
;------------------------------------------------------------------------------
ActApp:
;------------------------------------------------------------------------------
    StringSplit, in_act, act_param, `,
    act_idnt =%in_act1%
    act_text =%in_act2%
    in_act1=
    in_act2=
    Transform, id, deref, `%%act_idnt%_id`%
    IfWinExist, ahk_id %id%
        WinActivate
    else
    {
      IfWinExist, %act_text%,,%act_excl%
      {
          WinActivate
          WinGet, id, ID, A
      }
    }
    if id
      Transform, %act_idnt%_id, deref, %id%
return


;------------------------------------------------------------------------------
&QuickStart:
;------------------------------------------------------------------------------
    SendInput, #{F10}
return


;------------------------------------------------------------------------------
&GaimWin:
;------------------------------------------------------------------------------
    WinActivate ahk_id %gaim_id%
return


;------------------------------------------------------------------------------
Set&vi:
;------------------------------------------------------------------------------
    vi_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
Set&Cygwin:
;------------------------------------------------------------------------------
    cygw_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetE&xplore:
;------------------------------------------------------------------------------
    fcx_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
Set&Firefox:
;------------------------------------------------------------------------------
    fox_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetRe&mote:
;------------------------------------------------------------------------------
    wksh_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
Set&Outlook:
;------------------------------------------------------------------------------
    outl_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
Set&RTM:
;------------------------------------------------------------------------------
    rtm_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
SetRemin&ders:
;------------------------------------------------------------------------------
    rmdr_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
Set&Scratch:
;------------------------------------------------------------------------------
    scr_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
Set&GaimWin:
;------------------------------------------------------------------------------
    gaim_id=%lastwin%
    WinActivate ahk_id %lastwin%
return


;------------------------------------------------------------------------------
&Firefox:
C&hrome:
;------------------------------------------------------------------------------
    target = %shortcuts_dir%\firefox.lnk
    GoApp("fox", "Mozilla Firefox", target, 1)
return


;------------------------------------------------------------------------------
old&Firefox:
;------------------------------------------------------------------------------
    target = %shortcuts_dir%\chrome.lnk
    GoApp("chrome", "Chrome", target, 1)
return


;------------------------------------------------------------------------------
Options&b:
;------------------------------------------------------------------------------
    Gosub, options_gui
return


;------------------------------------------------------------------------------
&Cygwin:
;------------------------------------------------------------------------------
    target = %shortcuts_dir%\cygwin.lnk
    GoApp("cygw","ahk_class PuTTY", target, 1,"","","","","",1)
return


;------------------------------------------------------------------------------
P&aint:
;------------------------------------------------------------------------------
    target = %sys_drive%\Program Files\Paint.NET\PaintDotNet.exe
    GoApp("pnt","Paint.NET",target,"","",1)
return


;------------------------------------------------------------------------------
&Calculator:
;------------------------------------------------------------------------------
    GoApp("clc","Calculator","calc","","",1)
return


;------------------------------------------------------------------------------
V&PN:
;------------------------------------------------------------------------------
    Run, %shortcuts_dir%\glob.lnk
return


;------------------------------------------------------------------------------
Re&mote:
;------------------------------------------------------------------------------
    remote=%shortcuts_dir%\putty.lnk
    GoApp("wksh","ahk_class PuTTY",remote,"","-load NO_remote","","","","xrm",1)
return


;------------------------------------------------------------------------------
&Outlook:
;------------------------------------------------------------------------------
    target = %shortcuts_dir%\outlook.lnk
    GoApp("outl","Outlook",target,1)
    Gosub, outlook_keys
return


;------------------------------------------------------------------------------
Internet&Explorer:
;------------------------------------------------------------------------------
    app_run=%shortcuts_dir%\ie.lnk
    GoApp("ie","zaxtjeq",app_run,1)
return


;------------------------------------------------------------------------------
&RTM:
;------------------------------------------------------------------------------
    app_run=http://www.rememberthemilk.com
    GoApp("rtm","Remember The Milk",app_run)
return


;------------------------------------------------------------------------------
&vi:
;------------------------------------------------------------------------------
    target = %shortcuts_dir%\gvim.lnk
    GoApp("vi","GVIM",target,1)
return


;------------------------------------------------------------------------------
&Scratch:
;------------------------------------------------------------------------------
    target = %shortcuts_dir%\gvim.lnk
    scratch = %A_ScriptDir%\scratch.txt
    GoApp("scr","scratch",target,0,scratch)
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
    Run, %shortcuts_dir%\gvim.lnk "%f_path%",,Max
    WinWait, %f_param%,,%timeout%
    WinActivate
    WinMaximize
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
GoLink(f_path,link_enter=1,tab_number=0,link_delay=0)
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
    SendInput, %f_path%
    Sleep, 500
    if !link_enter
    {
        SendInput, %link_input%
    }
    SendInput, {enter}
    return 0
}



;------------------------------------------------------------------------------
Go&WorkLink:
;------------------------------------------------------------------------------
    StringTrimLeft, f_path, f_pathWorkLink%A_ThisMenuItemPos%, 0
    If f_path =
        return
    StringTrimLeft, f_param, f_paramWorkLink%A_ThisMenuItemPos%, 0
    GoLink(f_path,1,f_param)
return


;------------------------------------------------------------------------------
E&xplore:
;------------------------------------------------------------------------------
    target = %shortcuts_dir%\freecommander.lnk
    GoApp("fcx","reeComm",target,1,"","","","","",1)
return


;------------------------------------------------------------------------------
&Reload:
;------------------------------------------------------------------------------
    Reload
return


;------------------------------------------------------------------------------
&DumpSTDERR:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
    SendInput, print STDERR "\n\ndmb_file:",__FILE__,' dmb_line:',__LINE__,':',Data{:}{:}Dumper{:}{:}Dumper();{esc}{left}i
return


;------------------------------------------------------------------------------
&EjectAll:
;------------------------------------------------------------------------------
    drive=65
    Loop,25
    {
      Transform,name,Chr,%drive%
      Drive, Eject, %name%:
      drive+=1
    }
return


;------------------------------------------------------------------------------
&PrintSTDERR:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
    SendInput, print STDERR "\n\ndmb_file:",__FILE__," dmb_line:",__LINE__,':{{}',$,"{}}\n";{esc}{left 6}i
return


;------------------------------------------------------------------------------
&Madeit:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
    SendInput, print STDERR "\n\ndmb_file:",__FILE__," dmb_line:",__LINE__,":made it\n";
return


;------------------------------------------------------------------------------
&UseDataDumper:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
    SendInput, use Data{:}{:}Dumper ();
return


;------------------------------------------------------------------------------
&Compile:
;------------------------------------------------------------------------------
    WinActivate ahk_id %lastwin%
    SendInput, {esc}{:}{!}perl -I'.' -I'..' -TWc `% 2>&1 | head{enter}
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
        Hotkey, h, Off
        Hotkey, j, Off
        Hotkey, k, Off
        Hotkey, l, Off
        Hotkey, WheelDown, Off
        Hotkey, WheelUp, Off
        Hotkey, esc, Off
        Hotkey, Enter, Off
        volume_esc =0
    }
    If mouse_esc
    {
        SetTimer,mouse_shimmy,Off
        ToolTip
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
        ToolTip
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
big_tip:
;------------------------------------------------------------------------------
    ToolTip, `n`n%show_tip%`n`n, 0, 0
return


;------------------------------------------------------------------------------
mode_tip:
;------------------------------------------------------------------------------
    ToolTip, `n`n               %mode% MODE          `n`n, 0, 0
return


F12::
Gosub, vol_setting1
Gosub, vol_MasterMute
return


/*
$LButton::
   Send {LButton Down}
   KeyWait LButton
   Send {LButton Up}
Return

$RButton::
   Send {RButton Down}
   KeyWait RButton
   Send {RButton Up}
Return

RButton & LButton::
    Gosub, esc_key
    menu, man, show
Return

&C:
    Gosub, cappy
return

&M:
&P:
return
*/



;------------------------------------------------------------------------------
starttusc_init:
;------------------------------------------------------------------------------
FileDelete, %A_ScriptDir%\starttusc.ahk
FileAppend,
(
#NoTrayIcon
#SingleInstance force

#j::
Run, %A_ScriptDir%\tusc.ahk
return
), %A_ScriptDir%\starttusc.ahk
Run, %A_ScriptDir%\starttusc.ahk
return



;------------------------------------------------------------------------------
menufocus_init:
;------------------------------------------------------------------------------
FileDelete, %A_ScriptDir%\menufocus.ahk
FileAppend,
(
#SingleInstance force

BlockInput, On
Loop, 9999
{
    BlockInput, On
    if class = #32768
        break
    MouseGetPos, , , id, control
    WinGetClass, class, ahk_id `%id`%
}
Click
BlockInput, Off
), %A_ScriptDir%\menufocus.ahk
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Function_section                                                         |
;                                                                             |
;=============================================================================+

f_width()
{
    return A_ScreenWidth  - 1
}

f_height()
{
    return A_ScreenHeight - 1
}

f_cwidth()
{
    retval := A_ScreenWidth / 2
    Transform, retval, Round, %retval%
    return retval
}

f_cheight()
{
    retval := A_ScreenHeight / 2
    Transform, retval, Round, %retval%
    return retval
}

f_sheight()
{
    retval := A_ScreenHeight / 2 - 300
    Transform, retval, Round, %retval%
    return retval
}

f_swidth()
{
    retval  := A_ScreenWidth  / 2 - 90
    Transform, retval,  Round, %retval%
    return retval
}

refresh_ini_value(var, section)
{
    global
    Debug("var=" . var)
    Debug("section=" . section)
    Debug("ini_file=" . ini_file)
    Debug("mystring2=" . mystring2)
    IniRead, %var%, %ini_file%, %section%, %var%
    Debug("mystring2=" . mystring2)
    return
}


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Control_j_menu_section                                                   |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
&JMenu:
#z::
^j::
;------------------------------------------------------------------------------
    j_show_tip=
    Gosub, esc_key
    j_menu=`n
    j_menu=%j_menu%    kill script (k)    `n
    j_menu=%j_menu%    mute (m)    `n
    j_menu=%j_menu%    paste (v)    `n
    j_menu=%j_menu%    paste, Secondary (e)    `n
    j_menu=%j_menu%    restart script (r)    `n
    j_menu=%j_menu%    save to permanent buffer (y)    `n
    j_menu=%j_menu%    save to permanent buffer, Secondary (z)    `n
    j_menu=%j_menu%    Timestamp (i)    `n
    j_menu=%j_menu%    volume (u)    `n
    j_menu=%j_menu%                  `n
    j_menu=%j_menu%    (J)ust quit    `n
    ToolTip,%j_menu%, 0, 0
    Input, buffer_key, L1T60
    ToolTip
    if buffer_key = 0
      Gosub, control_0
    else if buffer_key = 1
      Gosub, control_1
    else if buffer_key = 2
      Gosub, control_2
    else if buffer_key = 3
      Gosub, control_3
    else if buffer_key = 4
      Gosub, control_4
    else if buffer_key = 5
      Gosub, control_5
    else if buffer_key = 6
      Gosub, control_6
    else if buffer_key = 7
      Gosub, control_7
    else if buffer_key = 8
      Gosub, control_8
    else if buffer_key = 9
      Gosub, control_9
    else if buffer_key = e
      Gosub, control_e
    else if buffer_key = i
      Gosub, Timestamp
    else if buffer_key = j
      j_show_tip=Operation Cancelled
    else if buffer_key = k
      Gosub, control_k
    else if buffer_key = m
      Gosub, vol_MasterMute
    else if buffer_key = r
      Gosub, control_r
    else if buffer_key = u
      Gosub, &Volume
    else if buffer_key = v
      Gosub, control_v
    else if buffer_key = y
      Gosub, control_y
    else if buffer_key = z
      Gosub, control_z
    else if buffer_key =
      j_show_tip=Timeout
    else
      j_show_tip=No such option.

    if(j_show_tip)
    {
        show_tip := j_show_tip
        Gosub, big_tip
        SetTimer,clear_tooltip,-1000
    }
return

clear_tooltip:
    ToolTip
return


;------------------------------------------------------------------------------
control_0:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring0", "string")
    SendInput, {Raw}%mystring0%
return


;------------------------------------------------------------------------------
control_1:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring1", "string")
    SendInput, {Raw}%mystring1%
return


;------------------------------------------------------------------------------
control_2:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring2", "string")
    SendInput, {Raw}%mystring2%
return


;------------------------------------------------------------------------------
control_3:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring3", "string")
    SendInput, {Raw}%mystring3%
return


;------------------------------------------------------------------------------
control_4:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring4", "string")
    SendInput, {Raw}%mystring4%
return


;------------------------------------------------------------------------------
control_5:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring5", "string")
    SendInput, {Raw}%mystring5%
return


;------------------------------------------------------------------------------
^!6::
control_6:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring6", "string")
    SendInput, {Raw}%mystring6%
return


;------------------------------------------------------------------------------
control_7:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring7", "string")
    SendInput, {Raw}%mystring7%
return


;------------------------------------------------------------------------------
control_8:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring8", "string")
    SendInput, {Raw}%mystring8%
return


;------------------------------------------------------------------------------
^!9::
control_9:
;------------------------------------------------------------------------------
    refresh_ini_value("mystring9", "string")
    SendInput, {Raw}%mystring9%
return


;------------------------------------------------------------------------------
control_e:
;------------------------------------------------------------------------------
    cb_prefix = ECB
Goto, paste_routine


;------------------------------------------------------------------------------
control_k:
;------------------------------------------------------------------------------
    &Exit:
    ExitApp
return


;------------------------------------------------------------------------------
control_r:
;------------------------------------------------------------------------------
    Reload
return


;------------------------------------------------------------------------------
control_v:
;------------------------------------------------------------------------------
    cb_prefix = CB
    Goto, paste_routine


;------------------------------------------------------------------------------
control_y:
;------------------------------------------------------------------------------
    cb_prefix = CB
    Goto, perm_copy_routine


;------------------------------------------------------------------------------
control_z:
;------------------------------------------------------------------------------
    cb_prefix = ECB
    Goto, perm_copy_routine


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Capslock_menu_section                                                    |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
GoCappy:
    Debug("GoCappy = No key press")
Capslock:
;------------------------------------------------------------------------------
    CoordMode, Mouse, Screen
    WinGet, lastwin, ID, A
    Debug("lastwin=" . lastwin)

    BlockInput, On

    Gosub, esc_key

    swidth := f_swidth()
    sheight := f_sheight()
    MouseMove, %swidth%, %sheight%, 0

    Run, menufocus.ahk

    BlockInput, Off

    menu, main, show, %swidth%, %sheight%
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Clipboard_section                                                        |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
^o::
;------------------------------------------------------------------------------
    cb_prefix = CB
    WinGetClass, cb_winclass, A
    Gosub, oYank
return


;------------------------------------------------------------------------------
cb_init:
;------------------------------------------------------------------------------
    FileCreateDir, %cb_dir%

    cb_key_static=abcdefghiklmnopqrstuwxyz
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
control_c:
;------------------------------------------------------------------------------
    cb_prefix = ECB
Goto, paste_routine


;------------------------------------------------------------------------------
paste_routine:
;------------------------------------------------------------------------------
    cb_routine=Paste
    Gosub, GetKey
    ClipBoard := cb_buf_%cb_prefix%_%buffer_key%
    IfInString, cb_winclass, putty
    {
        MouseGetPos,x_save,y_save
        MouseClick, Right, 24,35
        MouseMove, %x_save%, %y_save%
    }
    else If cb_winclass = Vim
    {
        Send +{ins}
    }
    else If cb_winclass = ConsoleWindowClass
    {
        SendInput, !{space}ep
    }
    else
    {
        Send ^v
    }
return


;------------------------------------------------------------------------------
perm_copy_routine:
;------------------------------------------------------------------------------
    cb_routine=PermaCopy
    Gosub, BYank
return


;------------------------------------------------------------------------------
GetKey:
;------------------------------------------------------------------------------
    cb_tip_text=
    cb_loop_index=%cb_index%
    If cb_prefix = CB
    {
      Loop, %cb_rotate_max%
      {
        StringMid, cb_index_letter, cb_key_rotate, %cb_loop_index%, 1
        cb_add := cb_buf_%cb_prefix%_%cb_index_letter%
        StringReplace, cb_add, cb_add, `r`n, , All
        StringReplace, cb_add, cb_add, %A_Space%, , All
        StringReplace, cb_add, cb_add, %A_Tab%, , All
        StringLeft, cb_add, cb_add, 80
        cb_tip_text = %cb_tip_text%%cb_index_letter%. %cb_add%`r`n
        cb_loop_index--
        if(cb_loop_index < 1)
          cb_loop_index=%cb_rotate_max%
      }
    }
    cb_tip_text = %cb_tip_text%`r`nPermanent buffers:`r`n
    cb_loop_index=1
    Loop, %cb_static_max%
    {
      StringMid, cb_index_letter, cb_key_static, %cb_loop_index%, 1
      cb_add := cb_label_%cb_prefix%_%cb_index_letter%
      cb_tip_text = %cb_tip_text%%cb_index_letter%. %cb_add%`r`n
      cb_loop_index++
    }
    WinGetClass, cb_winclass, A
    show_tip=%cb_routine% - Select buffer`r`n%cb_tip_text%
    Gosub, big_tip
    buffer_key=
    Input, buffer_key, L1T20
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
      ToolTip
      show_tip=Operation Cancelled
      Gosub, big_tip
      SetTimer,clear_tooltip,-1000
      exit
    }
    ToolTip
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
      show_tip=Copied %cb_add%
      Gosub, big_tip
      SetTimer,clear_tooltip,-1000
    }
return


;------------------------------------------------------------------------------
BYank:
;------------------------------------------------------------------------------
if(ClipBoard)
{
  cb_in=%ClipBoard%
  cb_default_label=%ClipBoard%
  Gosub, GetKey
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
  show_tip=Copied %cb_add%
  Gosub, big_tip
  SetTimer,clear_tooltip,-1000
}
return


;=============================================================================+
;=============================================================================+
;                                                                             |
;    Timestamp_section                                                        |
;                                                                             |
;=============================================================================+


;------------------------------------------------------------------------------
Timestamp:
;------------------------------------------------------------------------------
    Gosub, esc_key
    j_menu=`n
    j_menu=%j_menu%    Wednesday, April 13, 2011 (a)    `n
    j_menu=%j_menu%    11:06 PM 4/13/2011 (f)    `n
    j_menu=%j_menu%    2011-04-13 (k)    `n
    j_menu=%j_menu%    2011-04-13 23:06 (e)    `n
    j_menu=%j_menu%    2011-04-13 Wednesday (x)    `n
    ToolTip,%j_menu%, 0, 0
    Input, buffer_key, L1T60
    ToolTip
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


;------------------------------------------------------------------------------
timestamp_l:
;------------------------------------------------------------------------------
    FormatTime, TimeString,, MMMyy
    SendInput, %TimeString%
return


;=============================================================================+
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
vol_DisplayTime = 4000
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
&Volume:
;------------------------------------------------------------------------------
    volume_keys:
    Gosub, vol_ShowBars
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
    Hotkey, h, vol_MasterDown
    Hotkey, j, vol_WaveDown
    Hotkey, k, vol_WaveUp
    Hotkey, l, vol_MasterUp
    Hotkey, WheelDown, vol_WheelDown
    Hotkey, WheelUp, vol_WheelUp
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
    Hotkey, h, On
    Hotkey, j, On
    Hotkey, k, On
    Hotkey, l, On
    Hotkey, WheelDown, On
    Hotkey, WheelUp, On
    Hotkey, esc, On
    Hotkey, Enter, On
    volume_esc=1
return


;------------------------------------------------------------------------------
vol_setting0:
;------------------------------------------------------------------------------
    vol_setting=0
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting1:
;------------------------------------------------------------------------------
    vol_setting=10
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
do_vol_setting:
;------------------------------------------------------------------------------
    SoundSet, %vol_setting%, Wave
    SoundSet, %vol_setting%
    if volume_esc
        Gosub, vol_ShowBars
    else
        Gosub, &Volume
return


;------------------------------------------------------------------------------
vol_WaveUp:
;------------------------------------------------------------------------------
    SoundSet, +%vol_Step%, Wave
    Gosub, vol_ShowBars
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
vol_Mousedown:
;------------------------------------------------------------------------------
    Loop, 4
    {
        Gosub, vol_WaveDown
        Gosub, vol_MasterDown
    }
return


;------------------------------------------------------------------------------
vol_Mouseup:
;------------------------------------------------------------------------------
    Loop, 4
    {
        Gosub, vol_WaveUp
        Gosub, vol_MasterUp
    }
return


;------------------------------------------------------------------------------
vol_WaveDown:
;------------------------------------------------------------------------------
    SoundSet, -%vol_Step%, Wave
    Gosub, vol_ShowBars
return


;------------------------------------------------------------------------------
vol_MasterUp:
;------------------------------------------------------------------------------
    SoundSet, +%vol_Step%
    menu,tray,icon,%prog_icon%
    Gosub, vol_ShowBars
return


;------------------------------------------------------------------------------
vol_MasterDown:
;------------------------------------------------------------------------------
    SoundSet, -%vol_Step%
    Gosub, vol_ShowBars
return


;------------------------------------------------------------------------------
&Mute:
vol_MasterMute:
;------------------------------------------------------------------------------
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
    Gosub, volume_keys
return


;------------------------------------------------------------------------------
process_volume_icon(volume=-1)
;------------------------------------------------------------------------------
{
    global
    Debug("process_volume_icon")
    Debug("    volume: " . volume)
    if(volume=-1)
    {
        SoundGet, volume, Master
    }
    Debug("    volume: " . volume)
    Debug("    SettingRotate: " . SettingRotate)
    if(volume or !SettingRotate)
    {
        Debug("    setting prog icon:" . prog_icon)
        menu,tray,icon,%prog_icon%
    }
    else
    {
        Debug("    setting mute icon:" . mute_icon)
        menu,tray,icon,%mute_icon%
    }
    return
}


;------------------------------------------------------------------------------
process_annoy(annoy_status=-1)
;------------------------------------------------------------------------------
{
    global
    Debug("process_annoy")
    Debug("    annoy_status: " . annoy_status)
    if(annoy_status=-1)
    {
        IniRead, SettingAnnoy,   %ini_file%, settings, run_annoy_routine, 0
        annoy_status := SettingAnnoy
    }
    Debug("    annoy_status: " . annoy_status)
    Debug("    SettingAnnoy: " . SettingAnnoy)
    if(annoy_status)
    {
        Debug("    enabling annoy")
        SetTimer,annoy,%annoy_msecs%
    }
    else
    {
        Debug("    disabling annoy")
        SetTimer,annoy,Off
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
    vol_setting=20
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting3:
;------------------------------------------------------------------------------
    vol_setting=30
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting4:
;------------------------------------------------------------------------------
    vol_setting=40
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting5:
;------------------------------------------------------------------------------
    vol_setting=50
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting6:
;------------------------------------------------------------------------------
    vol_setting=60
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting7:
;------------------------------------------------------------------------------
    vol_setting=70
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting8:
;------------------------------------------------------------------------------
    vol_setting=80
    Gosub, do_vol_setting
return


;------------------------------------------------------------------------------
vol_setting9:
;------------------------------------------------------------------------------
    vol_setting=90
    Gosub, do_vol_setting
return


;-----------------------------------------------------------------------------
f_OpenFavorite:
;------------------------------------------------------------------------------
    StringTrimLeft, f_path, f_path%A_ThisMenuItemPos%, 0
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
    else if f_class in ConsoleWindowClass
    {
        WinActivate, ahk_id %f_window_id%
        WinGetActiveTitle, window_title
        SendInput, {bs 2}cd{space}"
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
        else if f_class not in ConsoleWindowClass,PuTTY,bosa_sdm_Mso96,gdkWindowToplevel
            return ; Since it's some other window type, don't display menu.
    }
    Menu % Favorites, show, f_swidth(), f_sheight()
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
    o_param=+^g{tab 3} {enter}{down}{up}~d
return


;------------------------------------------------------------------------------
o_f_key:
;------------------------------------------------------------------------------
    Gosub, o_a_key
    Suspend, On
    SendInput,+^v
    Sleep, 750
    SendInput,z
    Sleep, 750
    SendInput,{enter}
    Suspend, Off
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
      Hotkey, c, Off
      SendInput, ^y{home}c{enter}
      Hotkey, c, On
    }
    else
    {
      Gosub, esc_key
      SendInput, z
    }
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
      Suspend, On
      SendInput, ^y{home}h{enter}
      Suspend, Off
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
      Suspend, On
      SendInput, ^y{home}s{enter}
      Suspend, Off
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
M&ouseKeys:
mouse_keys:
;------------------------------------------------------------------------------
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
MyMouseMove(xx,yy=0)
;------------------------------------------------------------------------------
{
    CoordMode, Mouse, Screen
    MouseMove,%xx%,%yy%,%mouse_move_speed%,R
    return 0
}

;------------------------------------------------------------------------------
MyToolTip(text="",posx=0,posy=0,ident=1)
;------------------------------------------------------------------------------
{
    ToolTip %text%, %posx%, %posy%, %ident%
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
    MyToolTip(j_menu, 0, 0)
return

#Include tusc_addon.ahk
