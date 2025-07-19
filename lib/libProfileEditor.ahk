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



profileEditor(*) {
	global
		ui.editorGui:=gui()
;		ui.editorGui.opt("-caption toolWindow alwaysOnTop owner" winGetId(ui.game))
		ui.editorGui.opt("-caption -BORDER toolWindow owner" winGetId(ui.game))
		ui.editorGui.name:="editorGui"
		ui.editorGui.backColor:=ui.bgColor[3]
		ui.editorGui.color:=ui.bgColor[3]
		ui.editorGui.addText("x1 y1 w598 h840 background" ui.bgColor[3])
		ui.editorTitleBar := ui.editorGui.addText("x2 y2 w440 h28 background" ui.bgColor[3])
		ui.editorTitleBar.onEvent("click",wm_lbuttonDown_callback)
		ui.editorTitleBarText := ui.editorGui.addText("x5 y3 w430 h26 backgroundTrans c" ui.fontColor[2],"Profile Editor  (fpAssist v" a_fileVersion ")")
		ui.editorTitleBarText.setFont("s14 bold","calibri")
		ui.editorLogSaveBg := ui.editorGui.addText("x442 y2 w30 h28 background" ui.bgColor[3])
		ui.editorLogSaveBg.onEvent("click",saveLog)
		ui.editorLogSave := ui.editorGui.addPicture("x444 y4 w26 h25 backgroundTrans","./img/button_save.png")
		ui.editorLogSave.onEvent("click",saveLog)
		ui.editorCloseBg := ui.editorGui.addText("x471 y2 w30 h28 background" ui.bgColor[3])
		ui.editorCloseBg.onEvent("click",closeeditor)
		ui.editorClose := ui.editorGui.addPicture("x473 y4 w25 h24 background" ui.bgColor[3],"./img/button_cancel.png")
		ui.editorClose.onEvent("click",closeeditor)


		cp := object()
		cp.x := 5
		cp.y := 70
		cp.w := 412
		cp.h := 56
		cp.wCol1 := 122
		cp.wCol2 := 117
		cp.wCol3 := 118
		cp.wCol4 := 89

		;drawButton(1,753,395,60)
		;drawButton(398,753,264,60)
		ui.fs_profileBg0 := ui.editorGui.addText("x2 y30 w446 h30 background" ui.bgColor[3])
		ui.fs_profileBg := ui.editorGui.addText("x2 y137 w499 h64 background" ui.bgColor[4])
		profilePos := map("x",0,"y",35,"w",499,"h",28)
		ui.fs_profileBg := ui.editorGui.addText("x" profilePos["x"]+2 " y" profilePos["y"]-4 " w" profilePos["w"] " h" profilePos["h"]+8 " background" ui.bgColor[3])
		ui.fs_profileBg2 := ui.editorGui.addText("x" profilePos["x"]+3 " y" profilePos["y"]-3 " w" profilePos["w"]-30 " h" profilePos["h"]+6 " background" ui.bgColor[3])
		ui.fs_profileBg3 := ui.editorGui.addText("x4 y32 w496 h34 background" ui.bgColor[3])
		ui.fs_profileBg4 := ui.editorGui.addText("x3 y138 w497 h62 background" ui.bgColor[6])
		ui.fs_profileLArrow := ui.editorGui.addPicture("x" profilePos["x"]+5 " y" profilePos["y"]+3 " w20 h23 backgroundTrans","./img/button_arrowLeft_knot.png")
		ui.fs_profileRArrow := ui.editorGui.addPicture("x" (profilePos["x"]+30)+(profilePos["w"]-50) " y" profilePos["y"]+3 " w20 h23 backgroundTrans","./img/button_arrowRight_knot.png")
		ui.fs_profileLArrow.onEvent("click",profileLArrowClicked)
		ui.fs_profileRArrow.onEvent("click",profileRArrowClicked)
		ui.fs_profileText := ui.editorGui.addText("x" profilePos["x"]+30 " y" profilePos["y"]+4 " w446 h20 c" ui.fontColor[2] " center background" ui.bgColor[5])
		ui.fs_profileText.text := cfg.profileName[cfg.profileSelected]
		ui.fs_profileIcon := ui.editorGui.addPicture("hidden x410 y765 w230 h42 backgroundCC3355","")
		ui.fs_profileTextOutline1 := ui.editorGui.addText("x" profilePos["x"]+29 " y" profilePos["y"]+3 " w1 h22 background" ui.fontColor[2])
		ui.fs_profileTextOutline2 := ui.editorGui.addText("x" profilePos["x"]+29 " y" profilePos["y"]+24 " w446 h1 background" ui.fontColor[2])
		ui.fs_profileTextOutline1 := ui.editorGui.addText("x" profilePos["x"]+29 " y" profilePos["y"]+3 " w446 h1 background" ui.fontColor[2])
		ui.fs_profileTextOutline2 := ui.editorGui.addText("x" profilePos["x"]+475 " y" profilePos["y"]+3 " w1 h22 background" ui.fontColor[2])
		ui.fs_profileText.setFont("s12","calibri")
		profileNumStr := ""
		ui.fs_profileNum := ui.editorGui.addText("x" profilePos["x"]+80 " y" profilePos["y"]+29 " right w160 h20 backgroundTrans c" ui.bgColor[5],profileNumStr)
		ui.fs_profileNum.setFont("s13 c" ui.fontColor[2],"courier new")
		
		ui.fs_CastLength := ui.editorGui.addSlider("section toolTip background" ui.bgColor[3] " buddy2ui.ui.editorCastLengthText altSubmit center x" cp.x+65 " y" 71 " w176 h16  range1000-2500",1910)
		ui.fs_castLength.onEvent("change",editorCastLengthChanged)
		ui.fs_CastLengthLabel := ui.editorGui.addText("xs-3 y+5 w40 h13 right backgroundTrans","Cast")
		ui.fs_CastLengthLabel.setFont("s8 c" ui.fontColor[2])
		ui.fs_CastLengthLabel2 := ui.editorGui.addText("xs-3 y+-3 w40 h20 right backgroundTrans","Length")
		ui.fs_CastLengthLabel2.setFont("s8 c" ui.fontColor[2])
		ui.fs_CastLengthText := ui.editorGui.addText("x+0 ys+18 left w70 h32 backgroundTrans c" ui.fontColor[2])
		while cfg.profileSelected > cfg.castLength.Length
			cfg.castLength.push("2000")
		ui.fs_CastLengthText.text := cfg.castLength[cfg.profileSelected]
		ui.fs_CastLength.value := cfg.castLength[cfg.profileSelected]
		ui.fs_CastLengthText.setFont("s18")
		
		slider("ReelSpeed",ui.editorGui,6+cp.x,cp.y-3,20,62,"1-4",1,1,"left","Reel","vertical","b",)
		slider("dragLevel",ui.editorGui,33+cp.x,cp.y-3,20,62,"1-12",1,1,"center","Drag","vertical","b",)
		slider("landAggro",ui.editorGui,306+cp.x,cp.y-1,120,15,"0-4",1,1,"center","Land Aggro",,,)
		slider("twitchFreq",ui.editorGui,306+cp.x,cp.y+18,120,17,"0-10",1,1,"center","Twitch",,,)
		slider("stopFreq",ui.editorGui,306+cp.x,cp.y+40,120,15,"0-10",1,1,"center","Stop && Go",,,)
		slider("castTime",ui.editorGui,248+cp.x,cp.y-3,20,62,"0-6",1,1,"center","Cast","vertical","b",)
		slider("sinkTime",ui.editorGui,275+cp.x,cp.y-3,20,62,"0-20",1,1,"center","Sink","vertical","b",)
		slider("recastTime",ui.editorGui,102+cp.x,cp.y+43,139,13,"1-20",1,1,"center","Recast",,"l","11")
		slider("reelFreq",ui.editorGui,1900+cp.x,cp.y+0,0,0,"0-10",1,10,"center","Reel",,,)
		
		ui.%ui.editorGui.name%_reelFreq.value := 10
		ui.%ui.editorGui.name%_reelFreq.opt("hidden")

		while cfg.keepnetEnabled.length < cfg.profileSelected
			cfg.keepnetEnabled.push(false)
			
		ui.fs_keepnetEnabled := ui.editorGui.addCheckBox("x230 y" cp.y+20 " w10 h15 background" ui.bgColor[3],cfg.keepnetEnabled[cfg.profileSelected])
		ui.fs_keepnetEnabled.onEvent("click",toggleKeepnet)
		ui.fs_keepnetEnabledLabel := ui.editorGui.addText("right x164 y" cp.y+22 " w60 h15 backgroundTrans c" ui.fontColor[2],"Keepnet")
		ui.fs_keepnetEnabledLabel.setFont("s7","small fonts")
		
		ui.fs_floatEnabled := ui.editorGui.addCheckBox("x230 y" cp.y+32 " w10 h15 background" ui.bgColor[3],cfg.floatEnabled[cfg.profileSelected])
		ui.fs_floatEnabled.onEvent("click",toggleFloat)
		ui.fs_floatEnabledLabel := ui.editorGui.addText("right x164 y" cp.y+33 " w60 h15 backgroundTrans c" ui.fontColor[2],"Bottom")
		ui.fs_floatEnabledLabel.setFont("s7","small fonts")
		
		toggleFloat(*) {
			while cfg.floatEnabled.length < cfg.profileSelected
				cfg.floatEnabled.push(false)
			cfg.floatEnabled[cfg.profileSelected] := ui.fs_floatEnabled.value
			ui.fs_floatEnabledStr := ""
			if ui.fs_floatEnabled.value
				ui.fs_keepnetEnabled.opt("-disabled")
			else {
				ui.fs_keepnetEnabled.value:=false
				ui.fs_keepnetEnabled.opt("disabled")
			}
		}

		toggleKeepnet(*) {
			while cfg.keepnetEnabled.length < cfg.profileSelected
				cfg.keepnetEnabled.push(false)
			cfg.keepnetEnabled[cfg.profileSelected] := ui.fs_keepnetEnabled.value
		}
		
		bgModeChanged(*) {
			while cfg.profileSelected > cfg.bgModeEnabled.Length
				cfg.bgModeEnabled.push(bgModeEnabled.value)
			cfg.bgModeEnabled[cfg.profileSelected] := bgModeEnabled.value
		}
		cp := object()
		cp.x := 5
		cp.y := 140
		cp.w := 442
		cp.h := 56
		cp.wCol1 := 122
		cp.wCol2 := 117
		cp.wCol3 := 118
		cp.wCol4 := 89
		
		;drawButton(cp.x+9,+9,121,60)
		startButtonBg := ui.editorGui.addText("x" cp.x " y" cp.y+1 " w131 h56 background" ui.bgColor[2])
		startButton := ui.editorGui.addText("section center x" cp.x+4 " y" cp.y " w120 h60 c" ui.fontColor[2] " backgroundTrans","A&FK")
		startButton.setFont("s34 bold","Trebuchet MS")
		startButton.onEvent("click",startButtonClicked)
		startButtonHotkey := ui.editorGui.addText("x+-665 ys-2 w40 h20 c" ui.fontColor[4] " backgroundTrans","[Shift-F]")
		startButtonHotkey.setFont("s7","Palatino Linotype")
		startButtonStatus := ui.editorGui.addPicture("x" cp.x+98 " y775 w26 h14 backgroundTrans")
		;drawButton(cp.x+32,cp.y-2,105,29)
		castButtonBg := ui.editorGui.addText("x" cp.x+134 " y" cp.y+1 " w103 h27 background" ui.bgColor[2])
		castButton := ui.editorGui.addText("section x" cp.x+138 " center y" cp.y " w96 h26 c" ui.fontColor[2] " backgroundTrans","&Cast")
		castButton.setFont("s14 bold","Trebuchet MS")
		; ui.castButtonHotkey0 := ui.editorGui.addText("x+-26 ys-10 w40 h30 c" ui.trimDarkFontColor[1] " backgroundTrans","[    ]")
		; ui.castButtonHotkey0.setFont("s14","Palatino Linotype")	
		castButtonHotkey := ui.editorGui.addText("x+-12 ys+10 w40 h20 c" ui.fontColor[4] " backgroundTrans","")
		castButtonHotkey.setFont("s6","Small Fonts")	
		; ui.castButtonHotkey2 := ui.editorGui.addText("x+-34 ys+0 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","C")
		; ui.castButtonHotkey2.setFont("s8","Palatino Linotype")	
		castButton.onEvent("click",castButtonClicked)
		castButtonBg.onEvent("click",castButtonClicked)
		;drawButton(cp.x+32,cp.y+29,105,29)
		reelButtonBg := ui.editorGui.addText("x" cp.x+134 " y" cp.y+30 " w103 h27 background" ui.bgColor[2])
		reelButton := ui.editorGui.addText("section x" cp.x+134 " center y" cp.y+31 " w105 h26 c" ui.fontColor[2] " backgroundTrans","&Reel")
		reelButton.setFont("s14 bold","Trebuchet MS")

		
		reelButtonHotkey := ui.editorGui.addText("x+-17 ys+2 w40 h20 c" ui.fontcolor[4] " backgroundTrans","")
		reelButtonHotkey.setFont("s6","Small Fonts")	
		reelButton.onEvent("click",reelButtonClicked)
		reelButtonBg.onEvent("click",reelButtonClicked)
		;drawButton(cp.x+239,cp.y-2,124,29)
		retrieveButtonBg := ui.editorGui.addText("x" cp.x+240 " y" cp.y+1 " w125 h27 background" ui.bgColor[2])
		retrieveButton := ui.editorGui.addText("section x" cp.x+243 " center y" cp.y+1 " w113 h26 c" ui.fontColor[2] " backgroundTrans","Retrie&ve")
		retrieveButton.setFont("s14 bold","Trebuchet MS")
		retrieveButtonHotkey := ui.editorGui.addText("x+-113 ys+9 w40 h20 c" ui.fontColor[4] " backgroundTrans","")
		retrieveButtonHotkey.setFont("s6","Small Fonts")	
		retrieveButtonBg.onEvent("click",retrieveButtonClicked)
		retrieveButton.onEvent("click",retrieveButtonClicked)
		;drawButton(cp.x+241,cp.y+29,124,29)
		cancelButtonBg := ui.editorGui.addText("x" cp.x+240 " y" cp.y+30 " w125 h27 background" ui.bgColor[2]) 
		cancelButton := ui.editorGui.addText("section x" cp.x+246 " center y" cp.y+32 " w113 h26 c" ui.FontColor[2] " backgroundTrans","Cancel")
		cancelButton.setFont("s14 bold","Trebuchet MS")
		cancelButtonHotkey := ui.editorGui.addText("x+-122 ys+2 w40 h20 c" ui.fontColor[4] " backgroundTrans","")
		cancelButtonHotkey.setFont("s6","Small Fonts")
		cancelButtonBg.onEvent("click",stopButtonClicked)
		cancelButton.onEvent("click",stopButtonClicked)
		;drawButton(1457,753,94,19)
		reloadButtonBg := ui.editorGui.addText("x" cp.x+368 " y" cp.y+1 " w92 h19 background" ui.bgColor[2])
		reloadButton := ui.editorGui.addText("section x" cp.x+371 " center y" cp.y-2 " w85 h19 c" ui.FontColor[2] " backgroundTrans","Reload")
		reloadButton.setFont("s14 Bold","Trebuchet MS")	
		reloadButtonHotkey := ui.editorGui.addText("x+-12 ys+0 w40 h20 c" ui.fontColor[4] " backgroundTrans","")
		reloadButtonHotkey.setFont("s7","Palatino Linotype")	
		reloadButton.onEvent("click",appReload)
		reloadButtonBg.onEvent("click",appReload)
		;drawButton(cp.x+365,cp.y+19,94,39)
		exitButtonBg := ui.editorGui.addText("x" cp.x+368 " y" cp.y+22 " w92 h36 background" ui.bgcolor[2])
		exitButton := ui.editorGui.addText("section x" cp.x+371 " center y" cp.y+22 " w85 h39 c" ui.fontColor[2] " backgroundTrans","Exit")
		exitButton.setFont("s20 Bold","Trebuchet MS")	
		exitButtonHotkey := ui.editorGui.addText("x+-12 ys-1 w40 h30 c" ui.fontColor[4] " backgroundTrans","")
		exitButtonHotkey.setFont("s7","Palatino Linotype")	
		exitButton.onEvent("click",cleanExit)
		exitButtonBg.onEvent("click",cleanExit)
		;drawButton(461+cp.x,cp.y-2,28,60)	
		debugToggle := ui.editorGui.addPicture("x" cp.x+468 " y" cp.y+23 " w18 h33 backgroundTrans c" ui.fontColor[2],(cfg.debug:=iniRead(cfg.file,"Game","Debug",false)) ? "./img/toggle_on.png" : "./img/toggle_off.png")
		debugToggleLabel := ui.editorGui.addText("x" cp.x+463 " y" cp.y " w28 h20 center backgroundTrans c" ui.BGColor[2],"Debug`nMode")
		debugToggleLabel.setFont("s6","Small Fonts")
		;debugToggle.onEvent("click", () => ((cfg.debug:=!cfg.debug) ? debugToggle.value("./img/toggle_on.png") : debugToggle.value("./img/toggle_off.png")))
		
	
		shiftHotkeyBg := ui.editorGui.addText("x+-267 ys+0 w32 h15 c" ui.fontColor[4] " background" ui.fontColor[2])
		shiftHotkeyBg2 := ui.editorGui.addText("x+-31 y+-14 w30 h13 c" ui.fontColor[4] " background" ui.fontColor[2])
		shiftHotkey := ui.editorGui.addText("center x+-30 y+-16 w30 h15 c" ui.fontColor[4] " backgroundTrans","Shift")
		shiftHotkey.setFont("s10","Palatino Linotype")	
		
		
		guiVis(ui.editorGui,false)
		winGetPos(&tX,&tY,&tW,&tH,ui.editorGui.hwnd)
		ui.editorGui.show("x" tX+40+tW+8 " y" tY+20 " w503 h138")
		drawOutline(ui.editorGui,0,0,503,138,ui.bgColor[6],ui.bgColor[6],1)
		;ui.fs_profileEditButton.focus()
}
ui.editorVisible:=false
toggleEditor(*) {
	ui.editorVisible:= !ui.editorVisible
	if ui.editorVisible {
		showEditor()
	} else {
		closeEditor()
	}
	
}


closeeditor(*) {
			ui.editorGui.hide()
		}

showEditor(*) {
	; winGetPos(&tX,&tY,&tW,&tH,ui.game)
	; if monitorGetCount() > 1 {
		; winGetPos(&gX,&gY,&gW,&gH,ui.game)
	
		; monitorGetWorkArea(monitorGetPrimary(),&gmL,&gmT,&gmR,&gmB)
		; msgBox(gX+gW "`n" sysGet("78"))
		; if gX+gW==sysGet("78") {
			; monitorGetWorkArea(monitorGetPrimary()-1,&lmL,&lmT,&lmR,&lmB)
			; editorX:=sysGet("78")-(a_screenwidth+600)
			; editorY:=lmT
		; } else {
			; monitorGetWorkArea(monitorGetPrimary()+1,&lmL,&lmT,&lmR,&lmB)
			; editorX:=gmR
			; editorY:=lmT
		; }
	; }
	; if monitorGetCount() > 1 {
		; vdLeft:=sysGet("76")
		; vdWidth:=sysGet("78")
		; vdRight:=vdLeft+vdWidth

		; winGetPos(&gX,&gY,&gW,&gH,ui.game)
		; if gX+gW+600 > vdRight {
			; editorX:=gX-600
			; monitorGet(monitorGetPrimary()-1,&lmL,&lmT,&lmR,&lmB)
			; editorY:=lmT
		; } else {
			; editorX:=gX+gW
			; monitorGet(monitorGetPrimary()+1,&lmL,&lmT,&lmR,&lmB)
			; editorY:=lmT
		; }
		; } else {
	
	
	
	monitorGetWorkArea(monitorGetPrimary(),&mL,&mT,&mR,&mB)
	editorX:=mR-700
	; ui.editorGui.show("x" editorX " y" editorY)
	
	editorY:=-30
	ui.fishLogFS.focus()
	winSetTransparent(0,ui.editorGui)
	ui.editorGui.show("x" editorX " y" editorY)
	winSetRegion("0-67 w502 h160",ui.editorGui)
	transLevel:=0
	while transLevel < 240 {
		transLevel+=10
		sleep(10)
		winSetTransparent(transLevel,ui.editorGui)
	}
	winSetTransparent("off",ui.editorGui)
	

; editorX:=0
		; editorY:=0
	;}
	; loop monitorGetCount {
		; monitorGet(a_index,&thisLeft,&thisTop,&thisRight,&thisBottom)
		; txt.=thisLeft ":" thisTop ":" thisRight ":" thisBottom "`n"
	; }
	; msgBox(txt)
	
	;guiVis(ui.editorGui,true)
	;guiVis(ui.fishGuiFS,true)
	;guiVis(ui.fishGui,false)
}




