#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off
this_file:="libInit.ahk"

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpCalibrate.ahk")
	ExitApp
	Return
}

