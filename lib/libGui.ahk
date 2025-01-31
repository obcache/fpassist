#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off


if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

ui.fsPanelOffset:=[0,0]
ui.fishGuiFSy:=""
ui.fishGuiFSx:=""

; if ui.fullscreen {
switch a_screenWidth {
	case 3440:
		ui.hookedXfs:=3060																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
		ui.hookedYfs:=1000
		ui.hookedColor:=[0x1CACB5,0x1EA9C3]
		ui.reeledInCoord1fs:=[2944,1250]
		ui.reeledInCoord2fs:=[2944,1280]
		ui.reeledInCoord3fs:=[2984,1250]
		ui.reeledInCoord4fs:=[2984,1280]
		ui.reeledInCoord5fs:=[2963,1265]
		ui.fsPanelOffset:=[0,0]
	case 2560:
		ui.hookedXfs:=2160																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
		ui.hookedYfs:=1000
		ui.hookedColor:=[0x1CACB5,0x1EA9C3]
		ui.reeledInCoord1fs:=[2055,1270]
		ui.reeledInCoord2fs:=[2055,1310]
		ui.reeledInCoord3fs:=[2090,1310]
		ui.reeledInCoord4fs:=[2090,1270]
		ui.reeledInCoord5fs:=[2080,1330]
		ui.fsPanelOffset:=[-320,0]
	case 1920:
		ui.hookedXfs:=1625																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
		ui.hookedYfs:=745
		ui.hookedColor:=[0x1CACB5,0x1EA9C3]
		ui.reeledInCoord1fs:=[1550,928]
		ui.reeledInCoord2fs:=[1577,928]
		ui.reeledInCoord3fs:=[1577,952]
		ui.reeledInCoord4fs:=[1550,952]
		ui.reeledInCoord5fs:=[1565,970]
		ui.fsPanelOffset:=[-200,0]
}

createGui() {
	while cfg.profileSelected > cfg.profileName.Length
		cfg.profileName.push("Profile #" cfg.profileName.length+1)
	ui.fishGui := gui()
	ui.fishGui.opt("-caption owner" winGetId(ui.game))
	ui.fishGui.backColor := ui.bgColor[4]
	ui.fishGui.color := ui.fontColor[2]
	winSetTransColor("010203",ui.fishGui.hwnd)
	ui.fishGui.addText("x0 y0 w1583 h816 background" ui.bgColor[6])
	ui.fishGui.addText("x1 y2 w1581 h814 background" ui.bgColor[1])
	ui.appFrame := ui.fishGui.addText("x300 y32 w1281 h720 c" ui.fontColor[3] " background" ui.bgColor[3])
	ui.appFrame2 := ui.fishGui.addText("x301 y33 w1279 h718 c" ui.fontColor[1] " background" ui.bgColor[2])
	ui.fpBg := ui.fishGui.addText("x302 y34 w1277 h716 c010203 background010203")
	ui.titleBarOutline := ui.fishGui.addText("x299 y2 w1282 h30 background" ui.bgColor[1])
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
	ui.profileNum := ui.fishGui.addText("x" ui.profilePos["x"]+80 " y" ui.profilePos["y"]+29 " right w160 h20 backgroundTrans c" ui.bgColor[5],ui.profileNumStr)
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
	ui.castLengthLabel2 := ui.fishGui.addText("xs-3 y+-4 w40 h20 right backgroundTrans","Length")
	ui.castLengthLabel2.setFont("s8 c" ui.fontColor[4])
	ui.castLengthText := ui.fishGui.addText("x+0 ys+14 left w70 h32 backgroundTrans c" ui.fontColor[3])
	while cfg.profileSelected > cfg.castLength.Length
		cfg.castLength.push("2000")
	ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
	ui.castLength.value := cfg.castLength[cfg.profileSelected]
	
	ui.castLengthText.setFont("s17")
	
	slider("reelSpeed",,6,755,20,50,"1-4",1,1,"left","Reel","vertical","b")
	slider("dragLevel",,33,755,20,50,"1-12",1,1,"center","Drag","vertical","b")
	slider("landAggro",,290,756,50,15,"0-4",1,1,"center","Land Aggro",,)
	slider("twitchFreq",,290,772,50,15,"0-10",1,1,"center","Twitch")
	slider("stopFreq",,290,790,50,15,"0-10",1,1,"center","Stop && Go")
	slider("castTime",,238,755,20,50,"0-6",1,1,"center","Cast","vertical","b")
	slider("sinkTime",,265,755,20,50,"0-20",1,1,"center","Sink","vertical","b")
	slider("recastTime",,100,795,135,13,"1-20",1,1,"center","Recast",,"l","11")
	slider("reelFreq",,1900,0,0,0,"0-10",1,10,"center","Reel")
	ui.reelFreq.value := 10
	ui.reelFreq.opt("hidden")

	while cfg.rodHolderEnabled.length < cfg.profileSelected
		cfg.rodHolderEnabled.push(false)
		
	ui.rodHolderEnabled := ui.fishGui.addCheckBox("x223 y773 w10 h15 ",cfg.rodHolderEnabled[cfg.profileSelected])
	ui.rodHolderEnabled.onEvent("click",toggleRoldHolder)
	ui.rodHolderEnabledLabel := ui.fishGui.addText("right x160 y775 w60 h15 backgroundTrans c" ui.fontColor[4],"Rod Stand")
	ui.rodHolderEnabledLabel.setFont("s7","small fonts")

	ui.floatEnabled := ui.fishGui.addCheckBox("x223 y785 w10 h15",cfg.floatEnabled[cfg.profileSelected])
	ui.floatEnabled.onEvent("click",toggleFloat)
	ui.floatEnabledLabel := ui.fishGui.addText("right x160 y786 w60 h15 c" ui.fontColor[4],"Float/Bottom")
	ui.floatEnabledLabel.setFont("s7","small fonts")
	
	toggleFloat(*) {
		while cfg.floatEnabled.length < cfg.profileSelected
			cfg.floatEnabled.push(false)
		cfg.floatEnabled[cfg.profileSelected] := ui.floatEnabled.value
		floatEnabledStr := ""
		if ui.floatEnabled.value
			ui.rodHolderEnabled.opt("-disabled")
		else {
			ui.rodHolderEnabled.value:=false
			ui.rodHolderEnabled.opt("disabled")
		}
	}

	toggleRoldHolder(*) {
		while cfg.rodHolderEnabled.length < cfg.profileSelected
			cfg.rodHolderEnabled.push(false)
		cfg.rodHolderEnabled[cfg.profileSelected] := ui.rodHolderEnabled.value
	}
	
	bgModeChanged(*) {
		while cfg.profileSelected > cfg.bgModeEnabled.Length
			cfg.bgModeEnabled.push(ui.bgModeEnabled.value)
		cfg.bgModeEnabled[cfg.profileSelected] := ui.bgModeEnabled.value
	}
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
	ui.startButtonHotkey := ui.fishGui.addText("x+-25 ys-2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[Shift-F]")
	ui.startButtonHotkey.setFont("s7","Palatino Linotype")
	ui.startButtonStatus := ui.fishGui.addPicture("x1190 y775 w26 h14 backgroundTrans","./img/play_ani_0.png")
	drawButton(1224,753,105,29)
	ui.castButtonBg := ui.fishGui.addText("x1226 y755 w101 h25 background" ui.trimDarkColor[1])
	ui.castButton := ui.fishGui.addText("section x1230 center y755 w96 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","&Cast")
	ui.castButton.setFont("s14 bold","Trebuchet MS")
	; ui.castButtonHotkey0 := ui.fishGui.addText("x+-26 ys-10 w40 h30 c" ui.trimDarkFontColor[1] " backgroundTrans","[    ]")
	; ui.castButtonHotkey0.setFont("s14","Palatino Linotype")	
	ui.castButtonHotkey := ui.fishGui.addText("x+-12 ys+10 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[C]")
	ui.castButtonHotkey.setFont("s6","Small Fonts")	
	; ui.castButtonHotkey2 := ui.fishGui.addText("x+-34 ys+0 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","C")
	; ui.castButtonHotkey2.setFont("s8","Palatino Linotype")	
	ui.castButton.onEvent("click",castButtonClicked)
	ui.castButtonBg.onEvent("click",castButtonClicked)
	drawButton(1224,784,105,29)
	ui.reelButtonBg := ui.fishGui.addText("x1226 y786 w101 h25 background" ui.trimDarkColor[1])
	ui.reelButton := ui.fishGui.addText("section x1226 center y787 w105 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","&Reel")
	ui.reelButton.setFont("s14 bold","Trebuchet MS")

	
	ui.reelButtonHotkey := ui.fishGui.addText("x+-17 ys+2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[R]")
	ui.reelButtonHotkey.setFont("s6","Small Fonts")	
	ui.reelButton.onEvent("click",reelButtonClicked)
	ui.reelButtonBg.onEvent("click",reelButtonClicked)
	drawButton(1331,753,124,29)
	ui.retrieveButtonBg := ui.fishGui.addText("x1333 y755 w120 h25 background" ui.trimDarkColor[1])
	ui.retrieveButton := ui.fishGui.addText("section x1342 center y756 w113 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","Retrie&ve")
	ui.retrieveButton.setFont("s14 bold","Trebuchet MS")
	ui.retrieveButtonHotkey := ui.fishGui.addText("x+-122 ys+9 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[V]")
	ui.retrieveButtonHotkey.setFont("s6","Small Fonts")	
	ui.retrieveButtonBg.onEvent("click",retrieveButtonClicked)
	ui.retrieveButton.onEvent("click",retrieveButtonClicked)
	drawButton(1331,784,124,29)
	ui.cancelButtonBg := ui.fishGui.addText("x1333 y786 w120 h25 background" ui.trimDarkColor[2]) 
	ui.cancelButton := ui.fishGui.addText("section x1342 center y787 w113 h26 c" ui.trimDarkFontColor[2] " backgroundTrans","Cancel")
	ui.cancelButton.setFont("s14 bold","Trebuchet MS")
	ui.cancelButtonHotkey := ui.fishGui.addText("x+-122 ys+2 w40 h20 c" ui.trimDarkFontColor[2] " backgroundTrans","[Q]")
	ui.cancelButtonHotkey.setFont("s6","Small Fonts")
	ui.cancelButtonBg.onEvent("click",stopButtonClicked)
	ui.cancelButton.onEvent("click",stopButtonClicked)
	drawButton(1457,753,94,19)
	ui.reloadButtonBg := ui.fishGui.addText("x1458 y755 w92 h15 background" ui.trimDarkColor[1])
	ui.reloadButton := ui.fishGui.addText("section x1460 center y751 w85 h19 c" ui.trimDarkFontColor[1] " backgroundTrans","Reload")
	ui.reloadButton.setFont("s14 Bold","Trebuchet MS")	
	ui.reloadButtonHotkey := ui.fishGui.addText("x+-12 ys+0 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[F5]")
	ui.reloadButtonHotkey.setFont("s7","Palatino Linotype")	
	ui.reloadButton.onEvent("click",appReload)
	ui.reloadButtonBg.onEvent("click",appReload)
	drawButton(1457,774,94,39)
	ui.exitButtonBg := ui.fishGui.addText("x1458 y776 w92 h35 background" ui.trimDarkColor[1])
	ui.exitButton := ui.fishGui.addText("section x1460 center y775 w85 h39 c" ui.trimDarkFontColor[1] " backgroundTrans","Exit")
	ui.exitButton.setFont("s20 Bold","Trebuchet MS")	
	ui.exitButtonHotkey := ui.fishGui.addText("x+-12 ys-1 w40 h30 c" ui.trimDarkFontColor[1] " backgroundTrans","[F4]")
	ui.exitButtonHotkey.setFont("s7","Palatino Linotype")	
	ui.exitButton.onEvent("click",cleanExit)
	ui.exitButtonBg.onEvent("click",cleanExit)
	drawButton(1553,753,28,60)	
	ui.enableButtonToggle := ui.fishGui.addPicture("x1558 y776 w18 h33 backgroundTrans c" ui.fontColor[2],"./img/toggle_on.png")
	ui.enableButtonHotkey := ui.fishGui.addText("x1553 y753 w28 h20 center backgroundTrans c" ui.fontColor[2],"Caps`nLock")
	ui.enableButtonHotkey.setFont("s6","Small Fonts")
	ui.enableButtonToggle.onEvent("click",toggleEnabled)
	ui.shiftHotkeyBg := ui.fishGui.addText("x+-267 ys+0 w32 h15 c" ui.trimDarkFontColor[1] " background" ui.bgColor[3])
	ui.shiftHotkeyBg2 := ui.fishGui.addText("x+-31 y+-14 w30 h13 c" ui.trimDarkFontColor[1] " background" ui.bgColor[1])
	ui.shiftHotkey := ui.fishGui.addText("center x+-30 y+-16 w30 h15 c" ui.trimDarkFontColor[1] " backgroundTrans","Shift")
	ui.shiftHotkey.setFont("s10","Palatino Linotype")	
	ui.fishLogHeaderOutline := ui.fishGui.addText("x2 y1 w297 h30 background" ui.bgColor[3])
	ui.fishLogHeaderOutline2 := ui.fishGui.addText("x3 y2 w295 h28 background" ui.bgColor[1])
	ui.fishLogHeaderOutline3 := ui.fishGui.addText("x5 y3 w292 h26 background" ui.bgColor[2])
	ui.fishLogOutline := ui.fishGui.addText("x2 y32 w297 h689 background" ui.bgColor[3])
	ui.fishLogOutline2 := ui.fishGui.addText("x3 y33 w295 h687 background" ui.bgColor[4])
	ui.fishLogHeaderText := ui.fishGui.addText("x5 y3 w300 h28 c" ui.fontColor[5] " backgroundTrans","Activity")
	ui.fishLogHeaderText.setFont("s17 q5 c" ui.fontColor[2],"Impact")
	ui.fishLogViewerButton:=ui.fishGui.addPicture("x119 y5 w22 h22 background" ui.bgColor[2],"./img/button_popout.png")
	ui.fishLogViewerButton.onEvent("click",launchLogViewer)
	ui.fishPicFolderLabel := ui.fishGui.addText("x83 y5 w46 h26 backgroundTrans c" ui.fontColor[2],"Activity")
	ui.fishPicFolderLabel.setFont("s9 q5","Helvetica")
	ui.fishPicFolderLabel2 := ui.fishGui.addText("x76 y13 w46 h26 backgroundTrans c" ui.fontColor[2],"Monitor")
	ui.fishPicFolderLabel2.setFont("s10 q5","Helvetica")
	
	
	ui.fishPicFolder := ui.fishGui.addPicture("x188 y3 w24 h26 backgroundTrans","./img/button_folder.png")
	ui.fishPicFolderLabel := ui.fishGui.addText("x155 y5 w46 h26 backgroundTrans c" ui.fontColor[2],"Catch")
	ui.fishPicFolderLabel.setFont("s9 q5","Helvetica")
	ui.fishPicFolderLabel2 := ui.fishGui.addText("x146 y13 w46 h26 backgroundTrans c" ui.fontColor[2],"Photos")
	ui.fishPicFolderLabel2.setFont("s10 q5","Helvetica")
	ui.fishPicFolder.onEvent("click",openFishPicFolder)
	openFishPicFolder(*) {
		folderPath:=a_MyDocuments "/fpassist/fishPics/"
		run('"C:\windows\explorer.exe" "' a_scriptDir '\fishPics"')
		
	}
	ui.fishLogCountLabel := ui.fishGui.addText("x213 y5 w40 h25 backgroundTrans right c" ui.fontColor[2]," Fish")
	ui.fishLogCountLabel.setFont("s9 q5","Helvetica")
	ui.fishLogCountLabel2 := ui.fishGui.addText("x213 y13 w40 h25 backgroundTrans right c" ui.fontColor[2],"Count")
	ui.fishLogCountLabel2.setFont("s10 q5","Helvetica")
	ui.fishLogCount := ui.fishGui.addText("x254 y2 w40 h30 backgroundTrans c" ui.fontColor[2],"000")
	ui.fishLogCount.setFont("s18 q5","Impact") 
	ui.fishLog := ui.fishGui.addText("x4 y34 w292 h680 background" ui.bgColor[1])
	ui.fishLogText := ui.fishGui.addListbox("readOnly x4 y31 w292 h688 -wrap 0x2000 0x100 -E0x200 background" ui.bgColor[4],ui.fishLogArr)
	ui.fishLogText.setFont("s11 q5 c" ui.fontColor[2])
	ui.fishLogText.onEvent("DoubleClick",openFishPic)
		
	launchLogViewer(fullscreen,*) {
		static launchLogState:=false
		(launchLogState:=!launchLogState) ? showLogScreen() : hideLogScreen()
		
		showLogScreen(*) {
			guiVis(ui.logGui,true)
			winGetPos(&tX,&tY,&tW,&tH,ui.fishGui.hwnd)
			ui.logGui.show("x" tX+tW+1 " y" tY " w600 h" tH)
		}
		hideLogScreen(*) {
			guiVis(ui.logGui,false)
		}
	}
	
	
	

	logViewer()
	ui.fishLogFooterOutline := ui.fishGui.addText("x1 y722 w298 h30 background" ui.bgColor[3])
	ui.fishLogFooterOutline2 := ui.fishGui.addText("x2 y723 w296 h28 background" ui.bgColor[1])
	ui.fishLogFooterOutline3 := ui.fishGui.addText("x3 y724 w294 h26 background" ui.bgColor[4])
	ui.fishLogFooter := ui.fishGui.addText("x3 y724 w294 h25 background" ui.bgColor[5]) ;61823A
	ui.fishStatusText := ui.fishGui.addText("section x5 y723 w290 h25 center c" ui.fontColor[6] " backgroundTrans","Ready")
	ui.fishStatusText.setFont("s16 bold","Miriam Fixed")
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
	while ui.fishLogArr.length < 43 {
		ui.fishLogArr.push("")
		ui.fishLogText.delete()
		ui.fishLogText.add(ui.fishLogArr)
	}

	updateControls()
	ui.fishGui.addText("x1 y814 w1581 h1 background" ui.bgColor[6])
	ui.fishGui.addText("x1580 y1 w1 h751 background" ui.bgColor[3])
	ui.fishGui.addText("x1 y1 w1580 h1 background" ui.bgColor[3])
	ui.fishGui.show("x" x-300 " y" y+-30 " w1583 h815 noActivate")
	ui.fishLogAfkTime.text := "00:00:00"
	ui.disabledGui := gui()
	ui.disabledGui.opt("-caption -border toolWindow owner" ui.fishGui.hwnd)
	ui.disabledGui.backColor := ui.bgColor[3]
	ui.disabledGui.addText("x1 y1 w448 h58 background353535")
	guiVis(ui.disabledGui,false)
	ui.disabledGui.show("x1102 y754 w450 h60 noActivate")
	loadScreen(false)	
	
		
}

openFishPic(listBox:=ui.fishLogText,val2:="",*) {
	if inStr(listbox.text,"Screenshot:") {
		catchPhoto:=subStr(listbox.text,13)
		run('"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "' catchPhoto '"')
	}
}

saveLog(*) {
			logFilename := "log_" formatTime(,"yyyyMMddhhmmss") ".txt"
			loop ui.logLV.getCount() {
				fileAppend(ui.LogLV.getText(a_index) "`n","./logs/" logFilename)
			}
			log("Saved Log to " a_scriptdir "logs/" logFilename)
}

logViewer(*) {
		ui.logGui:=gui()
		ui.logGui.opt("-caption toolWindow owner" ui.fishGui.hwnd)
		ui.logGui.backColor:=ui.bgColor[6]
		ui.logGui.addText("x1 y1 w598 h840 background" ui.bgColor[1])
		ui.logTitleBar := ui.logGui.addText("x0 y0 w540 h30 background" ui.bgColor[5])
		ui.logTitleBar.onEvent("click",wm_lbuttonDown_callback)
		ui.logTitleBarText := ui.logGui.addText("x7 y3 w520 h26 backgroundTrans c" ui.fontColor[4],"Fishing Log  (fpAssist v" a_fileVersion ")")
		ui.logTitleBarText.setFont("s14 bold","calibri")
		ui.logSaveBg := ui.logGui.addText("x540 y0 w30 h30 background" ui.bgColor[5])
		ui.logSaveBg.onEvent("click",saveLog)
		ui.logSave := ui.logGui.addPicture("x542 y4 w26 h25 backgroundTrans","./img/button_save.png")
		ui.logSave.onEvent("click",saveLog)
		ui.logCloseBg := ui.logGui.addText("x570 y0 w30 h30 background" ui.bgColor[5])
		ui.logCloseBg.onEvent("click",closeLog)
		ui.logClose := ui.logGui.addPicture("x572 y3 w25 h25 background" ui.bgColor[5],"./img/button_cancel.png")
		ui.logClose.onEvent("click",closeLog)
		closeLog(*) {
			ui.logGui.hide()
		}
		ui.logLV := ui.logGui.addListview("x0 y30 w600 h805 -hdr background" ui.bgColor[4] " c" ui.fontColor[1],["Activity"])
		ui.logLV.setFont("s10 c" ui.fontColor[4],)
		ui.logLV.modifyCol(1,580)
		ui.logLV.onEvent("DoubleClick",openFishPic)

		guiVis(ui.logGui,false)
		winGetPos(&tX,&tY,&tW,&tH,ui.fishGui.hwnd)
		ui.logGui.show("x" tX+tW+8 " y" tY " w600 h835")
	}

goFS(*) {
	ui.fullscreen := true
	guiVis(ui.fishGuiFS,true)
	ui.fishCaughtFS.redraw()
	ui.fishCaughtLabelFS.redraw()
	ui.fishCaughtLabel2FS.redraw()
	guiVis(ui.fishGui,false)
	winMove(0,0,a_screenWidth,a_screenHeight-30,ui.game)	
	; winSetTransparent(160,ui.fishGuiFsBg)
	switch a_screenWidth {
		case 3440:
			ui.hookedXfs:=3060																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
			ui.hookedYfs:=1000
			ui.hookedColor:=[0x1CACB5,0x1EA9C3]
			ui.reeledInCoord1fs:=[2944,1250]
			ui.reeledInCoord2fs:=[2944,1280]
			ui.reeledInCoord3fs:=[2984,1250]
			ui.reeledInCoord4fs:=[2984,1280]
			ui.reeledInCoord5fs:=[2963,1265]
			ui.fsPanelOffset:=[0,0]
		case 2560:
			ui.hookedXfs:=2160																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
			ui.hookedYfs:=1000
			ui.hookedColor:=[0x1CACB5,0x1EA9C3]
			ui.reeledInCoord1fs:=[2055,1270]
			ui.reeledInCoord2fs:=[2055,1310]
			ui.reeledInCoord3fs:=[2090,1310]
			ui.reeledInCoord4fs:=[2090,1270]
			ui.reeledInCoord5fs:=[2080,1330]
			ui.fsPanelOffset:=[-350,0]

		case 1920:
			ui.hookedXfs:=1625																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
			ui.hookedYfs:=745
			ui.hookedColor:=[0x1CACB5,0x1EA9C3]
			ui.reeledInCoord1fs:=[1550,928]
			ui.reeledInCoord2fs:=[1577,928]
			ui.reeledInCoord3fs:=[1577,952]
			ui.reeledInCoord4fs:=[1550,952]
			ui.reeledInCoord5fs:=[1565,970]
			ui.fsPanelOffset:=[-100,0]
	}
	ui.reeledInCoord1:=ui.reeledInCoord1fs
	ui.reeledInCoord2:=ui.reeledInCoord2fs
	ui.reeledInCoord3:=ui.reeledInCoord3fs
	ui.reeledInCoord4:=ui.reeledInCoord4fs
	ui.reeledInCoord5:=ui.reeledInCoord5fs
	ui.hookedX:=ui.hookedXfs
	ui.hookedY:=ui.hookedYfs
	;createGuiFS()
	showLog()
	click()
	
}

showLog(*) {
		
		winGetPos(&tX,&tY,&tW,&tH,ui.game)
		highestMx:=0
		highestMy:=0
		rightMonitor:=1
		loop monitorGetCount() {
		this_monitor := a_index
		monitorGetWorkArea(this_monitor,&mX,&mY,&mW,&mH)
			if mX > highestMx {
				highestMx:=mX
				rightMonitor:=this_monitor
			}
			if mY > highestMy
				highestMy:=mY
		}
		monitorGetWorkArea(rightMonitor,&mX,&mY,&mW,&mH)
		ui.logGui.show("x" tX+tW " y" highestMy)
		guiVis(ui.logGui,true)
		guiVis(ui.fishGui,false)
}
	
noFS(*) {
	ui.fullscreen:=false
	ui.bigFishCaught.redraw()
	ui.bigFishCaughtLabel.redraw()
	ui.bigFishCaughtLabel2.redraw()
	                                                            
	ui.hookedXstd:=1075
	ui.hookedYstd:=508
	ui.reeledInCoord1std:=[1026,635]
	ui.reeledInCoord2std:=[1047,635]
	ui.reeledInCoord3std:=[1026,656]
	ui.reeledInCoord4std:=[1047,656]
	ui.reeledInCoord5std:=[1036,644]
	
	ui.hookedX:=ui.hookedXstd
	ui.hookedY:=ui.hookedYstd
	ui.reeledInCoord1:=ui.reeledInCoord1std
	ui.reeledInCoord2:=ui.reeledInCoord2std
	ui.reeledInCoord3:=ui.reeledInCoord3std
	ui.reeledInCoord4:=ui.reeledInCoord4std
	ui.reeledInCoord5:=ui.reeledInCoord5std
	
	guiVis(ui.fishGuiFS,false)
	
	winGetPos(&x,&y,&w,&h,ui.fishGui)
	winMove(x+300,y+30,1280*(a_screenDpi/96),720*(a_screenDpi/96),ui.game)
	guiVis(ui.fishGui,true)
	ui.fishGui.show("w1584 h816")
	ui.noFSbutton.opt("hidden")
	try
		ui.logGui.hide()
	click()
}


createGuiFS(*) {
	; try
		; ui.fishGuiFS.destroy()
	ui.fishGuiFSx := a_screenWidth-800+ui.fsPanelOffset[1]
	ui.fishGuiFSy := a_screenHeight-30-200-184
	; try 
		; winGetId(ui.fishGuiFS)
	; catch
		; h:=""
	; else
		; ui.fishGuiFS.destroy()
		
	ui.fishGuiFS := gui()
	
	ui.fishGuiFS.opt("-caption -border +toolWindow owner" ui.fishGui.hwnd)
	ui.fishGuiFS.backColor := "010203"
	;winSetTransColor("010203",ui.fishGuiFS.hwnd)
	ui.noFSbutton := ui.fishGuiFS.addPicture("x" a_screenWidth-70 " y10 w60 h60 backgroundTrans","./img/button_nofs.png")
	ui.noFSbutton.onEvent("click",noFS)
	ui.FishCaughtFS := ui.fishGuiFS.addText("hidden x" ui.fishGuiFSx+130-30 " y" ui.fishGuiFSy+20 " w250 h300 backgroundTrans c" ui.trimFontColor[6],format("{:03i}","0"))
	ui.FishCaughtFS.setFont("s94")
	ui.FishCaughtLabelFS := ui.fishGuiFS.addText("hidden right x" ui.fishGuiFSx-98-30 " y" ui.fishGuiFSy+20+8 " w200 h80 backgroundTrans c" ui.trimFontColor[6],"Fish")
	ui.FishCaughtLabelFS.setFont("s54","Calibri")
	ui.FishCaughtLabel2FS := ui.fishGuiFS.addtext("hidden right x" ui.fishGuiFSx-90-30 " y" ui.fishGuiFSy+20+40 " w200 h90 backgroundTrans c" ui.trimFontColor[6],"Count")
	ui.FishCaughtLabel2FS.setFont("s60","Calibri")
	ui.fishLogFS := ui.fishGuiFS.addText("hidden x95 y350 w360 h450 backgroundTrans c" ui.fontColor[3],"")
	ui.fishLogFS.setFont("s16")
	ui.fishGuiFS.setFont("s12")
	ui.fsPanel := object()
	ui.fsIcons := object()
	ui.fsIcons.x := (a_screenWidth*.68)
	ui.fsIcons.y := a_screenHeight*.875
	ui.fsIcons.w := 120
	ui.fsIcons.h := 120
	ui.fsPanel.x := 50
	ui.fsPanel.y := 230
	ui.fsPanel.w := 60
	ui.fsPanel.h := 20

	; try 
		; controlGetHwnd(ui.profilePrevFS)
	; catch
		; x:=""
	; else {
		; ui.profilePrevFS.destroy()
	; }
	
	ui.profilePrevFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x-35+ui.fsPanelOffset[1] " y" ui.fsIcons.y-44 " w30 h38 backgroundTrans","./img/button_arrowLeft_knot.png")

	; try 
		; controlGetHwnd(ui.profileSelectedFsBorder)
	; catch
	; else {
		; ui.profileSelectedFsBorder.opt("x" ui.fsIcons.x+ui.fsPanelOffset[1])
		; ui.profileSelectedFsBorder.redraw()
	; }
		ui.profileSelectedFsBorder := ui.fishGuiFS.addPicture("x" ui.fsIcons.x+ui.fsPanelOffset[1] " y" ui.fsIcons.y-45 " w" ui.fsIcons.w*3+150 " h40 center background" ui.bgColor[2] " c" ui.trimFontColor[6],"./img/profileFS_border.png")

; try
		; ui.profileSelectedFS.destroy()
	ui.profileSelectedFS := ui.fishGuiFS.addText("x" ui.fsIcons.x+10+ui.fsPanelOffset[1] " y" ui.fsIcons.y-40 " w" ui.fsIcons.w*3+134 " h30 center background" ui.bgColor[2] " c" ui.trimFontColor[6],cfg.profileName[cfg.profileSelected])
	 ui.profileSelectedFS.setFont("s19")
	
	ui.profileNextFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x+(ui.fsIcons.w*3+155)+ui.fsPanelOffset[1] " y" ui.fsIcons.y-44 " w32 h38 backgroundTrans","./img/button_arrowRight_knot.png")
	ui.profilePrevFS.onEvent("click",profileLArrowClicked)
	ui.profileNextFS.onEvent("click",profileRArrowClicked)
	
	ui.castIconFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x+ui.fsPanelOffset[1] " y" ui.fsIcons.y " w" ui.fsIcons.w " h" ui.fsIcons.h " backgroundTrans c" ui.bgcolor[6],"./img/icon_cast.png")
	
	ui.retrieveIconFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x+ui.fsIcons.w+30+ui.fsPanelOffset[1] " y" ui.fsIcons.y " w" ui.fsIcons.w " h" ui.fsIcons.h " backgroundTrans c" ui.bgcolor[6],"./img/icon_retrieve.png")
	
	ui.reelIconFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x+((ui.fsIcons.w+30)*2)+ui.fsPanelOffset[1] " y" ui.fsIcons.y " w" ui.fsIcons.w " h" ui.fsIcons.h " backgroundTrans c" ui.bgcolor[6],"./img/icon_reel.png")
	
	ui.toggleEnabledFSLabel := ui.fishGuiFS.addText("hidden x" ui.fsIcons.x+(ui.fsIcons.w*3)+80+ui.fsPanelOffset[1] " y" ui.fsIcons.y-10 " w80 backgroundTrans center","Caps`nLock`n`n`n`n`n`n`n`n`n`nfpAssist")
	ui.toggleEnabledFSLabel.setFont("s10 cWhite Bold","Small Fonts")
	
	ui.toggleEnabledFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x+(ui.fsIcons.w*3)+80+ui.fsPanelOffset[1] " y" ui.fsIcons.y+15 " w105 h45 backgroundTrans","./img/toggle_horz_ON.png")
	
	ui.fsObjects:=[ui.profilePrevFS,ui.profileSelectedFsBorder,ui.profileSelectedFS,ui.profileNextFS,ui.profilePrevFS,ui.castIconFS,ui.reelIconFS,ui.retrieveIconFS]
	guiVis(ui.fishGuiFS,false)
	ui.fishGuiFS.show("x0 y0 w" a_screenWidth " h" a_screenHeight-30)
}

drawButton(x,y,w,h) {
		ui.fishGui.addText("x" x " y" y " w" w " h" h " background" ui.bgColor[3])
		ui.fishGui.addText("x" x+1 " y" y+1 " w" w-2 " h" h-2 " background" ui.bgColor[4])
}

hotIfWinActive(ui.game)
XButton2::LAlt
xbutton1::LCtrl
hotIf()

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
		ui.notifyGui.addPicture("x0 y0 w1582 h812","./img/fp_splash.png")
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
			setTimer () => detectPrompts(1),-6000
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

WM_LBUTTONDOWN_callback(this_control*) {
	postMessage("0xA1",2,,,"A")
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

startButtonDim(*) {
	ui.startButtonBg.opt("background" ui.trimColor[3])
	ui.startButtonBg.redraw()
	ui.startButton.setFont("c" ui.trimFontColor[3])
	ui.startButton.redraw()
	ui.startButtonHotkey.setFont("c" ui.trimFontColor[3])
	ui.startButton.redraw()
	cancelButtonOn()
}


button(name,mode) {
	switch mode {
		case "on":
			ui.%name%ButtonBg.opt("background" ui.trimColor[(name=="cancel") ? 2 : 1])
			ui.%name%ButtonBg.redraw()
			ui.%name%Button.setFont("c" ui.trimFontColor[(name=="cancel") ? 2 : 1])
			ui.%name%Button.redraw()
			ui.%name%ButtonHotkey.setFont("c" ui.trimFontColor[(name=="cancel") ? 2 : 1])
			ui.%name%ButtonHotkey.redraw()
		case "flash":
	}
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
	startButtonOn()
	try {
		ui.castIconFS.value:="./img/icon_cast_on.png"
	}
	ui.castButtonBg.opt("background" ui.trimColor[1])
	ui.castButtonBg.redraw()
	ui.castButton.setFont("c" ui.trimFontColor[1])
	ui.castButton.redraw()
	ui.castButtonHotkey.setFont("c" ui.trimFontColor[1])
	ui.castButton.redraw()
}
castButtonDim(*) {
	startButtonOn()
	ui.castButtonBg.opt("background" ui.bgColor[4])
	ui.castButtonBg.redraw()
	ui.castButton.setFont("c" ui.trimFontColor[1])
	ui.castButton.redraw()
	ui.castButtonHotkey.setFont("c" ui.trimFontColor[1])
	ui.castButton.redraw()
}

castButtonOff(*) {
	ui.castButtonBg.opt("background" ui.trimDarkColor[1])
	ui.castButtonBg.redraw()
	ui.castButton.setFont("c" ui.trimDarkFontColor[1])
	ui.castButton.redraw()
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


flashRetrieve(*) {
	(tmp.retrieveFlashOn := !tmp.retrieveFlashOn)
		? (ui.reelIconFS.value:="./img/icon_reel_flash.png",ui.retrieveButtonBg.opt("background" ui.trimColor[3]),ui.retrieveButton.opt("c482a11"),ui.retrieveButtonHotkey.opt("c482a11"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
		: (ui.reelIconFS.value:="./img/icon_reel_on.png",ui.retrieveButtonBg.opt("background" ui.trimDarkColor[3]),ui.retrieveButton.opt("c1f1105"),ui.retrieveButtonHotkey.opt("c1f1105"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
}

flashButton(mode) {
	(tmp.%mode%FlashOn := !tmp.%mode%FlashOn)
		? (ui.%mode%ButtonBg.opt("background" ui.trimColor[3]),ui.%mode%Button.opt("c482a11"),ui.%mode%ButtonHotkey.opt("c482a11"),ui.%mode%ButtonBg.redraw(),ui.%mode%Button.redraw())
		: (ui.%mode%ButtonBg.opt("background" ui.trimDarkColor[3]),ui.%mode%Button.opt("c1f1105"),ui.%mode%ButtonHotkey.opt("c1f1105"),ui.%mode%ButtonBg.redraw(),ui.%mode%Button.redraw())
}

flashCast(*) {
	flashButton("cast")
}

flashCancel(*) {
	flashButton("cancel")
}


