Type(text, delayEachChar:=50) {
    chars := StrSplit(text, "")

    Loop % chars.MaxIndex()
    {
        char := chars[A_Index]
        Send, %char%
        Sleep, %delayEachChar% ; in milliseconds
    }
}

ShowWarningDialog(message) {
    OK_DIALOG := 0
    WARNING_ICON := 48
    MsgBox % OK_DIALOG WARNING_ICON, Warning, %message%
}

if WinExist("WiFi Keyboard - Mozilla Firefox") {
    Sleep, 1000 ; 1 sec
    WinActivate

    username := "near.huscarl@gmail.com"
    password := "subscribe to pewdiepie"

    Type(username)
    Sleep, 1500
    Type(password)
} else {
    ShowWarningDialog("WiFi Keyboard window not found")
}