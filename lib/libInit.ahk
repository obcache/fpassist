#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}


startGame(*) {
	loadScreen()
	if !winExist(ui.game) {
		run(getGamePath(),,"Hide")		
		winWait(ui.game)
		winMove(0,0,,,ui.game)
		winSetTransparent(1,ui.game)	
		loop 40 {
			sleep(200)
			ui.loadingProgress.value += 1
			ui.loadingProgress2.value += 1
		}
		winMove(0,0,,,ui.game)
		winSetStyle("-0xC00000",ui.game)
	} else {
		winActivate(ui.game)
		winWait(ui.game)	
		winSetStyle("-0xC00000",ui.game)
		setTimer(startupProgress2,120)
	}
	winSetTransparent(1,ui.game)
	winMove(0,0,1280*(a_screenDpi/96),720*(a_screenDpi/96),ui.game)
	sleep(1000)
	ui.loadingProgress.value += 4
	ui.loadingProgress2.value += 4
	winGetPos(&x,&y,&w,&h,ui.game)
	while w != 1280*(a_screenDpi/96) || h != 720*(a_screenDpi/96) {
		sleep(1000)
		if w == a_screenWidth && h == a_screenHeight {
			winActivate("ahk_exe fishingPlanet.exe")
			send("{alt down}{enter}{alt up}")
			sleep(500)
			ui.loadingProgress.value += 2
			ui.loadingProgress2.value += 2
			winMove(0,0,1280*(a_screenDpi/96),720*(a_screenDpi/96),ui.game)
			sleep(500)
			ui.loadingProgress.value += 2
			ui.loadingProgress2.value += 2
			winGetPos(&x,&y,&w,&h,ui.game)
		}
	winSetStyle("-0xC00000",ui.game)
	winSetTransparent(0,ui.game) 
	}
}
