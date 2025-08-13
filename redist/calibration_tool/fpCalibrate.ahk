A_FileVersion := "1.1.1.1"
A_AppName := "fpCalibrate"
#requires autoHotkey v2.0+
#singleInstance
#maxThreadsPerHotkey 1
persistent()	
setWorkingDir(a_scriptDir)
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

if !inStr("3440,1920",a_screenwidth) {
	msgBox("Apologies, currently screen resolution " a_screenwidth "x" a_screenheight " is not supported.`nPlease set your primary display to 1920x1080 or 3440x1440") 
	exitApp
}


	a_cmdLine := DllCall("GetCommandLine", "str")
	a_restarted := 
			(inStr(a_cmdLine,"/restart"))
				? true
				: false
				
cfg:= object()
ui:= object()
this:=object()
tmp:= object()

#include <libInit>
monitorGet(monitorGetPrimary(),&monLeft,&monTop,&monRight,&monBottom)

cfg.guiX:=
ui.calGui:=gui()
ui.calGui.opt("-caption -border alwaysOnTop")
ui.transparentColor:="FEFFFD"
winSetTransColor(ui.transparentColor,ui.calGui)
ui.calGui.backColor:=ui.transparentColor
ui.calGui.color:=ui.transparentColor
ui.calGui.addText("x" monLeft " y" monTop " w" ui.)
ui.calGui.show("x" monLeft " y" monTop " w" a_screenWidth " h" a_screenHeight)