A_FileVersion := "1.3.7.9"
A_AppName := "fpa"
#requires autoHotkey v2.0+
#singleInstance
#maxThreadsPerHotkey 1

persistent()	
setWorkingDir(a_scriptDir)
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

ui 					:= object()
this				:= object()
cfg 				:= object()
tmp 				:= object()
mechanic 			:= object()

cfg.window			:=object()

		sqliteExec(cfg.dbFilename,"INSERT into winPositions VALUES ('" ui.workspaceDDL.text "','" winName "','" currWinX "','" currWiny "','" currWinW "','" currWinH "','','" winGetProcessPath(winClicked) "',true,false)",&insertResult)
		sqliteQuery(cfg.dbFilename,"SELECT title,ProcessPath,winX,winY,winW,winH,caption,alwaysOnTop FROM winPositions WHERE workspace='" workspace "'",&sqlResult)

