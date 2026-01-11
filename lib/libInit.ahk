#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}


startGame(*) {
	if !winExist(ui.game) {
		ui.loadGui:=gui()
		ui.loadGui.opt("-caption -border toolWindow")
		ui.loadGui.backColor:="010203"
		ui.loadGui.color:="010203"
		winSetTransColor("010203",ui.loadGui)
		ui.loadGuiBorder:=ui.loadGui.addText("x0 y0 w600 h100 background909090")
		ui.loadGuiBg:=ui.loadGui.addText("x3 y3 w594 h94 background506050")
		ui.loadGuiText:=ui.loadGui.addText("x0 y10 w600 h50 center backgroundTrans","Fishing Planet Not Running")
		ui.loadGuiText2:=ui.loadGui.addText("x0 y55 w600 h50 center backgroundTrans","Please launch game through Steam or Epic launcher.")

		ui.loadGuiText.setFont("s28 ca0a0a0","calibri")
		ui.loadGuiText2.setFont("s18 ca0a0a0","calibri")
		ui.loadGui.show("x" (a_screenwidth/2)-300 " y" (a_screenheight/2)-50)
		
	;msgbox(getGamePath())
		;run(getGamePath(),,"Hide")		
		winWait(ui.game)
		loadScreen()
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
		loadScreen()
		winActivate(ui.game)
		winWait(ui.game)	
		winSetStyle("-0xC00000",ui.game)
		setTimer(startupProgress2,120)
	}
	winSetTransparent(255,ui.game)
	winMove(0,0,a_screenwidth,a_screenheight,ui.game)
	sleep(1000)
	ui.loadingProgress.value += 4
	ui.loadingProgress2.value += 4
	; winGetPos(&x,&y,&w,&h,ui.game)
	; while w != 1280*(a_screenDpi/96) || h != 720*(a_screenDpi/96) {
		; sleep(1000)
		; if w == a_screenWidth && h == a_screenHeight {
			; winActivate("ahk_exe fishingPlanet.exe")
			; send("{alt down}{enter}{alt up}")
			; sleep(500)
			; ui.loadingProgress.value += 2
			; ui.loadingProgress2.value += 2
			; winMove(0,0,1280*(a_screenDpi/96),720*(a_screenDpi/96),ui.game)
			; sleep(500)
			; ui.loadingProgress.value += 2
			; ui.loadingProgress2.value += 2
			; winGetPos(&x,&y,&w,&h,ui.game)
		; }
	winSetStyle("-0xC00000",ui.game)
	winSetTransparent(255,ui.game) 
	; }

	createGuiFS()

	goFS()

	ui.notifyGui.hide()
}
