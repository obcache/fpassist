A_FileVersion := "1.1.4.3"
A_AppName := "fpassist"
#requires autoHotkey v2.0+
#singleInstance

persistent()
;try
	;run("./update.exe")

cfg := object()
cfg.installDir := a_mydocuments "\fpassist\"
cfg.file := cfg.installDir "\fpassist.ini"
cfg.debug := iniRead(cfg.file,"System","Debug",false)
cfg.twitchToggleValue := iniRead(cfg.file,"Game","TwitchToggle",true)
cfg.waitToggleValue := iniRead(cfg.file,"Game","WaitToggle",true)
ui := object()
setWorkingDir(a_scriptDir)

#include <libGlobal>
#include <libGui>

verifyInstall()

initGui()


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
}


initGui(*) {
	cfg.castAdjust := iniRead(cfg.file,"Game","CastAdjust",2000)
	ui.sessionStartTime := A_Now
	ui.autoFish := false
	ui.fishLogArr := array()
	ui.fishCount := 0
	ui.reeledIn := false
	ui.isCasting := false
	ui.autoclickerActive := false

	ui.bgColor := ["222222","444444","666666","888888","AAAAAA","CCCCCC","EEEEEE"]
	ui.fontColor := ["EEEEEE","CCCCCC","AAAAAA","DDDDDD","666666","888888","444444"]

	ui.startKey := "F3"
	ui.stopKey := "F4"
	ui.reloadKey := "F5"
	ui.twitchKey := "F6"
	ui.waitKey := "F7"
	ui.exitKey := "F8"



	if !processExist("fishingPlanet.exe")
		Loop Reg, "HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache", "KVR" {
		
			if inStr(regRead(),"fishingPlanet.exe")
				if inStr(gameExecutable := a_loopRegName,"fishingPlanet.exe") {
					run(subStr(a_loopRegName,1,strLen(a_loopRegName)-16))
					winWait("ahk_exe fishingPlanet.exe")
					break
				}
		}	

	hotIfWinActive("ahk_exe fishingPlanet.exe")
		hotKey(ui.startKey,autoFishStart)
		hotKey(ui.stopKey,autoFishStop)
		hotKey(ui.reloadKey,appReload)
		hotKey(ui.twitchKey,toggleTwitch)
		hotKey(ui.waitKey,toggleWait)
		hotKey(ui.exitKey,cleanExit)
; Numpad0:: {
			; oneFish()
		; }
		
		; ^enter:: {
			; ui.autoclickerActive := true
				; loop {
					; if !ui.autoclickerActive
						; break
					; if winActive("ahk_exe fishingPlanet.exe") {
						; send("{LButton down}")
						; sleep(100)
						; send("{LButton up}")
					; sleep(round(random(1,100)))
				; }
			; }
		; }
		
		; ^+enter:: {
			; ui.autoclickerActive := false
		; }		

	hotIf()

	toggleWait(*) {
			(cfg.waitToggleValue := !cfg.waitToggleValue)
				? ui.waitToggleButton.value := "./img/toggle_on.png"
				: ui.waitToggleButton.value := "./img/toggle_off.png"
	}
	
	toggleTwitch(*) {
			(cfg.twitchToggleValue := !cfg.twitchToggleValue)
				? ui.twitchToggleButton.value := "./img/toggle_on.png"
				: ui.twitchToggleButton.value := "./img/toggle_off.png"
	}
		
	/* oneFish(*) {
		cast()
		retrieve()
	}
	 */
	autoFishStop(*) {
		ui.autoFish := 0
		setTimer(updateAfkTime,0)
		ui.fishLogAfkTime.text := "00:00:00"
		ui.startButton.opt("-hidden")
		ui.stopButton.opt("hidden")
		log("Stopped")
		ui.fishStatusText.text := "Stopped"
	}


	autoFishStart(*) {
		ui.autoFish := 1
		ui.startButton.opt("hidden")
		ui.stopButton.opt("-hidden")
		ui.afkStartTime := a_now
		setTimer(updateAfkTime,1000)

		while ui.autoFish == 1 {
			;checkRewards()
			;checkAds()
			(sleep500(10)) ? exit : 0
			send("{Esc down}")
			sleep(500)
			send("{Esc}")
			cast()
			retrieve()
		}
	}

	checkFocus(*) {
		fishFocus := (ui.autoFish)
						? !(winActive("ahk_exe fishingPlanet.exe"))
							? 0
							: 1
						: 1
			
		if !fishFocus
			autoFishStop()
	}

	sleep500(loopCount := 1) {
		errorLevel := 0
		loop loopCount {
			if ui.autoFish
				sleep(500)
			else
				errorLevel := 1
		}
		return errorLevel
	}

	cast(*) {
		log("Adjusting Reel Speed")
		MouseClick("WheelDown",,,9) 
		sleep(250)
		MouseClick("WheelUp",,,1)
		sleep(250)
		
		if !ui.autoFish || !ui.reeledIn
			return
			
		ui.fishStatusText.text := "Casting...."
		ui.isCasting := true
		
		log("Casting")
		(sleep500(5)) ? exit : 0
		send("{space down}")
		sleep(cfg.castAdjust)
		send("{space up}")
		(sleep500(12)) ? exit : 0		
		
		ui.isCasting := false
	}

	landFish(*) {
		lineHealth := round(pixelGetColor(1090,300))
		rodHealth := round(pixelGetColor(1150,300))
		reelHealth := round(pixelGetColor(1220,300))
		(dirExist("./logs"))
			? 0
			: dirCreate("./logs")
			
		fileAppend(lineHealth " :: " rodHealth " :: " reelHealth,"./logs/fplog.txt")
		if lineHealth > maxStress || rodHealth > maxStress || reelHealth > maxStress {
			send("{NumpadSub}")
		} else {
			send("{NumpadAdd}")
		}
	}
	maxStress := 0
	retrieve(*) {
		if !ui.autoFish
			return
		ui.fishStatusText.text := "Retrieving" 
		log("Retrieving")
		while !ui.reeledIn && ui.autoFish {
			jigMechanic := 5	
			if a_index < 30 && !(isHooked()) {
				jigMechanic := round(random(1,12))
			}
			switch jigMechanic {
				case 1,2: ;twitch
					if ui.twitchToggle.value {
						log("Retrieve Mechanic: Twitch")
						loop round(random(1,2)) {
							send("{RShift down}")
							sleep(150)
							send("{RShift up}")
							sleep(round(random(200,400)))
						}
					}
				case 3,4: ;pause
					if ui.waitToggle.value {
						log("Retrieve Mechanic: Pause")
						; loop round(random(4)) {
							sleep(1000)
							if !ui.autoFish
								return
						}
					;}
					sleep(round(random(1,999)))
				case 5,6,7,8,9,10,11,12: ;reel
					log("Retrieve Mechanic: Reel")
					if !ui.reeledIn
						send("{space down}")
					; loop round(random(2,4)) {
					; if !ui.reeledIn
						sleep(500)
					; }
					; if !ui.reeledIn
						; sleep(round(random(1,999)))
						send("{space up}")
				}
		}
		
		(sleep500(6)) ? exit : 0
		
		if fishCaught() {
			ui.fishLogCount.text += 1
			send("{space}")
			(sleep500(2)) ? exit : 0
			send("{backspace}")
			(sleep500(3)) ? exit : 0
		} else {	
			log("No Fish Detected.")
		}

	}

	updateAfkTime(*) {
		secondsElapsed := a_now-ui.afkStartTime
		ui.fishLogAfkTime.text := format("{:02}",floor(secondsElapsed/3600)) ":" format("{:02}",floor(secondsElapsed/60)) ":" format("{:02}",mod(secondsElapsed,60))
	}
	updateSessionTime(*) {
		secondsElapsed := a_now-ui.sessionStartTime
		ui.fishLogSessionTime.text := format("{:02}",floor(secondsElapsed/3600)) ":" format("{:02}",floor(secondsElapsed/60))
	}

	setTimer(updateSessionTime,1000)
	setTimer(checkReel,200)
	checkReel(*) {
		checkFocus()
		if ui.isCasting
			return
		ui.checkReel1 := round(pixelGetColor(1027,637))
		ui.checkReel2 := round(pixelGetColor(1027,653))
		ui.checkReel3 := round(pixelGetColor(1047,637))
		ui.checkReel4 := round(pixelGetColor(1047,653))
		ui.checkReel5 := round(pixelGetColor(1037,645))
			
		if (ui.checkReel1 >= 16250871
			&& ui.checkReel2 >= 16250871
			&& ui.checkReel3 >= 16250871
			&& ui.checkReel4 >= 16250871
			&& ui.checkReel5 < 16250871) {
				ui.reeledIn := 1
				send("{space up}")
				send("{rshift up}")
			}
		else
			ui.reeledIn := 0
		
		return ui.reeledIn
	}

	isHooked(*) {
		hookedPixel := round(pixelGetColor(1220,230)) 
		if (hookedPixel > (round(0x3BCC3C) - 10000) && hookedPixel < (round(0x3BCC3C) + 10000)) {
			log("HOOKED!")
			ui.isHooked := 1
		} else
			ui.isHooked := 0
			
		return ui.isHooked
	}

	reeledIn(*) {
		ui.checkReel1 := round(pixelGetColor(1027,637))
		ui.checkReel2 := round(pixelGetColor(1027,653))
		ui.checkReel3 := round(pixelGetColor(1047,637))
		ui.checkReel4 := round(pixelGetColor(1047,653))
		ui.checkReel5 := round(pixelGetColor(1037,645))
		
		if (ui.checkReel1 >= 16250871
			&& ui.checkReel2 >= 16250871
			&& ui.checkReel3 >= 16250871
			&& ui.checkReel4 >= 16250871
			&& ui.checkReel5 < 16250871)
				ui.reeledIn := 1
		else
			ui.reeledIn := 0
		
		if (cfg.debug) {
			if ui.reeledIn
				log("Reeled In")
			else 
				log("Checking Reel: " ui.checkReel1 ":" ui.checkReel2 ":" ui.checkReel3 ":" ui.checkReel4 ":" ui.checkReel5)
			}
		return ui.reeledIn
		} 

	fishCaught(*) {
		fishCaughtPixel := round(pixelGetColor(450,575))
		log("Analyzing Catch: " fishCaughtPixel)
		if (fishCaughtPixel >= 16250871) {
			if !(DirExist("./fishPics"))
				DirCreate("./fishPics")
			run("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "./fishPics/" formatTime(,"yyMMddhhmmss") ".png",,"hide")
			sleep(1000)
			log("Fish Caught!")
			return 1
		} else {
			return 0
		}
	}
	
	checkRewards(*) {
		rewardScreenPixel := round(pixelGetColor(213,529))
		log("Reward Screen Pixel: " rewardScreenPixel)
		if (rewardScreenPixel >= 16250871) {
			log("Challenge Completion Detected")
			log("Claiming Reward")
			mouseClick("left",213,529)
			sleep(500)
		}
	}

	checkAds(*) {
		AdScreenPixel := round(pixelGetColor(1037,625))
		log("AdScreen Pixel: " AdScreenPixel)
		if (AdScreenPixel >= 16250871) {
			log("Ad Screen Detected")
			log("Dismissing Ad")
			mouseClick("left",1037,625)
			sleep(500)
		}
	}

	toggleLog(*) {
		static logVisible := false
		(logVisible := !logVisible)
			? (ui.fishLog.opt("-hidden"),ui.fishLogText.opt("-hidden"))
			: (ui.fishLog.opt("hidden"),ui.fishLogText.opt("hidden"))
	}



	appReload(*) {
		reload()
	}

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
			;ui.fishLogText.text .= formatTime(,"[yyyy-MM-dd@hh:mm:ss]> ") msg "`n"
	}

	createGui()
	createGui(*) {
		ui.fishGui := gui()
		ui.fishGui.opt("-caption owner" winGetId("ahk_exe fishingPlanet.exe"))
		ui.fishGui.backColor := ui.bgColor[1]
		winSetTransColor("010203",ui.fishGui.hwnd)
		ui.appFrame := ui.fishGui.addText("x0 y0 w1583 h814 c" ui.fontColor[3] " background" ui.bgColor[3])

		ui.appFrame2 := ui.fishGui.addText("x1 y1 w1581 h812 c" ui.fontColor[1] " background" ui.bgColor[2])
		ui.fpBg := ui.fishGui.addText("x301 y31 w1279 h719 c010203 background010203")
		ui.titleBar := ui.fishGui.addText("x301 y2 w1252 h27 cC7C7C7 background" ui.bgColor[1])
		ui.titleBar.onEvent("click",wm_lbuttonDown_callback)
		ui.titleBarText := ui.fishGui.addText("x305 y6 w1280 h30 cC7C7C7 backgroundTrans","Fishing Planet`t(fpassist v" a_fileVersion ")")
		ui.titleBarText.setFont("s13","Arial Bold")
		ui.titleBarExitButton := ui.fishGui.addText("x1554 y2 w26 h27 center background" ui.bgColor[1] " c" ui.fontColor[2],"T")
		ui.titleBarExitButton.setFont("s21","wingdings 2")
		ui.titleBarExitButton.onEvent("click",cleanExit)
		;ui.appFrame.onEvent("click",WM_LBUTTONDOWN_callback)
		;ui.appFrame2.onEvent("click",WM_LBUTTONDOWN_callback)
		;ui.titleBar3.onEvent("click",WM_LBUTTONDOWN_callback)
		ui.fishStatus := ui.fishGui.addText("x2 y752 w1580 h61 cBBBBBB background" ui.bgColor[1])
		ui.fishStatusText := ui.fishGui.addText("x15 y765 w1280 h60 cBBBBBB backgroundTrans","Ready to Cast")
		ui.fishStatusText.setFont("s24")
		ui.twitchToggleButton := ui.fishGui.addPicture("section x320 y755 w45 h25 backgroundTrans",(cfg.twitchToggleValue) ? "./img/toggle_on.png" : "./img/toggle_off.png")
		ui.twitchToggleButton.onEvent("click",toggleTwitch)
		ui.twitchToggle := ui.fishGui.addText("x+5 ys+1 w130 h30 backgroundTrans c" ui.fontColor[3],"Twitch [F6]")
		ui.twitchToggle.setFont("s12")
				
		ui.waitToggleButton := ui.fishGui.addPicture("section x320 y784 w45 h25 backgroundTrans",(cfg.waitToggleValue) ? "./img/toggle_on.png" : "./img/toggle_off.png")
		ui.waitToggleButton.onEvent("click",toggleWait)
		ui.waitToggle := ui.fishGui.addText("x+5 ys+1 w130 h30 backgroundTrans c" ui.fontColor[3],"Stop n Go [F7]")
		ui.waitToggle.setFont("s12")
		ui.castAdjustBg := ui.fishGui.addText("x500 y752 w140 h58 background" ui.bgColor[1])
		ui.castAdjustBg := ui.fishGui.addText("x501 y753 w138 h56 background" ui.bgColor[1])
		ui.castAdjustBg := ui.fishGui.addText("x502 y754 w136 h54 background" ui.bgColor[1])
		ui.castAdjust := ui.fishGui.addSlider("section toolTip buddy2ui.castAdjustText center x500 y753 w140 h20 c" ui.bgColor[1] " range1600-2200",1910)
		ui.castAdjust.onEvent("change",castAdjustChanged)
				ui.castAdjustLabel := ui.fishGui.addText("xs-24 y+2 w80 h40 right backgroundTrans","Cast`nAdjust")
		ui.castAdjustLabel.setFont("s11 c" ui.fontColor[3])
		ui.castAdjustText := ui.fishGui.addText("x+10 ys+22 left w80 h40 backgroundTrans c" ui.fontColor[5],cfg.castAdjust)
		ui.castAdjustText.setFont("s20")
		castAdjustChanged(*) {
			cfg.castAdjust := ui.castAdjust.value
			ui.castAdjustText.text := cfg.castAdjust
		}

		ui.startButton := ui.fishGui.addText("section x1060 y765 w160 h60 cBBBBBB backgroundTrans","[F3] Start")
		ui.startButton.setFont("s22","Helvetica")
		ui.startButton.onEvent("click",autoFishStart)
		ui.stopButton := ui.fishGui.addText("x+-160 ys+0 w160 h60 cBBBBBB hidden cCCCC33 backgroundTrans","[F4] Stop")
		ui.stopButton.setFont("s22","Helvetica")
		ui.stopButton.onEvent("click",autoFishStop)
		ui.reloadButton := ui.fishGui.addText("section x+15 ys+0 w160 h60 cBBBBBB backgroundTrans","[F5] Reload")
		ui.reloadButton.setFont("s22","Helvetica")
		ui.reloadButton.onEvent("click",appReload)
		; ui.logButton := ui.fishGui.addText("section x+50 ys+0 w180 h60 cBBBBBB backgroundTrans","[F6]Show Log")
		; ui.logButton.setFont("s22","Helvetica")
		; ui.logButton.onEvent("click",toggleLog)
		ui.exitButton := ui.fishGui.addText("section x+48 ys+0 w160 h60 cBBBBBB backgroundTrans","[F8] Exit")
		ui.exitButton.setFont("s22","Helvetica")	
		ui.exitButton.onEvent("click",cleanExit)
		ui.fishLogHeader := ui.fishGui.addText("x2 y1 w296 h28 background222222")
		ui.fishLogHeaderSpace := ui.fishGui.addText("x300 y1 w1 h29 background" ui.bgColor[3])
		ui.fishLogHeaderText := ui.fishGui.addText("x5 y2 w300 h28 c353535 backgroundTrans","Log")
		ui.fishLogHeaderText.setFont("s14 cAAAAAA","Bold")
		ui.fishLogCountLabel := ui.fishGui.addText("x220 y1 w40 h25 backgroundTrans right cAAAAAA"," Fish")
		ui.fishLogCountLabel.setFont("s11","Helvetica")
		ui.fishLogCountLabel2 := ui.fishGui.addText("x220 y12 w40 h25 backgroundTrans right cAAAAAA","Count")
		ui.fishLogCountLabel2.setFont("s11","Helvetica")
		ui.fishLogCount := ui.fishGui.addText("x267 y2 w40 h30 backgroundTrans ceedc82",ui.fishCount)
		ui.fishLogCount.setFont("s18","Impact") 
		ui.fishLog := ui.fishGui.addText("x2 y30 w298 h690 background353535")
		ui.fishLogText := ui.fishGui.addListbox("x2 y33 w298 h680 -wrap 0x2000 0x100 -E0x200 background353535",[])
		ui.fishLogText.setFont("s13 cBBBBBB")
		ui.fishLogFooterOutline := ui.fishGui.addText("x2 y719 w298 h1 background" ui.bgColor[1])
		ui.fishLogFooter := ui.fishGui.addText("x2 y720 w298 h30 background454545")
		ui.fishLogSessionTime := ui.fishGui.addText("section right x7 y722 w60 h30 c" ui.fontColor[3] " backgroundTrans","00:00:00")
		ui.fishLogSessionTime.setFont("s18","Arial")
		ui.fishLogSessionTimeLabel := ui.fishGui.addText("x+8 ys+4 w65 h30 backgroundTrans c" ui.fontColor[5],"Session")
		ui.fishLogSessionTimeLabel.setFont("s12 Bold","Helvetica")
		ui.fishLogTimerSpace := ui.fishGui.addText("x+7 ys-2 w1 h30 background" ui.bgColor[1])
		ui.fishLogAfkTimeLabel := ui.fishGui.addText("section right x+5 ys+4 w40 h30 c" ui.fontColor[5] " backgroundTrans","AFK")
		ui.fishLogAfkTimeLabel.setFont("s12 Bold","Helvetica")
		ui.fishLogAfkTime := ui.fishGui.addText("right x+7 ys-4 w92 h30 c" ui.fontColor[3] " backgroundTrans","00:00:00")
		ui.fishLogAfkTime.setFont("s18","Arial")
		ui.waitToggle.onEvent("click",toggleWait)
		ui.twitchToggle.onEvent("click",toggleTwitch)
		

		try
			winSetAlwaysOnTop(0,"ahk_exe fishingPlanet.exe")

		;msgBox(winGetMinMax("ahk_exe fishingPlanet.exe"))
		try
			winActivate("ahk_exe fishingPlanet.exe")
		;if (winGetMinMax("ahk_exe fishingPlanet.exe") == 0)
		sleep(500)
		try
			WinSetStyle("-0xC00000","ahk_exe fishingplanet.exe")
		try
			winGetPos(&x,&y,&w,&h,"ahk_exe fishingPlanet.exe")
		try
		while (w > 1280 || h > 720) && a_index < 4 {
			sleep(2000)
			send("{alt down}{enter}{alt up}")
			sleep(2000)
			WinSetStyle("-0xC00000","ahk_exe fishingplanet.exe")
			winMove((a_screenwidth/2)-590,(a_screenheight/2)-370,1280,720,"ahk_exe fishingPlanet.exe" 		)
			winGetPos(&x,&y,&w,&h,"ahk_exe fishingPlanet.exe")
		}
		; OnMessage(0x0202, moveWindow)
		; moveWindow(*) {
		try
			ui.fishGui.show("x" x-300 " y" y-30 " w1584 h814 noActivate")
		;ui.fishGui.onEvent("focus",appFocused)
		
		appFocused(*) {
			winActivate("ahk_exe fishingPlanet.exe")
		}
		; }
	}
	onExit(exitFunc)

	;onMessage(0x0200,WM_LBUTTONDOWN)
	onMessage(0x47,WM_WINDOWPOSCHANGED)
	WM_LBUTTONDOWN(wparam,lparam,msg,hwnd) {
		;msgBox(hwnd.hwnd)
		if hwnd == wparam.hwnd
			postMessage("0xA1",2,,,"A")
	}

	WM_LBUTTONDOWN_callback(this_control*) {
		postMessage("0xA1",2,,,"A")
	;	WM_LBUTTONDOWN(0,0,0,this_control)
	}

	WM_WINDOWPOSCHANGED(wParam, lParam, msg, Hwnd) {
		try {
			(hwnd == ui.fishGui.hwnd)
				? moveFP()
				: 0
		}	catch {
			return 0
		}
		moveFP(*) {
			
				winGetPos(&x,&y,&w,&h,ui.fishGui)
				winMove(x+300,y+30,,,"ahk_exe fishingplanet.exe")
				return 1
		}
	}
}

cleanExit(*) {
exitFunc()
}

exitFunc(*) {
;msgBox('here')
	try
		winActivate("ahk_exe fishingPlanet.exe")
	try
		WinSetStyle("+0xC00000","ahk_exe fishingplanet.exe")
	iniWrite(cfg.twitchToggleValue,cfg.file,"Game","TwitchToggle")
	iniWrite(cfg.waitToggleValue,cfg.file,"Game","WaitToggle")
	iniWrite(cfg.castAdjust,cfg.file,"Game","CastAdjust")
	;sleep(250)
	;send("{alt down}{enter}{alt up}")
	if winExist("ahk_exe fishingPlanet.exe")
		winKill("ahk_exe fishingPlanet.exe")
	exitApp
}

