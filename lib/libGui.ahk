#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off


if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

createGui() {
	while cfg.profileSelected > cfg.profileName.Length
		cfg.profileName.push("Profile #" cfg.profileName.length+1)
	ui.fishGui := gui()
	ui.fishGui.opt("-caption owner" winGetId(ui.game))
	ui.fishGui.backColor := ui.bgColor[4]
	ui.fishGui.color := ui.fontColor[2]
	winSetTransColor("010203",ui.fishGui.hwnd)
	ui.appFrame := ui.fishGui.addText("x300 y32 w1281 h720 c" ui.fontColor[3] " background" ui.bgColor[3])
	ui.appFrame2 := ui.fishGui.addText("x301 y33 w1279 h718 c" ui.fontColor[1] " background" ui.bgColor[2])
	ui.fpBg := ui.fishGui.addText("x302 y34 w1277 h716 c010203 background010203")
	ui.titleBarOutline := ui.fishGui.addText("x299 y0 w1282 h30 background" ui.bgColor[1])
	ui.titleBarOutline2 := ui.fishGui.addText("x300 y1 w1281 h30 background" ui.bgColor[3])
	ui.titleBarOutline3 := ui.fishGui.addText("x301 y2 w1279 h28 background" ui.bgColor[1])
	ui.titleBarOutline4 := ui.fishGui.addText("x302 y3 w1277 h26 background" ui.bgColor[2])
	ui.titleBar := ui.fishGui.addText("x305 y4 w1222 h24 cC7C7C7 backgroundTrans")
	ui.titleBar.onEvent("click",wm_lbuttonDown_callback)
	ui.titleBarText := ui.fishGui.addText("x305 y5 w900 h24 c" ui.fontColor[2] " backgroundTrans","Fishing Planet`t(fpassist v" a_fileVersion ")")
	ui.titleBarText.setFont("s14","Arial Bold")
	ui.titleBarFullscreenButton := ui.fishGui.addPicture("x1524 y2 w29 h29 center backgroundTrans","./img/button_fs.png")
	ui.titleBarFullScreenButton.onEvent("click",goFS)
	ui.titleBarExitButton := ui.fishGui.addPicture("x1554 y4 w25 h25 center backgroundTrans","./img/button_close.png")
	ui.titleBarExitButton.onEvent("click",cleanExit)
	ui.fishStatus := ui.fishGui.addText("x2 y752 w1580 h61 c" ui.fontColor[2] " background" ui.bgColor[4])
	drawButton(1,753,395,60)
	drawButton(398,753,264,60)
	ui.profilePos := map("x",396,"y",759,"w",261,"h",50)
	ui.profileBg := ui.fishGui.addText("x" ui.profilePos["x"]+2 " y" ui.profilePos["y"]-4 " w" ui.profilePos["w"] " h" ui.profilePos["h"]+8 " background" ui.bgColor[3])
	ui.profileBg2 := ui.fishGui.addText("x" ui.profilePos["x"]+3 " y" ui.profilePos["y"]-4 " w" ui.profilePos["w"] " h" ui.profilePos["h"]+7 " background" ui.bgColor[4])
	ui.profileNewButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+40 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_new.png")
	ui.profileDeleteButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+81 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_delete.png")
	ui.profileSaveCancelButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+40 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_cancel.png")
	ui.profileSaveCancelButton.onEvent("click",cancelEditProfileName)
	ui.profileSaveButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+62 " y" ui.profilePos["y"]+31 " w16 h17 backgroundTrans","./img/button_save.png")
	ui.profileEditButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+62 " y" ui.profilePos["y"]+31 " w15 h16 backgroundTrans","./img/button_edit.png")
	ui.profileLArrow := ui.fishGui.addPicture("x" ui.profilePos["x"]+5 " y" ui.profilePos["y"]+3 " w20 h22 backgroundTrans","./img/button_arrowLeft.png")
	ui.profileRArrow := ui.fishGui.addPicture("x" (ui.profilePos["x"]+30)+(ui.profilePos["w"]-50) " y" ui.profilePos["y"]+3 " w20 h22 backgroundTrans","./img/button_arrowRight.png")
	ui.profileLArrow.onEvent("click",profileLArrowClicked)
	ui.profileRArrow.onEvent("click",profileRArrowClicked)
	ui.profileText := ui.fishGui.addText("x" ui.profilePos["x"]+30 " y" ui.profilePos["y"]+4 " w207 h20 c" ui.fontColor[1] " center background" ui.bgColor[5])
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileIcon := ui.fishGui.addPicture("hidden x410 y765 w230 h42 backgroundCC3355","")
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+29 " y" ui.profilePos["y"]+3 " w1 h22 background" ui.fontColor[2])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+29 " y" ui.profilePos["y"]+24 " w208 h1 background" ui.fontColor[2])
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+29 " y" ui.profilePos["y"]+3 " w208 h1 background" ui.fontColor[2])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+236 " y" ui.profilePos["y"]+3 " w1 h22 background" ui.fontColor[2])
	ui.profileText.setFont("s12","calibri")
	ui.profileNumStr := "Profile[" cfg.profileSelected "/" cfg.profileName.length "]"
	ui.profileNum := ui.fishGui.addText("x" ui.profilePos["x"]+70 " y" ui.profilePos["y"]+29 " right w160 h20 backgroundTrans c" ui.bgColor[5],ui.profileNumStr)
	ui.profileNum.setFont("s13 c" ui.fontColor[2],"courier new")
	ui.profileSaveButton.onEvent("click",saveProfileName)
	ui.profileEditButton.onEvent("click",editProfileName)
	ui.profileNewButton.onEvent("click",newProfileName)
	ui.profileDeleteButton.onEvent("click",deleteProfileName)
	ui.fishGui.onEvent("escape",cancelEditProfileName)
	ui.castLength := ui.fishGui.addSlider("section toolTip background" ui.bgColor[4] " buddy2ui.castLengthText altSubmit center x62 y756 w176 h16  range1000-2500",1910)
	ui.castLength.onEvent("change",castLengthChanged)
	ui.castLengthLabel := ui.fishGui.addText("xs-3 y+1 w40 h13 right backgroundTrans","Cast")
	ui.castLengthLabel.setFont("s8 c" ui.fontColor[4])
	ui.castLengthLabel2 := ui.fishGui.addText("xs-3 y+-4 w40 h20 right backgroundTrans","Adjust")
	ui.castLengthLabel2.setFont("s8 c" ui.fontColor[4])
	ui.castLengthText := ui.fishGui.addText("x+0 ys+14 left w70 h32 backgroundTrans c" ui.fontColor[3])
	while cfg.profileSelected > cfg.castLength.Length
		cfg.castLength.push("2000")
	ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
	ui.castLength.value := cfg.castLength[cfg.profileSelected]
	
	ui.castLengthText.setFont("s17")
	
	slider("reelSpeed",,6,755,20,50,"1-4",1,1,"left","Reel","vertical","b")
	slider("dragLevel",,33,755,20,50,"1-12",1,1,"center","Drag","vertical","b")
	slider("landAggro",,291,756,50,15,"0-4",1,1,"center","Land Aggro",,)
	slider("twitchFreq",,291,772,50,15,"0-10",1,1,"center","Twitch")
	slider("stopFreq",,291,790,50,15,"0-10",1,1,"center","Stop && Go")
	slider("castTime",,236,755,20,50,"0-6",1,1,"center","Cast","vertical","b")
	slider("sinkTime",,263,755,20,50,"0-10",1,1,"center","Sink","vertical","b")
	slider("recastTime",,157,778,80,15,"1-20",1,1,"center","Recast",,"b","11")
	slider("reelFreq",,0,0,0,0,"0-10",1,10,"center","Reel")
	ui.reelFreq.value := 10
	ui.reelFreq.opt("hidden")
	ui.BoatEnabled := ui.fishGui.addCheckBox("x100 y797 w10 center h15")
	ui.BoatEnabled.onEvent("click",toggledBoat)
	ui.BoatEnabledLabel := ui.fishGui.addText("x75 y797 w40 h15 backgroundTrans c" ui.fontColor[4],"Boat")
	ui.BoatEnabledLabel.setFont("s8")	
	
	ui.floatEnabled := ui.fishGui.addCheckBox("x116 y797 w10 center h15",cfg.floatEnabled[cfg.profileSelected])
	ui.floatEnabled.onEvent("click",toggledFloat)
	ui.floatEnabledLabel := ui.fishGui.addText("x130 y797 w30 h15 backgroundTrans c" ui.fontColor[4],"Float")
	ui.floatEnabledLabel.setFont("s8")

	; ui.bgModeEnabled := ui.fishGui.addCheckBox("x381 y757 w12 h12 right")
	; ui.bgModeEnabledLabel := ui.fishGui.addText("x328 y758 w50 h12 right backgroundTrans c" ui.fontColor[4],"Bg Mode")
	; ui.bgModeEnabled.onEvent("click",bgModeChanged)
	; ui.bgModeEnabledLabel.setFont("s6","Small Fonts")
	
	toggledFloat(*) {
		while cfg.floatEnabled.length < cfg.profileSelected
			cfg.floatEnabled.push(false)
		cfg.floatEnabled[cfg.profileSelected] := ui.floatEnabled.value
		floatEnabledStr := ""
	}

	toggledBoat(*) {
		while cfg.BoatEnabled.length < cfg.profileSelected
			cfg.BoatEnabled.push(false)
		cfg.BoatEnabled[cfg.profileSelected] := ui.BoatEnabled.value
	}
	
	bgModeChanged(*) {
		while cfg.profileSelected > cfg.bgModeEnabled.Length
			cfg.bgModeEnabled.push(ui.bgModeEnabled.value)
		cfg.bgModeEnabled[cfg.profileSelected] := ui.bgModeEnabled.value
	}



	

	;drawButton(1101,753,121,60)
	cp := object()
	cp.x := 1103
	cp.y := 755
	cp.w := 442
	cp.h := 56
	cp.wCol1 := 122
	cp.wCol2 := 117
	cp.wCol3 := 118
	cp.wCol4 := 89
	
	drawButton(1101,753,121,60)
	ui.startButtonBg := ui.fishGui.addText("x1103 y755 w117 h56 background" ui.trimDarkColor[1])
	ui.startButton := ui.fishGui.addText("section x1092 center y754 w120 h60 c" ui.trimDarkFontColor[1] " backgroundTrans","A&FK")
	ui.startButton.setFont("s34 bold","Trebuchet MS")
	ui.startButton.onEvent("click",startButtonClicked)
	ui.startButtonHotkey := ui.fishGui.addText("x+-108 ys-1 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[F]")
	ui.startButtonHotkey.setFont("s9","Palatino Linotype")
	ui.startButtonStatus := ui.fishGui.addPicture("x1190 y775 w26 h14 backgroundTrans","./img/play_ani_0.png")
	drawButton(1224,753,105,29)
	ui.castButtonBg := ui.fishGui.addText("x1226 y755 w101 h25 background" ui.trimDarkColor[1])
	ui.castButton := ui.fishGui.addText("section x1230 center y755 w96 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","&Cast")
	ui.castButton.setFont("s14 bold","Trebuchet MS")
		ui.castButtonHotkey := ui.fishGui.addText("x+-99 ys-2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[C]")
	ui.castButtonHotkey.setFont("s9","Palatino Linotype")	
	;ui.castButtonStatus := ui.fishGui.addPicture("x1310 y760 w26 h14 backgroundTrans","./img/play_ani_0.png")
	ui.castButton.onEvent("click",singleCast)
	ui.castButtonBg.onEvent("click",singleCast)
	drawButton(1224,784,105,29)
	ui.reelButtonBg := ui.fishGui.addText("x1226 y786 w101 h25 background" ui.trimDarkColor[1])
	ui.reelButton := ui.fishGui.addText("section x1226 center y786 w105 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","&Reel")
	ui.reelButton.setFont("s14 bold","Trebuchet MS")
	ui.reelButtonHotkey := ui.fishGui.addText("x+-104 ys-2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[R]")
	ui.reelButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.reelButton.onEvent("click",singlereel)
	ui.reelButtonBg.onEvent("click",singlereel)
	drawButton(1331,753,124,29)
	ui.retrieveButtonBg := ui.fishGui.addText("x1333 y755 w120 h25 background" ui.trimDarkColor[1])
	ui.retrieveButton := ui.fishGui.addText("section x1342 center y755 w113 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","Retrie&ve")
	ui.retrieveButton.setFont("s14 bold","Trebuchet MS")
	ui.retrieveButtonHotkey := ui.fishGui.addText("x+-121 ys-2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[V]")
	ui.retrieveButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.retrieveButtonBg.onEvent("click",singleretrieve)
	ui.retrieveButton.onEvent("click",singleretrieve)
	drawButton(1331,784,124,29)
	ui.cancelButtonBg := ui.fishGui.addText("x1333 y786 w120 h25 background" ui.trimDarkColor[2]) 
	ui.cancelButton := ui.fishGui.addText("section x1342 center y786 w113 h26 c" ui.trimDarkFontColor[2] " backgroundTrans","Cancel")
	ui.cancelButton.setFont("s14 bold","Trebuchet MS")
	ui.cancelButtonHotkey := ui.fishGui.addText("x+-121 ys-2 w40 h20 c" ui.trimDarkFontColor[2] " backgroundTrans","[Q]")
	ui.cancelButtonHotkey.setFont("s9","Palatino Linotype")
	ui.cancelButtonBg.onEvent("click",autoFishStop)
	ui.cancelButton.onEvent("click",autoFishStop)
	drawButton(1457,753,94,19)
	ui.reloadButtonBg := ui.fishGui.addText("x1458 y755 w92 h15 background" ui.trimDarkColor[1])
	ui.reloadButton := ui.fishGui.addText("section x1469 center y751 w85 h19 c" ui.trimDarkFontColor[1] " backgroundTrans","Reload")
	ui.reloadButton.setFont("s12 Bold","Trebuchet MS")	
	ui.reloadButtonHotkey := ui.fishGui.addText("x+-94 ys+2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[F5]")
	ui.reloadButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.reloadButton.onEvent("click",appReload)
	ui.reloadButtonBg.onEvent("click",appReload)
	drawButton(1457,774,94,39)
	ui.exitButtonBg := ui.fishGui.addText("x1458 y776 w92 h35 background" ui.trimDarkColor[1])
	ui.exitButton := ui.fishGui.addText("section x1468 center y775 w85 h39 c" ui.trimDarkFontColor[1] " backgroundTrans","Exit")
	ui.exitButton.setFont("s20 Bold","Trebuchet MS")	
	ui.exitButtonHotkey := ui.fishGui.addText("x+-93 ys-1 w40 h30 c" ui.trimDarkFontColor[1] " backgroundTrans","[F4]")
	ui.exitButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.exitButton.onEvent("click",cleanExit)
	ui.exitButtonBg.onEvent("click",cleanExit)
	drawButton(1553,753,28,60)	
	ui.enableButtonToggle := ui.fishGui.addPicture("x1558 y776 w18 h33 backgroundTrans c" ui.fontColor[2],"./img/toggle_on.png")
	ui.enableButtonHotkey := ui.fishGui.addText("x1553 y753 w28 h20 center backgroundTrans c" ui.fontColor[2],"Caps`nLock")
	ui.enableButtonHotkey.setFont("s6","Small Fonts")
	ui.enableButtonToggle.onEvent("click",toggleEnabled)
	
	ui.fishLogHeaderOutline := ui.fishGui.addText("x1 y1 w298 h30 background" ui.bgColor[3])
	ui.fishLogHeaderOutline2 := ui.fishGui.addText("x2 y2 w296 h28 background" ui.bgColor[1])
	ui.fishLogHeaderOutline3 := ui.fishGui.addText("x3 y3 w294 h26 background" ui.bgColor[2])
	ui.fishLogOutline := ui.fishGui.addText("x1 y32 w298 h687 background" ui.bgColor[3])
	ui.fishLogOutline2 := ui.fishGui.addText("x2 y33 w296 h685 background" ui.bgColor[4])
	ui.fishLogHeaderText := ui.fishGui.addText("x10 y3 w300 h28 c" ui.fontColor[5] " backgroundTrans","Activity")
	ui.fishLogHeaderText.setFont("s14 q5 c" ui.fontColor[2],"Bold")
	ui.fishLogCountLabel := ui.fishGui.addText("x212 y4 w40 h25 backgroundTrans right c" ui.fontColor[2]," Fish")
	ui.fishLogCountLabel.setFont("s10 q5","Helvetica")
	ui.fishLogCountLabel2 := ui.fishGui.addText("x212 y12 w40 h25 backgroundTrans right c" ui.fontColor[2],"Count")
	ui.fishLogCountLabel2.setFont("s10 q5","Helvetica")
	ui.fishLogCount := ui.fishGui.addText("x255 y2 w40 h30 backgroundTrans c" ui.fontColor[2],"000")
	ui.fishLogCount.setFont("s18 q5","Impact") 
	ui.fishLog := ui.fishGui.addText("x2 y34 w296 h680 background" ui.bgColor[1])
	ui.fishLogText := ui.fishGui.addListbox("readOnly x3 y35 w294 h683 -wrap 0x2000 0x100 -E0x200 background" ui.bgColor[4],ui.fishLogArr)
	ui.fishLogText.setFont("s11 q5 c" ui.fontColor[2])
	ui.fishLogFooterOutline := ui.fishGui.addText("x1 y722 w298 h30 background" ui.bgColor[3])
	ui.fishLogFooterOutline2 := ui.fishGui.addText("x2 y723 w296 h28 background" ui.bgColor[1])
	ui.fishLogFooterOutline3 := ui.fishGui.addText("x3 y724 w294 h26 background" ui.bgColor[4])
	ui.fishLogFooter := ui.fishGui.addText("x3 y724 w294 h25 background" ui.bgColor[5]) ;61823A
	ui.fishStatusText := ui.fishGui.addText("section x5 y723 w290 h25 center c" ui.fontColor[6] " backgroundTrans","Ready")
	ui.fishStatusText.setFont("s16 bold","Miriam Fixed")
	;ui.fishLogTimerOutline := ui.fishGui.addText("x1047 y710 w268 h40 background" ui.bgColor[3])
	;ui.fishLogTimerOutline2 := ui.fishGui.addText("x1048 y711 w266 h38 background" ui.bgColor[1])
	;ui.fishLogTimerOutline3 := ui.fishGui.addText("x1049 y712 w264 h36 background" ui.bgColor[2])
	;ui.fishLogTimer := ui.fishGui.addText("x1050 y713 w263 h35 background3F3F3F") ;61823A
	;ui.timerAnim := ui.fishGui.addText("x1047 y710 w268 h40 background010203")
	ui.fishLogAfkTimeLabel := ui.fishGui.addText("hidden section right x751 y695 w80 h40 c" ui.trimFontColor[6] " backgroundTrans","AFK")
	ui.fishLogAfkTimeLabel.setFont("s16 q5","Arial")
	ui.fishLogAfkTimeLabel2 := ui.fishGui.addText("hidden section right x751 y707 w80 h40 c" ui.trimFontColor[6] " backgroundTrans","Timer")
	ui.fishLogAfkTimeLabel2.setFont("s19 q5","Arial")
	ui.fishLogAfkTime := ui.fishGui.addText("hidden x835 y688 w200 h60 c" ui.trimFontColor[6] " backgroundTrans","00:00:00")
	ui.fishLogAfkTime.setFont("s35 q5","Arial")
	ui.bigFishCaught := ui.fishGui.addText("hidden x1160 y666 w160 h300 backgroundTrans c" ui.trimFontColor[6],format("{:03i}","000"))
	ui.bigFishCaught.setFont("s54 q5")
	ui.bigFishCaughtLabel := ui.fishGui.addText("hidden right x1053 y677 w100 h40 backgroundTrans c" ui.trimFontColor[6],"Fish")
	ui.bigFishCaughtLabel.setFont("s24 q5")
	ui.bigFishCaughtLabel2 := ui.fishGui.addtext("hidden right x1055 y696 w100 h40 backgroundTrans c" ui.trimFontColor[6],"Count")
	ui.bigFishCaughtLabel2.setFont("s28 q5")

	if winExist(ui.game) {
		winSetTransparent(255,ui.game)
		winGetPos(&x,&y,&w,&h,ui.game)
	} else {
		exitApp
	}
	sleep(500)
	ui.profileIcon.focus()
	statPanel()
	while ui.fishLogArr.length < 41 {
		ui.fishLogArr.push("")
		ui.fishLogText.delete()
		ui.fishLogText.add(ui.fishLogArr)
		ui.fishLogText.add([""])
	}

	updateControls()
	ui.fishGui.addText("x0 y814 w1583 h1 background" ui.bgColor[3])
	ui.fishGui.addText("x1582 y0 w1 h814 background" ui.bgColor[3])
	ui.fishGui.addText("x0 y0 w1583 h1 background" ui.bgColor[3])
	ui.fishGui.show("x" x-300 " y" y+-30 " w1584 h816 noActivate")
	ui.fishLogAfkTime.text := "00:00:00"
	loadScreen(false)	
}


goFS(*) {
	ui.fullscreen := true
	ui.fishGui.hide()
	ui.fishGuiFS.show()
	winMove(0,0,a_screenWidth,a_screenHeight-30,ui.game)	

	; ui.fishGuiBg := gui()
	; ui.fishGuiBg.opt("-caption -border toolwindow alwaysOnTop owner" winGetId(ui.game))
	; ui.fishGuiBg.backColor := 656565
	; ui.fishGuiBg.addText("x0 y0 w500 h500 background656565")
	; winSetTransparent(150,ui.fishGuiBg)
	; ui.fishGuiBg.show("x95 y350 w360 h450 noactivate")
}

noFS(*) {
	winGetPos(&x,&y,&w,&h,ui.fishGui)
	winMove(x+300,y+30,1280,720,ui.game)
	ui.fishGui.show()
	ui.noFSbutton.opt("hidden")
	ui.fishGuiFS.hide()
	
}


createGuiFS(*) {
	fishGuiFSx := a_screenWidth-900
	fishGuiFSy := a_screenHeight-30-200
	ui.fishGuiFS := gui()
	ui.fishGuiFS.opt("-caption -border +toolWindow alwaysOnTop owner" winGetId(ui.game))
	ui.fishGuiFS.backColor := "010203"
	winSetTransColor("010203",ui.fishGuiFS.hwnd)
	ui.noFSbutton := ui.fishGuiFS.addPicture("x" a_screenWidth-70 " y10 w60 h60 backgroundTrans","./img/button_nofs.png")
	ui.noFSbutton.onEvent("click",noFS)
	ui.FishCaughtFS := ui.fishGuiFS.addText("x" fishGuiFSx+130-30 " y" fishGuiFSy+20 " w250 h300 backgroundTrans c" ui.fontColor[2],format("{:03i}","0"))
	ui.FishCaughtFS.setFont("s94")
	ui.FishCaughtLabelFS := ui.fishGuiFS.addText("right x" fishGuiFSx-98-30 " y" fishGuiFSy+20+8 " w200 h80 backgroundTrans c" ui.fontColor[3],"Fish")
	ui.FishCaughtLabelFS.setFont("s54","Calibri")
	ui.FishCaughtLabel2FS := ui.fishGuiFS.addtext("right x" fishGuiFSx-90-30 " y" fishGuiFSy+20+40 " w200 h90 backgroundTrans c" ui.fontColor[3],"Count")
	ui.FishCaughtLabel2FS.setFont("s60","Calibri")
	ui.fishLogFS := ui.fishGuiFS.addText("x95 y350 w360 h450 backgroundTrans c" ui.fontColor[3],"")
	ui.fishLogFS.setFont("s16")
	ui.fishGuiFS.setFont("s12")
	ui.castButtonFSOutline := ui.fishGuiFS.addText("x10 y300 w60 h20 background" ui.bgColor[4])
	ui.retrieveButtonFSOutline := ui.fishGuiFS.addText("x70 y300 w60 h20 background" ui.bgColor[4])
	ui.reelButtonFSOutline := ui.fishGuiFS.addText("x130 y300 w60 h20 background" ui.bgColor[4])
	ui.castButtonFSBg := ui.fishGuiFS.addText("x12 y302 w56 h16 background" ui.trimDarkColor[1])
	ui.retrieveButtonFSBg := ui.fishGuiFS.addText("x72 y302 w16 h36 background" ui.trimDarkColor[1])
	ui.reelButtonFSBg := ui.fishGuiFS.addText("x132 y302 w56 h16 background" ui.trimDarkColor[1])
	ui.castButtonFS := ui.fishGuiFS.addText("x10 y300 w60 h20 backgroundTrans c" ui.trimDarkFontColor[1],"Cast")
	ui.retrieveButtonFS := ui.fishGuiFS.addText("x70 y300 w60 h20 backgroundTrans c" ui.trimDarkFontColor[1],"Retrieve")
	ui.reelButtonFS := ui.fishGuiFS.addText("x130 y300 w60 h20 backgroundTrans c" ui.trimDarkFontColor[1],"Reel")
	ui.fishGuiFS.show("x0 y0 w" a_screenWidth " h" a_screenHeight-30)
	ui.fishGuiFS.hide()

}

drawButton(x,y,w,h) {
		ui.fishGui.addText("x" x " y" y " w" w " h" h " background" ui.bgColor[3])
		ui.fishGui.addText("x" x+1 " y" y+1 " w" w-2 " h" h-2 " background" ui.bgColor[4])
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
	ui.statPanelOutline2 := ui.fishGui.addText("x" ui.statCoord["x"]+2 " y" ui.statCoord["y"]+2 " w" ui.statCoord["w"]-4 " h" ui.statCoord["h"]-4 " background" ui.bgColor[4])
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
	ui.statAfkDuration := ui.fishGui.addText("x+0 ys w130 r1 backgroundTrans c" ui.fontColor[2],"")
	
	ui.statReelSpeedLabel := ui.fishGui.addText("x+-15 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Speed: ")
	ui.statReelSpeed := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2],ui.reelSpeed.value)
	
	ui.viewLog := ui.fishGui.addText("x+-35 ys right section w55 r1 backgroundTrans c" ui.fontColor[2],"View Log")
	ui.viewLog.setFont("s9 underline")
	ui.viewLog.onEvent("click",viewLog)
	
	viewLog(*) {
		run("notepad.exe " a_scriptDir "/logs/current_log.txt")
	}
}
timerFadeIn(*) {
while tmp.h > 0 {
		ui.timerAnim.move(,,,tmp.h-=1)
		sleep(1)
	}
}
timerFadeOut(*) {
while tmp.h < 40 {
		ui.timerAnim.move(,,,tmp.h+=1)
		sleep(1)
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
; WM_LBUTTONDOWN(wparam,lparam,msg,hwnd) {
	; if hwnd == wparam.hwnd
		; postMessage("0xA1",2,,,"A")
; }

WM_LBUTTONDOWN_callback(this_control*) {
	postMessage("0xA1",2,,,"A")
	;WM_LBUTTONDOWN(0,0,0,this_control)
}

WM_WINDOWPOSCHANGED(wParam, lParam, msg, Hwnd) {
			try
				if winExist(ui.fishGui)
					winGetPos(&x,&y,&w,&h,ui.fishGui)
			try 
				if !ui.fullscreen {
					try
						winMove(x+(301*(a_screenDpi/96)),y+(31*(a_screenDpi/96)),,,ui.game)
		
					try
						winMove(x+1101,y+753,,,ui.disabledGui) 
					try
						winMove(x+427,y+762,,,ui.editProfileGui)		
				} else {
				winMove(0,0,a_screenWidth,a_screenHeight-30,ui.fishGui)
				winMove(0,0,a_screenWidth,a_screenHeight-30,ui.game)
			}
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
