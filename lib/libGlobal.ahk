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

install() {
	Global
	InstallDir := cfg.installDir
	if (A_IsCompiled)
	{
		if !inStr(A_ScriptDir,InstallDir)
  		{
			errorLevel := 1
			createPbConsole("fpassist Install")
			pbConsole("Running standalone executable, attempting to install")
			if !(DirExist(InstallDir))
			{
				pbConsole("Attempting to create install folder")
				try
				{
					if !DirCreate(InstallDir) 
						errorLevel := 0
					SetWorkingDir(InstallDir)
				} catch {
					sleep(1500)
					pbConsole("Cannot Create Folder at the Install Location.")
					pbConsole("Suspect permissions issue with the desired install location")
					pbConsole("`n`nTERMINATING")
					sleep(4000)
					ExitApp
				}
				pbConsole("Successfully created install location at " InstallDir)
				sleep(1000)
			}
			pbConsole("Copying executable to install location")
			sleep(1000)
			try{
				FileCopy(A_ScriptFullPath, InstallDir "/" A_AppName ".exe", true)
			}

			if (FileExist(InstallDir "/fpassist.ini"))
			{
				msgBoxResult := MsgBox("Previous install detected. `nAttempt to preserve your existing settings?",, "Y/N T300")
				
				switch msgBoxResult {
					case "No": 
					{
						sleep(1000)
						pbConsole("`nReplacing existing configuration files with updated and clean files")
						FileInstall("./fpassist.ini",InstallDir "/fpassist.ini",1)
					} 
					case "Yes": 
					{
						cfg.ThemeFont1Color := "00FFFF"
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

				FileInstall("./fpassist.ini",InstallDir "/fpassist.ini",1)
			}
			if !(DirExist(InstallDir "\lib"))
			{
				DirCreate(InstallDir "\lib")
			}			
			if !(DirExist(InstallDir "\Img"))
			{
				DirCreate(InstallDir "\Img")
			}
			if !(DirExist(InstallDir "\Redist"))
			{
				DirCreate(InstallDir "\Redist")
			}
			if !(DirExist(InstallDir "\fishPics"))
			{
				DirCreate(InstallDir "\fishPics")
			}
			if !(DirExist(InstallDir "\logs"))
			{
				DirCreate(InstallDir "\logs")
			}
			FileInstall("./Img/fp_splash.png",InstallDir "/img/fp_splash.png",1)
			FileInstall("./Img/button_nofs.png",InstallDir "/img/button_nofs.png",1) 
			FileInstall("./Img/button_fs.png",InstallDir "/img/button_fs.png",1) 
			FileInstall("./Img/button_close.png",InstallDir "/Img/button_close.png",true)
			FileInstall("./Img/rod.png",InstallDir "/Img/rod.png",true)
			fileInstall("./redist/sqlite3.dll",cfg.installDir "/redist/sqlite3.dll",1)
			fileInstall("./redist/ss.exe",cfg.installDir "/redist/ss.exe",1)
			FileInstall("./update.exe",InstallDir "/update.exe",1)
			FileInstall("./fpassist_currentBuild.dat",InstallDir "/fpassist_currentBuild.dat",1)
			fileInstall("./img/hooman.ico",installDir "/img/hooman.ico",1)

			pbConsole("`nINSTALL COMPLETED SUCCESSFULLY!")
			
			fileCreateShortcut(installDir "/fpassist.exe", A_Desktop "\fpassist.lnk",installDir,,"Fishing Planet Assist",installDir "/img/hooman.ico")
			fileCreateShortcut(installDir "/fpassist.exe", A_StartMenu "\Programs\fpassist.lnk",installDir,,"fpassist Gaming Assistant",installDir "/img/hooman.ico")
			IniWrite(installDir,installDir "/fpassist.ini","System","InstallDir")
			if errorLevel
				return errorLevel
			Run(InstallDir "\" A_AppName ".exe")
			sleep(4500)
			ExitApp
		
		}
	}
	
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

verifyAdmin(*) {
	if !a_isAdmin {
		if a_isCompiled
			run '*runAs "' a_scriptFullPath '" /restart'
		else
			run '*runAs "' a_ahkPath '" /restart "' a_scriptFullPath '"'
			run '*runAs "' a_ahkPath '" /restart "' a_scriptFullPath '"'
		
	}

	a_cmdLine := DllCall("GetCommandLine", "str")
	a_restarted := 
	(inStr(a_cmdLine,"/restart"))
					? true
					: false		
}	

onExit(exitFunc)

cleanExit(*) {
	if winExist(ui.game) {
		winActivate(ui.game)
		WinSetStyle("+0xC00000",ui.game)
		while winExist(ui.game)
			winClose(ui.game)
			sleep(1000)
	}
	
	exitFunc()
}

exitFunc(*) {
	exitApp
}
ui.lastMsg := ""
log(msg) {
	if ui.lastMsg {
		ui.fishStatusText.text := msg
		;if ui.fishLogArr.length > 33 {
			
			ui.fishLogArr.push(formatTime(,"[hh:mm:ss] ") ui.lastMsg)
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
	ui.lastMsg := msg
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
	ui.pbConsoleBg := gui()
	ui.pbConsoleBg.backColor := "304030"
	ui.pbConsoleHandle := ui.pbConsoleBg.addPicture("w700 h400 background203020","")
	ui.pbConsoleBg.show("w700 h400 noActivate")
	ui.pbConsole := gui()
	ui.pbConsole.opt("-caption")
	ui.pbConsole.backColor := transColor
	ui.pbConsole.color := transColor
	ui.pbConsoleTitle := ui.pbConsole.addText("x8 y4 w700 h35 section center background303530 c859585",title)
	ui.pbConsoleTitle.setFont("s20","Verdana Bold")

	drawOutlineNamed("pbConsoleTitle",ui.pbConsole,6,4,692,35,"253525","202520",2)
	ui.pbConsoleData := ui.pbConsole.addText("xs+10 w680 h380 backgroundTrans cA5C5A5","")
	ui.pbConsoleData.setFont("s16")
	drawOutlineNamed("pbConsoleOutside",ui.pbConsole,2,2,698,398,"355535","355535",2)
	drawOutlineNamed("pbConsoleOutside2",ui.pbConsole,3,3,696,396,"457745","457745",1)
	drawOutlineNamed("pbConsoleOutside3",ui.pbConsole,4,4,694,394,"" ui.bgColor[2],"" ui.bgColor[2],2)
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