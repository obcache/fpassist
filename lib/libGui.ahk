#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off


if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}


this:=object()

ui.fsPanelOffset:=[0,0]
ui.fishGuiFSy:=""
ui.fishGuiFSx:=""

; if ui.fullscreen {
setFScoords()
setFScoords(*) {
	switch a_screenWidth {
		case 3440:
			ui.scaleFactorX:=1
			ui.scaleFactorY:=1
			ui.hookedXfs:=3060																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
			ui.hookedYfs:=1020
			ui.hookedX2fs:=3060
			ui.hookedY2fs:=1020
			ui.hookedColorfs:=[0x1EA9C3,0x1EA9C3]
			ui.reeledInCoord1fs:=[2935,1275]
			ui.reeledInCoord2fs:=[2935,1310]
			ui.reeledInCoord3fs:=[2970,1275]
			ui.reeledInCoord4fs:=[2970,1310]
			ui.reeledInCoord5fs:=[2955,1290]
			ui.fsPanelOffset:=[0,0]
			ui.fishCaughtCoord1fs:=[1836,1240]
			ui.fishCaughtCoord2fs:=[2036,1240]
			ui.fishCaughtColorFs:=[16777215,14642944]
			ui.keepnetX:=116
			ui.keepnetY:=288
			ui.keepnetColor:=0xFFC300
			
		case 2560:
			ui.scaleFactorX:=.95
			ui.scaleFactorY:=1
			ui.hookedXfs:=2184																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
			ui.hookedYfs:=999
			ui.hookedX2fs:=2160
			ui.hookedY2fs:=1000
			ui.hookedColorfs:=[0x1EA9C3,0x1EA9C3]
			ui.reeledInCoord1fs:=[2070,1237]
			ui.reeledInCoord2fs:=[2066,1289]
			ui.reeledInCoord3fs:=[2101,1239]
			ui.reeledInCoord4fs:=[2101,1293]
			ui.reeledInCoord5fs:=[2085,1263]
			ui.fishCaughtCoord1fs:=[1836,1240]
			ui.fishCaughtCoord2fs:=[2036,1240]
			ui.fishCaughtColorFs:=[round(0xF7F7F7),14642944]
			ui.fsPanelOffset:=[-320,0]
			ui.keepnetX:=116
			ui.keepnetY:=288
			ui.keepnetColor:=0xFFC300
			
		case 1920:
			ui.scaleFactorX:=.89
			ui.scaleFactorY:=.95
			ui.hookedXfs:=1630																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
			ui.hookedYfs:=767
			ui.hookedX2fs:=1741
			ui.hookedY2fs:=746
			ui.hookedColorfs:=[0x1EA6C6,0x1EA6C6]
			ui.reeledInCoord1fs:=[1540,955]
			ui.reeledInCoord2fs:=[1540,980]
			ui.reeledInCoord3fs:=[1570,955]
			ui.reeledInCoord4fs:=[1570,980]
			ui.reeledInCoord5fs:=[1558,967]
			ui.fishCaughtCoord1fs:=[1078,915]
			ui.fishCaughtCoord2fs:=[1115,917]
			ui.fishCaughtColorFs:=[round(0xFFFFFF),round(0xFFFFFF)]
			ui.fsPanelOffset:=[-200,0]		
			ui.keepnetX:=88
			ui.keepnetY:=211
			ui.keepnetColor:=0xFFC300
			
		DEFAULT:
			ui.scaleFactorX:=.89
			ui.scaleFactorY:=.95
			
			ui.hookedXfs:=1641																																																																																																																																																																																																																																																																																																																																																																																																																																																																		
			ui.hookedYfs:=747
			ui.hookedColorfs:=[0x1EA6C6]

			ui.reeledInCoord1fs:=[1577,930]
			ui.reeledInCoord2fs:=[1551,930]
			ui.reeledInCoord3fs:=[1577,956]
			ui.reeledInCoord4fs:=[1551,956]
			ui.reeledInCoord5fs:=[1568,940]
			ui.fsPanelOffset:=[-200,0]
			ui.keepnetX:=116
			ui.keepnetY:=288
			ui.keepnetColor:=0xFFC300
	}
	
	ui.reeledInCoord1:=ui.reeledInCoord1fs
	ui.reeledInCoord2:=ui.reeledInCoord2fs
	ui.reeledInCoord3:=ui.reeledInCoord3fs
	ui.reeledInCoord4:=ui.reeledInCoord4fs
	ui.reeledInCoord5:=ui.reeledInCoord5fs
	ui.hookedX:=ui.hookedXfs
	ui.hookedY:=ui.hookedYfs
	ui.hookedX2:=ui.hookedX2fs
	ui.hookedY2:=ui.hookedY2fs
	ui.hookedColor:=ui.hookedColorfs
	ui.fishCaughtCoord1:=ui.fishCaughtCoord1fs
	ui.fishCaughtCoord2:=ui.fishCaughtCoord2fs
	ui.fishCaughtColor:=ui.fishCaughtColorFs
	
;MSGbOX(ui.reeledInCoord5fs[1] "`n" ui.reeledInCoord5fs[2])
}


toggleKeepnet(*) {
	while cfg.keepnetEnabled.length < cfg.profileSelected
		cfg.keepnetEnabled.push(false)
	cfg.keepnetEnabled[cfg.profileSelected] := ui.keepnetEnabled.value
	keepnetEnabledStr := ""
	loop cfg.keepnetEnabled.length {
		keepnetEnabledStr.=cfg.keepnetEnabled[a_index] ","
	}
	iniWrite(rtrim(keepnetEnabledStr,","),cfg.file,"Game","KeepnetEnabled")	
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
		ui.logGui.opt("-caption toolWindow alwaysOnTop owner" winGetId(ui.game))
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
		winGetPos(&tX,&tY,&tW,&tH,winGetId(ui.game))
		ui.logGui.show("x" tX+tW+8 " y" tY " w600 h835")
	}
	showLog(*) {
	if monitorGetCount() > 1 {
		vdLeft:=sysGet("76")
		vdWidth:=sysGet("78")
		vdRight:=vdLeft+vdWidth

		winGetPos(&gX,&gY,&gW,&gH,ui.game)
		if gX+gW+600 > vdRight {
			logX:=gX-600
			monitorGet(monitorGetPrimary()+1,&lmL,&lmT,&lmR,&lmB)
			logY:=lmT
		} else {
			logX:=gX+gW
			monitorGet(monitorGetPrimary()-1,&lmL,&lmT,&lmR,&lmB)
			logY:=lmT
		}
	} else {
		logX:=0
		logY:=0
	}

	; ui.logGui.show("x" logX " y" logY)
	; guiVis(ui.logGui,true)
	; guiVis(ui.fishGui,false)
}
	
goFS(*) {
	ui.fullscreen := true
	setFScoords()
	guiVis(ui.fishGuiFS,true)
	;ui.fishCountFS.redraw()
	; ui.fishCountLabelFS.redraw()
	; ui.fishCountLabel2FS.redraw()
	;guiVis(ui.fishGui,false)
	monitorGetWorkArea(monitorGetPrimary(),&l,&t,&r,&b)
	;msgBox(r "`n" b)
	winMove(0,0,r,b,ui.game)	
	; winSetTransparent(160,ui.fishGuiFsBg)
	; winMinimize(ui.game)
	; winRestore(ui.game)
	ui.reeledInCoord1:=ui.reeledInCoord1fs
	ui.reeledInCoord2:=ui.reeledInCoord2fs
	ui.reeledInCoord3:=ui.reeledInCoord3fs
	ui.reeledInCoord4:=ui.reeledInCoord4fs
	ui.reeledInCoord5:=ui.reeledInCoord5fs
	;msgBox(ui.reeledInCoord1[1] ":" ui.reeledInCoord1[2] "`n" ui.reeledInCoord2[1] ":" ui.reeledInCoord2[2] "`n" ui.reeledInCoord3[1] ":" ui.reeledInCoord3[2])
	ui.hookedX:=ui.hookedXfs
	ui.hookedY:=ui.hookedYfs
	;createGuiFS()
	
	logViewer()		
	showLog()
	;click()
}
	
createGuiFS(*) {
	ui.fsPanel := object()
	ui.fsIcons := object()
	ui.fsIcons.xOffset := map(3440,0,2560,8,1920,60)
	ui.fsIcons.x := map(3440,2708,2560,1800,1920,1190)
	ui.fsIcons.y := map(3440,1,2560,5,1920,0)
	ui.fsIcons.w := map(3440,90,2560,80,1920,30)
	ui.fsIcons.h := map(3440,30,2560,80,1920,30)
	ui.fsPanel.x := 550
	ui.fsPanel.y := 830
	ui.fsPanel.w := 60
	ui.fsPanel.h := 20
	ui.fishGuiFSx := 800
	ui.fishGuiFSy := a_screenHeight-30-200-184

	monitorGetWorkArea(monitorGetPrimary(),&mX,&mY,&mW,&mH)	
	
	ui.fishGuiFS := gui()
	ui.fishGuiFS.name:="fishGuiFS"
	ui.fishGuiFS.opt("-caption -border +toolWindow owner" winGetId(ui.game))
	ui.fishGuiFS.backColor := "010203"

	; ui.noFSbutton := ui.fishGuiFS.addPicture("HIDDEN x" a_screenwidth-50 " y" ui.fsIcons.y[a_screenwidth]-2 " w41 h41 backgroundTrans","./img/button_nofs.png")
	; ui.noFSbutton.onEvent("click",noFS)

	ui.actionBorder := ui.fishGuiFS.addPicture("section x" ui.fsIcons.x[a_screenwidth]-70 " y" ui.fsIcons.y[a_screenwidth] " w710 h36 center backgroundTrans c" ui.trimFontColor[6],"./img/profileFS_border.png")
	ui.actionBg :=ui.fishGuiFS.addText("x" ui.fsIcons.x[a_screenwidth]-58 " y" ui.fsIcons.y[a_screenwidth]+4 " h29 w70 background" ui.bgColor[3])
	ui.fishCountBorder := ui.fishGuiFS.addPicture("section x" ui.fsIcons.x[a_screenwidth] " y" ui.fsIcons.y[a_screenwidth] " w730 h36 center background" ui.bgColor[3] " c" ui.trimFontColor[6],"./img/profileFS_border.png")
	ui.profileBorder := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth] " y" ui.fsIcons.y[a_screenwidth] " w560 h36 center background" ui.bgColor[2] " c" ui.trimFontColor[6],"./img/profileFS_border.png")
	ui.panelBg :=ui.fishGuiFS.addText("x" ui.fsIcons.x[a_screenwidth]+12 " y" ui.fsIcons.y[a_screenwidth]+4 " h29 w536 background" ui.bgColor[3])
	ui.panelBg2 :=ui.fishGuiFS.addText("x" ui.fsIcons.x[a_screenwidth]+560 " y" ui.fsIcons.y[a_screenwidth]+4 " h29 w156 background" ui.bgColor[3])
	
	ui.action := ui.fishGuiFS.addText("center x" ui.fsIcons.x[a_screenwidth]-56 " y" ui.fsIcons.y[a_screenwidth]+3 " w54 h30 backgroundTrans","Idle")
	ui.action.setFont("q5 s18 c" ui.fontColor[2],"Calibri")
	ui.profilePrevFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+14 " y" ui.fsIcons.y[a_screenwidth]+6 " w20 h26 background" ui.bgColor[3],"./img/button_arrowLeft_knot.png")
	ui.profileNextFS := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+108 " y" ui.fsIcons.y[a_screenwidth]+6 " w20 h26 background" ui.bgColor[3],"./img/button_arrowRight_knot.png")
	ui.profileSelectedBg := ui.fishGuiFS.addText("center x" ui.fsIcons.x[a_screenwidth]+130 " y" ui.fsIcons.y[a_screenwidth]+5 " w340 h28 center background" ui.bgColor[3] " c" ui.trimFontColor[6])
	ui.profileSelectedFS := ui.fishGuiFS.addText("center x" ui.fsIcons.x[a_screenwidth]+130 " y" ui.fsIcons.y[a_screenwidth]+3 " w340 h28 center backgroundTrans c" ui.trimFontColor[6],cfg.profileName[cfg.profileSelected])
	ui.helpButton := ui.fishGuiFS.addText("x" ui.fsIcons.x[a_screenwidth]+470 " y" ui.fsIcons.y[a_screenwidth]+4 " w24 h24 backgroundTrans c" ui.fontColor[1],"s")
	ui.helpButton.setFont("s19 c" ui.trimFontColor[6],"Webdings")
	ui.helpButton.onEvent("click",toggleHelp)
	ui.profileEdit := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+496 " y" ui.fsIcons.y[a_screenwidth]+8 " w20 h20 backgroundTrans","./img/button_settings.png")
	ui.profileEdit.onEvent("click",toggleEditor)
	ui.viewLog := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+523 " y" ui.fsIcons.y[a_screenwidth]+5 " w20 h26 background" ui.bgColor[3],"./img/button_folder.png")
	ui.viewLog.onEvent("click",launchLogViewer)
	ui.fs_profileNewButton := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+144+ui.fsIcons.xOffset[a_screenWidth]+ui.fsIcons.w[a_screenwidth]-194 " y" ui.fsIcons.y[a_screenwidth]+9 " w20 h20 backgroundTrans","./img/button_new.png")
	ui.fs_profileDeleteButton := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+144+ui.fsIcons.xOffset[a_screenWidth]+ui.fsIcons.w[a_screenwidth]-148 " y" ui.fsIcons.y[a_screenwidth]+9 " w20 h20 backgroundTrans","./img/button_delete.png")
	ui.fs_profileSaveCancelButton := ui.fishGuiFS.addPicture("hidden x" ui.fsIcons.x[a_screenwidth]+144+ui.fsIcons.xOffset[a_screenWidth]+ui.fsIcons.w[a_screenwidth]-194 " y" ui.fsIcons.y[a_screenwidth]+9 " w20 h19 backgroundTrans","./img/button_cancel.png")
	ui.fs_profileSaveCancelButton.onEvent("click",cancelEditProfileName)
	ui.fs_profileSaveButton := ui.fishGuiFS.addPicture("hidden x" ui.fsIcons.x[a_screenwidth]+144+ui.fsIcons.xOffset[a_screenwidth]+ui.fsIcons.w[a_screenwidth]-170 " y" ui.fsIcons.y[a_screenwidth]+9 " w20 h20 backgroundTrans","./img/button_save.png")
	ui.fs_profileEditButton := ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+144+ui.fsIcons.xOffset[a_screenwidth]+ui.fsIcons.w[a_screenwidth]-170 " y" ui.fsIcons.y[a_screenwidth]+9 " w20 h20 backgroundTrans","./img/button_edit.png")
	ui.fs_profileSaveButton.onEvent("click",saveProfileNameFS)
	ui.fs_profileEditButton.onEvent("click",editProfileNameFS)
	ui.fs_profileNewButton.onEvent("click",newProfileNameFS)
	ui.fs_profileDeleteButton.onEvent("click",deleteProfileNameFS)
	;ui.fishGuiFS.onEvent("escape",cancelEditProfileName)
	ui.profileSelectedFS.setFont("s19 cFFFFFF q5","Calibri")
	ui.fishCount:=" " format("{:05i}",iniRead(cfg.file,"Game","fishCount",0)) " "
	ui.fishCountText:=ui.fishGuiFS.addText("right x" ui.fsIcons.x[a_screenwidth]+556 " y" ui.fsIcons.y[a_screenwidth]+0 " w160 h30 right backgroundTrans  c" ui.trimFontColor[6],ui.fishCount)
	ui.fishCountIcon:=ui.fishGuiFS.addPicture("x" ui.fsIcons.x[a_screenwidth]+568 " y" ui.fsIcons.y[a_screenwidth]+6 " h26 w-1 backgroundTrans","./img/icon_fish.png")
	ui.fishCountText.setFont("s22 cFFFFFF","Impact")
	ui.profilePrevFS.onEvent("click",profileLArrowClicked)
	ui.profileNextFS.onEvent("click",profileRArrowClicked)
	

	; ui.fishCount1:=ui.fishGuiFS.addPicture("hidden x+-520 ys+5 h" ui.scaleFactorX*46 " w-1","./img/0.png")
	; ui.fishCount2:=ui.fishGuiFS.addPicture("hidden x+0 ys+5 h" ui.scaleFactorX*46 " w-1","./img/0.png")
	; ui.fishCount3:=ui.fishGuiFS.addPicture("hidden x+0 ys+5 h" ui.scaleFactorX*46 " w-1","./img/0.png")
	; ui.fishCount4:=ui.fishGuiFS.addPictur e("hidden x+0 ys+5 h" ui.scaleFactorX*46 " w-1","./img/0.png")
	; ui.fishCount5:=ui.fishGuiFS.addPicture("hidden x+0 ys+5 h" ui.scaleFactorX*46 " w-1","./img/0.png")
	; ui.toggleEnabledFS := ui.fishGuiFS.addPicture("hidden x" ui.fsIcons.x[a_screenwidth]-57 " y" ui.fsIcons.y[a_screenwidth]+3 " h6 w56 backgroundTrans","./img/toggle_horz_off.png")
	; ui.toggleEnabledFS.onEvent("click",toggleEnabled)
	ui.fishCountBorder.opt("-hidden")
	ui.toggleLabelOutline:=ui.fishGuiFS.addPicture("hidden x" ui.fsIcons.x[a_screenwidth]+350 " y" ui.fsIcons.y[a_screenwidth]+0 " w380 h36 backgroundTrans","./img/profileFS_border.png")
	ui.toggleLabelBg:=ui.fishGuiFS.addText("hidden x" ui.fsIcons.x[a_screenwidth]+370 " y" ui.fsIcons.y[a_screenwidth]+2 " w370 h34 backgroundTrans")
	ui.toggleLabel:=ui.fishGuiFS.addText("hidden x" ui.fsIcons.x[a_screenwidth]+365 " y" ui.fsIcons.y[a_screenwidth]+0 " w400 h40 backgroundTrans","PAUSE Key to toggle fpAssist")
	ui.toggleLabel.setFont("s22 cffffff bold q5","Calibri")
	
	ui.fishLogFS := ui.fishGuiFS.addText("hidden x95 y350 w360 h450 backgroundTrans c" ui.fontColor[3],"")
	ui.fishGuiFS.setFont("s12")
	ui.fsIcons.x[a_screenwidth]-=(a_screenwidth==3440) ? 215 : (a_screenwidth==2560) ? 160 : 100
	ui.fsIcons.y[a_screenwidth]-=(a_screenwidth==3440) ? 25 : (a_screenwidth==2560) ? 25 : -21

	ui.castIconFS := ui.fishGuiFS.addPicture("hidden section x" ui.fsIcons.x[a_screenwidth]+380 " y" ui.fsIcons.y[a_screenwidth]+(a_screenheight-840) " w" ui.fsIcons.w[a_screenwidth] " h" ui.fsIcons.h[a_screenwidth] " backgroundTrans c" ui.bgcolor[2],"./img/icon_cast.png")
	ui.castIconFS.onEvent("click",startButtonClicked)
	ui.retrieveIconFS := ui.fishGuiFS.addPicture("hidden xs+0 y+30 w" ui.fsIcons.w[a_screenwidth] " h" ui.fsIcons.w[a_screenwidth] " backgroundTrans","./img/icon_retrieve.png")
	ui.retrieveIconFS.onEvent("click",retrieveButtonClicked)
	ui.reelIconFS := ui.fishGuiFS.addPicture("hidden xs+0 y+30 w" ui.fsIcons.w[a_screenwidth] " h" ui.fsIcons.w[a_screenwidth] " backgroundTrans","./img/icon_reel.png")
	ui.reelIconFS.onEvent("click",reelButtonClicked)
	
	guiVis(ui.fishGuiFS,false)
	ui.fishGuiFS.show("x0 y0 w" a_screenWidth " h" a_screenHeight)
}

;drawButton(x,y,w,h) {
		; ui.fishGui.addText("x" x " y" y " w" w " h" h " background" ui.bgColor[3])
		; ui.fishGui.addText("x" x+1 " y" y+1 " w" w-2 " h" h-2 " background" ui.bgColor[4])
;}



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
	ui.statCastLength := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2],cfg.castLength[cfg.profileSelected])
	
	ui.statFishCountLabel := ui.fishGui.addText("x+-35 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Fish Count: ")
	ui.statFishCount := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2], ui.fishLogCount.text)
	
	ui.statAfkStartTimeLabel := ui.fishGui.addText("xs-320 y+0 right section w80 r1 backgroundTrans c" ui.fontColor[2],"Start: ")
	ui.statAfkStartTime := ui.fishGui.addText("x+0 ys w130 r1 backgroundTrans c" ui.fontColor[2],formatTime(,"yyyy-MM-dd@HH:mm:ss"))
	
	ui.statDragLevelLabel := ui.fishGui.addText("x+-15 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Drag: ")
	ui.statDragLevel := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2],ui.%ui.fishGui.name%_dragLevel.value)
	
	ui.statCastCountLabel := ui.fishGui.addText("x+-35 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Cast Count: ")
	ui.statCastCount := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2], "000")
	
	ui.statAfkDurationLabel := ui.fishGui.addText("xs-320 y+0 right section w80 r1 backgroundTrans c" ui.fontColor[2],"Duration: ")
	ui.statAfkDuration := ui.fishGui.addText("x+0 ys w130 r1 backgroundTrans c" ui.fontColor[2],"")
	
	ui.statReelSpeedLabel := ui.fishGui.addText("x+-15 ys right section w80 r1 backgroundTrans c" ui.fontColor[2],"Speed: ")
	ui.statReelSpeed := ui.fishGui.addText("x+0 ys w80 r1 backgroundTrans c" ui.fontColor[2],ui.%ui.fishGui.name%_reelSpeed.value)
	
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
		ui.notifyGui.addPicture("x0 y0 w" a_screenwidth " h" a_screenheight,"./img/fp_splash.png")
		ui.loadingProgress := ui.notifyGui.addProgress("smooth x2 y" a_screenheight-30 " w" a_screenwidth " h57 c202020 background404040")
		ui.loadingProgress.value := 0
		if winExist(ui.game) {
			setTimer(startupProgress,32)
		} else {
			setTimer(startupProgress0,200)
		}
		ui.loadingProgress2 := ui.notifyGui.addProgress("smooth x2 y" a_screenheight-2 " w" a_screenwidth " h2 c707070 background404040")
		ui.loadingProgress2.value := 0
		if winExist(ui.game) {
			setTimer(startupProgress,32)
		} else {
			setTimer(startupProgress0,200)
		}

		ui.notifyGui.AddText("xs hidden")
		ui.notifyGui.show("x0 y0 w" a_screenwidth " h" a_screenheight " noActivate")
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
			;setTimer () => detectPrompts(1),-6000
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
	; ui.cancelButtonBg.opt("background" ui.trimColor[2])
	; ui.cancelButtonBg.redraw()
	; ui.cancelButton.setFont("c" ui.trimFontColor[2])
	; ui.cancelButton.redraw()
	; ui.cancelButtonHotkey.setFont("c" ui.trimFontColor[2])
	; ui.cancelButtonHotkey.redraw()
}

cancelButtonOff(*) {
	; ui.cancelButtonBg.opt("background" ui.trimDarkColor[2])
	; ui.cancelButtonBg.redraw()
	; ui.cancelButton.setFont("c" ui.trimDarkFontColor[2])
	; ui.cancelButton.redraw()
	; ui.cancelButtonHotkey.setFont("c" ui.trimDarkFontColor[2])
	; ui.cancelButtonHotkey.redraw()
}

startButtonOff(*) {
	; ui.startButtonBg.opt("background" ui.trimDarkColor[1])
	; ui.startButtonBg.redraw()
	; ui.startButton.setFont("c" ui.trimDarkFontColor[1])
	; ui.startButton.redraw()
	; ui.startButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	; ui.startButton.redraw()
}

startButtonDim(*) {
	; ui.startButtonBg.opt("background" ui.trimColor[3])
	; ui.startButtonBg.redraw()
	; ui.startButton.setFont("c" ui.trimFontColor[3])
	; ui.startButton.redraw()
	; ui.startButtonHotkey.setFont("c" ui.trimFontColor[3])
	; ui.startButton.redraw()
	; cancelButtonOn()
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
	; ui.castButtonBg.opt("background" ui.trimColor[1])
	; ui.castButtonBg.redraw()
	; ui.castButton.setFont("c" ui.trimFontColor[1])
	; ui.castButton.redraw()
	; ui.castButtonHotkey.setFont("c" ui.trimFontColor[1])
	; ui.castButton.redraw()
}
castButtonDim(*) {
	; startButtonOn()
	; ui.castButtonBg.opt("background" ui.bgColor[4])
	; ui.castButtonBg.redraw()
	; ui.castButton.setFont("c" ui.trimFontColor[1])
	; ui.castButton.redraw()
	; ui.castButtonHotkey.setFont("c" ui.trimFontColor[1])
	; ui.castButton.redraw()
}

castButtonOff(*) {
	; ui.castButtonBg.opt("background" ui.trimDarkColor[1])
	; ui.castButtonBg.redraw()
	; ui.castButton.setFont("c" ui.trimDarkFontColor[1])
	; ui.castButton.redraw()
	; ui.castButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	; ui.castButtonHotkey.redraw()
}

reelButtonOn(*) {
		; ui.reelButtonBg.opt("background" ui.trimColor[1])
		; ui.reelButtonBg.redraw()
		; ui.reelButton.setFont("c" ui.trimFontColor[1])
		; ui.reelButton.redraw()
		; ui.reelButtonHotkey.setFont("c" ui.trimFontColor[1])
		; ui.reelButtonHotkey.redraw()	
		; cancelButtonOn()
}

reelButtonOff(*) {
	; ui.reelButtonBg.opt("background" ui.trimDarkColor[1])
	; ui.reelButtonBg.redraw()
	; ui.reelButton.setFont("c" ui.trimDarkFontColor[1])
	; ui.reelButton.redraw()
	; ui.reelButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	; ui.reelButtonHotkey.redraw()
}

retrieveButtonOn(*) {
	; ui.retrieveButtonBg.opt("background" ui.trimColor[1])
	; ui.retrieveButtonBg.redraw()
	; ui.retrieveButton.setFont("c" ui.trimFontColor[1])
	; ui.retrieveButton.redraw()
	; ui.retrieveButtonHotkey.setFont("c" ui.trimFontColor[1])
	; ui.retrieveButtonHotkey.redraw()
	; cancelButtonOn()
}

retrieveButtonOff(*) {
	; ui.retrieveButtonBg.opt("background" ui.trimDarkColor[1])
	; ui.retrieveButtonBg.redraw()
	; ui.retrieveButton.opt("c" ui.trimDarkFontColor[1])
	; ui.retrieveButton.redraw()
	; ui.retrieveButtonHotkey.opt("c" ui.trimDarkFontColor[1])
	; ui.retrieveButtonHotkey.redraw()
}


flashRetrieve(*) {
	; (tmp.retrieveFlashOn := !tmp.retrieveFlashOn)
		; ? (ui.reelIconFS.value:="./img/icon_reel_flash.png",ui.retrieveButtonBg.opt("background" ui.trimColor[3]),ui.retrieveButton.opt("c482a11"),ui.retrieveButtonHotkey.opt("c482a11"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
	; : (ui.reelIconFS.value:="./img/icon_reel_on.png",ui.retrieveButtonBg.opt("background" ui.trimDarkColor[3]),ui.retrieveButton.opt("c1f1105"),ui.retrieveButtonHotkey.opt("c1f1105"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
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






	launchLogViewer(fullscreen,*) {
		static launchLogState:=false
		(launchLogState:=!launchLogState) ? showLogScreen() : hideLogScreen()
		
		showLogScreen(*) {
			guiVis(ui.logGui,true)
			;winGetPos(&tX,&tY,&tW,&tH,ui.fishGuiFS.hwnd)
			;ui.logGui.show("x" tX+tW+1 " y" tY " w600 h" tH)
		}
		hideLogScreen(*) {
			guiVis(ui.logGui,false)
		}
	}
	