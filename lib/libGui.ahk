#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off


if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}


statPanel(*) {
	ui.sessionStartTime := a_now
	ui.afkStartTime := a_now
	
	ui.statCoord := map("x",664,"y",755,"w",435,"h",56)
	x := ui.statCoord["x"] + 8
	y := ui.statCoord["y"] + 4
	w := ui.statCoord["w"]
	h := ui.statCoord["h"]

	ui.statPanelOutline2 := ui.fishGui.addText("x" ui.statCoord["x"]-1 " y" ui.statCoord["y"]-1 " w" ui.statCoord["w"]+2 " h" ui.statCoord["h"]+2 " background" ui.bgColor[3])
	ui.statPanelOutline := ui.fishGui.addText("x" ui.statCoord["x"]-1 " y" ui.statCoord["y"]-1 " w" ui.statCoord["w"] " h" ui.statCoord["h"] " background" ui.bgColor[5])
	ui.statPanelBg := ui.fishGui.addText("x" ui.statCoord["x"] " y" ui.statCoord["y"] " w" ui.statCoord["w"] " h" ui.statCoord["h"] " background" ui.bgColor[1])
	;msgBox(ui.statCoord["w"])
	
	ui.statSessionStartTimeLabel := ui.fishGui.addText("x" 7+x " y" 5+y " right section w70 r1 backgroundTrans c" ui.fontColor[3],"Session Start: ")
	ui.statSessionStartTime := ui.fishGui.addText("x+0 ys w100 r1 backgroundTrans c" ui.fontColor[3],formatTime(,"yyyyMMdd HH:mm:ss"))
	
	ui.statCastLengthLabel := ui.fishGui.addText("x+30 ys section w63 r1 backgroundTrans c" ui.fontColor[3],"Cast Length:`t")
	ui.statCastLength := ui.fishGui.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],cfg.castAdjust[cfg.profileSelected])
	
	ui.statFishCountLabel := ui.fishGui.addText("x+10 ys section w55 r1 backgroundTrans c" ui.fontColor[3],"Fish Count:")
	ui.statFishCount := ui.fishGui.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3], ui.fishLogCount.text)
	
	ui.statAfkStartTimeLabel := ui.fishGui.addText("xs-333 y+0 right section w70 r1 backgroundTrans c" ui.fontColor[3],"AFK Start: ")
	ui.statAfkStartTime := ui.fishGui.addText("x+0 ys w100 r1 backgroundTrans c" ui.fontColor[3],formatTime(,"yyyyMMdd HH:mm:ss"))
	
	ui.statDragLevelLabel := ui.fishGui.addText("x+30 ys section w63 r1 backgroundTrans c" ui.fontColor[3],"Drag Level:`t")
	ui.statDragLevel := ui.fishGui.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],cfg.dragLevel[cfg.profileSelected])
	
	ui.statCastCountLabel := ui.fishGui.addText("x+10 ys section w55 r1 backgroundTrans c" ui.fontColor[3],"Cast Count:")
	ui.statCastCount := ui.fishGui.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3], ui.castCount)
	
	ui.statAfkDurationLabel := ui.fishGui.addText("xs-333 y+0 right section w70 r1 backgroundTrans c" ui.fontColor[3],"AFK Duration: ")
	ui.statAfkDuration := ui.fishGui.addText("x+0 ys w100 r1 background" ui.bgColor[1] " c" ui.fontColor[3],"")
	
	ui.statReelSpeedLabel := ui.fishGui.addText("x+30 ys section w63 r1 backgroundTrans c" ui.fontColor[3],"Reel Speed:`t")
	ui.statReelSpeed := ui.fishGui.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],cfg.reelSpeed[cfg.profileSelected])
	
	ui.viewLog := ui.fishGui.addText("x+10 ys right section w55 r1 backgroundTrans c" ui.fontColor[3],"View Log")
	ui.viewLog.setFont("s9 underline")
	ui.viewLog.onEvent("click",viewLog)
	
	viewLog(*) {
		run("notepad.exe " a_scriptDir "/logs/current_log.txt")
	}
	

	
}
startupProgress(*) {
	try {
		ui.loadingProgress.value += 1
		if ui.loadingProgress.value >= 100 {
		
			setTimer(startupProgress,0)
		}
	}
	
}

startupProgress0(*) {
	try {
		ui.loadingProgress.value += 1
		if ui.loadingProgress.value >= 20 {
			setTimer(startupProgress0,0)
		}
	}
	
}
startupProgress2(*) {
	try {
		ui.loadingProgress.value += 2
		if ui.loadingProgress.value >= 100 {
		
			setTimer(startupProgress2,0)
		}
	}
	
}
loadScreen(visible := true,NotifyMsg := "...Loading...",Duration := 10) {
	if (visible) {
		Transparent := 0
		ui.notifyGui			:= Gui()
		ui.notifyGui.Title 		:= "Loading.  Please Wait...."

		ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		ui.notifyGui.BackColor := "353535" ; Can be any RGB color (it will be made transparent below).
		ui.notifyGui.SetFont("s30 bold")  ; Set a large font size (32-point).
		ui.notifyGui.addPicture("x0 y0 w1580 h780","./img/button_log.png")
		;ui.notifyGui.AddText("x" (1580/2)-100 " y" (810/2) " c252525 center BackgroundTrans","Please Wait")  ; XX & YY serve to 00auto-size the window.
		;ui.notifyGUi.addText("xs+1 y+1 w302 h22 background959595")
		ui.loadingProgress := ui.notifyGui.addProgress("smooth x0 y750 w1580 h60 c202020 background404040")
		ui.loadingProgress.value := 0
		if winExist(ui.game) {
			setTimer(startupProgress,32)
		} else {
			setTimer(startupProgress0,200)
		}

		;setTimer(loadingProgressStep,100)
		ui.notifyGui.AddText("xs hidden")

		ui.notifyGui.show("x0 y0 w1580 h810 noActivate")
		winGetPos(&x,&y,&w,&h,ui.notifyGui.hwnd)
		drawOutline(ui.notifyGui,1,1,w-2,h-2,"454545","757575",1)
		drawOutline(ui.notifyGui,2,2,w-4,h-4,"858585","454545",1)
		while transparent < 245 {
			winSetTransparent(transparent,ui.notifyGui.hwnd)
			transparent += 8
			sleep(1)
		}
		winSetTransparent("Off",ui.notifyGui.hwnd)
	} else {
			transparent := 255
			while transparent < 20 {
				winSetTransparent(transparent,ui.notifyGui.hwnd)
				transparent -= 8
				sleep(1)
			}
			ui.notifyGui.hide()
			
	}
}



line(this_gui,startingX,startingY,length,thickness,color,vertical:=false) {
	this_guid := comObject("Scriptlet.TypeLib").GUID
	if (vertical) {
		this_guid := this_gui.addText("x" startingX " y" startingY " w" thickness " h" length " background" color)
	} else {
		this_guid := this_gui.addText("x" startingX " y" startingY " w" length " h" thickness " background" color)
	}
	return this_guid
}

drawOutline(guiName, X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
	guiName.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	guiName.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	guiName.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	guiName.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}	

drawOutlineNamed(outLineName, guiName, X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
	outLineName1	:= outLineName "1"
	outLineName2	:= outLineName "2"
	outLineName3	:= outLineName "3"
	outLineName4	:= outLineName "4"
	(outLineName1 := outLineName "1") := guiName.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	(outLineName2 := outLineName "2") := guiName.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	(outLineName3 := outLineName "3") := guiName.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	(outLineName4 := outLineName "4") := guiName.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}



drawButton(x,y,w,h) {
		ui.fishGui.addText("x" x " y" y " w" w " h" h " background111111")
		ui.fishGui.addText("x" x+1 " y" y+1 " w" w-2 " h" h-2 " background888888")
		ui.fishGui.addText("x" x+2 " y" y+2 " w" w-4 " h" h-4 " background111111")
}

onMessage(0x47,WM_WINDOWPOSCHANGED)
WM_LBUTTONDOWN(wparam,lparam,msg,hwnd) {
	if hwnd == wparam.hwnd
		postMessage("0xA1",2,,,"A")
}

WM_LBUTTONDOWN_callback(this_control*) {
	postMessage("0xA1",2,,,"A")
	;WM_LBUTTONDOWN(0,0,0,this_control)
}

WM_WINDOWPOSCHANGED(wParam, lParam, msg, Hwnd) {
	try {
		(hwnd == ui.fishGui.hwnd)
			? moveFP()
			: 0
	}	catch {
		return 0
	}
	moveFP(*) {
		
			winGetPos(&x,&y,&w,&h,ui.fishGui)
			winMove(x+300,y+30,,,ui.game)
			return 1
	}
}

