#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

osdNotify(msg) {
	winGetPos(&x,&y,&w,&h,ui.fishGui)	
	msgWidth := strLen(msg)*5
	ui.osdNotify := ui.fishGui.addText("-hidden x" (w/2)-(msgWidth/2) " y100 w" msgWidth " h50 backgroundTrans cEEEEEE",msg)
	setTimer () => ui.osdNotify.opt("hidden"),-5000
}

themeDef(themeNum:=1,*) {
	switch themeNum {
		case 1:
			ui.bgColor 				:= ["202020","323032","636363","1B1A1C","DFDFFF","999999"]
			ui.fontColor 			:= ["151415","A0AFB5","D0D5FF","666666","353535","50556F"]
			ui.trimColor 			:= ["DFDFFF","6d0f0f","f39909","11EE11","EE1111","303030"]
			ui.trimDarkColor 		:= ["101011","2d0f0f","7b4212","11EE11","EE1111","303030"]
			ui.trimFontColor 		:= ["282828","d0b7b4","44DDCC","11EE11","EE1111","DEDEDE"]
			ui.trimDarkFontColor 	:= ["9595A5","9595A5","44DDCC","11EE11","EE1111","303030"]
			case 2:
			ui.bgColor 				:= ["202020","323032","454548","1B1A1C","DFDFFF","999999"]
			ui.fontColor 			:= ["151415","A0AFB5","D0D5FF","666666","353535","50556F"]
			ui.trimColor 			:= ["DFDFFF","6d0f0f","44DDCC","11EE11","EE1111","303030"]
			ui.trimDarkColor 		:= ["101011","2d0f0f","44DDCC","11EE11","EE1111","303030"]
			ui.trimFontColor 		:= ["282828","d0b7b4","44DDCC","11EE11","EE1111","303030"]
			ui.trimDarkFontColor 	:= ["9595A5","9595A5","44DDCC","11EE11","EE1111","303030"]
		case 3:
			ui.bgColor 				:= ["202020","323032","454548","1B1A1C","DFDFFF","999999"]
			ui.fontColor 			:= ["151415","A0AFB5","D0D5FF","666666","353535","50556F"]
			ui.trimColor 			:= ["DFDFFF","6d0f0f","44DDCC","11EE11","EE1111","303030"]
			ui.trimDarkColor 		:= ["101011","2d0f0f","44DDCC","11EE11","EE1111","303030"]
			ui.trimFontColor 		:= ["282828","d0b7b4","44DDCC","11EE11","EE1111","303030"]
			ui.trimDarkFontColor 	:= ["9595A5","9595A5","44DDCC","11EE11","EE1111","303030"]
	}
}
;setTimer(menuCheck,1000)
menuCheck(*) {
	static guiVisible:=true
		if winActive(ui.game)
			if pixelGetColor(557,187)=="0xEFD070" {
				if guiVisible {
					guiVisible:=false
					guiVis(ui.fishGuiFS,false)
				}
			} else {
				if !guiVisible {
					guiVis(ui.fishGuiFS,true)
					guiVisible:=true
				}
			}
	}
initVars(*) {
	cfg.profile 			:= array()
	ui.fishLogArr 			:= array()
	ui.sliderList 			:= array()
	ui.mode					:= "off"
	cfg.file 				:= a_appName ".ini"
	cfg.installDir 			:= a_mydocuments "\" a_appName "\"
	
	ui.gameExe 				:= "fishingPlanet.exe"
	ui.game 				:= "ahk_exe " ui.gameExe

	cfg.buttons 			:= ["startButton","castButton","retrieveButton","reelButton","cancelButton","reloadButton","exitButton"]
	;cfg.profileSettings 	:= ["profileName","castLength","castTime","sinkTime","reelSpeed","dragLevel","landAggro","twitchFreq","stopFreq","reelFreq","BoatEnabled","floatEnabled","bgModeEnabled"]
	;cfg.profileDefaults 	:= {"NewProfile","1900","1","1","1","1","1","1","1","0","0","0"]

	cfg.profileSetting := map()
		
	cfg.profileSetting["profileName"] := "NewProfile"
	cfg.profileSetting["castLength"] := "1900"
	cfg.profileSetting["castTime"] := "1"
	cfg.profileSetting["sinkTime"] := "1"
	cfg.profileSetting["reelSpeed"] := "1"
	cfg.profileSetting["dragLevel"] := "1"
	cfg.profileSetting["landAggro"] := "1"
	cfg.profileSetting["twitchFreq"] := "1"
	cfg.profileSetting["stopFreq"] := "1"
	cfg.profileSetting["reelFreq"] := "1"
	cfg.profileSetting["keepnetEnabled"] := "0"
	cfg.profileSetting["floatEnabled"] := "0"
	cfg.profileSetting["bgModeEnabled"] := "0"
	cfg.profileSetting["recastTime"] := "5"
	cfg.profileSetting["keepnetEnabled"] := 0
	
	tmp.beenPaused			:= false
	tmp.retrieveFlashOn 	:= false
	ui.greenCheckColor 		:= round(0x7ED322)
	ui.sessionStartTime 	:= A_Now
	ui.enabled 				:= true
	cfg.emptyKeepnet 		:= false
	ui.isAFK 				:= false
	ui.isFS 				:= false
	ui.fullscreen 			:= false
	ui.isHooked				:= false
	ui.reeledIn 			:= false
	ui.cancelOperation 		:= false
	ui.casting 				:= false
	ui.autoclickerActive 	:= false
	ui.fishCount 			:= ""
	ui.castCount 			:= 0
	ui.runCount				:= 0
	ui.scaleFactorX		:= 1
	ui.scaleFactorY		:= 1
	tmp.h					:= 40
	ui.currDrag 			:= 0
	defaultValue 			:= 0
	ui.secondsElapsed 		:= 0
	ui.loadingProgress 		:= 5
	ui.loadingProgress2 	:= 5
	ui.playAniStep 			:= 0
	ui.startKey 			:= "f"
	ui.cancelKey 			:= "q"
	ui.reloadKey 			:= "F5"
	ui.castKey 				:= "c"
	ui.reelKey 				:= "r"
	ui.reelKeyFS			:= "^+space"
	ui.exitKey 				:= "F4"
	ui.retrieveKey 			:= "v"
	ui.flashlight 			:= "+F"
	ui.keepnetNumber		:= 1
	ui.startKeyMouse 		:= "!LButton"
	ui.stopKeyMouse 		:= "!RButton"
	ui.lastMsg 				:= ""
	ui.lastMode 			:= 0
	ui.cycleStartTime		:= 0

	
	ui.hookedColorstd:=[0x1DECFE,0x1EA9C3,0x419AAC]
	
	ui.hooked1std:=[1090,510]
	ui.hooked2std:=[1100,510]
	
	ui.reeledInCoord1std:=[1026,635]
	ui.reeledInCoord2std:=[1047,635]
	ui.reeledInCoord3std:=[1026,656]
	ui.reeledInCoord4std:=[1047,656]
	ui.reeledInCoord5std:=[1036,644]
	
	ui.fishCaughtCoord1Std:=[1836,1240]
	ui.fishCaughtColorStd:=[0xEF7F00]
	
	ui.hookedCoord1:=ui.hooked1std
	ui.hookedCoord2:=ui.hooked2std
	
	
	ui.reeledInCoord1:=ui.reeledInCoord1std
	ui.reeledInCoord2:=ui.reeledInCoord2std
	ui.reeledInCoord3:=ui.reeledInCoord3std
	ui.reeledInCoord4:=ui.reeledInCoord4std
	ui.reeledInCoord5:=ui.reeledInCoord5std
	ui.hookedX:=ui.hookedCoord1[1]
	ui.hookedY:=ui.hookedCoord1[2]
	ui.hookedX2:=ui.hookedCoord2[1]
	ui.hookedY2:=ui.hookedCoord2[2]
	ui.hookedColor:=ui.hookedColorStd
	ui.fishCaughtCoord1:=ui.fishCaughtCoord1Std
	ui.fishCaughtColor:=ui.fishCaughtColorStd
	
	setcapsLockState(false)
}

cfgWrite(*) {
	for setting,default in cfg.profileSetting {
		ui.%setting%Str := ""
		if setting != "profileName" {
			while cfg.%setting%.length < cfg.profileName.length
				cfg.%setting%.push(cfg.%setting%[cfg.profileSelected])
			}
			for profile in cfg.profileName {
				ui.%setting%Str .= cfg.%setting%[a_index] ","
			}
		iniWrite(rtrim(ui.%setting%Str,","),cfg.file,"Game",setting)
	}
	iniWrite(cfg.profileSelected,cfg.file,"Game","ProfileSelected")
	iniWrite(cfg.rodCount,cfg.file,"Game","RodCount")
	ui.fishGui.getPos(&guiX,&guiY,&guiW,&guiH)
	iniWrite(guiX,cfg.file,"System","GuiX")
	iniWrite(guiY,cfg.file,"System","GuiY")
	iniWrite(guiW,cfg.file,"System","GuiW")
	iniWrite(guiH,cfg.file,"System","GuiH")
	iniWrite(ui.fullscreen,cfg.file,"Game","Fullscreen")
	if ui.fishLogCount.text < ui.bigfishCount.text	
		ui.fishLogCount.text:=ui.bigfishCount.text
	iniWrite(ui.fishLogCount.text,cfg.file,"Game","fishCount")
}

cfgLoad(*) {
	timeStamp:=formatTime(,"yyyyMMddhhmmss")
	ui.logFile:="./logs/log_fpassist_" timeStamp ".txt"
	ui.fishLogFile:="./logs/current_fish_data.txt"
	if !fileExist(ui.fishLogFile)
		 fileAppend('"Session Start","AFK Start","AFK Duration","Fish Caught","Cast Count","Cast Length","Drag Level","Reel Speed"`n',ui.fishLogFile)
	if !fileExist(ui.logFile)
		 fileAppend('"Timestamp","LogMessage"`n',ui.logFile)

	for setting,default in cfg.profileSetting {
		 cfg.%setting% := strSplit(iniRead(cfg.file,"Game",setting,default),",")
	}
	
	ui.fullscreen			:= iniRead(cfg.file,"Game","Fullscreen",0)
	cfg.profileSelected 	:= iniRead(cfg.file,"Game","ProfileSelected",1)
	cfg.debug 				:= iniRead(cfg.file,"System","Debug",2)
	cfg.rodCount 			:= iniRead(cfg.file,"Game","RodCount",6)
	ui.currentRod 			:= iniRead(cfg.file,"Game","CurrentRod",1)
	ui.fishCountText		:= iniRead(cfg.file,"Game","fishCount",0)


}

initTrayMenu(*) {
	A_TrayMenu.Delete
	A_TrayMenu.Add
	A_TrayMenu.Add("Show Window", restoreWin)
	A_TrayMenu.Add("Hide Window", HideGui)
	A_TrayMenu.Add("Reset Window Position", ResetWindowPosition)
	A_TrayMenu.Add()
	A_TrayMenu.Add("Toggle Log Window", toggleConsole)
	A_TrayMenu.Add()
	A_TrayMenu.Add("Exit App", KillMe)
	A_TrayMenu.Default := "Show Window"
}

isFS(*) {
	if ui.fullscreen
		return 1
	else
		return 0
}

checkMode(*) {
	(ui.visible)
		? (!(pixelGetColor(98,53)=="0xF7F7F7" || pixelGetColor(70,37)=="0xF7F7F7") && (pixelGetColor(107,56)=="0xF7F7F7" || pixelGetColor(80,37)=="0xF7F7F7"))
			? 0 
			: guiVis(ui.fishGuiFS,false)
		: (!(pixelGetColor(98,53)=="0xF7F7F7" || pixelGetColor(70,37)=="0xF7F7F7") && (pixelGetColor(107,56)=="0xF7F7F7" || pixelGetColor(80,37)=="0xF7F7F7"))
			? guiVis(ui.fishGuiFS,true)
			: 0
}

guiVis(guiName,isVisible:= true) {
	if (isVisible) {
		WinSetTransparent(255,guiName)
		WinSetTransparent("Off",guiName)
		WinSetTransColor("010203",guiName)
		ui.visible:=true
	} else {
		WinSetTransparent(0,guiName)
		ui.visible:=false

	}
}

notifyOSD(notifyMsg,relativeControl := ui.fishGui,duration := 3000,alignment := "Left",YN := "") {
	if !InStr("LeftRightCenter",Alignment)
		Alignment := "Left"
		
	Transparent := 250
	try
		ui.notifyGui.Destroy()
	ui.notifyGui			:= Gui()
	ui.notifyGui.Title 		:= "Notify"

	ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow +Owner" ui.fishGui.hwnd)  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	ui.notifyGui.BackColor := ui.bgColor[2]  ; Can be any RGB color (it will be made transparent below).
	ui.notifyGui.SetFont("s16")  ; Set a large font size (32-point).
	ui.notifyGui.AddText("w262 h58 c" ui.fontColor[2] " " Alignment " BackgroundTrans",NotifyMsg)  ; XX & YY serve to 00auto-size the window.
	ui.notifyGui.AddText("xs hidden")

	WinSetTransparent(0,ui.notifyGui)
	ui.notifyGui.Show("NoActivate Autosize")  ; NoActivate avoids deactivating the currently active window.
	ui.notifyGui.GetPos(&x,&y,&w,&h)
	ui.profileText.getPos(&guiX,&guiY,&guiW,&guiH)
	ui.notifyGui.Show("x" (GuiX+(GuiW/2)-(w/2)+20) " y" GuiY+(13-(h/2))+6  "w262 h58 NoActivate")
	guiVis(ui.notifyGui,true)
	drawOutlineNamed("notify2",ui.notifyGui,1,1,260,56,ui.bgColor[3],ui.bgColor[1])
	if (YN) {
		ui.notifyGui.AddText("xs hidden")
		ui.notifyYesButton := ui.notifyGui.AddPicture("ys x30 y30","./Img/button_yes.png")
		ui.notifyYesButton.OnEvent("Click",notifyConfirm)
		ui.notifyNoButton := ui.notifyGui.AddPicture("ys","/Img/button_no.png")
		ui.notifyNoButton.OnEvent("Click",notifyCancel)
		SetTimer(waitOSD,-%duration%)
	} else {
		ui.Transparent := 250
		try {
			WinSetTransparent(ui.Transparent,ui.notifyGui)
			setTimer () => (sleep(duration),fadeOSD()),-100
		}
	}

	waitOSD() {
		ui.notifyGui.destroy()
		notifyOSD("Timed out waiting for response.`nPlease try your action again",-1000)
	
	}
}

fadeOSD() {
	ui.transparent := 250
	While ui.Transparent > 10 { 	
		try
			WinSetTransparent(ui.Transparent,ui.notifyGui)
		ui.Transparent -= 3
		Sleep(1)
	}
	try
		guiVis(ui.notifyGui,false)
	ui.Transparent := ""
}

sendIfWinActive(msg,win := "A",wait := false) {
	(winActive(win))
		? send(msg)
		: waitForWin()	
	waitForWin(*) {
		while !(winActive(win))
			sleep(500)
	}
}

install() {
	Global
	installDir := cfg.installDir
	if (a_isCompiled)
	{
		if !inStr(a_scriptDir,installDir)
  		{
			errorLevel := 1
			createPbConsole("fpassist Install")
			pbConsole("Running standalone executable, attempting to install")
			if !(dirExist(installDir))
			{
				pbConsole("Attempting to create install folder")
				try
				{
					if !dirCreate(installDir) 
						errorLevel := 0
					setWorkingDir(installDir)
				} catch {
					sleep(1500)
					pbConsole("Cannot Create Folder at the Install Location.")
					pbConsole("Suspect permissions issue with the desired install location")
					pbConsole("`n`nTERMINATING")
					sleep(4000)
					exitApp
				}
				pbConsole("Successfully created install location at " InstallDir)
				sleep(1000)
			}
			pbConsole("Copying executable to install location")
			sleep(1000)
			try{
				fileCopy(A_ScriptFullPath, installDir "/" A_AppName ".exe", true)
			}

			if (fileExist(installDir "/fpassist.ini"))
			{
				msgBoxResult := msgBox("Previous install detected. `nAttempt to preserve your existing settings?",, "Y/N T300")
				switch msgBoxResult {
					case "No": 
					{
						sleep(1000)
						pbConsole("`nReplacing existing configuration files with updated and clean files")
						fileInstall("./fpassist.ini",InstallDir "/fpassist.ini",1)
					} 
					case "Yes": 
					{
						cfg.themeFont1Color := "00FFFF"
						sleep(1000)
						pbConsole("`nPreserving existing configuration may cause issues.")
						pbConsole("If you encounter issues,try installing again, choosing NO.")
					}
					case "Timeout":
					{
						setTimer () => pbNotify("Timed out waiting for your response.`Attempting to update using your exiting config files.`nIf you encounter issues, re-run the install `nselecting the option to replace your existing files.",5000),-100
						if !fileExist("./fpassist.ini")
							fileInstall("./fpassist.ini",installDir "/fpassist.ini")	
					}
				}
			} else {
				sleep(1000)
				pbConsole("This seems to be the first time you're running fpassist.")
				pbConsole("A fresh install to " A_MyDocuments "\fpassist is being performed.")
				fileInstall("./fpassist.ini",installDir "/fpassist.ini",1)
			}
			if !(dirExist(installDir "\lib"))
			{
				dirCreate(installDir "\lib")
			}			
			if !(dirExist(installDir "\Img"))
			{
				dirCreate(installDir "\Img")
			}
			if !(dirExist(installDir "\Redist"))
			{
				dirCreate(installDir "\Redist")
			}
			if !(dirExist(installDir "\fishPics"))
			{
				dirCreate(installDir "\fishPics")
			}
			if !(dirExist(installDir "\logs"))
			{
				dirCreate(installDir "\logs")
			}
			
			fileInstall("./Img/fp_splash.png",installDir "/img/fp_splash.png",1)
			fileInstall("./img/button_folder.png",installDir "/img/button_folder.png",1)
			fileInstall("./img/profileFS_border.png",installDir "/img/profileFS_border.png",1)
			fileInstall("./Img/button_search.png",installDir "/img/button_search.png",1)
			fileInstall("./Img/button_popout.png",installDir "/img/button_popout.png",1) 
			fileInstall("./Img/button_nofs.png",installDir "/img/button_nofs.png",1) 
			fileInstall("./Img/button_fs.png",installDir "/img/button_fs.png",1) 
			fileInstall("./Img/button_close.png",installDir "/Img/button_close.png",true)
			fileInstall("./Img/button_save.png",installDir "/img/button_save.png",1)
			fileInstall("./Img/button_new.png",installDir "/img/button_new.png",1)
			fileInstall("./Img/button_delete.png",installDir "/img/button_delete.png",1)
			fileInstall("./Img/button_cancel.png",installDir "/img/button_cancel.png",1)
			fileInstall("./Img/button_edit.png",installDir "/img/button_edit.png",1)
			fileInstall("./img/button_arrowLeft.png",installDir "/img/button_arrowLeft.png",1)
			fileInstall("./img/button_arrowRight.png",installDir "/img/button_arrowRight.png",1)
			fileInstall("./img/button_arrowLeft_knot.png",installDir "/img/button_arrowLeft_knot.png",1)
			fileInstall("./img/button_arrowRight_knot.png",installDir "/img/button_arrowRight_knot.png",1)
			fileInstall("./img/icon_cast.png",installDir "/img/icon_cast.png",1)
			fileInstall("./img/icon_cast_on.png",installDir "/img/icon_cast_on.png",1)
			fileInstall("./img/icon_retrieve_on.png",installDir "/img/icon_retrieve_on.png",1)
			fileInstall("./img/icon_retrieve.png",installDir "/img/icon_retrieve.png",1)
			fileInstall("./img/icon_reel_on.png",installDir "/img/icon_reel_on.png",1)
			fileInstall("./img/icon_reel_flash.png",installDir "/img/icon_reel_flash.png",1)
			fileInstall("./img/icon_fish.png",installDir "/img/icon_fish.png",1)
			fileInstall("./img/icon_reel.png",installDir "/img/icon_reel.png",1)													
			fileInstall("./img/toggle_on.png",installDir "/img/toggle_on.png",1)
			fileInstall("./img/toggle_off.png",installDir "/img/toggle_off.png",1)
			fileInstall("./img/toggle_horz_on.png",installDir "/img/toggle_horz_on.png",1)
			fileInstall("./img/toggle_horz_off.png",installDir "/img/toggle_horz_off.png",1)
			fileInstall("./img/play_ani_1.png",installDir "/img/play_ani_1.png",1)
			fileInstall("./img/play_ani_2.png",installDir "/img/play_ani_2.png",1)
			fileInstall("./img/play_ani_3.png",installDir "/img/play_ani_3.png",1)
			fileInstall("./img/play_ani_0.png",installDir "/img/play_ani_0.png",1)
			fileInstall("./redist/sqlite3.dll",installDir "/redist/sqlite3.dll",1)
			fileInstall("./redist/ss.exe",installDir "/redist/ss.exe",1)
			fileInstall("./update.exe",installDir "/update.exe",1)
			fileInstall("./fpassist_currentBuild.dat",installDir "/fpassist_currentBuild.dat",1)
			fileInstall("./img/hooman.ico",installDir "/img/hooman.ico",1)
			fileInstall("./img/action_cast.png",installDir "/img/action_cast.png",1)
			fileInstall("./img/action_retrieve.png",installDir "/img/action_retrieve.png",1)
			fileInstall("./img/action_reel.png",installDir "/img/action_reel.png",1)
			fileInstall("./img/action_idle.png",installDir "/img/action_idle.png",1)
			fileInstall("./img/button_edit_light.png",installDir "/img/button_edit_light.png",1)
			
			pbConsole("`nINSTALL COMPLETED SUCCESSFULLY!")
			
			fileCreateShortcut(installDir "/fpassist.exe", a_desktop "\fpassist.lnk",installDir,,"Fishing Planet Assist",installDir "/img/fpassist_icon.ico")
			fileCreateShortcut(installDir "/fpassist.exe", a_startMenu "\Programs\fpassist.lnk",installDir,,"fpassist Gaming Assistant",installDir "/img/fpassist_icon.ico")
			iniWrite(installDir,installDir "/fpassist.ini","System","InstallDir")
			if errorLevel
				return errorLevel
			
			run(installDir "\" a_appName ".exe")
			sleep(4500)
			ui.pbConsole.destroy()
			exitApp

			exit
		
		}
	}
	
}

getGamePath(*) {
	loop reg, "HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences", "KVR" {
		if inStr(a_loopRegName,ui.gameExe) {
				;msgBox(ui.gameExe "`n" this_game:=subStr(a_loopRegName,1,strLen(a_loopRegName)-16))
				return a_loopRegName
		}
	}	
}

runApp(appName) {
	global
	for app in comObject('shell.application').nameSpace('shell:appsFolder').items
	(app.Name = appName) && runWait('explorer shell:appsFolder\' app.path,,,&appPID)
}

verifyAdmin(*) {
	if !a_isAdmin {
		if a_isCompiled
			run '*runAs "' a_scriptFullPath '" /restart'
		else
			run '*runAs "' a_ahkPath '" /restart "' a_scriptFullPath '"'
			run '*runAs "' a_ahkPath '" /restart "' a_scriptFullPath '"'		
	}

	a_cmdLine := dllCall("GetCommandLine", "str")
	a_restarted := 
	(inStr(a_cmdLine,"/restart"))
					? true
					: false		
}	

cleanExit(*) {
	if winExist(ui.game) {
		ui.exitButtonBg.opt("background" ui.trimColor[2])
		ui.exitButtonBg.redraw()
		ui.exitButton.opt("c" ui.trimFontColor[2])
		ui.exitButtonHotkey.opt("c" ui.trimFontColor[2])
		winActivate(ui.game)
		winSetStyle("+0xC00000",ui.game)
		while winExist(ui.game)
			winClose(ui.game)
			sleep(1000)
	}
	exitFunc()
}

exitFunc(*) {
	cfgWrite()
	exitApp
}

logCatch(*) {
	 fileAppend(ui.statSessionStartTime.text "," ui.statAfkStartTime.text "," ui.statAfkDuration.text "," ui.statFishCount.text "," ui.statCastCount.text "," ui.statCastLength.text "," ui.statDragLevel.text "," ui.statReelSpeed.text "`n",ui.fishLogFile)
}

log(msg,debug:=0,msgHistory:=msg) {
	ui.fishLogStr := ""
	if !ui.lastMsg
		ui.lastMsg:="Starting: FPAssist"
		
	msgData:=formatTime(,"[hh:mm:ss] ") 
	ui.logLV.insert(1,,formatTime(,"[hh:mm:ss] ") msg)
	ui.fishStatusText.text := msg
		
	if msg=="Ready" 
		ui.fishLogArr.push(substr("_________________________________________________________________________",1,70))
	else
		ui.fishLogArr.push(formatTime(,"[hh:mm:ss] ") ui.lastMsg)
	
	ui.fishLogArr.removeAt(1)
	ui.fishLogText.delete()
	ui.fishLogText.add(ui.fishLogArr)

	ui.lastMsg := msgHistory
}


killMe(*) {
	ExitApp
}

arr2str(arrayName) {
	loop arrayName.Length
	{
		stringFromArray .= arrayName[a_index] ","
	}
	return rtrim(stringFromArray,",")
}

newGuid(*) {
	return ComObjCreate("Scriptlet.TypeLib").GUID
}

createPbConsole(title) {
	transColor := "010203"
	ui.pbConsole := gui()
	ui.pbConsole.opt("-caption -border toolWindow alwaysOnTop")
	ui.pbConsole.backColor := transColor
	ui.pbConsole.color := transColor
	winSetTransColor(transColor,ui.pbConsole)
			ui.bgColor 				:= ["202020","323032","454548","1B1A1C","DFDFFF","999999"]
			ui.fontColor 			:= ["151415","A0AFB5","D0D5FF","666666","353535","50556F"]
			ui.trimColor 			:= ["DFDFFF","6d0f0f","f39909","11EE11","EE1111","303030"]
			ui.trimDarkColor 		:= ["101011","2d0f0f","7b4212","11EE11","EE1111","303030"]
			ui.trimFontColor 		:= ["282828","d0b7b4","44DDCC","11EE11","EE1111","303030"]
			ui.trimDarkFontColor 	:= ["9595A5","9595A5","44DDCC","11EE11","EE1111","303030"]
	ui.pbConsoleDataBg := ui.pbConsole.addText("x0 y0 w690 h296 background" ui.bgColor[1])
	ui.pbConsoleTitle := ui.pbConsole.addText("x2 y0 w685 h35 section center background" ui.bgColor[2] " c" ui.fontColor[2],title)
	ui.pbConsoleTitle.setFont("s20","Verdana Bold")

	drawOutlineNamed("pbConsoleTitle",ui.pbConsole,2,0,688,35,ui.bgColor[2],ui.bgColor[3],2)
	ui.pbConsoleData := ui.pbConsole.addText("xs+6 w676 h280 backgroundTrans c" ui.fontColor[2],"")
	ui.pbConsoleData.setFont("s16")
	drawOutlineNamed("pbConsoleOutside",ui.pbConsole,1,0,689,298,ui.bgColor[3],ui.bgColor[3],2)
	ui.pbConsole.show("w694 h300 noActivate")
}

hidePbConsole(*) {
	guiVis(ui.pbConsole,false)
	guiVis(ui.pbConsoleBg,false)
}

showPbConsole(*) {
	guiVis(ui.pbConsole,false)
	guiVis(ui.pbConsoleBg,false)
}

pbConsole(msg) {
	if !hasProp(ui,"pbConsole")
		createPbConsole("fpassist Console")
	ui.pbConsoleData.text := msg "`n" ui.pbConsoleData.text
}