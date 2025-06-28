#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off


if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off


if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}


createHelp(*) {
	ui.keybase:=map()
	ui.keybase["01_capslock"]:="Enables/Disables fpAssist"
	ui.keybase["02_Shift-F"]:="Cast"
	ui.keybase["05_Alt-ScrollUp"]:="Rod stand slot 1"
	ui.keybase["06_Alt-ScrollDown"]:="Rod stand slot 2"
	ui.keybase["07_RButton-ScrollUp"]:="Rod stand slot 3"
	ui.keybase["08_RButton-ScrollDown"]:="Rod stand slot 4"
	ui.keybase["09_Shift-D"]:="Autosteer boat Right"
	ui.keybase["03_Shift-R"]:="Reel In"
	ui.keybase["04_Ctrl-Shift-L"]:="Land Fish"

	ui.transparentColor:="010203"
	ui.helpGui:=gui()
	ui.helpGuiPos:=object()
	ui.helpGuiPos.w:=1024
	ui.helpGuiPos.h:=364
	ui.helpGuiPos.x:=(a_screenwidth/2)-(ui.helpGuiPos.w/2)
	ui.helpGuiPos.y:=(a_screenheight/2)-(ui.helpGuiPos.h/2)
	ui.helpGui.opt("-caption -border toolWindow alwaysOnTop")
	ui.helpGui.backColor:=ui.transparentColor
	ui.helpGui.color:=ui.transparentcolor

	ui.helpGuiBg:=ui.helpGui.addText("x" 0 " y" 0 " w" ui.helpGuiPos.w " h" ui.helpGuiPos.h " background" ui.bgColor[1])
	ui.helpGuiBg2:=ui.helpGui.addText("x1 y1 w" ui.helpGuiPos.w-2 " h" ui.helpGuiPos.h-2 " background" ui.bgColor[5])
	ui.helpGuiBg3:=ui.helpGui.addText("x3 y3 w" ui.helpGuiPos.w-6 " h" ui.helpGuiPos.h-6 " background" ui.bgColor[1])
	ui.helpGuiTitlebar:=ui.helpGui.addText("x3 y3 w" ui.helpGuiPos.w-6-30 " h" 26 " background" ui.bgColor[3])
	ui.helpGuiTitlebarText:=ui.helpGui.addText("x8 y3 w" ui.helpGuiPos.w-6-30 " h" 26 " backgroundTrans","Help - fpAssist v" a_fileVersion)
	ui.helpGuiTitlebarText.setFont("s16 c" ui.fontColor[3],"Calibri")
	ui.helpGuiTitlebar.onEvent("click",wm_LButtonDown_callback)
	ui.helpGuiCloseBg:=ui.helpGui.addText("x" ui.helpGuiPos.w-30-3 " y3 w" 30 " h" 26 " background" ui.bgColor[1])
	ui.helpGuiClose:=ui.helpGui.addText("x" ui.helpGuiPos.w-30-3 " y1 w" 30 " h" 26 " backgroundTrans c" ui.fontColor[1],"r")
	ui.helpGuiClose.onEvent("click",toggleHelp)
	ui.helpGuiClose.setFont("s22 c" ui.fontColor[3],"Webdings")

	ui.helpGui.setFont("s16 c" ui.fontColor[3],"Calibri")
	ui.helpGui.addText("x8 y30 w0 h0 section backgroundTrans")
	
	for this_hotkey in ui.keybase {
		ui.helpGui.addText("right section xs w180 h30 background" ui.bgColor[2]," " substr(this_hotkey,4))
		ui.helpGui.addText("x+6 ys w822 h30 background" ui.bgColor[2]," " ui.keybase[this_hotkey])
	}
}

ui.helpVisible:=false
toggleHelp(*) {
	(ui.helpVisible:=!ui.helpVisible)
		? ui.helpGui.show("x" ui.helpGuiPos.x " y" ui.helpGuiPos.y " w" 1024 " h" ui.helpGuiPos.h " noActivate")
		: ui.helpGui.hide()
	}
	
