#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

initTrayMenu(*) {
	A_TrayMenu.Delete
	A_TrayMenu.Add
	A_TrayMenu.Add("Show Window", restoreWin)
	A_TrayMenu.Add("Hide Window", HideGui)
	A_TrayMenu.Add("Reset Window Position", ResetWindowPosition)
	; A_TrayMenu.Add("Toggle Dock", DockApps)
	A_TrayMenu.Add()
	A_TrayMenu.Add("Toggle Log Window", toggleConsole)
	A_TrayMenu.Add()
	A_TrayMenu.Add("Exit App", KillMe)
	A_TrayMenu.Default := "Show Window"
}



sendIfWinActive(msg,win := "A") {
	(winActive(win))
		? send(msg)
		: exit
}

install(*) {
	if !a_isCompiled
		return
		
	if StrCompare(A_ScriptDir,cfg.installDir) {
		createPbConsole("fpassist Install")
		pbConsole("Running standalone executable, attempting to install")
		if !(DirExist(cfg.installDir)) {
			pbConsole("Attempting to create install folder")
			try	{
				Dir
				Create(cfg.installDir)
				SetWorkingDir(cfg.installDir)
			} catch {
				sleep(1500)
				pbConsole("Cannot Create Folder at the Install Location.")
				pbConsole("Suspect permissions issue with the desired install location")
				pbConsole("`n`nTERMINATING")
				sleep(4000)
				ExitApp
			}
			pbConsole("Successfully created install location at " cfg.installDir)
			sleep(1000)
		}
		pbConsole("Copying executable to install location")
		sleep(1000)
		try{
			FileCopy(A_ScriptFullPath, cfg.installDir "/" A_AppName ".exe", true)
		}

		if (FileExist(cfg.installDir "/fpassist.ini"))
		{
			msgBoxResult := MsgBox("Previous install detected. `nAttempt to preserve your existing settings?",, "Y/N T300")
			
			switch msgBoxResult {
				case "No": 
				{
					sleep(1000)
					pbConsole("`nReplacing existing configuration files with updated and clean files")
					FileInstall("./fpassist.ini",cfg.installDir "/fpassist.ini",1)
					;FileInstall("./fpassist.themes",cfg.installDir "/fpassist.themes",1)
					;FileInstall("./AfkData.csv",cfg.installDir "/AfkData.csv",1)
					;fileInstall("./fpassist.db",cfg.installDir "/fpassist.db",1)
				} 
				case "Yes": 
				{
					cfg.ThemeFont1Color := "00FFFF"
					sleep(1000)
					pbConsole("`nPreserving existing configuration may cause issues.")
					pbConsole("If you encounter issues,try installing again, choosing NO.")
					; if !(FileExist(cfg.installDir "/AfkData.csv"))
						; FileInstall("./AfkData.csv",cfg.installDir "/AfkData.csv",1)
					; if !(FileExist(cfg.installDir "/fpassist.themes"))
						; FileInstall("./fpassist.themes",cfg.installDir "/fpassist.themes",1)
					; if !(fileExist(cfg.installDir "/fpassist.db"))
						; fileInstall("./fpassist.db",cfg.installDir "/fpassist.db",1)
				}
				case "Timeout":
				{
					setTimer () => pbNotify("Timed out waiting for your response.`Attempting to update using your exiting config files.`nIf you encounter issues, re-run the install `nselecting the option to replace your existing files.",5000),-100
					if !fileExist("./fpassist.ini")
						fileInstall("./fpassist.ini",cfg.installDir "/fpassist.ini")
					; if !(FileExist(cfg.installDir "/AfkData.csv"))
						; FileInstall("./AfkData.csv",cfg.installDir "/AfkData.csv",1)
					; if !(FileExist(cfg.installDir "/fpassist.themes"))
						; FileInstall("./fpassist.themes",cfg.installDir "/fpassist.themes",1)
					; if !(fileExist(cfg.installDir "/fpassist.db"))
					; fileInstall("./fpassist.db",cfg.installDir "/fpassist.db",1)	
				}
			}
		} else {
			sleep(1000)
			pbConsole("This seems to be the first time you're running fpassist.")
			pbConsole("A fresh install to " A_MyDocuments "\fpassist is being performed.")

			FileInstall("./fpassist.ini",cfg.installDir "/fpassist.ini",1)
			; FileInstall("./fpassist.themes",cfg.installDir "/fpassist.themes",1)
			; FileInstall("./AfkData.csv",cfg.installDir "/AfkData.csv",1)
			; fileInstall("./fpassist.db",cfg.installDir "/fpassist.db",1)

		}
	}
	if !dirExist(cfg.installDir)
		dirCreate(cfg.installDir)
	if !dirExist(cfg.installDir "/redist")
		dirCreate(cfg.installDir "/redist")
	if !dirExist(cfg.installDir "/logs")
		dirCreate(cfg.installDir "/logs")
	if !dirExist(cfg.installDir "/img")
		dirCreate(cfg.installDir "/img")
	if !dirExist(cfg.installDir "/fishPics")
		dirCreate(cfg.installDir "/fishPics")
		
	fileInstall("./redist/sqlite3.dll",cfg.installDir "/redist/sqlite3.dll",1)
	fileInstall("./img/toggle_off.png",cfg.installDir "/img/toggle_off.png",1)
	fileInstall("./img/toggle_on.png",cfg.installDir "/img/toggle_on.png",1)
	fileInstall("./img/rod.png",cfg.installDir "/img/rod.png",1)
	fileInstall("./img/startup_fp.png",cfg.installDir "/img/startup_fp.png",1)
	fileInstall("./img/button_log.png",cfg.installDir "/img/button_log.png",1)
	fileInstall("./img/hooman.ico",cfg.installDir "/img/hooman.ico",1)
	fileInstall("./redist/ss.exe",cfg.installDir "/redist/ss.exe",1)
	fileInstall("./update.exe",cfg.installDir "/update.exe",1)
	pbConsole("`nINSTALL COMPLETED SUCCESSFULLY!")
	;installLog("Copied Assets to: " cfg.installDir)
			
	fileCreateShortcut(cfg.installDir "/fpassist.exe", A_Desktop "\fpassist.lnk",cfg.installDir,,"fpassist Gaming Assistant",cfg.installDir "/img2/attack_icon.ico")
	fileCreateShortcut(cfg.installDir "/fpassist.exe", A_StartMenu "\Programs\fpassist.lnk",cfg.installDir,,"fpassist Gaming Assistant",cfg.installDir "/img2/attack_icon.ico")
	IniWrite(cfg.installDir,cfg.installDir "/fpassist.ini","System","InstallDir")
	Run(cfg.installDir "\" A_AppName ".exe")
	
	
	
	sleep(500)
	exitApp
}



getGamePath(*) {
	Loop Reg, "HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache", "KVR" {
		if inStr(regRead(),ui.gameExe)
			if inStr(ui.gameExe := a_loopRegName,ui.gameExe) {
				return subStr(a_loopRegName,1,strLen(a_loopRegName)-16)
			}
	}	
}

runApp(appName) {
	global
	For app in ComObject('Shell.Application').NameSpace('shell:AppsFolder').Items
	(app.Name = appName) && RunWait('explorer shell:appsFolder\' app.Path,,,&appPID)
}

verifyInstall(*) {
	if !a_isAdmin {
		try
		{
			if a_isCompiled
				run '*runAs "' a_scriptFullPath '" /restart'
			else
				run '*runAs "' a_ahkPath '" /restart "' a_scriptFullPath '"'
				run '*runAs "' a_ahkPath '" /restart "' a_scriptFullPath '"'
		}
		exitApp()
	}

	a_cmdLine := DllCall("GetCommandLine", "str")
	a_restarted := 
	(inStr(a_cmdLine,"/restart"))
					? true
					: false
	if !fileExist("./fpassist.ini")
		install()
	loadScreen()
}	

onExit(exitFunc)

cleanExit(*) {
	if winExist(ui.game)
		winKill()
	if processExist("fishingPlanet.exe")
		processClose("fishingPlanet.exe")
	exitFunc()
}

exitFunc(*) {
	if winExist(ui.game) {
		winActivate(ui.game)
		WinSetStyle("+0xC00000",ui.game)
	}
	try {
		iniWrite(cfg.twitchToggleValue,cfg.file,"Game","TwitchToggle")
		iniWrite(cfg.waitToggleValue,cfg.file,"Game","WaitToggle")
		loop 3 {
			castAdjustList .= cfg.castAdjust[a_index] ","
			reelSpeedList .= cfg.reelSpeed[a_index] ","
			dragLevelList .= cfg.dragLevel[a_index] ","
		}
		iniWrite(rtrim(castAdjustList,","),cfg.file,"Game","CastAdjust")
		iniWrite(rtrim(reelSpeedList,","),cfg.file,"Game","ReelSpeed")
		iniWrite(rtrim(dragLevelList,","),cfg.file,"Game","DragLevel")
	}
	
	
	exitApp
}


 ; NotifyOSD(NotifyMsg,Duration := 10,Alignment := "Left",YN := "") {
	; if !InStr("LeftRightCenter",Alignment)
		; Alignment := "Left"
		
	; Transparent := 250
	; try
		; ui.notifyGui.Destroy()
	; ui.notifyGui			:= Gui()
	; ui.notifyGui.Title 		:= "Notify"

	; ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow +Owner" ui.mainGui.hwnd)  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	; ui.notifyGui.BackColor := cfg.ThemePanel1Color  ; Can be any RGB color (it will be made transparent below).
	; ui.notifyGui.SetFont("s16")  ; Set a large font size (32-point).
	; ui.notifyGui.AddText("c" cfg.ThemeFont1Color " " Alignment " BackgroundTrans",NotifyMsg)  ; XX & YY serve to 00auto-size the window.
	; ui.notifyGui.AddText("xs hidden")
	
	; WinSetTransparent(0,ui.notifyGui)
	; ui.notifyGui.Show("NoActivate Autosize")  ; NoActivate avoids deactivating the currently active window.
	; ui.notifyGui.GetPos(&x,&y,&w,&h)
	
	; winGetPos(&GuiX,&GuiY,&GuiW,&GuiH,ui.mainGui.hwnd)
	; ui.notifyGui.Show("x" (GuiX+(GuiW/2)-(w/2)) " y" GuiY+(100-(h/2)) " NoActivate")
	; guiVis(ui.notifyGui,true)
	; drawOutlineNotifyGui(1,1,w,h,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)
	; drawOutlineNotifyGui(2,2,w-2,h-2,cfg.ThemeBright2Color,cfg.ThemeBright2Color,1)
	
	; if (YN) {
		; ui.notifyGui.AddText("xs hidden")
		; ui.notifyYesButton := ui.notifyGui.AddPicture("ys x30 y30","./Img/button_yes.png")
		; ui.notifyYesButton.OnEvent("Click",notifyConfirm)
		; ui.notifyNoButton := ui.notifyGui.AddPicture("ys","/Img/button_no.png")
		; ui.notifyNoButton.OnEvent("Click",notifyCancel)
		; SetTimer(waitOSD,-10000)
	; } else {
		; ui.Transparent := 250
		; try {
			; WinSetTransparent(ui.Transparent,ui.notifyGui)
			; setTimer () => (sleep(duration),fadeOSD()),-100
		; }
	; }
	; waitOSD() {
		; ui.notifyGui.destroy()
		; notifyOSD("Timed out waiting for response.`nPlease try your action again",-1000)
	; }
; }

log(msg) {
	if ui.fishLogArr.length > 33 {
		ui.fishLogArr.removeAt(1)
		ui.fishLogArr.push(formatTime(,"[hh:mm:ss] ") msg)
		ui.fishLogText.delete()
		ui.fishLogText.add(ui.fishLogArr)
	} else {
		ui.fishLogArr.push(formatTime(,"[hh:mm:ss] ") msg)
		ui.fishLogText.delete()
		ui.fishLogText.add(ui.fishLogArr)
	}
}

killMe(*) {
	ExitApp
}
restartApp(*) {
	reload()
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



; iniEditor(*) {
	; loop read configFilename {
	; if substr(a_loopReadline,1,1) = "[" {
		; this_section := ltrim(rtrim(a_loopReadline,"]"),"[")
		
; }


createPbConsole(title) {
	transColor := "010203"
	ui.pbConsoleBg := gui()
	ui.pbConsoleBg.backColor := "304030"
	ui.pbConsoleHandle := ui.pbConsoleBg.addPicture("w700 h400 background203020","")
	ui.pbConsoleBg.show("w700 h400 noActivate")
	;winSetTransparent(160,ui.pbConsoleBg)
	ui.pbConsole := gui()
	ui.pbConsole.opt("-caption")
	ui.pbConsole.backColor := transColor
	ui.pbConsole.color := transColor
	;winSetTransColor(transColor,ui.pbConsole)
	ui.pbConsoleTitle := ui.pbConsole.addText("x8 y4 w700 h35 section center background303530 c859585",title)
	ui.pbConsoleTitle.setFont("s20","Verdana Bold")


	drawOutlineNamed("pbConsoleTitle",ui.pbConsole,6,4,692,35,"253525","202520",2)
	ui.pbConsoleData := ui.pbConsole.addText("xs+10 w680 h380 backgroundTrans cA5C5A5","")
	ui.pbConsoleData.setFont("s16")
	drawOutlineNamed("pbConsoleOutside",ui.pbConsole,2,2,698,398,"355535","355535",2)
	drawOutlineNamed("pbConsoleOutside2",ui.pbConsole,3,3,696,396,"457745","457745",1)
	drawOutlineNamed("pbConsoleOutside3",ui.pbConsole,4,4,694,394,"353535","353535",2)
	ui.pbConsole.show("w700 h400 noActivate")
	ui.pbConsoleBg.opt("-caption owner" ui.pbConsole.hwnd)
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
