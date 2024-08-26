A_FileVersion := "1.1.1.2"
#singleInstance

persistent()

ui := object()
ui.autoFish := false
ui.debug := false
ui.fishLogArr := array()
ui.fishCount := 0

jigMethod := [1,2,3]



ui.startKey := "F3"
ui.stopKey := "F4"
ui.reloadKey := "F5"
ui.showLogKey := "F6"
ui.exitKey := "F7"
ui.autoclickerActive := false
hotIfWinActive("ahk_exe fishingPlanet.exe")
	hotKey(ui.startKey,autoFishStart)
	hotKey(ui.stopKey,autoFishStop)
	hotKey(ui.reloadKey,appReload)
	hotKey(ui.showLogKey,toggleLog)
	hotKey(ui.exitKey,cleanExit)
	Numpad0:: {
		oneFish()
	}
	
	^enter:: {
		ui.autoclickerActive := true
			loop {
				if !ui.autoclickerActive
					break
				if winActive("ahk_exe fishingPlanet.exe") {
					send("{LButton down}")
					sleep(100)
					send("{LButton up}")
				sleep(round(random(1,100)))
			}
		}
	}
	
	^+enter:: {
		ui.autoclickerActive := false
	}		
hotIf()

oneFish(*) {
	cast()
	retrieve()
}

autoFishStop(*) {
	ui.autoFish := false
	ui.fishStatusText.text := "Stopped"
	ui.startButton.opt("cBBBBBB")
}

autoFishStart(*) {
	ui.autoFish := 1
	ui.startButton.opt("c55CC55")
	while ui.autoFish == 1 {
		cast()
		retrieve()
		if reeledIn()
			if fishCaught() {
				log("Fish Caught!")
				ui.fishLogCount.text += 1
				send("{space}")
				sleep(1000)
				send("{backspace}")
				sleep(1500)
			} else {
				log("No Fish, Trying Again.")
			}
		else
			retrieve()
	}
}


cast(*) {
	if !ui.autoFish
		return
	ui.fishStatusText.text := "Casting...."
	
	log("Casting")
	sleep(1000) 
	if !ui.autoFish
		return
	sleep(1000)
	if !ui.autoFish 
		return
	sleep(500)
	if !ui.autoFish
		return
	send("{space down}")
	sleep(1000)
	if !ui.autoFish
		return
	sleep(1000)
	if !ui.autoFish
		return
	send("{space up}")
	if !ui.autoFish
		return	 
	sleep(1000)
	if !ui.autoFish
		return	
	sleep(1000)
	if !ui.autoFish
		return	
	sleep(1000)
	if !ui.autoFish
		return	
	sleep(1000)
	if !ui.autoFish
		return	
	sleep(1000)
	if !ui.autoFish
		return	
	sleep(1000)
}

retrieve(*) {
	ui.fishStatusText.text := "Retrieving / Jigging" 
	while !reeledIn() {
		if a_index < 30 {
			jigMechanic := round(random(1,3))
		} else {
			jigMechanic := 3
		}
		
		switch jigMechanic {
			case 1: ;twitch
				log("Jig Mechanic: Twitch")
				;send("{space down}")
				loop round(random(1,2)) {
						;send("{space down}")
						send("{RShift down}")
						sleep(100)
						send("{RShift up}")
						sleep(round(random(200,400)))
				}
				send("{space up}")
			case 2: ;pause
				log("Jig Mechanic: Pause")
				send("{space up}")
				loop round(random(4)) {
					sleep(1000)
					if !ui.autoFish
						return
				}
				sleep(round(random(1,999)))
				send("{space down}")
			case 3: ;reel
				log("Jig Mechanic: Reel")
				send("{space down}")
				loop round(random(2,4)) {
					sleep(1000)
				}
				sleep(round(random(1,999)))
				send("{space up}")
			}
	}
	sleep(1500)
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
			reeledIn := 1
	else
		reeledIn := 0
	
	if (ui.debug) {
		if reeledIn
			log("Reeled In")
		else 
			log("Checking Reel: " ui.checkReel1 ":" ui.checkReel2 ":" ui.checkReel3 ":" ui.checkReel4 ":" ui.checkReel5)
		}
	return reeledIn
	} 

fishCaught(*) {
	if (round(pixelGetColor(450,575)) >= 16250871) {
		return 1
	} else {
		return 0
	}
}

toggleLog(*) {
	static logVisible := false
	(logVisible := !logVisible)
		? (ui.fishLog.opt("-hidden"),ui.fishLogText.opt("-hidden"))
		: (ui.fishLog.opt("hidden"),ui.fishLogText.opt("hidden"))
}

cleanExit(*) {
	exitApp
}

appReload(*) {
	reload()
}

log(msg) {
	if strSplit(ui.fishLogText.text,"`n").length > 34 {
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
	ui.fishGui.backColor := "010203"
	winSetTransColor("010203",ui.fishGui.hwnd)
	ui.titleBar2 := ui.fishGui.addText("x400 y0 w1280 h30 cBBBBBB background444444")
	ui.titleBar3 := ui.fishGui.addText("x400 y1 w1278 h28 cBBBBBB background999999")
	ui.titleBar := ui.fishGui.addText("x400 y1 w1278 h29 cBBBBBB background555555")
	ui.titleBarText := ui.fishGui.addText("x405 y5 w1280 h30 cC7C7C7 backgroundTrans","Fishing Planet")
	ui.titleBarText.setFont("s13","Arial Bold")
	ui.titleBar.onEvent("click",WM_LBUTTONDOWN_callback)
	ui.titleBar2.onEvent("click",WM_LBUTTONDOWN_callback)
	ui.titleBar3.onEvent("click",WM_LBUTTONDOWN_callback)
	ui.fishStatus := ui.fishGui.addText("x400 y750 w1280 h60 cBBBBBB background353535")
	ui.fishStatusText := ui.fishGui.addText("x408 y760 w1280 h60 cBBBBBB backgroundTrans","Ready to Cast")
	ui.fishStatusText.setFont("s24")
	ui.startButton := ui.fishGui.addText("section x820 y760 w140 h60 cBBBBBB backgroundTrans","[F3]Start")
	ui.startButton.setFont("s22","Helvetica")
	ui.startButton.onEvent("click",autoFishStart)
	ui.stopButton := ui.fishGui.addText("x+25 ys+0 w140 h60 cBBBBBB backgroundTrans","[F4]Stop")
	ui.stopButton.setFont("s22","Helvetica")
	ui.stopButton.onEvent("click",autoFishStop)
	ui.reloadButton := ui.fishGui.addText("section x+10 ys+0 w140 h60 cBBBBBB backgroundTrans","[F5]Reload")
	ui.reloadButton.setFont("s22","Helvetica")
	ui.reloadButton.onEvent("click",appReload)
	ui.logButton := ui.fishGui.addText("section x+50 ys+0 w180 h60 cBBBBBB backgroundTrans","[F6]Show Log")
	ui.logButton.setFont("s22","Helvetica")
	ui.logButton.onEvent("click",toggleLog)
	ui.exitButton := ui.fishGui.addText("section x+30 ys+0 w140 h60 cBBBBBB backgroundTrans","[F7]Exit")
	ui.exitButton.setFont("s22","Helvetica")
	ui.exitButton.onEvent("click",exitFunc)
	ui.fishLogHeader := ui.fishGui.addText("x0 y30 w400 h30 background555555")
	ui.fishLogHeaderText := ui.fishGui.addText("x5 y32 w400 h28 c353535 backgroundTrans","Log")
	ui.fishLogHeaderText.setFont("s14 cAAAAAA","Bold")
	ui.fishLogCountLabel := ui.fishGui.addText("x320 y31 w40 h25 backgroundTrans right cAAAAAA"," Fish")
	ui.fishLogCountLabel.setFont("s11","Helvetica")
	ui.fishLogCountLabel2 := ui.fishGui.addText("x320 y42 w40 h25 backgroundTrans right cAAAAAA","Count")
	ui.fishLogCountLabel2.setFont("s11","Helvetica")
	ui.fishLogCount := ui.fishGui.addText("x365 y32 w40 h30 backgroundTrans ceedc82",ui.fishCount)
	ui.fishLogCount.setFont("s18","Impact")
	ui.fishLog := ui.fishGui.addText("x0 y60 w400 h690 background353535")
	ui.fishLogText := ui.fishGui.addListbox("x0 y63 w400 h720 r34 -wrap -E0x200 background353535",[])
	ui.fishLogText.setFont("s13 cBBBBBB")
	winSetAlwaysOnTop(0,"ahk_exe fishingPlanet.exe")

	;msgBox(winGetMinMax("ahk_exe fishingPlanet.exe"))
	winActivate("ahk_exe fishingPlanet.exe")
	;if (winGetMinMax("ahk_exe fishingPlanet.exe") == 0)
	sleep(1500)
	WinSetStyle("-0xC00000","ahk_exe fishingplanet.exe")
	winGetPos(&x,&y,&w,&h,"ahk_exe fishingPlanet.exe")
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
	ui.fishGui.show("x" x-400 " y" y-30 " w1700 h840 noActivate")
	;ui.fishGui.onEvent("focus",appFocused)
	appFocused(*) {
		winActivate("ahk_exe fishingPlanet.exe")
	}
	; }
}
onExit(exitFunc)

hotIfWinActive("ahk_exe fishingPlanet.exe")
;onMessage(0x0200,WM_LBUTTONDOWN)
onMessage(0x47,WM_WINDOWPOSCHANGED)
WM_LBUTTONDOWN(wparam,lparam,msg,hwnd) {
	;msgBox(hwnd.hwnd)
	postMessage("0xA1",2,,,"A")
}

WM_LBUTTONDOWN_callback(this_control*) {
	WM_LBUTTONDOWN(0,0,0,this_control)
}

WM_WINDOWPOSCHANGED(wParam, lParam, msg, Hwnd) {
	if hwnd == ui.fishGui.hwnd {
		winGetPos(&x,&y,&w,&h,ui.fishGui.hwnd)
		winMove(x+400,y+30,,,"ahk_exe fishingplanet.exe")
		;msgBox('here')
	}
}

exitFunc(*) {
		WinSetStyle("+0xC00000","ahk_exe fishingplanet.exe")
		winActivate("ahk_exe fishingPlanet.exe")
		sleep(250)
		send("{alt down}{enter}{alt up}")
	exitApp
}
