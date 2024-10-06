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

guiVis(guiName,isVisible:= true) {
	if (isVisible) {
		WinSetTransparent(255,guiName)
		WinSetTransparent("Off",guiName)
		WinSetTransColor("010203",guiName)
	} else {
		WinSetTransparent(0,guiName)

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
			fileInstall("./img/toggle_on.png",installDir "/img/toggle_on.png",1)
			fileInstall("./img/toggle_off.png",installDir "/img/toggle_off.png",1)
			fileInstall("./img/play_ani_1.png",installDir "/img/play_ani_1.png",1)
			fileInstall("./img/play_ani_2.png",installDir "/img/play_ani_2.png",1)
			fileInstall("./img/play_ani_3.png",installDir "/img/play_ani_3.png",1)
			fileInstall("./img/play_ani_0.png",installDir "/img/play_ani_0.png",1)
			fileInstall("./redist/sqlite3.dll",installDir "/redist/sqlite3.dll",1)
			fileInstall("./redist/ss.exe",installDir "/redist/ss.exe",1)
			fileInstall("./update.exe",installDir "/update.exe",1)
			fileInstall("./fpassist_currentBuild.dat",installDir "/fpassist_currentBuild.dat",1)
			fileInstall("./img/hooman.ico",installDir "/img/hooman.ico",1)

			pbConsole("`nINSTALL COMPLETED SUCCESSFULLY!")
			
			fileCreateShortcut(installDir "/fpassist.exe", a_desktop "\fpassist.lnk",installDir,,"Fishing Planet Assist",installDir "/img/hooman.ico")
			fileCreateShortcut(installDir "/fpassist.exe", a_startMenu "\Programs\fpassist.lnk",installDir,,"fpassist Gaming Assistant",installDir "/img/hooman.ico")
			iniWrite(installDir,installDir "/fpassist.ini","System","InstallDir")
			if errorLevel
				return errorLevel
			run(installDir "\" a_appName ".exe")
			sleep(4500)
			exitApp
		
		}
	}
	
}

getGamePath(*) {
	loop reg, "HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache", "KVR" {
		if inStr(regRead(),ui.gameExe)
			if inStr(ui.gameExe := a_loopRegName,ui.gameExe) {
				return subStr(a_loopRegName,1,strLen(a_loopRegName)-16)
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

onExit(exitFunc)

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
	for setting in cfg.profileSettings {
		ui.%setting%Str := ""
		if setting != "profileName" {
			while cfg.%setting%.length < cfg.profileName.length
				cfg.%setting%.push(ui.%setting%.value)
			}
			for profile in cfg.profileName {
				ui.%setting%Str .= cfg.%setting%[a_index] ","
			}
		iniWrite(rtrim(ui.%setting%Str,","),cfg.file,"Game",setting)
	}
	iniWrite(cfg.profileSelected,cfg.file,"Game","ProfileSelected")
	iniWrite(cfg.rodCount,cfg.file,"Game","RodCount")
	exitApp
}


ui.lastMsg := ""
log(msg,debug:=0,msgHistory:=msg) {
	if debug > cfg.debug
		return
	if ui.lastMsg {
	if msg=="divider" {
		msg:="Ready"
		msgHistory:="———————————————————————————————————————————————————————————————————————————————————————————————————" 			
	}
	;ui.fishStatusText.text := (msg=="___________________________________________________________________") ? "Ready" : msg
	;if ui.fishLogArr.length > 33 {
	ui.fishStatusText.text := msg
	ui.fishLogArr.push((ui.lastMsg=="Ready") ? "——————————————————————————————————————" : formatTime(,"[hh:mm:ss] ") ui.lastMsg)
	ui.fishLogText.delete()
	ui.fishLogText.add(ui.fishLogArr)
	ui.fishLogArr.removeAt(1)
	;} else {
	;	ui.fishLogArr.push(formatTime(,"[hh:mm:ss] ") ui.lastMsg)
	;	ui.fishLogText.delete()
	;	ui.fishLogText.add(ui.fishLogArr)
	}
	try {
		ui.fishLogStr := ""
		loop ui.fishLogArr.length {
			ui.fishLogStr .= ui.fishLogArr[a_index] "`n"
			ui.fishLogFS.text := rtrim(ui.fishLogStr,"`n")
		}
	}
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
;createPbConsole("poo")
createPbConsole(title) {
	transColor := "010203"
	; ui.pbConsoleBg := gui()
	; ui.pbConsoleBg.backColor := "304030"
	; ui.pbConsoleHandle := ui.pbConsoleBg.addPicture("w700 h400 background203020","")
	; ui.pbConsoleBg.show("w700 h400 noActivate")
	ui.pbConsole := gui()
	ui.pbConsole.opt("-caption -border toolWindow alwaysOnTop")
	ui.pbConsole.backColor := transColor
	ui.pbConsole.color := transColor
	winSetTransColor(transColor,ui.pbConsole)
	ui.pbConsoleDataBg := ui.pbConsole.addText("x0 y0 w690 h296 background" ui.bgColor[1])
	ui.pbConsoleTitle := ui.pbConsole.addText("x2 y0 w685 h35 section center background" ui.bgColor[2] " c" ui.fontColor[2],title)
	ui.pbConsoleTitle.setFont("s20","Verdana Bold")

	drawOutlineNamed("pbConsoleTitle",ui.pbConsole,2,0,688,35,ui.bgColor[2],ui.bgColor[3],2)
	ui.pbConsoleData := ui.pbConsole.addText("xs+6 w676 h280 backgroundTrans c" ui.fontColor[2],"")
	ui.pbConsoleData.setFont("s16")
	drawOutlineNamed("pbConsoleOutside",ui.pbConsole,1,0,689,298,ui.bgColor[3],ui.bgColor[3],2)
	;drawOutlineNamed("pbConsoleOutside2",ui.pbConsole,2,2,690,298,ui.bgColor[2],ui.bgColor[1],1)
	;drawOutlineNamed("pbConsoleOutside3",ui.pbConsole,2,3,688,296,ui.bgColor[3],ui.bgColor[2],2)
	ui.pbConsole.show("w694 h300 noActivate")
	; ui.pbConsoleBg.opt("-caption owner" ui.pbConsole.hwnd)
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