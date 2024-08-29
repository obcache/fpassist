A_FileVersion := "1.1.1.2"
;@Ahk2Exe-Let FileVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% 
;@Ahk2Exe-SetName fpassist
;@Ahk2Exe-SetVersion %U_FileVersion%
;@Ahk2Exe-SetFileVersion %U_FileVersion%

#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off

update(*) {
	splitPath(a_scriptFullPath,&scriptFilename,&scriptDir,&scriptExtension,&scriptNameNoExt,&scriptDrive) 
	A_AppName := scriptNameNoExt


	currExe := DllCall("GetCommandLine", "str")
	if not (a_isAdmin or regExMatch(currExe, " /restart(?!\S)"))
	{
		try
		{
			if a_isCompiled
				run '*runAs "' a_scriptFullPath '" /restart'
			else
				run '*runAs "' a_ahkPath '" /restart "' a_scriptFullPath '"'
		}
		exitApp()
		}
	InstallMouseHook()
	InstallKeybdHook()
	KeyHistory(10)
	SetWorkingDir(A_ScriptDir)

	cfg				:= Object()
	ui 				:= Object()

	if (A_Args.length > 0) && FileExist("./versions/" A_Args[1]) {
		winWaitClose("ahk_exe fpAssist.exe")
		run("./versions/" A_Args[1])
		exitApp
	} else {
		
		latestVersion := "0000"
		currentVersion := "0000"
		
		whr := ComObject("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "https://raw.githubusercontent.com/obcache/fpAssist/main/fpassist_currentBuild.dat", true)
		whr.Send()
		whr.WaitForResponse()
		latestVersion := whr.ResponseText

		currentVersion := fileRead("./fpassist_currentBuild.dat")
		if !(DirExist("./versions"))
			DirCreate("./versions")
						
		if (latestVersion > currentVersion) 
		{
			msgBoxAnswer := MsgBox("A newer version is available.`nYou currently have: " currentVersion "`nBut the newest is: " latestVersion "`nWould you like to update now?",,"YN")

			if (msgBoxAnswer == "Yes")
			{ 	
				if winExist("ahk_exe fpassist.exe")	{
					winClose("ahk_exe fpassist.exe")
				}			
				pbNotify("Upgrading fpAssist to version " latestVersion)
		
				;download("http://sorryneedboost.com/fpAssist/bin/fpAssist_" latestVersion ".exe",A_ScriptDir "/versions/fpAssist_" latestVersion ".exe")
				runWait("cmd /C start /b /wait curl.exe https://raw.githubusercontent.com/obcache/fpassist/main/bin/fpAssist_" latestVersion ".exe -o " A_ScriptDir  "/versions/fpAssist_" latestVersion ".exe")
				sleep(3000)
				if winExist("ahk_exe fpassist.exe")
				{
					processClose("fpAssist.exe") 
					sleep(2000)
				}			
				if fileExist("./versions/fpassist_" latestVersion ".exe")
					run("./versions/fpAssist_" latestVersion ".exe")
				else 
					pbNotify("Problem downloading or running the updated version. `nCheck your antivirus to ensure that it is not being blocked.")
			} else {
				pbNotify("Skipping upgrade. You can re-trigger it from the setup tab`nWhenever you are ready to upgrade.",2500)
			}
		} 
		pbNotify("v" latestVersion "`nv" currentVersion)
	}

	pbNotify(NotifyMsg,Duration := 10,YN := "")
	{
		Transparent := 250
		ui.notifyGui			:= Gui()
		ui.notifyGui.Title 		:= "Notify"

		ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		ui.notifyGui.BackColor := "353535" ; Can be any RGB color (it will be made transparent below).
		ui.notifyGui.SetFont("s16")  ; Set a large font size (32-point).
		ui.notifyGui.AddText("c00FFFF center BackgroundTrans",NotifyMsg)  ; XX & YY serve to 00auto-size the window.
		ui.notifyGui.AddText("xs hidden")
		
		if (YN) {
			ui.notifyGui.AddText("xs hidden")
			ui.notifyGui.SetFont("s10")
			ui.notifyYesButton := ui.notifyGui.AddButton("ys section w60 h25","Yes")
			ui.notifyYesButton.OnEvent("Click",notifyConfirm)
			ui.notifyNoButton := ui.notifyGui.AddButton("xs w60 h25","No")
			ui.notifyNoButton.OnEvent("Click",notifyCancel)
		}
		
		ui.notifyGui.Show("AutoSize")
		winGetPos(&x,&y,&w,&h,ui.notifyGui.hwnd)
		drawOutline(ui.notifyGui,0,0,w,h,"202020","808080",3)
		drawOutline(ui.notifyGui,5,5,w-10,h-10,"BBBBBB","DDDDDD",2)
		if !(YN) {
			Sleep(5000)
			FadeOSD()
		} else {
			SetTimer(pbWaitOSD,-10000)
		}
		
		notifyConfirm(*) {
			return 1
		}
		notifyCancel(*) {
			return 0
		}
	}
	pbWaitOSD() {
		ui.notifyGui.destroy()
		pbNotify("Timed out waiting for response.`nPlease try your action again",-1000)
	}
		
	drawOutline(guiName, X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		
		guiName.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		guiName.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		guiName.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		guiName.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}	
		
		
	fadeOSD() {
		ui.transparent := 250
		While ui.Transparent > 10 { 	
			WinSetTransparent(ui.Transparent,ui.notifyGui)
			ui.Transparent -= 3
			Sleep(1)
		}
		ui.Transparent := ""
		ui.notifyGui.Destroy()
	}
}
