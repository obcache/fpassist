A_FileVersion := "1.3.1.4"
A_AppName := "fpassist"
#requires autoHotkey v2.0+
#singleInstance
persistent()	
setWorkingDir(a_scriptDir)
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

ui 					:= object()
cfg 				:= object()
tmp 				:= object()
mechanic 			:= object()
	
initVars()

#include <libInit>
#include <libGlobal>
#include <libMod>
#include <libGui>
#include <libGame>

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

themeDef()
cfgLoad()
startGame()
createGui()
createGuiFS()
winActivate(ui.game)
;winGetPos(&tX,&tY,&tW,&tH,ui.game)
;mouseMove(tW/2,tH/2)
setTimer () => detectPrompts(1),10000
onExit(exitFunc)

hotIfWinActive(ui.game)
	hotkey("CapsLock",toggleEnabled)
hotIf()

startHotkey(*) {
	autoFishStop()
	autoFishStart(ui.runCount+=1)
}

ui.toggleReelFS := false
toggleReelFS(*) {
	winActivate(ui.game)
	startReelFS()
	
	startReelFS(*) {
		send("{space down}")
	}
	stopReelFS(*) {
		send("{space up}")
	}
}

ui.fullscreen := false


isEnabled(*) {
		if ui.enabled && winActive(ui.game) 
			return 1
		else
			return 0
}

isEnabledFS(*) {
		if winActive(ui.game) && ui.fullscreen
			return 1
		else
			return 0
}

hotifWinActive(ui.game)
	hotKey("Home",appReload)
hotIf()
	
hotIf(isEnabled)
	hotkey(ui.reelKey,singleReel)
	hotKey(ui.startKey,startHotkey)
	hotKey(ui.startKeyMouse,startHotkey)
	hotKey(ui.stopKeyMouse,autoFishStop)
	hotKey(ui.reloadKey,appReload)
	hotKey(ui.castKey,singleCast)
	hotKey(ui.retrieveKey,singleRetrieve)
	hotkey(ui.cancelKey,autoFishStop)
	hotKey(ui.exitKey,cleanExit)
	hotKey("F11",toggleFS)
	hotKey("^End",rodsIn)
	hotKey("^a",turnLeft)
	hotKey("^d",turnRight)
	^w:: {
		setTimer(throttleForward,2500)
	}
	~s:: {
		setTimer(throttleForward,0)
	}
hotif()

hotIf(isEnabledFS)
	hotkey("+" ui.reelKey,singleReel)
	hotKey("+" ui.startKey,startHotkey)
	hotKey(ui.startKeyMouse,startHotkey)
	hotKey(ui.stopKeyMouse,autoFishStop)
	hotKey(ui.reloadKey,appReload)
	hotKey("+" ui.castKey,singleCast)
	hotKey("+" ui.retrieveKey,singleRetrieve)
	hotkey("+" ui.cancelKey,autoFishStop)
	hotKey(ui.exitKey,cleanExit)
	hotKey("F11",toggleFS)
hotif()

throttleForward(*) {
	send("{w down}")
	sleep(750)
	send("{w up}")
	sleep(500)
	send("{s down}")
	sleep(750)
	send("{s up}")
	sleep(500)
}

turnLeft(*) {
	send("{a down}")
}
turnRight(*) {
	send("{d down}")
}
toggleFS(*) {
	(ui.isFS := !ui.isFS) ? goFS() : noFS()
}

stopBgMode(*) {
	autoFishStop()
	winActivate(ui.game)
	winWait(ui.game)
}


ui.modeName := ["off","cast","retrieve","land","reel"]

modeChanged(*) {
	panelMode(ui.mode)
}
	
autoFishStop(restart:="",*) {
	;log("AFK: Stopping",1,"AFK: Stopped")
	;setTimer () => log("Ready"),-2500 
	setTimer(isHooked,0)
	setTimer(throttleForward,0)
	setTimer(landFish,0)
	setTimer(updateAfkTime,0)
	ui.retrieveButton.text := "Retrie&ve"
	ui.mode				:= "off"
	ui.cancelOperation 	:= true
	ui.autoFish 		:= false

	send("{space up}")
	send("{lshift up}")
	send("{lbutton up}")
	send("{rbutton up}")
	 
	ui.fishLogAfkTime.opt("+hidden")
	ui.fishLogAfkTimeLabel.opt("+hidden")
	ui.fishLogAfkTimeLabel2.opt("+hidden")
	ui.bigFishCaught.opt("+hidden")
	ui.bigFishCaughtLabel.opt("+hidden")
	ui.bigFishCaughtLabel2.opt("+hidden")	

	 if !fileExist(a_scriptDir "/logs/current_log.txt")
		 fileAppend('"Session Start","AFK Start","AFK Duration","Fish Caught","Cast Count","Cast Length","Drag Level","Reel Speed"`n', a_scriptDir "/logs/current_log.txt")
	 fileAppend(ui.statSessionStartTime.text "," ui.statAfkStartTime.text "," ui.statAfkDuration.text "," ui.statFishCount.text "," ui.statCastCount.text "," ui.statCastLength.text "," ui.statDragLevel.text "," ui.statReelSpeed.text "`n", a_scriptDir "/logs/current_log.txt")
	
	if restart=="restart" {
		setTimer () => autoFishStart(ui.runCount+=1)
	} else {
		panelMode("off")
		ui.secondsElapsed := 0
		ui.fishLogAfkTime.text := "00:00:00" 
	}
}
^+r:: {
	autoFishRestart()
}

autoFishRestart(*) {
	autoFishStop("restart")
}

this:=object()
autoFishStart(runCount,mode:="cast",*) {
	this.runCount := runCount
	ui.mode:=mode
	if mode=="reelStop" {
		reelIn(1)
		return
	}
	

	log("STARTING: AFK",1,"STARTED: AFK")
	setTimer(updateAfkTime,1000)
	ui.statAfkStartTime.text 	:= formatTime(,"yyyy-MM-dd@hh:mm:ss")
	ui.autoFish 				:= true
	ui.reeledIn:=reeledIn()
	ui.cycleAFK := false
	panelMode("afk")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	ui.bigFishCaught.opt("-hidden")
	ui.bigFishCaughtLabel.opt("-hidden")
	ui.bigFishCaughtLabel2.opt("-hidden")
	resetKeyStates()
	while ui.autoFish {
		detectPrompts(1)
		(sleep500(2,0)) ? exit : 0
		switch ui.mode {
			case "cast":
				if !reeledIn() {
					reelIn()
					sleep(3000)
				} 
				if reeledIn()
					cast(1)
				ui.mode:="retrieve"
			case "retrieve":
				if !reeledIn()
					retrieve(1)		
				ui.mode:="reel"
			case "restart":
				setTimer () => autoFishRestart(),-100
				return
			case "reel":
				if !reeledIn()
					reelIn(1)				
				ui.mode:="cast" 
		}
	}
	sleep500(3)
	analyzeCatch()
	sleep500(3)
	checkKeepnet()
	send("{LButton Up}{RButton Up}{space up}")
	ui.cycleAFK := true
	if !ui.autoFish {
		autoFishStop()
		return
	}
	if !ui.cycleAfk
		ui.mode:="off"
}



isHooked(*) {
	ui.isHooked := 0
	
	for hookedColor in ui.hookedColor {
		if (checkPixel(ui.hookedX,ui.hookedY,hookedColor)) {
			log("HOOKED!")
			ui.isHooked := 1
			setTimer(isHooked,0)
			return ui.isHooked
		}
	}
	return ui.isHooked
}

checkPixel(x,y,targetColor) {
	screenColor := round(pixelGetColor(x,y))
	if (targetColor >= screenColor-10000) && (targetColor <= screenColor+10000)
		errorLevel := 1
	else
		errorLevel := 0
	return errorLevel
}	


calibrate(*) {
	if ui.runCount > this.runCount
	return
	modeHeader("Calibrate")
	if !ui.autoFish
		return
	log("Calibrate: Drag",1)
	loop 13 {
		winWait("ahk_exe fishingplanet.exe")
		sendNice("{-}")
		sleep(50)
	}
	if !ui.autoFish
		return
	ui.currDrag := 0
	loop cfg.dragLevel[cfg.profileSelected] {
		sendNice("{+}")
		sleep(100)
	}
	if !ui.autoFish
		return
	if ui.runCount > this.runCount
		return
	
	log("Calibrate: Reel Speed",1)
	if !ui.autoFish
		return
	if ui.runCount > this.runCount
		return
	loop 6 {
		winWait("ahk_exe fishingPlanet.exe")
		sendNice("{click wheelDown}")
		sleep(50)
	}	 
	if !ui.autoFish
		return
	if ui.runCount > this.runCount
		return
	loop cfg.reelSpeed[cfg.profileSelected] {
		sendNice("{click wheelUp}") 
		sleep(50)
	}
	;log("Ready",1)
	if !ui.autoFish
		return
}

cast(isAFK:=true,*) {
	panelMode("cast")
	if !ui.autoFish || ui.mode != "cast"
		return
	if ui.runCount > this.runCount
		return
	if cfg.boatEnabled[cfg.profileSelected] {
		log("Boat: Cast Rod #1",1)
		modeHeader("Boat")
		ui.castButton.text:="Boat"
		boatRotation()	
		ui.castButton.text:="Cast"
		return
	}
	sleep(1500)
	if !ui.autoFish
		return
	if ui.runCount > this.runCount
		return
	modeHeader("Cast")
	log("Cast: Preparing",1,"Cast: Prepared")
	ui.statCastCount.text := format("{:03d}",ui.statCastCount.text+1)
	if !ui.autoFish || ui.mode != "cast"
		return
	sleep(4500)
	;sendIfWinActive("{backspace}",ui.game,true)
	errorLevel := sleep500(6)
	if !ui.autoFish || ui.mode != "cast"
		return
	if ui.runCount > this.runCount
		return

	loop 10 {
		if !reeledIn() {
			sleep500(2)
		} else {
			break 
		}
		timeout := a_index
		if timeout == 30 {
			log("Retrieve: Timed Out Reeling In",2)
			log("Retrieve: Stopping AFK",2)
			autoFishStop()
			return
		}
	}
	log("Cast: Drawing Back Rod",1)
	sendNice("{space down}")
	(cfg.profileSelected <= cfg.castLength.length)  
		? sleep(cfg.castLength[cfg.profileSelected])
		: sleep(cfg.castLength[cfg.castLength.length])
	sendNice("{space up}")
	log("Cast: Releasing Cast",1)
	calibrate()
	;setTimer(calibrate,-100)
	if !ui.autoFish || ui.mode != "cast"
		return
	if ui.runCount > this.runCount
		return

	log("Wait: Lure In-Flight",1)
	loop cfg.castTime[cfg.profileSelected] {
		sleep500(2)
	}
	log("Wait: Lure Sinking",1)
	if !ui.autoFish || ui.mode != "cast"
		return
	if ui.runCount > this.runCount
		return

	loop cfg.sinkTime[cfg.profileSelected] {
		sleep500(2)
	}
	log("Cast: Closing Bail")
	sendNice("{space down}")
	sleep(500)
	sendNice("{space up}")
	sleep(150)
	;setTimer () => reelIn(),-30000
	if !ui.autoFish || ui.mode != "cast"
		return
}

boatRotation(*) {
	send("{1}")
	sleep(2500)
	send("{space down}")
	sleep(2000)
	send("{space up}")
	sleep(8000)

	send("{space}")
	sleep(1500)
	loop 12 
		send("{-}")
	loop cfg.dragLevel[cfg.profileSelected]
		send("{+}")
	sleep(1500)
	log("Boat: Place Rod 1 in Holder",1)
	send("{shift down}{1 down}")
	sleep(100)
	send("{1 up}{shift up}")
	sleep(2000)
	log("Boat: Switch to Rod 2",1)
	send("{2}")
	sleep(4500)
	log("Boat: Cast Rod 2",1)
	send("{space down}")
	sleep(2000)
	send("{space up}")
	sleep(8000)
	log("Boat: Closing Bail on Rod 2",1)
	send("{space}")
	sleep(1500)
	log("Boat: Setting Drag on Rod 2",1)
	loop 12 
		send("{WheelDown}")
	loop cfg.dragLevel[cfg.profileSelected]
		send("{WheelUp}")
	sleep(1500)

	while ui.autoFish {
		send("{shift down}{1}{shift up}")
		sleep(2000)
		while ui.autoFish && !isHooked() {
			sleep(500)
			if a_index > 40
				break
		}
		if isHooked() {
			landFish()
			return
		}
		log("Boat: Picking up Rod 2",1)
		send("{shift down}{1}{shift up}")
		sleep(2000)
		while ui.autoFish && !isHooked() && ui.runCount == this.runCount {
			sleep(500)
			if a_index > 40
				break
		}
		if isHooked() {
			landFish()
			return
		}
	}
}

retrieve(*) {
	panelMode("retrieve")
	ui.cancelOperation := true	
	if !ui.autoFish || ui.mode != "retrieve"
		return
	modeHeader("Retrieve")
	if ui.floatEnabled.value {
		log("Watch: Monitoring Bait",1)
		ui.retrieveButton.text := "Watch"
		while !reeledIn() {
			if !ui.floatEnabled.value && a_index > cfg.recastTime[cfg.profileSelected]*2*60 {
				log("Cast: Stale",1)
				log("Cast: Recasting",1)
				reelIn()
				return
			}
			if isHooked() { 
				winActivate(ui.game)
				ui.retrieveButton.text := "Retrie&ve"
				landFish()
				return
			} else
				sleep500()
		} else
			return
	} else {
		mechanic.names:=["twitchFreq","stopFreq","reelFreq"]
		mechanic.count := 0
		mechanic.last := ""
		mechanic.repeats := 0
		mechanic.current := ""
		mechanic.number := 0
		
		ui.cancelOperation:=false
		if !ui.autoFish || ui.mode != "retrieve"
			return
		if ui.runCount > this.runCount
			return

		log("Retrieve: Starting",1,"Retrieve: Started")
		
		while ui.runCount == this.runCount && !ui.cancelOperation && !reeledIn() && ui.mode == "retrieve" {
			if isHooked() { 
				winActivate(ui.game)
				landFish()
				return
			}
			
			mechanic.number := round(random(1,3))
			mechanic.strength := round(random(1,10))
			if mechanic.number == mechanic.last {
				mechanic.repeats += 1
			} else {
				mechanic.repeats := 0
			}
			
			mechanic.last := mechanic.number
			
			
			if mechanic.repeats < 2 && ui.%mechanic.names[mechanic.number]%.value >= round(random(1,10))		
				switch mechanic.number {
						case 0:
							;do nothing
						case 1:
						log("Retrieve: Twitch",1)
							loop round(random(1,3)) {
								if isHooked() {
									landFish()
									return
								}
								sendNice("{space down}")
								sendNice("{RButton Down}")
								sleep(300)
								sendNice("{RButton Up}")
								sendNice("{space up}")
							}
					case 2:
						log("Retrieve: Pause",1)
						sendNice("{space up}")
						sleep500(round(random(2,4)))
					case 3:
						log("Retrieve: Reel",1)
						setKeyDelay(0)
						sendNice("{space down}")
						sleep500(3)
						sendNice("{space up}")
						setKeyDelay(50)
			}
		}
	}

	timeOut := 0
	while !reeledIn() && timeOut && ui.mode != "off" < 20
		sleep500(1)
	if timeOut > 19
		return
}
				
				
				
		
			
			; mechanic.number := round(random(1,30))
			; mechanic.current := "reelFreq"
			; if mechanic.number < 11 
				; mechanic.current := "twitchFreq"
			; if mechanic.number > 19
				; mechanic.current := "stopFreq"
			; currMechanic := mechanic.current
			; switch mechanic.number {
				; case 1,2,3,4,5,6,7,8,9,10:
					; if (mechanic.number < cfg.%currMechanic%[cfg.profileSelected]) 
					; && (mechanic.last != mechanic.current || mechanic.repeats <= 3) {
						; if isHooked() {
							; landFish()
							; return
						; }
						; log("Retrieve: Twitch",1)
						; sendNice("{space down}")
						; sendNice("{RButton Down}")
						; sleep(round(random(100,300)))
						; sendNice("{RButton Up}")
						; sendNice("{space up}")
					; }
				; case 21,22,23,24,25,26,27,28,29,30:
					; mechanic.number -= 20
					; if (mechanic.number < cfg.%currMechanic%[cfg.profileSelected]) 
					; && (mechanic.last != mechanic.current || mechanic.repeats <= 3) {
					; if isHooked() {
						; landFish()
						; return
					; }
					; log("Retrieve: Pause",1)
						; sendNice("{space up}")
						; sleep500(random(2,3))
						; sleep(round(random(1-499)))
					; }
				; case 11,12,13,14,15,16,17,18,19,20:
					; mechanic.number -= 10
					; if (mechanic.last != mechanic.current || mechanic.repeats < 3) {
						; if isHooked() {
							; landFish()
							; return
						; }	
						; log("Retrieve: Reel",1)
						; sendNice("{space down}")
						; sleep500(2)
						; sendNice("{space up}")
					; }
				; }
			
				; if cfg.profileSelected <= cfg.%currMechanic%.length
					; if (mechanic.last == mechanic.current)
						; mechanic.repeats += 1
					; else
						; mechanic.repeats := 1
				; mechanic.last := mechanic.current	


reelIn(isAFK:=true,*) {
	modeHeader("Reel")
	panelMode("reel")
	if !ui.autoFish
		return

	loop 5 {
		sendNice("{l}")
		sleep(150)
	}		

	while !reeledIn() {
		if !ui.autoFish
			return
		sendNice("{space down}")
		sleep(1000)
		sendNice("{space up}")
	}
	sendNice("{space up}")
	if !ui.autoFish
		return

	sleep(500)
	;setTimer(landFish,0)
	;analyzeCatch()
	log("Reel: Finished",2)
	if !ui.autoFish {
		panelMode("off")
		autoFishStop()
	}
}

flashRetrieve(*) {
	(tmp.retrieveFlashOn := !tmp.retrieveFlashOn)
		? (ui.reelIconFS.value:="./img/icon_reel_flash.png",ui.retrieveButtonBg.opt("background" ui.trimColor[3]),ui.retrieveButton.opt("c482a11"),ui.retrieveButtonHotkey.opt("c482a11"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
		: (ui.reelIconFS.value:="./img/icon_reel_on.png",ui.retrieveButtonBg.opt("background" ui.trimDarkColor[3]),ui.retrieveButton.opt("c1f1105"),ui.retrieveButtonHotkey.opt("c1f1105"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
}

^+\:: {
	ui.autoFish:=true
	landFish()
}
landFish(*) {
	setTimer(isHooked,0)
	modeHeader("Land Fish")
	panelMode("land")
	sendNice("{RButton down}")
	sleep500()
	sendNice("{space Down}")
	while !reeledIn() && ui.autoFish {
		sendNice("{RButton Down}")
		loop round(random(((cfg.landAggro[cfg.profileSelected]-2)*2),cfg.landAggro[cfg.profileSelected]*2))
			sleep500(2)
		sendNice("{RButton Up}")
		loop round((4-cfg.landAggro[cfg.profileSelected])/2)
			sleep500()
	}
	sendNice("{space Up}")
	setTimer(flashRetrieve,0)
	ui.reelIconFS.value:="./img/icon_reel.png"
	ui.retrieveButtonBg.opt("background" ui.trimDarkColor[1])
	ui.retrieveButton.opt("c" ui.trimDarkFontColor[1])
	ui.retrieveButtonHotkey.opt("c" ui.trimDarkFontColor[1])
	ui.retrieveButtonBg.redraw()
	ui.retrieveButtonHotkey.redraw()
	ui.retrieveButton.redraw()
	sleep(1500)
	analyzeCatch()
	sleep(1500)
}	


analyzeCatch(logWork:=true) { 
	sleep(1500)
	if !fishCaught(logWork) {
		return
	}
			if !(DirExist("./fishPics"))
			DirCreate("./fishPics")
		ui.bigFishCaught.opt("hidden")
		ui.bigFishCaughtLabel.opt("hidden")
		ui.bigFishCaughtLabel2.opt("hidden")
		ui.fishLogAfkTime.opt("hidden")
		ui.fishLogAfkTimeLabel.opt("hidden")
		ui.fishLogAfkTimeLabel2.opt("hidden")
		log("Fish Caught!",0)
		picTimestamp := formatTime(,"yyyyMMddhhmmss")
		runWait("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "/fishPics/" picTimestamp ".png",,"hide")
		sleep500(2)
		log("Screenshot: " a_scriptDir "/fishPics/" picTimestamp ".png",1)
		ui.bigFishCaught.opt("-hidden")
		ui.bigFishCaughtLabel.opt("-hidden")
		ui.bigFishCaughtLabel2.opt("-hidden")
		ui.fishLogAfkTime.opt("-hidden")
		ui.fishLogAfkTimeLabel.opt("-hidden")
		ui.fishLogAfkTimeLabel2.opt("-hidden")
		if ui.fishLogCount.text < 999
			ui.fishLogCount.text := format("{:03i}",ui.fishLogCount.text + 1)
			try
				ui.bigFishCaught.text := format("{:03i}",ui.fishLogCount.text)
			try
				ui.statFishCount.text := format("{:03i}",ui.fishLogCount.text)
			try
				ui.FishCaughtFS.text := format("{:03i}",ui.fishLogCount.text)
	sleep(1500)
	sendNice("{space}")
	sleep(1500)
}

ui.fishCaughtX:=450
ui.fishCaughtY:=575
ui.fishCaughtColor:=[0xFFFFFF,0x797A7E]
fishCaught(logWork:=true) {
	fishCaughtPixel := round(pixelGetColor(450,575))
	log("Analyzing: Catch",1,"Analyzed: Catch")
	if checkWhite := checkPixel(ui.fishCaughtX,ui.fishCaughtY,ui.fishCaughtColor[1]) || checkGrey := checkPixel(ui.fishCaughtX,ui.fishCaughtY,ui.fishCaughtColor[2]) {
		return 1
	} else {
		log("No Fish Detected.",2)
		return 0
	}
}

checkKeepnet(*) {
	thisColor := pixelGetColor(59,120)
	if round(thisColor) >= round(0xFFC300)-5000
	&& round(thisColor) <= round(0xFFC300)+5000 {
		autoFishStop()
		log("Keepnet: Full",0)
		send("{t down}")
		sleep500(1)
		send("{t up}")
		sleep500(3)
		mouseMove(620,590)
		sleep500(1)
		sendNice("{LButton Down}")
		sleep500(1)
		sendNice("{LButton Up}")
		sleep500(1)
		if !(round(pixelGetColor(350,100)) == ui.greenCheckColor) {
			mouseGetPos(&tmpX,&tmpY)
			mouseMove(620,590)
			sleep500(1)
			sendNice("{LButton Down}")
			sleep500(1)
			sendNice("{LButton Up}")
			mouseMove(tmpX,tmpY)
			setTimer(autoFishStart,-100)
			return 1
		} 
		} else {
		log("Keepnet: Not Full",2)
		return 0
	}
}


reeledIn(*) {
	ui.checkReel1 := round(pixelGetColor(ui.reeledInCoord1[1],ui.reeledInCoord1[2]))
	ui.checkReel2 := round(pixelGetColor(ui.reeledInCoord2[1],ui.reeledInCoord2[2]))
	ui.checkReel3 := round(pixelGetColor(ui.reeledInCoord3[1],ui.reeledInCoord3[2]))
	ui.checkReel4 := round(pixelGetColor(ui.reeledInCoord4[1],ui.reeledInCoord4[2]))
	ui.checkReel5 := round(pixelGetColor(ui.reeledInCoord5[1],ui.reeledInCoord5[2]))
	
	if (ui.checkReel1 >= 12250871
		&& ui.checkReel2 >= 12250871
		&& ui.checkReel3 >= 12250871
		&& ui.checkReel4 >= 12250871
		&& ui.checkReel5 < 12250871) {
			ui.reeledIn := 1
		} else
		ui.reeledIn := 0
	return ui.reeledIn
}


detectPrompts(logWork := false) {
	if !winActive(ui.game) 
		return
	; mouseGetPos(&tmpX,&tmpY)
	ui.popupFound := true
	ui.popupCount := 0
	while ui.popupFound == true && a_index < 10 {
		ui.popupFound := false
		if round(pixelGetColor(75,180)) == ui.greenCheckColor {
			log("Rewards: Reward Detected",1)
			ui.popupFound := true
			MouseMove(210,525)
			sendNice("{LButton Down}")
			sleep(350)
			sendNice("{LButton Up}")
			sleep(500)
			log("Rewards: Reward Claimed",1)
		}
		if round(pixelGetColor(75,50)) == ui.greenCheckColor {
			log("Rewards: Reward Detected",1)
			ui.popupFound := true
			MouseMove(80,630)
			sendIfWinActive("{LButton Down}",ui.game,true)
			sleep(350)
			sendIfWinActive("{LButton Up}",ui.game,true)
			sleep(500)
			MouseMove(215,630)
			sendIfWinActive("{LButton Down}",ui.game,true)
			sleep(350)
			sendIfWinActive("{LButton Up}",ui.game,true)
			sleep(500)
			log("Rewards: Reward Claimed",1)
		}

		tmpColor1 := pixelGetColor(480,590)
		tmpColor2 := pixelGetColor(680,590)
		if ((round(tmpColor1) > round(0xF79A45)-10000 &&
			round(tmpColor1) < round(0xF79A45)+10000)
		&&	(round(tmpColor2) > round(0x45606C)-10000 &&
			round(tmpColor2) < round(0x45606C)+10000)) || 
			(round(pixelGetColor(1396,77) > round(0xC1C2C2)-10000) &&
			round(pixelGetColor(1396,77) < round(0xC1C2C2)+10000)) {
				log("Detected: Ad Window",1)
				send("{escape}")
				ui.popupFound := true
		}
		ui.adcloseButton := object()
		ui.adCloseButton.x:=1079
		ui.adCloseButton.y:=48
		tmp.detectAdPixel:=pixelGetColor(ui.adCloseButton.x,ui.adCloseButton.y)
		;log("1079,48: " tmp.detectAdPixel,2)
		if tmp.detectAdPixel == "0xF0F0F0"
		|| tmp.detectAdPixel == "0xF5F5F5"
		|| tmp.detectAdPixel == "0xFCFCFC"
		|| tmp.detectAdPixel == "0xE1E1E0" {
				log("Detected: Ad Window",1)
				send("{escape down}")
				log("Closing: Ad Window",1)
				sleep(100)
				send("{escape up}")
				ui.popupFound := true
		}
			
		

		if round(pixelGetColor(350,100)) == ui.greenCheckColor {
			log("Trip: Trip Ended",1)
			ui.popupFound := true
			mouseMove(530,610)
			sendIfWinActive("{LButton Down}",ui.game,true)
			sleep(350)
			sendIfWinActive("{LButton Up}",ui.game,true)
			sleep(1000)
			log("Trip: Adding Day Trip",1)
			MouseMove(530,450)
			sendIfWinActive("{LButton Down}",ui.game,true)
			sleep(350)
			sendIfWinActive("{LButton Up}",ui.game,true)
			sleep(500)	
			ui.popupFound:=true
		}

		if pixelGetColor(295,95) == "0x7ED322" || pixelGetColor(140,95) == "0x7ED322" {
			log("Detected: Rank Up!",1)
			ui.popupFound := true
			mouseMove(620,600)
			sleep(350)
			sendIfWinActive("{LButton Down}",ui.game,true)
			sleep(350)
			sendIfWinActive("{LButton Up}",ui.game,true)
			sleep(1000)
			if pixelGetColor(295,95) == "0x7ED322" || pixelGetColor(140,95) == "0x7ED322" {
				mouseMove(430,600)
				sleep(350)
				sendIfWinActive("{LButton Down}",ui.game,true)
				sleep(350)
				sendIfWinActive("{LButton Up}",ui.game,true)
				sleep(1000)
			}
		}
		
		if round(pixelGetColor(535,598)) > round(0xFFFFFF)-100000 {
			log("Ads: Ad Detected",1)
			ui.popupFound := true
			mouseGetPos(&x,&y)
			mouseMove(1088,57)
			sendNice("{LButton Down}")
			sleep(300)
			sendNice("{LButton Up}")
			sleep(500)
			mouseMove(x,y)
			log("Ads: Ad Closed",1)
		}		
		if ui.popupFound==true
			ui.popupCount+=1
	}
	if ui.popupCount > 0
		log("Cleared: " ui.popupCount " Windows",2)
	
	;mouseMove(tmpX,tmpY)
}

sleep500(loopCount := 1,stopOnReel := false) {
	errorLevel := 0
	while a_index <= loopCount && !reeledIn() {
		; if isHooked() {
			; landFish()
			; return 1
		; }	
		sleep(500)
		errorLevel := 0
	}	
	return errorLevel
}

tmp.beenPaused := false
sendNice(payload:="",gameWin:=ui.game) {
	if payload=="" {
		if winActive(gameWin) {
			if tmp.beenPaused {
				log("Game: Resuming",1,"Game: Resumed")
				tmp.beenPaused:=false
			}
		} else {
			if !tmp.beenPaused {
			log("Game: Pausing",1,"Game: Paused")
			tmp.beenPaused:=true
			}
		} 
	} else { 
		if winActive(gameWin) {
			sendIfWinActive(payload,gameWin:=ui.game,true)
			if tmp.beenPaused {
				log("Game: Resuming",1,"Game: Resumed") 
				tmp.beenPaused:=false
			}
		} else { 
			tmp.beenPaused := true
			log("Game: Pausing",1,"Game: Paused")
			loop {
				sleep500(2)
			}
		}
	}
}
resetKeystates(*) {
	send("{space up}")
	send("{lbutton up}")
	send("{rbutton up}")
}


/*slider2(this_name,this_gui:=ui.fishGui,this_x:=0,this_y:=0,this_w:=100,this_h:=20,thumbImg:="") {
	; global
	; cSlider := object()
	; cSlider.x := this_x
	; cSlider.w := this_w    
	; cSlider.h := this_h
	; cslider.%this_name%Bg := this_gui.addPicture("x" this_x " y" this_y " w" this_w " h" this_h " background" ui.bgColor[5])
	; if thumbImg {
		; cslider.%this_name%Thumb := this_gui.addPicture("v" this_name " x" this_x-4 " y" this_y-4 " w" this_h+8 " backgroundTrans h" this_h+8,thumbImg)
	; } else {
		; cslider.%this_name%Thumb := this_gui.addPicture("v" this_name " background" ui.trimColor[1] " x" this_x+4 " y" this_y-4 " w10 backgroundTrans h" this_h+4)
	; }
	; cslider.%this_name%Thumb.onEvent("click",sliderMoved)
	; cslider.%this_name%Thumb.redraw()
; }

;sliderMoved(this_slider,info*) {
	msgBox('here')
	; button_down := true
	; while button_down {
		; button_down := getKeyState("LButton")
		; mouseGetPos(&x,&y)
		cslider.%this_slider%.getPos(&slider_x,,,)
		; if x>cSlider.x+cSlider.w-cSlider.h
			; x:=cSlider.x+cSlider.w-cSlider.h
		; if x<cSlider.x
			; x:=cSlider.x
		; this_slider.move(x,,,)
		; sleep(10)
	; }
; }
*/

modeHeader(mode,debugLevel:=1) {
	;log(ui.lastMode ": Stopping",1,ui.lastMode ": Stopped")
	log("Ready",debugLevel)
	;log("<<<STOPPING: " strUpper(ui.lastMode) ">>>",debugLevel,"<<<STOPPED: " strUpper(ui.lastMode) ">>>")


	log("STARTING: " strUpper(ui.mode),debugLevel,"STARTED: " strUpper(ui.mode))
	log("Ready",debugLevel,"••••••••••••••••••••••••••••••••••••••")
	ui.lastMode := ui.mode
}

updateAfkTime(*) {	
	ui.secondsElapsed += 1
	ui.fishLogAfkTime.text := format("{:02i}",ui.secondsElapsed/3600) ":" format("{:02i}",mod(format("{:02i}",ui.secondsElapsed/60),60)) ":" format("{:02i}",mod(ui.secondsElapsed,60)) 
	ui.statAfkDuration.text := format("{:02i}",ui.secondsElapsed/3600) ":" format("{:02i}",mod(format("{:02i}",ui.secondsElapsed/60),60)) ":" format("{:02i}",mod(ui.secondsElapsed,60)) 
	ui.playAniStep += 1
	if ui.playAniStep > 3
		ui.playAniStep := 1
	ui.startButtonStatus.value := "./img/play_ani_" ui.playAniStep ".png"
	}
hotIfWinActive(ui.game)
	!WheelUp:: {
		sendIfWinActive("{LShift Down}",ui.game,true)
		sleep(200)
		sendIfWinActive("{2}",ui.game,true)
		sleep(200)
		sendIfWinActive("{LShift Up}",ui.game,true)
	}
	!WheelDown:: {
		sendIfWinActive("{LShift Down}",ui.game,true)
		sleep(200)
		sendIfWinActive("{1}",ui.game,true)
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
	^WheelDown:: {
		cfg.currentRod += 1
		if cfg.currentRod > cfg.rodCount
			cfg.currentRod := 1
		send("{cfg.currentRod}")
	}
	
	^WheelUp:: {
		cfg.currentRod -= 1
		if cfg.currentRod < 1 
			cfg.currentRod := cfg.rodCount
		send("{cfg.currentRod}")
	}

hotIf()
