#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off


if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

 goFS(*) {
	fishGuiFSx := a_screenWidth-900
	fishGuiFSy := a_screenHeight-30-200
	; ui.fishGuiBg := gui()
	; ui.fishGuiBg.opt("-caption -border toolwindow alwaysOnTop owner" winGetId(ui.game))
	; ui.fishGuiBg.backColor := 656565
	; ui.fishGuiBg.addText("x0 y0 w500 h500 background656565")
	; winSetTransparent(150,ui.fishGuiBg)
	; ui.fishGuiBg.show("x95 y350 w360 h450 noactivate")
	
	ui.fullscreen := true
	ui.fishGui.hide()
	ui.fishGuiFS := gui()


	ui.fishGuiFS.opt("-caption -border +toolWindow alwaysOnTop owner" winGetId(ui.game))
	ui.fishGuiFS.backColor := "010203"
	winSetTransColor("010203",ui.fishGuiFS.hwnd)
	ui.noFSbutton := ui.fishGuiFS.addPicture("x" a_screenWidth-70 " y10 w60 h60 backgroundTrans","./img/button_nofs.png")
	ui.noFSbutton.onEvent("click",noFS)
	ui.FishCaughtFS := ui.fishGuiFS.addText("x" fishGuiFSx+130-30 " y" fishGuiFSy+20 " w250 h300 backgroundTrans c" ui.fontColor[3],format("{:03i}","0"))
	ui.FishCaughtFS.setFont("s94")
	ui.FishCaughtLabelFS := ui.fishGuiFS.addText("right x" fishGuiFSx-98-30 " y" fishGuiFSy+20+8 " w200 h80 backgroundTrans c" ui.fontColor[3],"Fish")
	ui.FishCaughtLabelFS.setFont("s54","Calibri")
	ui.FishCaughtLabel2FS := ui.fishGuiFS.addtext("right x" fishGuiFSx-90-30 " y" fishGuiFSy+20+40 " w200 h90 backgroundTrans c" ui.fontColor[3],"Count")
	ui.FishCaughtLabel2FS.setFont("s60","Calibri")
	ui.fishLogFS := ui.fishGuiFS.addText("x95 y350 w360 h450 backgroundTrans c" ui.fontColor[3],"")
	ui.fishLogFS.setFont("s16")
	ui.fishGuiFS.show("x0 y0 w" a_screenWidth " h" a_screenHeight-30)
	winMove(0,0,a_screenWidth,a_screenHeight-30,ui.game)
	

}

noFS(*) {
	winGetPos(&x,&y,&w,&h,ui.fishGui)
	winMove(x+300,y+30,1280,720,ui.game)
	ui.fishGui.show()

	;ui.fishGuiFS.hide()
}
drawButton(x,y,w,h) {
		ui.fishGui.addText("x" x " y" y " w" w " h" h " background" ui.bgColor[3])
		ui.fishGui.addText("x" x+1 " y" y+1 " w" w-2 " h" h-2 " background" ui.bgColor[1])
		;ui.fishGui.addText("x" x+2 " y" y+2 " w" w-4 " h" h-4 " background" ui.bgColor[1])
}

statPanel(*) {
	ui.sessionStartTime := a_now
	ui.afkStartTime := a_now
	
	ui.statCoord := map("x",664,"y",753,"w",435,"h",60)
	x := ui.statCoord["x"] + 8
	y := ui.statCoord["y"] + 4
	w := ui.statCoord["w"]
	h := ui.statCoord["h"]


	ui.fishGui.setFont("s10")
	ui.statPanelBg := ui.fishGui.addText("x" ui.statCoord["x"] " y" ui.statCoord["y"] " w" ui.statCoord["w"] " h" ui.statCoord["h"] " background" ui.bgColor[3])
	ui.statPanelOutline := ui.fishGui.addText("x" ui.statCoord["x"]+1 " y" ui.statCoord["y"]+1 " w" ui.statCoord["w"]-2 " h" ui.statCoord["h"]-2 " background111111")
	ui.statPanelOutline2 := ui.fishGui.addText("x" ui.statCoord["x"]+2 " y" ui.statCoord["y"]+2 " w" ui.statCoord["w"]-4 " h" ui.statCoord["h"]-4 " background" ui.bgColor[1])
	;msgBox(ui.statCoord["w"])
	
	x-=20
	y-=3
	ui.statSessionStartTimeLabel := ui.fishGui.addText("x" 7+x " y" 5+y " right section w80 r1 backgroundTrans c" ui.fontColor[2],"Session: ")
	ui.statSessionStartTime := ui.fishGui.addText("x+0 ys w130 r1 backgroundTrans c" ui.fontColor[2],formatTime(,"yyyy-MM-dd@hh:mm:ss"))
	
	ui.statCastLengthLabel := ui.fishGui.addText("x+-15 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Cast: ")
	ui.statCastLength := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2],ui.castLength.value)
	
	ui.statFishCountLabel := ui.fishGui.addText("x+-35 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Fish Count: ")
	ui.statFishCount := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2], ui.fishLogCount.text)
	
	ui.statAfkStartTimeLabel := ui.fishGui.addText("xs-320 y+0 right section w80 r1 backgroundTrans c" ui.fontColor[2],"Start: ")
	ui.statAfkStartTime := ui.fishGui.addText("x+0 ys w130 r1 backgroundTrans c" ui.fontColor[2],formatTime(,"yyyy-MM-dd@HH:mm:ss"))
	
	ui.statDragLevelLabel := ui.fishGui.addText("x+-15 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Drag: ")
	ui.statDragLevel := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2],ui.dragLevel.value)
	
	ui.statCastCountLabel := ui.fishGui.addText("x+-35 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Cast Count: ")
	ui.statCastCount := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2], "000")
	
	ui.statAfkDurationLabel := ui.fishGui.addText("xs-320 y+0 right section w80 r1 backgroundTrans c" ui.fontColor[2],"Duration: ")
	ui.statAfkDuration := ui.fishGui.addText("x+0 ys w130 r1 background" ui.bgColor[1] " c" ui.fontColor[2],"")
	
	ui.statReelSpeedLabel := ui.fishGui.addText("x+-15 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Speed: ")
	ui.statReelSpeed := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2],ui.reelSpeed.value)
	
	ui.viewLog := ui.fishGui.addText("x+-35 ys right section w55 r1 backgroundTrans c" ui.fontColor[2],"View Log")
	ui.viewLog.setFont("s9 underline")
	ui.viewLog.onEvent("click",viewLog)
	
	viewLog(*) {
		run("notepad.exe " a_scriptDir "/logs/current_log.txt")
	}
	

	
}

; statPanelFS(*) {
	; ui.sessionStartTimeFS := a_now
	; ui.afkStartTimeFS := a_now
	
	; ui.statCoordFS := map("x",664,"y",753,"w",435,"h",60)
	; x := ui.statCoord["x"] + 8
	; y := ui.statCoord["y"] + 4
	; w := ui.statCoord["w"]
	; h := ui.statCoord["h"]



	; ui.statPanelBgFS := ui.fishGuiFS.addText("x" ui.statCoordFS["x"] " y" ui.statCoordFS["y"] " w" ui.statCoordfS["w"] " h" ui.statCoordFS["h"] " background" ui.bgColor[3])
	; ui.statPanelOutlineFS := ui.fishGuiFS.addText("x" ui.statCoordfS["x"]+1 " y" ui.statCoordFS["y"]+1 " w" ui.statCoordfS["w"]-2 " h" ui.statCoordFS["h"]-2 " background111111")
	; ui.statPanelOutline2FS := ui.fishGuiFS.addText("x" ui.statCoordFS["x"]+2 " y" ui.statCoordFS["y"]+2 " w" ui.statCoordFS["w"]-4 " h" ui.statCoordfS["h"]-4 " background" ui.bgColor[1])
	;msgBox(ui.statCoord["w"])
	
	; ui.statSessionStartTimeLabelFS := ui.fishGuiFS.addText("x" 7+x " y" 5+y " right section w100 r1 backgroundTrans c" ui.fontColor[3],"Session: ")
	; ui.statSessionStartTimeFS := ui.fishGuiFS.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],formatTime(,"yyyyMMdd HH:mm:ss"))
	
	; ui.statCastLengthLabelFS := ui.fishGuiFS.addText("x+30 ys right section w100 r1 backgroundTrans c" ui.fontColor[3],"Cast: ")
	; ui.statCastLengthFS := ui.fishGuiFS.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],cfg.castLength[cfg.profileSelected])
	
	; ui.statFishCountLabelFS := ui.fishGuiFS.addText("x+10 ys right section w100 r1 backgroundTrans c" ui.fontColor[3],"Fish Count: ")
	; ui.statFishCountFS := ui.fishGuiFS.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3], ui.fishLogCount.text)
	
	; ui.statAfkStartTimeLabelFS := ui.fishGuiFS.addText("xs-333 y+0 right section w100 r1 backgroundTrans c" ui.fontColor[3],"AutoFish: ")
	; ui.statAfkStartTimeFS := ui.fishGuiFS.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],formatTime(,"yyyyMMdd HH:mm:ss"))
	
	; ui.statDragLevelLabelFS := ui.fishGuiFS.addText("x+30 ys right section w63 r1 backgroundTrans c" ui.fontColor[3],"Drag: ")
	; ui.statDragLevelFS := ui.fishGuiFS.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],cfg.dragLevel[cfg.profileSelected])
	
	; ui.statCastCountLabelfS := ui.fishGuiFS.addText("x+10 ys right section w55 r1 backgroundTrans c" ui.fontColor[3],"Cast Count: ")
	; ui.statCastCountFS := ui.fishGuiFS.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3], ui.castCount)
	
	; ui.statAfkDurationLabelfS := ui.fishGuiFS.addText("xs-333 y+0 right section w100 r1 backgroundTrans c" ui.fontColor[3],"AFK Duration: ")
	; ui.statAfkDurationFS := ui.fishGuiFS.addText("x+0 ys w60 r1 background" ui.bgColor[1] " c" ui.fontColor[3],"")
	
	; ui.statReelSpeedLabelFS := ui.fishGuiFS.addText("x+10 ys right section w100 r1 backgroundTrans c" ui.fontColor[3],"Speed: ")
	; ui.statReelSpeedFS := ui.fishGuiFS.addText("x+0 ys w60 r1 backgroundTrans c" ui.fontColor[3],cfg.reelSpeed[cfg.profileSelected])
	
	; ui.viewLogFS := ui.fishGuiFS.addText("x+10 ys right section w55 r1 backgroundTrans c" ui.fontColor[3],"View Log")
	; ui.viewLogFS.setFont("s9 underline")
	; ui.viewLogFS.onEvent("click",viewLog)
	
; viewLog(*) {
		; run("notepad.exe " a_scriptDir "/logs/current_log.txt")
	; }
	

	
; }



startupProgress(*) {
	try {
		ui.loadingProgress.value += 1
 		ui.loadingProgress2.value += 1
		
		if ui.loadingProgress.value >= 100 {
		
			setTimer(startupProgress,0)
		}
	}
	
}

startupProgress0(*) {
	try {
		ui.loadingProgress.value += 1
		ui.loadingProgress2.value += 1
		if ui.loadingProgress.value >= 20 {
			setTimer(startupProgress0,0)
		}
	}
	
}
startupProgress2(*) {
	try {
		ui.loadingProgress.value += 2
		ui.loadingProgress2.value += 2
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
		ui.notifyGui.BackColor := ui.bgColor[3] ; Can be any RGB color (it will be made transparent below).
		ui.notifyGui.SetFont("s30 bold")  ; Set a large font size (32-point).
		;if a_isCompiled 
		ui.notifyGui.addPicture("x0 y0 w1582 h812","./img/fp_splash.png")
		; else
			; ui.notifyGui.addPicture("x0 y0 w1580 h780","./img/fp_splash.png")
		;ui.notifyGui.AddText("x" (1580/2)-100 " y" (810/2) " c252525 center BackgroundTrans","Please Wait")  ; XX & YY serve to 00auto-size the window.
		;ui.notifyGUi.addText("xs+1 y+1 w302 h22 background959595")
		ui.loadingProgress := ui.notifyGui.addProgress("smooth x2 y757 w1580 h57 c202020 background404040")
		ui.loadingProgress.value := 0
		if winExist(ui.game) {
			setTimer(startupProgress,32)
		} else {
			setTimer(startupProgress0,200)
		}
		ui.loadingProgress2 := ui.notifyGui.addProgress("smooth x2 y755 w1580 h2 c707070 background404040")
		ui.loadingProgress2.value := 0
		if winExist(ui.game) {
			setTimer(startupProgress,32)
		} else {
			setTimer(startupProgress0,200)
		}

		;setTimer(loadingProgressStep,100)
		ui.notifyGui.AddText("xs hidden")

		ui.notifyGui.show("x0 y0 w1584 h816 noActivate")
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
			winActivate(ui.game)
			setTimer () => detectPrompts(1),-3000
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
		try
			winGetPos(&x,&y,&w,&h,ui.fishGui)
		try
			winMove(x+(301*(a_screenDpi/96)),y+(31*(a_screenDpi/96)),,,ui.game)
		try
			winMove(x+1101,y+753,,,ui.disabledGui) 
		try
			winMove(x+427,y+762,,,ui.editProfileGui)		
	
}


cancelButtonOn(*) {
	ui.cancelButtonBg.opt("background" ui.trimColor[2])
	ui.cancelButtonBg.redraw()
	ui.cancelButton.setFont("c" ui.trimFontColor[2])
	ui.cancelButton.redraw()
	ui.cancelButtonHotkey.setFont("c" ui.trimFontColor[2])
	ui.cancelButtonHotkey.redraw()
}

cancelButtonOff(*) {
	ui.cancelButtonBg.opt("background" ui.trimDarkColor[2])
	ui.cancelButtonBg.redraw()
	ui.cancelButton.setFont("c" ui.trimDarkFontColor[2])
	ui.cancelButton.redraw()
	ui.cancelButtonHotkey.setFont("c" ui.trimDarkFontColor[2])
	ui.cancelButtonHotkey.redraw()
}

startButtonOff(*) {
	ui.startButtonBg.opt("background" ui.trimDarkColor[1])
	ui.startButtonBg.redraw()
	ui.startButton.setFont("c" ui.trimDarkFontColor[1])
	ui.startButton.redraw()
	ui.startButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	ui.startButton.redraw()
}

startButtonOn(*) {
	ui.startButtonBg.opt("background" ui.trimColor[1])
	ui.startButtonBg.redraw()
	ui.startButton.setFont("c" ui.trimFontColor[1])
	ui.startButton.redraw()
	ui.startButtonHotkey.setFont("c" ui.trimFontColor[1])
	ui.startButton.redraw()
	cancelButtonOn()
}

castButtonOn(*) {
	ui.castButtonBg.opt("background" ui.trimColor[1])
	ui.castButtonBg.redraw()
	ui.castButton.setFont("c" ui.trimFontColor[1])
	ui.castButton.redraw()
	ui.castButtonHotkey.setFont("c" ui.trimFontColor[1])
	ui.castButton.redraw()
	cancelButtonOn()
}

castButtonOff(*) {
	ui.castButtonBg.opt("background" ui.trimDarkColor[1])
	ui.castButtonBg.redraw()
	ui.castButton.setFont("c" ui.trimDarkFontColor[1])
	ui.castButtonBg.redraw()
	ui.castButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	ui.castButtonHotkey.redraw()
}
	
reelButtonOn(*) {
		ui.reelButtonBg.opt("background" ui.trimColor[1])
		ui.reelButtonBg.redraw()
		ui.reelButton.setFont("c" ui.trimFontColor[1])
		ui.reelButton.redraw()
		ui.reelButtonHotkey.setFont("c" ui.trimFontColor[1])
		ui.reelButtonHotkey.redraw()	
		cancelButtonOn()
}

reelButtonOff(*) {
	ui.reelButtonBg.opt("background" ui.trimDarkColor[1])
	ui.reelButtonBg.redraw()
	ui.reelButton.setFont("c" ui.trimDarkFontColor[1])
	ui.reelButton.redraw()
	ui.reelButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	ui.reelButtonHotkey.redraw()
}

retrieveButtonOn(*) {
	ui.retrieveButtonBg.opt("background" ui.trimColor[1])
	ui.retrieveButtonBg.redraw()
	ui.retrieveButton.setFont("c" ui.trimFontColor[1])
	ui.retrieveButton.redraw()
	ui.retrieveButtonHotkey.setFont("c" ui.trimFontColor[1])
	ui.retrieveButtonHotkey.redraw()
	cancelButtonOn()
}

retrieveButtonOff(*) {
	ui.retrieveButtonBg.opt("background" ui.trimDarkColor[1])
	ui.retrieveButtonBg.redraw()
	ui.retrieveButton.opt("c" ui.trimDarkFontColor[1])
	ui.retrieveButton.redraw()
	ui.retrieveButtonHotkey.opt("c" ui.trimDarkFontColor[1])
	ui.retrieveButtonHotkey.redraw()
}
