#Persistent

if running_on_guest()
    Exitapp

SetTimer, Check_Delete_Signal, 1000
return

running_on_guest()
{
    DriveGet, label, label, S:

    IfInString, label, shared
        return 1
    else
        return 0
}

LockComputer:
    DllCall("user32.dll\LockWorkStation")
return

Check_Delete_Signal:
    FileDelete, C:\shared\lock_computer.sig
    if !ErrorLevel
        Gosub, LockComputer
return

