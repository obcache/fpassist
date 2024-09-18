A_FileVersion := "1.2.6.7"
A_AppName := "fpassist"
#requires autoHotkey v2.0+
#singleInstance

persistent()
;try
	;run("./update.exe")
	
setWorkingDir(a_scriptDir)
ui := object()
cfg := object()
tmp := object()

cfg.file := a_appName ".ini"
cfg.installDir := a_mydocuments "\" a_appName "\"
ui.gameExe := "fishingPlanet.exe"
ui.game := "ahk_exe " ui.gameExe

cfg.twitchToggleValue := iniRead(cfg.file,"Game","TwitchToggle",true)
cfg.waitToggleValue := iniRead(cfg.file,"Game","WaitToggle",true)
cfg.profileSelected := iniRead(cfg.file,"Game","ProfileSelected",1)
cfg.profileName := strSplit(iniRead(cfg.file,"Game","ProfileNames","Profile #1,Profile #2,Profile #3,Profile #4,Profile #5"),",")
cfg.dragLevel 	:= strSplit(iniRead(cfg.file,"Game","DragLevel","5,5,5,5,5"),",")
cfg.reelSpeed 	:= strSplit(iniRead(cfg.file,"Game","ReelSpeed","1,1,1,1,1"),",")
cfg.castAdjust 	:= strSplit(iniRead(cfg.file,"Game","CastAdjust","2000,2000,2000,2000,2000"),",")
cfg.zoomEnabled := strSplit(iniRead(cfg.file,"Game","ZoomEnabled","0,0,0,0,0"),",")
cfg.reelLevel 	:= strSplit(iniRead(cfg.file,"Game","SpeedLevel","10,10,10,10,10"),",")
cfg.debug 		:= iniRead(cfg.file,"System","Debug",false)

ui.fishLogArr := array()
ui.sliderList := array()
ui.cancelOperation := false
ui.isAFK := false
ui.bgColor := ["202020","333333","666666","","858585","999999","C9C9C9"]
ui.fontColor := ["D2D2D2","AAAAAA","999999","666666","353535","151515"]
ui.trimColor := ["1c8508","7a2814","44DDCC","11EE11","EE1111","303030"]

ui.loadingProgress := 5
ui.reeledIn := true

#include <libGlobal>
#include <libGui>

verifyAdmin()
if a_isCompiled && !inStr(cfg.installDir,a_scriptDir) {
	;msgBox(a_isCompiled "`n" cfg.installDir "`n" a_scriptDir "`n" inStr(cfg.installDir,a_scriptDir))
	if DirExist(cfg.installDir) {
		processClose("fpassist.exe")
		DirDelete(cfg.installDir,1)
	}
	install()
	exitApp
}

startGame()
initGui()
createGui()

detectPrompts(0)
onExit(exitFunc)

initGui(*) {
	ui.sessionStartTime := A_Now
	ui.autoFish := false
	ui.fullscreen := false
	ui.fishCount := 000
	ui.reeledIn := false
	ui.isCasting := false
	ui.autoclickerActive := false

	ui.startKey := "F3"
	ui.startKey2 := "q"
	ui.stopKey := "F4"
	ui.cancelKey := "c"
	ui.reloadKey := "F9"
	ui.castKey := "F5"
	ui.castKey2 := "f"
	ui.reelKey := "F7"
	ui.reelKey2 := "r"
	ui.exitKey := "F10"
	ui.retrieveKey := "F6"
	ui.retrieveKey2 := "v"
	ui.flashlight := "+F"

	ui.startKeyMouse := "!LButton"
	ui.stopKeyMouse := "!RButton"
	hotIfWinActive(ui.game)
		hotkey(ui.reelKey2,singleReel)
		hotKey(ui.startKey,autoFishStart)
		hotKey(ui.startKey2,autoFishStart)
		hotKey(ui.startKeyMouse,autoFishStart)
		hotKey(ui.stopKeyMouse,autoFishStop)
		hotKey(ui.reloadKey,appReload)
		hotKey(ui.castKey,singleCast)
		hotKey(ui.castKey2,singleCast)
		hotKey(ui.reelKey,singleReel)
		hotKey(ui.reelKey2,singleReel)
		hotKey(ui.retrieveKey,singleRetrieve)
		hotKey(ui.retrieveKey2,singleRetrieve)
		hotkey(ui.cancelKey,cancelOperation)
		hotKey(ui.exitKey,cleanExit)
	hotif()
	ui.castCount := 0
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
	winMove(0,0,1280,720,ui.game)
	sleep(1000)
	ui.loadingProgress.value += 4
	winGetPos(&x,&y,&w,&h,ui.game)
	while w != 1280 || h != 720 {
		sleep(1000)
		if w == a_screenWidth && h == a_screenHeight {
			winActivate("ahk_exe fishingPlanet.exe")
			sendNice("{alt down}{enter}{alt up}")
			sleep(500)
			ui.loadingProgress.value += 2
			winMove(0,0,1280,720,ui.game)
			sleep(500)
			ui.loadingProgress.value += 2
			winGetPos(&x,&y,&w,&h,ui.game)
			;send("{enter}")
		}
	winSetStyle("-0xC00000",ui.game)
	winSetTransparent(0,ui.game) 
	}
}

m(msg := "") {
	static dbugMsg := 0
	dbugMsg += 1
	msgBox(dbugMsg ". " msg)
}

autoFishStop(*) {
	ui.autoFish := 0
	ui.isAFK := false
	ui.fishLogAfkTime.text := "00:00:00"
	;setTimer(updateAfkTime,0)
	; ui.startButton.opt("-hidden")
	; ui.startButtonHotkey.opt("-hidden")
	; ui.stopButton.opt("hidden")
	; ui.stopButtonHotkey.opt("hidden")

	ui.fishLogAfkTime.opt("+hidden")
	ui.fishLogAfkTimeLabel.opt("+hidden")
	ui.fishLogAfkTimeLabel2.opt("+hidden")
	ui.bigFishCaught.opt("+hidden")
	ui.bigFishCaughtLabel.opt("+hidden")
	ui.bigFishCaughtLabel2.opt("+hidden")	
	ui.secondsElapsed := 0
	
	send("{space up}")
	send("{lshift up}")
	send("{lbutton up}")
	send("{rbutton up}")

	ui.startButtonBg.opt("background273d62")
	ui.startButtonBg.redraw()
	ui.castButtonBg.opt("background" ui.bgColor[1])
	ui.castButtonBg.redraw() 
	ui.retrieveButtonBg.opt("background " ui.bgColor[3])
	ui.retrieveButtonBg.redraw()
	ui.castButtonBg.opt("background" ui.bgColor[1])
	ui.castButtonBg.redraw() 
	ui.cancelButtonBg.opt("background5c0303")
	ui.cancelButtonBg.redraw()
	ui.cancelButton.setFont("c" ui.fontColor[1])
	ui.cancelButtonHotkey.setFont("c" ui.fontColor[1])
	ui.startbutton.setFont("c" ui.fontColor[1])
	ui.startbuttonHotkey.setFont("c" ui.fontColor[1])
	ui.retrieveButton.setFont("c" ui.fontColor[1])
	ui.retrieveButtonHotKey.setFont("c" ui.fontColor[1])
	ui.reelButton.setFont("c" ui.fontColor[1])
	ui.reelButtonHotkey.setFont("c" ui.fontColor[1])
	ui.castButton.setFont("c" ui.fontColor[1])
	ui.castButtonHotkey.setFont("c" ui.fontColor[1])
	
	ui.cancelOperation := false
	ui.reeling := false
	ui.casting := false
	ui.retrieving := false
	
	if !fileExist(a_scriptDir "/logs/current_log.txt")
		fileAppend('"Session Start","AFK Start","AFK Duration","Fish Caught","Cast Count","Cast Length","Drag Level","Reel Speed"`n', a_scriptDir "/logs/current_log.txt")
	fileAppend(ui.statSessionStartTime.text "," ui.statAfkStartTime.text "," ui.statAfkDuration.text "," ui.statFishCount.text "," ui.statCastCount.text "," ui.statCastLength.text "," ui.statDragLevel.text "," ui.statReelSpeed.text "`n", a_scriptDir "/logs/current_log.txt")
	

}

autoFishStart(*) {
	ui.autoFish := 1
	ui.isAFK:=true
	ui.statCastCount.text := format("{:02d}",ui.statCastCount.text + 1)
	ui.secondsElapsed := 0
	ui.statAfkStartTime.text := formatTime(,"yyyyMMdd HH:mm:ss")
	setTimer(updateAfkTime,1000)
	; ui.startButton.opt("hidden")
	; ui.startButtonHotkey.opt("hidden")
	; ui.stopButton.opt("-hidden")
	; ui.stopButtonHotkey.opt("-hidden")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	ui.bigFishCaught.opt("-hidden")
	ui.bigFishCaughtLabel.opt("-hidden")
	ui.bigFishCaughtLabel2.opt("-hidden")
	ui.startButtonBg.opt("background" ui.trimColor[1])
	ui.startButtonBg.redraw()
	ui.startButton.setFont("c" ui.fontColor[5])
	ui.startButton.redraw()
	ui.startButtonHotkey.setFont("c" ui.fontColor[5])
	ui.startButtonHotkey.redraw()
	ui.cancelButtonBg.opt("background" ui.trimColor[2])
	ui.cancelButtonBg.redraw()
	
	send("{space up}")
	send("{lshift up}")
	send("{lbutton up}")
	send("{rbutton up}")
	ui.reeling := false
	ui.casting := false
	ui.retrieving := false
	;setTimer(detectPrompts,15000)
	log("AFK: Starting","AFK: Started")
	
	while ui.autoFish == 1 && !ui.cancelOperation {
		detectPrompts(1)
		(sleep500(2,0)) ? exit : 0
		if !reeledIn() && !ui.cancelOperation
			reelIn(1)
		if reeledIn() && !ui.cancelOperation
			cast(1)
		if !reeledIn() && !ui.cancelOperation
			retrieve()
		
		if !ui.cancelOperation
			analyzeCatch()
	}
	log("AFK: Stopping","AFK: Stopped")
	log("___________________________________________________________________")
}


isHooked(*) {
	if pixelGetColor(1090,510) == 0x419AAC {
		log("Line: HOOK SET!")
		ui.isHooked := 1
	} else {
		ui.isHooked := 0
	}
	
	return ui.isHooked
}

checkPixel(x,y,color,dataType := "decimal") {
	loadColor := round(pixelGetColor(x,y))
	if (loadColor < round(color)+10000) && (loadColor > round(color)-10000) {
		errorLevel := 1
		log("Line: BITE DETECTED!")
	} else
		errorLevel := 0
	;if ui.debug
	;log("Pixel: " x "x" y)
	;log("Color: " loadColor)
	;log("Range: " round(color)-200000 "-" round(color)+200000)
	return errorLevel
}		
		

fishCaught(*) {
	fishCaughtPixel := round(pixelGetColor(450,575))
	if cfg.debug
		log("Analyzing Catch: " fishCaughtPixel)
	else
		log("Analyzing: Catch","Analyzed: Catch")
	if checkWhite := checkPixel(450,575,round("0xFFFFFF")) || checkGrey := checkPixel(450,575,round("0x797A7E")) {
		if !(DirExist("./fishPics"))
			DirCreate("./fishPics")
		run("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "/fishPics/" formatTime(,"yyMMddhhmmss") ".png",,"hide")
		sleep(1000)
		log("Fish Caught!")

		if ui.fishLogCount.text < 999
			ui.fishLogCount.text := format("{:03i}",ui.fishLogCount.text + 1)
			try
				ui.bigFishCaught.text := ui.fishLogCount.text
			try
				ui.statFishCount.text := ui.fishLogCount.text
			try
				ui.FishCaughtFS.text := ui.fishLogCount.text
		return 1
	} else {
		;msgbox(checkWhite "`n" checkGrey)
		return 0
	}
}


reelIn(isAFK*) {
		ui.reelButtonBg.opt("background" ui.trimColor[1])
		ui.reelButtonBg.redraw()
		ui.reelButton.setFont("c" ui.fontColor[5])
		ui.reelButton.redraw()
		ui.reelButtonHotkey.setFont("c" ui.fontColor[5])
		ui.reelButtonHotkey.redraw()
		ui.cancelButtonBg.opt("background" ui.trimColor[2])
		ui.cancelButtonBg.redraw()
		log("Reel: Starting","Reel: Started")
		log("___________________________________________________________________")

		loop 5 {
			if ui.cancelOperation
				break
			sendNice("{l}")
			sleep(150)
		}
		
		while !reeledIn() && !ui.cancelOperation {
			; if checkPixel(1090,270,"0xb21e1c") {
				; sendNice("{NumpadDel}")
			; } else {
				;send("{NumpadAdd}")
			; }
			sendNice("{space down}")
			sleep(1000)
			sendNice("{space up}")
		}
		sendNice("{space up}")
		sleep(500)
		if ui.cancelOperation
			return
		analyzeCatch()
		log("Reel: Finishing","Reel: Finished")
		ui.reelButtonBg.opt("background" ui.bgColor[1])
		ui.reelButtonBg.redraw()

}

osdNotify(msg) {
	winGetPos(&x,&y,&w,&h,ui.fishGui)	
	msgWidth := strLen(msg)*5
	ui.osdNotify := ui.fishGui.addText("-hidden x" (w/2)-(msgWidth/2) " y100 w" msgWidth " h50 backgroundTrans cEEEEEE",msg)
	setTimer () => ui.osdNotify.opt("hidden"),-5000
}

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

checkFocus(*) {
	fishFocus := (ui.autoFish)
					? !(winActive(ui.game))
						? 0
						: 1
					: 1
	if !fishFocus
		autoFishStop()
}

sleep500(loopCount := 1,stopOnReel := false) {
	errorLevel := 0
	while a_index <= loopCount && !isHooked() && !ui.cancelOperation && !reeledIn() {
		sleep(500)
		errorLevel := 1
	}	
	return errorLevel
}

sendNice(payload,gameWin:=ui.game) {
	sendIfWInActive(payload,gameWin:=ui.game,true)
}

calibrate(*) {
	log("Calibration: Drag")
	loop 13{
		winActivate(ui.game)
		sendNice("{NumpadSub}")
		sleep(50)
	}
	loop cfg.dragLevel[cfg.profileSelected] {
		sendNice("{NumpadAdd}")
		sleep(50)
	}
	
	log("Calibration: Reel Speed")
	loop 6 {
		winActivate(ui.game)
		sendNice("{click wheelDown}")
		sleep(100)
	}	 
	loop cfg.reelSpeed[cfg.profileSelected] {
		sendNice("{click wheelUp}") 
		sleep(100)
	}
log("___________________________________________________________________")

}
	
	
cast(*) {
	ui.castButtonBg.opt("background" ui.trimColor[1])
	ui.castButtonBg.redraw()
	ui.castButton.setFont("c" ui.fontColor[5])
	ui.castButton.redraw()
	ui.castButtonHotkey.setFont("c" ui.fontColor[5])
	ui.cancelButtonBg.opt("background" ui.trimColor[2])
	ui.cancelButtonBg.redraw()
	
	format("{:3di}",ui.statCastCount.text += 1)
	calibrate()
	ui.isCasting := true
	sendIfWinActive("{backspace}",ui.game,true)
	errorLevel := sleep500(3)
	log("Cast: Drawing Back Rod")
	sendIfWinActive("{space down}",ui.game,true)
	sleep(cfg.castAdjust[cfg.profileSelected])
	sendIfWinActive("{space up}",ui.game,true)
	log("Cast: Releasing Cast")
	ui.isCasting := false
	if ui.isAFK {
		log("Wait: Lure In-Flight")
		loop cfg.castTime[cfg.profileSelected] {
			sleep500(2)
		}
		log("Wait: Lure Sinking")
		loop cfg.sinkTime[cfg.profileSelected] {
			sleep500(2)
		}
	}	
	if (ui.zoomToggle.value)
		sendIfWinActive("{z}",ui.game,true)
		sleep(150)
	log("___________________________________________________________________")
	ui.castButtonBg.opt("background" ui.bgColor[1])
	ui.castButtonBg.redraw()
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
		sendIfWinActive("{NumpadSub}",ui.game,true)
	} else {
		sendIfWinActive("{NumpadAdd}",ui.game,true)
	}
}

maxStress := 0
mechanic := object()
mechanic.last := ""
mechanic.repeats := 0
retrieve(isAFK:=true) {
	if ui.cancelOperation
		return
	ui.retrieveButtonBg.opt("background" ui.trimColor[1])
	ui.retrieveButtonBg.redraw()
	ui.retrieveButton.setFont("c" ui.fontColor[5])
	ui.retrieveButton.redraw()
	ui.retrieveButtonHotkey.setFont("c" ui.fontColor[5])
	ui.retrieveButtonHotkey.redraw()
	ui.cancelButtonBg.opt("background" ui.trimColor[2])
	ui.cancelButtonBg.redraw()

	while !reeledIn() && (!isAFK || ui.autoFish) {
		if ui.cancelOperation
			return		
		if isHooked() {
			reelIn()
			return
		}
		jigMechanicNumber := round(random(1,20))
		jigMechanic := "reelLevel"
		switch jigMechanicNumber {
			case 1,2,3,4,5:
				jigMechanic := "twitchLevel"
				log("Retrieve: Twitch")
				sendNice("{space down}")
				sendNice("{RButton Down}")
				sleep(round(random(100,200)))
				sendNice("{RButton Up}")
				sendNice("{space up}")
			case 6,7,8,9,10:
				jigMechanic := "pauseLevel"
				jigMechanicNumber -= 5
				log("Retrieve: Pause")
				sendNice("{space}")
				sleep(1000)
				sleep(round(random(99-999)))
			case 11,12,13,14,15,16,17,18,19,20:
				jigMechanic := "reelLevel"
				jigMechanicNumber -= 10
				log("Retrieve: Reel")
				sendNice("{space down}")
				sleep(1500)
				sendNice("{space up}")
			}
			
		if (jigMechanicNumber < cfg.%jigMechanic%[cfg.profileSelected]) 
		&& (mechanic.last != jigMechanic || mechanic.repeats < 3) {
			if (mechanic.last == jigMechanic)
				mechanic.repeats += 1
			else
				mechanic.repeats := 1
			mechanic.last := jigMechanic	
			sleep(1000)
		}
	}
	log("___________________________________________________________________")
	ui.retrieveButtonBg.opt("background" ui.bgColor[1])
	ui.retrieveButtonBg.redraw()
}

analyzeCatch(*) { 
	if reeledIn() {
		sleep500(6)
		if fishCaught() {
			sendNice("{space}")
			sleep500(6)
			sendNice("{backspace}")
			sleep500(2)
		} else {	
			log("No Fish Detected.")
		}
	}
}

updateAfkTime(*) {
	
	ui.secondsElapsed += 1
	ui.fishLogAfkTime.text := format("{:02i}",ui.secondsElapsed/3600) ":" format("{:02i}",mod(format("{:02i}",ui.secondsElapsed/60),60)) ":" format("{:02i}",mod(ui.secondsElapsed,60)) 
	ui.statAfkDuration.text := ui.fishLogAfkTime.text
	;ui.fishLogAfkTime2.text := format("{:02i}",secondsElapsed/3600) ":" format("{:02i}",secondsElapsed/60) ":" format("{:02i}",mod(secondsElapsed,60))
}

reeledIn(*) {
	ui.checkReel1 := round(pixelGetColor(1026,635))
	ui.checkReel2 := round(pixelGetColor(1047,635))
	ui.checkReel3 := round(pixelGetColor(1026,656))
	ui.checkReel4 := round(pixelGetColor(1047,656))
	ui.checkReel5 := round(pixelGetColor(1036,644))

	if(ui.fullscreen) {
		ui.checkReel1 := round(pixelGetColor(2963,1225))
		ui.checkReel2 := round(pixelGetColor(2963,1301))
		ui.checkReel3 := round(pixelGetColor(2944,1250))
		ui.checkReel4 := round(pixelGetColor(2984,1250))
		ui.checkReel5 := round(pixelGetColor(2944,1280))
		ui.checkReel6 := round(pixelGetColor(2984,1280))
	}
	;msgBox(substr(ui.checkReel1 "`n" ui.checkReel2 "`n" ui.checkReel3 "`n" ui.checkReel4 "`n" ui.checkReel5)
	;log(substr(ui.checkReel1,1,5) ":" subStr(ui.checkReel2,1,5) ":" subStr(ui.checkReel3,1,5) ":" subStr(ui.checkReel4,1,5) ";" subStr(ui.checkReel5,1,5))
		if (ui.checkReel1 >= 12250871
			&& ui.checkReel2 >= 12250871
			&& ui.checkReel3 >= 12250871
			&& ui.checkReel4 >= 12250871
			&& ui.checkReel5 < 12250871) {
			;log("Reeled In")
				ui.reeledIn := 1
			} else
			ui.reeledIn := 0
		return ui.reeledIn
	
}
	; if checkPixel(1160,530,"0x262F36")	;rod load lvl1
	; if checkPixel(1230,530,"0x292134")	;reel load lvl1
	; 1160,530 262F36
	; 1230,530 292134
	; 1090,520
	; 1090,510	419aac
	; 1090,500
	; 1160,520	2434
	; 1160,510
	; 1160,500
	; 1230,520
	; 1230,510
	; 1230,500


detectPrompts(silent := false) {
	((silent) && (ui.isAFK)) ? 0 : log("Prompts: Detecting Popups")
	ui.popupFound := false
	while ui.popupFound == false && a_index < 10 {
		if round(pixelGetColor(75,180)) == 8311586 {
			((silent) && (ui.isAFK)) ? log("Rewards: Reward Detected") : 0
			ui.popupFound := true
			MouseMove(210,525)
			sendNice("{LButton Down}")
			sleep(350)
			sendNice("{LButton Up}")
			sleep(500)
			((silent) && (ui.isAFK)) ? log("Rewards: Reward Claimed") : 0
		}
	}

	if round(pixelGetColor(75,50)) == 8311586 {
		((silent) && (ui.isAFK)) ? log("Rewards: Reward Detected") : 0
		ui.popupFound := true
		MouseMove(215,630)
		sendIfWinActive("{LButton Down}",ui.game,true)
		sleep(350)
		sendIfWinActive("{LButton Up}",ui.game,true)
		sleep(500)
		((silent) && (ui.isAFK)) ? log("Rewards: Reward Claimed") : 0
	}
	
	if round(pixelGetColor(365,80)) == 8311586 {
		((silent) && (ui.isAFK)) ? log("Trip: Trip Ended") : 0
		ui.popupFound := true
		mouseMove(530,610)
		sendIfWinActive("{LButton Down}",ui.game,true)
		sleep(350)
		sendIfWinActive("{LButton Up}",ui.game,true)
		sleep(1000)
		((silent) && (ui.isAFK)) ? log("Trip: Adding Day Trip") : 0
		MouseMove(530,450)
		sendIfWinActive("{LButton Down}",ui.game,true)
		sleep(350)
		sendIfWinActive("{LButton Up}",ui.game,true)
		sleep(500)	
	}
	
	if checkPixel(545,600,"0xFAF2EE") && checkPixel(1088,57,"0xFFFFFF") {
		((silent) && (ui.isAFK)) ? log("Ads: Ad Detected") : 0
		ui.popupFound := true
		mouseGetPos(&x,&y)
		mouseMove(1088,57)
		sendNice("{LButton Down}")
		sleep(300)
		sendNice("{LButton Up}")
		sleep(500)
		mouseMove(x,y)
		(silent) ? log("Ads: Ad Closed") : 0
	}
			
	;((silent) && (ui.isAFK)) ? log("Prompts: All Clear") : 0
	((silent) && (ui.isAFK)) ? log("___________________________________________________________________") : 0
}


appReload(*) {
	reload()
}

tmp.h:=40
timerFadeIn(*) {
	while tmp.h > 0 {
		ui.timerAnim.move(,,,tmp.h-=1)
		sleep(1)
	}

}
/* enter:: {
	x:=1379
	y:=78
	mousemove(x,y)
	;mouseGetPos(&x,&y)
	msgBox(pixelGetColor(x,y))
} */
timerFadeOut(*) {
	while tmp.h < 40 {
		ui.timerAnim.move(,,,tmp.h+=1)
		sleep(1)
	}
}
hotIfWinActive(ui.game)
	!WheelUp:: {
		sendIfWinActive("{LShift Down}",ui.game,true)
		sleep(200)
		sendIfWinActive("{1}",ui.game,true)
		sleep(200)
		sendIfWinActive("{LShift Up}",ui.game,true)
	}
	!WheelDown:: {
		sendIfWinActive("{LShift Down}",ui.game,true)
		sleep(200)
		sendIfWinActive("{2}",ui.game,true)
		sleep(200)
		sendIfWinActive("{LShift Up}",ui.game,true)
	}
	!MButton:: {
		sendIfWinActive("{LShift Down}",ui.game,true)
		sleep(200)
		sendIfWinActive("{3}",ui.game,true)
		sleep(200)
		sendIfWinActive("{LShift Up}",ui.game,true)
	}
hotIf()


createGui() {
	;msgBox(cfg.profileSelected)
	if cfg.profileSelected > cfg.profileName.Length
		cfg.profileSelected := cfg.profileName.length
	ui.fishGui := gui()
	ui.fishGui.opt("-caption owner" winGetId(ui.game))
	ui.fishGui.backColor := ui.bgColor[1]
	winSetTransColor("010203",ui.fishGui.hwnd)
	ui.appFrame := ui.fishGui.addText("x300 y30 w1282 h722 c" ui.fontColor[3] " background" ui.bgColor[1])
	ui.appFrame2 := ui.fishGui.addText("x300 y32 w1281 h719 c" ui.fontColor[1] " background" ui.bgColor[3])
	;ui.appFrame3 := ui.fishGui.addText("x302 y33 w1276 h716 c" ui.fontColor[3] " background" ui.bgColor[1])
	ui.fpBg := ui.fishGui.addText("x301 y33 w1279 h717 c010203 background010203")
	ui.titleBarOutline := ui.fishGui.addText("x299 y0 w1282 h30 background" ui.bgColor[1])
	ui.titleBarOutline2 := ui.fishGui.addText("x300 y1 w1281 h30 background" ui.bgColor[3])
	ui.titleBarOutline3 := ui.fishGui.addText("x301 y2 w1279 h28 background" ui.bgColor[1])
	ui.titleBar := ui.fishGui.addText("x305 y4 w1222 h24 cC7C7C7 background" ui.bgColor[1])
	ui.titleBar.onEvent("click",wm_lbuttonDown_callback)
	ui.titleBarText := ui.fishGui.addText("x305 y6 w900 h24 cC7C7C7 backgroundTrans","Fishing Planet`t(fpassist v" a_fileVersion ")")
	ui.titleBarText.setFont("s13","Arial Bold")
	ui.titleBarFullscreenButton := ui.fishGui.addPicture("x1524 y2 w29 h29 center backgroundTrans","./img/button_fs.png")
	ui.titleBarFullscreenButton.onEvent("click",goFS)
	ui.titleBarExitButton := ui.fishGui.addPicture("x1554 y4 w25 h25 center backgroundTrans","./img/button_close.png")
	ui.titleBarExitButton.onEvent("click",cleanExit)
	ui.fishStatus := ui.fishGui.addText("x2 y752 w1580 h61 cBBBBBB background" ui.bgColor[1])
	drawButton(1,753,661,60)
	ui.profilePos := map("x",398,"y",759,"w",260,"h",50)
	ui.profileBg := ui.fishGui.addText("x" ui.profilePos["x"]+2 " y" ui.profilePos["y"]-4 " w" ui.profilePos["w"] " h" ui.profilePos["h"]+8 " background" ui.bgColor[3])
	ui.profileBg2 := ui.fishGui.addText("x" ui.profilePos["x"]+3 " y" ui.profilePos["y"]-4 " w" ui.profilePos["w"] " h" ui.profilePos["h"]+7 " background" ui.trimColor[6])

;	ui.profileLabelOutline := ui.fishGui.addText("x" ui.profilePos["x"]+48 " y" ui.profilePos["y"]+29 " w85 h21 background" ui.bgColor[5])
;	ui.profileLabelOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+49 " y" ui.profilePos["y"]+28 " w83 h22 background" ui.bgColor[1])
	;ui.profileBg := ui.fishGui.addText("section x" ui.profilePos["x"] " y" ui.profilePos["y"] " w" ui.profilePos["w"] " h" ui.profilePos["h"] " background" ui.bgColor[3]) 
	;ui.profileBg2 := ui.fishGui.addText("x+-" ui.profilePos["w"]-1 " ys+1 w" ui.profilePos["w"]-2 " h" ui.profilePos["h"]-2 " background" ui.bgColor[1]) 
	;ui.profileNewButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+203 " y" ui.profilePos["y"]+0 " w16 h16 backgroundTrans","./img/button_new.png")
	
	ui.profileNewButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+29 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_new.png")
	ui.profileDeleteButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+70 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_delete.png")
	ui.profileSaveCancelButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+29 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_cancel.png")
	ui.profileSaveCancelButton.onEvent("click",cancelEditProfileName)
	ui.profileSaveButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+51 " y" ui.profilePos["y"]+31 " w16 h17 backgroundTrans","./img/button_save.png")
	;ui.profileEditButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+224 " y" ui.profilePos["y"]+0 " w16 h16 backgroundTrans","./img/button_edit.png")
	ui.profileEditButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+51 " y" ui.profilePos["y"]+31 " w15 h16 backgroundTrans","./img/button_edit.png")
	ui.profileLArrow := ui.fishGui.addPicture("x" ui.profilePos["x"]+5 " y" ui.profilePos["y"]+3 " w20 h22 backgroundTrans","./img/button_arrowLeft.png")
	ui.profileRArrow := ui.fishGui.addPicture("x" (ui.profilePos["x"]+30)+(ui.profilePos["w"]-50) " y" ui.profilePos["y"]+3 " w20 h22 backgroundTrans","./img/button_arrowRight.png")
	ui.profileLArrow.onEvent("click",profileLArrowClicked)
	ui.profileRArrow.onEvent("click",profileRArrowClicked)
	;ui.profileLabel := ui.fishGui.addText("x" ui.profilePos["x"]+138 " y" ui.profilePos["y"]+28 " w95 h18 background" ui.bgColor[2] " c" ui.fontColor[4],"Profile")
	
	
	;ui.profileSaveButtonOutline := ui.fishGui.addText("hidden x406 y781 w157 h25 background" ui.fontColor[1])
	;ui.profileEdit := ui.fishGui.addEdit("hidden x408 y781 w125 h25 wantReturn c" ui.fontColor[3] " background" ui.bgColor[1],cfg.profileName[cfg.profileSelected])
	;ui.profileEdit.setFont("s14")
	ui.profileText := ui.fishGui.addText("x" ui.profilePos["x"]+30 " y" ui.profilePos["y"]+4 " w207 h20 c" ui.fontColor[3] " center background" ui.bgColor[1])
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	;ui.profileIcon := ui.fishGui.addPicture("hidden x410 y765 w230 h42 backgroundCC3355","./img/rod.png")
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+28 " y" ui.profilePos["y"]+3 " w1 h22 background" ui.bgColor[3])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+28 " y" ui.profilePos["y"]+24 " w209 h1 background" ui.bgColor[3])
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+28 " y" ui.profilePos["y"]+3 " w209 h1 background" ui.bgColor[3])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+236 " y" ui.profilePos["y"]+3 " w1 h22 background" ui.bgColor[3])
	ui.profileText.setFont("s12","calibri")
	ui.profileNumStr := "Profile[" cfg.profileSelected "/" cfg.profileName.length "]"
	ui.profileNum := ui.fishGui.addText("x" ui.profilePos["x"]+65 " y" ui.profilePos["y"]+29 " right w160 h20 backgroundTrans",ui.profileNumStr)
	ui.profileNum.setFont("s13 c" ui.fontColor[2],"courier new")
;	ui.profileLabel := ui.fishGui.addText("x" ui.profilePos["x"]+150 " y" ui.profilePos["y"]+30 " center w83 h19 background" ui.bgColor[2] " c" ui.fontColor[3],"Profile")
;	ui.profileLabel.setFont("s14","Courier New")
	;ui.profileIcon.onEvent("click",changeProfile)
	;ui.profileIcon.onEvent("doubleClick",editProfileName)
	;ui.profileText.onEvent("doubleClick",editProfileName)
	;ui.profileEdit.onEvent("change",profileNameChange)

	ui.profileSaveButton.onEvent("click",saveProfileName)
	ui.profileEditButton.onEvent("click",editProfileName)
	ui.profileNewButton.onEvent("click",newProfileName)
	ui.profileDeleteButton.onEvent("click",deleteProfileName)
	
	ui.fishGui.onEvent("escape",cancelEditProfileName)

	ui.castAdjust := ui.fishGui.addSlider("section toolTip background" ui.bgColor[1] " buddy2ui.castAdjustText center x70 y758 w150 h16  range1000-2500",1910)
	ui.castAdjust.onEvent("change",castAdjustChanged)
	ui.castAdjustLabel := ui.fishGui.addText("xs-4 y+2 w40 h13 right backgroundTrans","Cast")
	ui.castAdjustLabel.setFont("s9 c" ui.fontColor[4])
	ui.castAdjustLabel2 := ui.fishGui.addText("xs-4 y+0 w40 h20 right backgroundTrans","Adjust")
	ui.castAdjustLabel2.setFont("s9 c" ui.fontColor[4])
	ui.castAdjustText := ui.fishGui.addText("x+3 ys+15 left w70 h30 backgroundTrans c" ui.fontColor[3])
	if cfg.castAdjust.length >= cfg.profileSelected {
		ui.castAdjustText.text := cfg.castAdjust[cfg.profileSelected]
		ui.castAdjust.value := cfg.castAdjust[cfg.profileSelected]
	}
	ui.castAdjustText.setFont("s21")
	slider("reelSpeed",,5,755,20,50,"1-4",1,1,"center","Speed","vertical","b")
	slider("dragLevel",,38,755,20,50,"1-12",1,1,"center","Drag","vertical","b")
	slider("twitchLevel",,295,760,50,15,"0-3",1,1,"center","Twitch")
	slider("pauseLevel",,295,783,50,15,"0-3",1,1,"center","Stop && Go")
	slider("castTime",,227,755,20,50,"2-6",1,1,"center","Cast","vertical","b")
	slider("sinkTime",,260,755,20,50,"1-10 ",1,1,"center","Sink","vertical","b")

	ui.zoomToggle := ui.fishGui.addCheckBox("x202 y780 w30 center h20 c" ui.fontColor[4])
	ui.zoomToggle.onEvent("click",toggledZoom)
	toggledZoom(*) {
		while cfg.zoomEnabled.length < cfg.profileSelected
			cfg.zoomEnabled.push(false)
		
		cfg.zoomEnabled[cfg.profileSelected] := ui.zoomToggle.value
		zoomEnabledStr := ""
		loop cfg.zoomEnabled.length {
			zoomEnabledStr .= cfg.zoomEnabled[a_index] ","
		}
		iniWrite(rtrim(zoomEnabledStr,","),cfg.file,"Game","ZoomEnabled")
	}
	ui.zoomToggleLabel := ui.fishGui.addText("x189 y798 w30 center h15 backgroundTrans c" ui.fontColor[4],"Zoom")
	ui.zoomToggleLabel.setFont("s9")
	
	drawButton(1101,753,121,60)
	ui.startButtonBg := ui.fishGui.addText("x1103 y755 w117 h56 background0a260a")
	ui.startButton := ui.fishGui.addText("section x1101 center y768 w120 h60 c" ui.fontColor[2] " backgroundTrans","AFK")
	ui.startButton.setFont("s22","Helvetica")
	ui.startButtonHotkey := ui.fishGui.addText("x+-117 center ys-13 w20 h20 c" ui.fontColor[2] " backgroundTrans","[ Q ]")
	ui.startButtonHotkey.setFont("s9","Sans Serif")	
	ui.startButton.onEvent("click",startButtonClicked)
	ui.stopButton := ui.fishGui.addText("hidden section x1101 center y768 w120 h60 c" ui.fontColor[2] " backgroundTrans","Stop")
	ui.stopButton.setFont("s22","Helvetica")
	ui.stopButtonHotkey := ui.fishGui.addText("hidden x+-113 center ys-1 w20 h20 c" ui.fontColor[2] " backgroundTrans","[ F4 ]")
	ui.stopButtonHotkey.setFont("s9","Sans Serif")	
	ui.stopButton.onEvent("click",autoFishStop)

	drawButton(1224,753,125,29)
	ui.castButtonBg := ui.fishGui.addText("x1226 y755 w121 h25 background" ui.bgColor[1])
	ui.castButton := ui.fishGui.addText("section x1230 center y756 w116 h26 cC9C9C9 backgroundTrans","Cast")
	ui.castButton.setFont("s16","Helvetica")
		ui.castButtonHotkey := ui.fishGui.addText("x+-120 center ys-1 w20 h20 c" ui.fontColor[2] " backgroundTrans","[ F ]")
	ui.castButtonHotkey.setFont("s9","Sans Serif")	
	ui.castButton.onEvent("click",singleCast)
	ui.castButtonBg.onEvent("click",singleCast)
	
	drawButton(1224,784,125,29)
	ui.retrieveButtonBg := ui.fishGui.addText("x1226 y786 w121 h25 background" ui.bgColor[1])
	ui.retrieveButton := ui.fishGui.addText("section x1228 center y787 w125 h26 cC9C9C9 backgroundTrans","Retrieve")
	ui.retrieveButton.setFont("s16","Helvetica")
	ui.retrieveButtonHotkey := ui.fishGui.addText("x+-126 center ys-1 w20 h20 c" ui.fontColor[2] " backgroundTrans","[ V ]")
	ui.retrieveButtonHotkey.setFont("s9","Sans Serif")	
	ui.retrieveButton.onEvent("click",singleretrieve)
	ui.retrieveButtonBg.onEvent("click",singleretrieve)
	
	drawButton(1351,753,115,29)
	ui.reelButtonBg := ui.fishGui.addText("x1353 y755 w111 h25 background" ui.bgColor[1])
	ui.reelButton := ui.fishGui.addText("section x1357 center y756 w106 h26 cC9C9C9 backgroundTrans","Reel")
	ui.reelButton.setFont("s16","Helvetica")
	ui.reelButtonHotkey := ui.fishGui.addText("x+-109 center ys-1 w20 h20 c" ui.fontColor[2] " backgroundTrans","[ R ]")
	ui.reelButtonHotkey.setFont("s9","Sans Serif")	
	ui.reelButtonBg.onEvent("click",singlereel)
	ui.reelButton.onEvent("click",singlereel)
	
	drawButton(1351,784,115,29)
	ui.cancelButtonBg := ui.fishGui.addText("x1353 y786 w111 h25 background270202") 
	ui.cancelButton := ui.fishGui.addText("section x1357 center y787 w106 h26 cC9C9C9 backgroundTrans","Cancel")
	ui.cancelButton.setFont("s16","Helvetica")
	ui.cancelButtonHotkey := ui.fishGui.addText("x+-109 center ys-1 w20 h20 c" ui.fontColor[2] " backgroundTrans","[ C ]")
	ui.cancelButtonHotkey.setFont("s9","Sans Serif")
	ui.cancelButtonBg.onEvent("click",cancelOperation)
	ui.cancelButton.onEvent("click",cancelOperation)
	
	drawButton(1468,753,113,19)
	ui.reloadButtonBg := ui.fishGui.addText("x1471 y755 w106 h15 background" ui.bgColor[1])
	ui.reloadButton := ui.fishGui.addText("section x1473 center y755 w104 h19 cC9C9C9 backgroundTrans","Reload")
	ui.reloadButton.setFont("s10","Helvetica")	
	ui.reloadButtonHotkey := ui.fishGui.addText("x+-109 center ys-1 w30 h13 cC9C9C9 backgroundTrans","[ F9 ]")
	ui.reloadButtonHotkey.setFont("s9","Sans Serif")	
	ui.reloadButton.onEvent("click",appReload)
	ui.reloadButtonBg.onEvent("click",appReload)

	drawButton(1468,774,113,39)
	ui.exitButtonBg := ui.fishGui.addText("x1471 y776 w106 h35 background" ui.bgColor[1])
	ui.exitButton := ui.fishGui.addText("section x1473 center y778 w104 h39 cC9C9C9 backgroundTrans","Exit")
	ui.exitButton.setFont("s20","Helvetica")	
	ui.exitButtonHotkey := ui.fishGui.addText("x+-107 center ys-2 w30 h30 cC9C9C9 backgroundTrans","[ F10 ]")
	ui.exitButtonHotkey.setFont("s9","Sans Serif")	
	ui.exitButton.onEvent("click",cleanExit)
	ui.exitButtonBg.onEvent("click",cleanExit)

	ui.fishLogHeaderOutline := ui.fishGui.addText("x1 y1 w298 h30 background" ui.bgColor[3])
	ui.fishLogHeaderOutline2 := ui.fishGui.addText("x2 y2 w296 h28 background" ui.bgColor[1])
	ui.fishLogHeaderOutline3 := ui.fishGui.addText("x3 y3 w294 h26 background" ui.bgColor[5])
	ui.fishLogOutline := ui.fishGui.addText("x1 y32 w298 h687 background" ui.bgColor[3])
	ui.fishLogOutline2 := ui.fishGui.addText("x2 y33 w296 h685 background" ui.bgColor[1])
	;ui.fishLogOutline3 := ui.fishGui.addText("x3 y34 w294 h682 background" ui.bgColor[2])

	;ui.fishLogHeader := ui.fishGui.addText("x2 y2 w296 h28 background222222")
	;ui.fishLogHeaderSpace := ui.fishGui.addText("x300 y2 w1 h29 background" ui.bgColor[1])
	ui.fishLogHeaderText := ui.fishGui.addText("x10 y3 w300 h28 c" ui.fontColor[5] " backgroundTrans","Activity")
	ui.fishLogHeaderText.setFont("s14 c" ui.fontColor[5],"Bold")
	ui.fishLogCountLabel := ui.fishGui.addText("x215 y4 w40 h25 backgroundTrans right c" ui.fontColor[5]," Fish")
	ui.fishLogCountLabel.setFont("s10","Helvetica")
	ui.fishLogCountLabel2 := ui.fishGui.addText("x215 y12 w40 h25 backgroundTrans right c" ui.fontColor[5],"Count")
	ui.fishLogCountLabel2.setFont("s10","Helvetica")
	ui.fishLogCount := ui.fishGui.addText("x258 y2 w40 h30 backgroundTrans c" ui.fontColor[5],"000")
	ui.fishLogCount.setFont("s18","Impact") 
	ui.fishLog := ui.fishGui.addText("x2 y34 w296 h680 background" ui.bgColor[1])
	ui.fishLogText := ui.fishGui.addListbox("x3 y35 w294 h682 -wrap 0x2000 0x100 -E0x200 background" ui.bgColor[1],ui.fishLogArr)
	ui.fishLogText.setFont("s13 c" ui.fontColor[2])
	ui.fishLogFooterOutline := ui.fishGui.addText("x1 y721 w298 h30 background" ui.bgColor[3])
	ui.fishLogFooterOutline2 := ui.fishGui.addText("x2 y722 w296 h28 background" ui.bgColor[1])
	ui.fishLogFooterOutline3 := ui.fishGui.addText("x3 y723 w294 h26 background" ui.bgColor[2])
	ui.fishLogFooter := ui.fishGui.addText("x3 y724 w294 h25 background" ui.bgColor[5]) ;61823A
	ui.fishStatusText := ui.fishGui.addText("section x5 y723 w290 h25 center c" ui.fontColor[5] " backgroundTrans","Ready")
	ui.fishStatusText.setFont("s16 bold","Miriam Fixed")
	ui.fishLogTimerOutline := ui.fishGui.addText("x1047 y710 w268 h40 background" ui.bgColor[3])
	ui.fishLogTimerOutline2 := ui.fishGui.addText("x1048 y711 w266 h38 background" ui.bgColor[1])
	ui.fishLogTimerOutline3 := ui.fishGui.addText("x1049 y712 w264 h36 background" ui.bgColor[2])
	ui.fishLogTimer := ui.fishGui.addText("x1050 y713 w263 h35 background3F3F3F") ;61823A
	ui.timerAnim := ui.fishGui.addText("x1047 y710 w268 h40 background010203")
	ui.fishLogAfkTimeLabel := ui.fishGui.addText("hidden section right x751 y695 w80 h40 c" ui.fontColor[1] " backgroundTrans","AFK")
	ui.fishLogAfkTimeLabel.setFont("s16","Arial")
	ui.fishLogAfkTimeLabel2 := ui.fishGui.addText("hidden section right x751 y707 w80 h40 c" ui.fontColor[1] " backgroundTrans","Timer")
	ui.fishLogAfkTimeLabel2.setFont("s19","Arial")
	ui.fishLogAfkTime := ui.fishGui.addText("hidden x835 y688 w200 h60 c" ui.fontColor[1] " backgroundTrans","00:00:00")
	ui.fishLogAfkTime.setFont("s35","Arial")
	ui.bigFishCaught := ui.fishGui.addText("hidden x1160 y666 w160 h300 backgroundTrans c" ui.fontColor[1],format("{:03i}","000"))
	ui.bigFishCaught.setFont("s54")
	ui.bigFishCaughtLabel := ui.fishGui.addText("hidden right x1053 y677 w100 h40 backgroundTrans c" ui.fontColor[1],"Fish")
	ui.bigFishCaughtLabel.setFont("s24")
	ui.bigFishCaughtLabel2 := ui.fishGui.addtext("hidden right x1055 y696 w100 h40 backgroundTrans c" ui.fontColor[1],"Count")
	ui.bigFishCaughtLabel2.setFont("s28")
	if winExist(ui.game) {
		winSetTransparent(255,ui.game)
		winGetPos(&x,&y,&w,&h,ui.game)
	} else {
		exitApp
	}
	sleep(500)
	;ui.profileIcon.focus()
	statPanel()
	while ui.fishLogArr.length < 33 {
		ui.fishLogArr.push("")
		ui.fishLogText.delete()
		ui.fishLogText.add(ui.fishLogArr)
		ui.fishLogText.add([""])
	}
	ui.fishGui.show("x" x-300 " y" y+-30 " w1582 h814 noActivate")
	ui.fishLogAfkTime.text := "00:00:00"
	loadScreen(false)	
	
	winActivate(ui.game)
	mouseMove(200,200,0)
	sleep(150)
	send("{LButton Down}")
	sleep(150)
	send("{LButton Up}")
}

saveSliderValues(*) {
for this_slider in ui.sliderList {
		if cfg.%this_slider%.length < cfg.profileSelected
			cfg.%this_slider%[cfg.profileSelected] := ui.%this_slider%.value
		else
			cfg.%this_slider%.push(ui.%this_slider%.value)
	}
}

profileLArrowClicked(*) {
	saveSliderValues()
	if cfg.profileSelected > 1
	cfg.profileSelected -= 1
	else
		cfg.profileSelected := cfg.profileName.Length
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	updateControls()
}
profileRArrowClicked(*) {
	saveSliderValues()
	if cfg.profileSelected < cfg.profileName.length
		cfg.profileSelected += 1
	else
		cfg.profileSelected := 1
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	updateControls()
}

deleteProfileName(*) {
	if cfg.profileName.length > 1 {
		try 
			cfg.profileName.removeAt(cfg.profileSelected)
		try
			cfg.castAdjust.removeAt(cfg.profileSelected)
		try
			cfg.twitchLevel.removeAt(cfg.profileSelected)
		try
			cfg.pauseLevel.removeAt(cfg.profileSelected)
		try
			cfg.dragLevel.removeAt(cfg.profileSelected)
		try
			cfg.reelSpeed.removeAt(cfg.profileSelected)
		try
			cfg.profileName.removeAt(cfg.profileSelected)
		try
			cfg.castAdjust.removeAt(cfg.profileSelected)
		try
			cfg.twitchLevel.removeAt(cfg.profileSelected)
		try
			cfg.pauseLevel.removeAt(cfg.profileSelected)
		try
			cfg.dragLevel.removeAt(cfg.profileSelected)
		try
			cfg.reelSpeed.removeAt(cfg.profileSelected)
		try
			cfg.zoomEnabled.removeAt(cfg.profileSelected)

		if cfg.profileSelected == cfg.profileName.length {
			cfg.profileSelected := 1
		}
		
		try
			ui.profileText.text := cfg.profileName[cfg.profileSelected]
		try
			ui.castAdjust.value := cfg.castAdjust[cfg.profileSelected]
		try
			ui.castAdjustText.text := cfg.castAdjust[cfg.profileSelected]
		try
			ui.twitchLevel.value := cfg.twitchLevel[cfg.profileSelected]
		try
			ui.pauseLevel.value := cfg.pauseLevel[cfg.profileSelected]
		try
			ui.dragLevel.value := cfg.dragLevel[cfg.profileSelected]
		try
			ui.reelSpeed.value := cfg.reelSpeed[cfg.profileSelected]
		try
			ui.zoomToggle.value := cfg.zoomEnabled[cfg.profileSelected]
	
		} else {
		notifyOSD("Can't Delete Only Profile",ui.profileText)
		;msgBox("Can't Delete Only Profile")
	}
}

;editProfileName()
editProfileName(*) {
	ui.editProfileGui := gui()
	ui.editProfileGui.opt("-border -caption owner" ui.fishGui.hwnd)
	ui.editProfileBg := ui.editProfileGui.addText("x0 y0 w210 h30 background" ui.trimColor[6])
	ui.editProfileEdit := ui.editProfileGui.addEdit("x0 y0 w209 center h23 background" ui.bgColor[3] " -multi -wantReturn -wantTab limit -wrap -theme c" ui.fontColor[5],cfg.profileName[cfg.profileSelected])
	ui.editProfileEdit.setFont("s12","calibri")	
	ui.profileText.opt("hidden")
	ui.profileNewButton.opt("hidden")
	ui.profileEditButton.opt("hidden")
	ui.profileDeleteButton.opt("hidden")
	ui.profileSaveButton.opt("-hidden")
	ui.profileSaveCancelButton.opt("-hidden")
	winGetPos(&x,&y,&w,&h,ui.fishGui)
	ui.editProfileGui.show("x" ui.profilePos["x"]+27 " y" ui.profilePos["y"]+4 " w208 h22")
	ui.editProfileEdit.focus()
}

newProfileName(*) {
	cfg.profileName.push("Profile #" cfg.profileName.length+1)
	cfg.profileSelected := cfg.profileName.Length
	updateControls()
	editProfileName()
}
saveProfileName(*) {
	cfg.profileName[cfg.profileSelected] := ui.editProfileEdit.text
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileText.opt("-hidden")
	ui.profileSaveButton.opt("hidden")
	ui.profileSaveCancelButton.opt("hidden")
	ui.profileEditButton.opt("-hidden")
	ui.profileNewButton.opt("-hidden")
	ui.profileDeleteButton.opt("-hidden")
	try
		ui.editProfileGui.destroy()
}


cancelEditProfileName(*) {
	cfg.profileName[cfg.profileSelected] := ui.profileText.text 
	try
		ui.editProfileGui.destroy()
	ui.profileText.opt("-hidden")
	ui.profileSaveButton.opt("hidden")
	ui.profileSaveCancelButton.opt("hidden")
	ui.profileEditButton.opt("-hidden")
	ui.profileNewButton.opt("-hidden")
	ui.profileDeleteButton.opt("-hidden")
	
}

startButtonClicked(*) { 
		winActivate("ahk_exe fishingPlanet.exe")
		ui.cancelOperation := false
		autoFishStart()
	}

updateControls(*) {
	try 
		ui.twitchLevel.value := cfg.twitchLevel[cfg.profileSelected]
	try 
		ui.pauseLevel.value := cfg.pauseLevel[cfg.profileSelected]
	try 
		ui.dragLevel.value := cfg.dragLevel[cfg.profileSelected]
	try 
		ui.reelSpeed.value := cfg.reelSpeed[cfg.profileSelected]
	try 
		ui.castTime.value := cfg.castTime[cfg.profileSelected]
	try 
		ui.sinkTime.value := cfg.sinkTime[cfg.profileSelected]
	try 
		ui.castAdjust.value := cfg.castAdjust[cfg.profileSelected]
	try
		ui.zoomToggle.value := cfg.zoomEnabled[cfg.profileSelected]
	try
		ui.castAdjust.value := cfg.castAdjust[cfg.profileSelected]
	try 
		ui.castAdjustText.text := cfg.castAdjust[cfg.profileSelected]
	try 
		ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileNum.text := "Profile[" cfg.profileSelected "/" cfg.profileName.length "]"
	
	try 
		ui.profileIcon.focus()
	
}


cancelOperation(*) {
		ui.cancelOperation := true
		ui.cancelButtonBg.opt("background" ui.trimColor[2])
		ui.cancelButtonBg.redraw()
		
		ui.reelButtonBg.opt("background" ui.bgColor[1])
		ui.reelButtonBg.redraw()
		ui.reelButton.setFont("c" ui.fontColor[2])
		ui.reelButton.redraw()
		ui.reelButtonHotkey.setFont("c" ui.fontColor[2])
		ui.reelButtonHotkey.redraw()
		ui.castButtonBg.opt("background" ui.bgColor[1])
		ui.castButtonBg.redraw()
		ui.castButton.setFont("c" ui.fontColor[2])
		ui.castButton.redraw()
		ui.castButtonHotkey.setFont("c" ui.fontColor[2])
		ui.castButtonHotkey.redraw()
		ui.retrieveButtonBg.opt("background" ui.bgColor[1])
		ui.retrieveButtonBg.redraw()
		ui.retrieveButton.setFont("c" ui.fontColor[2])
		ui.retrieveButton.redraw()
		ui.retrieveButtonHotkey.setFont("c" ui.fontColor[2])
		ui.retrieveButtonHotkey.redraw()
		ui.startButtonBg.opt("background273d62")
		ui.startButtonBg.redraw()
		ui.startButton.setFont("c" ui.fontColor[2])
		ui.startButton.redraw()
		ui.startButtonHotkey.setFont("c" ui.fontColor[2])
		ui.startButtonHotkey.redraw()
		autoFishStop()
		
		send("{space up}")
		send("{lshift up}")
		send("{lbutton up}")
		send("{rbutton up}")
		
		ui.cancelButtonBg.opt("background5c0303")
		ui.cancelButtonBg.redraw()
	}

cancelReset(*) {
	ui.cancelOperation := false
	ui.cancelButtonBg.opt("background5c0303")
	ui.retrieveButtonBg.opt("background" ui.bgColor[1])
	ui.reelButtonBg.opt("background" ui.bgColor[1])
	ui.castButtonBg.opt("background" ui.bgColor[1])
}

singleCast(*) {
	cancelReset()
	cast(0)
}

singleReel(*) {
	cancelReset()
	reelIn(0)
}

singleRetrieve(*) {
	cancelReset()
	retrieve(0)
}

slider(name := random(1,999999),gui := ui.fishGui,x := 0,y := 0,w := 100,h := 20,range := 0-10,tickInterval := 1,default := 1,align := "center",label := "",orient := "",labelAlign := "r") {
	ui.sliderList.push(name)
	cfg.%name% := strSplit(iniRead(cfg.file,"Game",name,"1,1,1,1,1"),",")
	ui.%name% := gui.addSlider("section v" name " x" x " y" y " w" w " h" h " tickInterval" tickInterval " " orient " range" range " " align " toolTip")
	while cfg.profileSelected > cfg.%name%.length {
		cfg.%name%.push(cfg.%name%[cfg.%name%.length])
	}
	ui.%name%.value := cfg.%name%[cfg.profileSelected]
	ui.%name%.onEvent("change",sliderChange)
	
	if (label)
	switch substr(labelAlign,1,1) {
		case "r":
			ui.%name%Label := gui.addText("x+0 ys+5 backgroundTrans c" ui.fontColor[4],label)
			ui.%name%Label.setFont("s9")
		case "b":
			ui.%name%Label := gui.addText("xs+2 y+-7 backgroundTrans c" ui.fontColor[4],label)
			ui.%name%Label.setFont("s9")
	}
}

sliderChange(this_slider,*) {
	name := this_slider.name
	ui.tmp%name%Str := ""
	
	if cfg.%name%.length <= cfg.profileSelected
		cfg.%name%.push(this_slider.value)
	else
	cfg.%name%[cfg.profileSelected] := this_slider.value
	loop cfg.%name%.length {
		ui.tmp%name%Str .= cfg.%name%[a_index] ","
	}
		iniWrite(rtrim(ui.tmp%name%Str,","),cfg.file,"Game",name)
	ui.%name%Label.redraw()
	ui.profileIcon.focus()
}

castAdjustChanged(*) {
	try {
		if cfg.castAdjust.length <= cfg.profileSelected
			cfg.castAdjust.push(ui.castAdjust.value)
		else
			cfg.castAdjust[cfg.profileSelected] := ui.castAdjust.value
		ui.castAdjustText.text := cfg.castAdjust[cfg.profileSelected]
		ui.profileIcon.focus()
	}
	
	castAdjustStr := ""
	loop cfg.castAdjust.length {
		castAdjustStr .= cfg.castAdjust[a_index] ","
	}	
	iniWrite(rtrim(castAdjustStr,","),cfg.file,"Game","CastAdjust")
}
