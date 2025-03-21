A_FileVersion := "1.3.2.7"
A_AppName := "fpassist"
#requires autoHotkey v2.0+
#singleInstance
#maxThreadsPerHotkey 10

persistent()	
setWorkingDir(a_scriptDir)
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

ui 					:= object()
cfg 				:= object()
tmp 				:= object()
mechanic 			:= object()
	ui.mode := "off"
initVars()

#include <libInit>
#include <libGlobal>
#include <libMod>
#include <libGui>
#include <libGame>
#include <Class_LV_Colors>

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

onExit(exitFunc)

hotIfWinActive(ui.game)
	hotkey("CapsLock",toggleEnabled)
hotIf()

ui.toggleReelFS := false
toggleReelFS(*) {
	winActivate(ui.game)
	startReelFS()
	
	startReelFS(*) {
		sendNice("{space down}")
	}
	stopReelFS(*) {
		sendNice("{space up}")
	}
}

ui.fullscreen := false


isEnabled(*) {
		if ui.enabled && winActive(ui.game) && !ui.fullscreen
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

holdSpace(*) {
	send("{space down}")
	while !reeledIn()
		sleep500(1)
	send("{space up}")
}

hotifWinActive(ui.game)
	hotkey("+^space",holdspace)
	hotKey(ui.exitKey,cleanExit)
	hotKey(ui.reloadKey,appReload)
	hotKey(ui.startKeyMouse,startButtonClicked)
	hotKey(ui.stopKeyMouse,autoFishStop)
	hotkey("+" ui.cancelKey,autoFishStop)
	hotkey("+" ui.reelKey,singleReel)
	hotKey("+" ui.startKey,startButtonClicked)
	hotKey("+" ui.castKey,singleCast)
	hotKey("+" ui.retrieveKey,singleRetrieve)
	hotKey("F11",toggleFS)
	hotKey("Home",appReload)
	hotKey("^End",rodsIn)
	hotKey("^a",turnLeft)
	hotKey("^d",turnRight)

	^\:: {
		ui.autoFish:=true
		landFish()
	}

~^w:: {
		setTimer(throttleForward,2500)
	}

	~w:: {
		setTimer(throttleForward,0)
	}

	~^a:: {
		IF (A_ThisHotkey = A_PriorHotkey) And (A_TimeSincePriorHotkey < 200)
			setTimer(turnLeft,2000)
		else 
			setTimer(turnLeft,1000)
	}
	~^d:: {
		IF (A_ThisHotkey = A_PriorHotkey) And (A_TimeSincePriorHotkey < 200)
			setTimer(turnRight,2000)
		else 
			setTimer(turnRight,1000)
	}
	~a:: {
		setTimer(turnLeft,0)
	}

	~d:: {
		setTimer(turnRight,0)
	}
hotIf()

throttleForward(*) {
	sendNice("{w down}")
	sleep(750)
	sendNice("{w up}")
	sleep(500)
	sendNice("{s down}")
	sleep(750)
	sendNice("{s up}")
	sleep(500)
}


turnLeft(*) {
	sendNice("{a down}")
	sleep(900)
	sendNice("{a up}")
}
turnRight(*) {
	sendNice("{d down}")
	sleep(900)
	sendNice("{d up}")
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
	log("AFK: Stopping",1)
	ui.mode:="off"
	ui.autoFish 		:= false
	;panelMode("off")
	;setTimer () => cancelButtonFlash(),-100
	;setTimer () => log("Ready"),-2500 
	setTimer(isHooked,0)
	setTimer(throttleForward,0)
	setTimer(landFish,0)
	setTimer(updateAfkTime,0)
	ui.retrieveButton.text := "Retrie&ve"

	sendNice("{space up}")
	sendNice("{lshift up}")
	sendNice("{lbutton up}")
	sendNice("{rbutton up}")
	 
	ui.FishCaughtFS.opt("+hidden")
	ui.fishCaughtLabelFS.opt("+hidden")
	ui.fishCaughtLabel2FS.opt("+hidden")
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
		setTimer () => autoFishStart("restart")
	} else {
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
afStart(mode:="cast",*) {
	ui.autoFish:=true
	ui.mode:=mode
	switch ui.mode {
	case "cast":
		cast()
		retrieve()
	case "retrieve":
		retrieve()
	case "reelStop":
		reelIn()
		ui.autoFish:=false
		return
	case "off":
		ui.autoFish:=false
		return
	}
	while ui.mode != "off" && ui.autofish==true {
		cast()
		retrieve()
		
autoFishStart(mode:="",*) {
	ui.autoFish:=true
	switch mode {
		case "": 
			mode:="cast"
		case "off":
			;autoFishStop()
			return		
		}
	ui.mode:=mode
	setTimer(updateAfkTime,1000)
	log("AFK: STARTED",1)
	ui.statAfkStartTime.text 	:= formatTime(,"yyyy-MM-dd@hh:mm:ss")
	if mode=="reelStop" {
		reelIn(1)
		return
	}
	panelMode("cast")
	
	ui.FishCaughtFS.opt("-hidden")
	ui.fishCaughtLabelFS.opt("-hidden")
	ui.fishCaughtLabel2FS.opt("-hidden")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	ui.bigFishCaught.opt("-hidden")
	ui.bigFishCaughtLabel.opt("-hidden")
	ui.bigFishCaughtLabel2.opt("-hidden")

	while ui.autoFish && ui.mode!="off" && !isHooked() {
		;detectPrompts(1)
		(sleep500(2)) ? exit : 0
		
		switch ui.mode {
			case "cast":
				if reeledIn() {
					cast()
				} else {
					ui.castButtonBg.opt("background" ui.bgColor[6])
					ui.castButtonBg.redraw()
					reelButtonOn()
					reelIn(1)
					ui.castButtonBg.opt("background" ui.bgColor[5])
					ui.castButtonBg.redraw()
					ui.mode:="retrieve"
					cast()
				} 
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
	(sleep500(3)) ? 0 : exit
	analyzeCatch()
	(sleep500(3)) ? 0 : exit
	checkKeepnet()
	sendNice("{LButton Up}{RButton Up}{space up}")
	ui.cycleAFK := true
	panelMode("off")
	log("AFK: Stopped",1)
	log("Ready")
}



isHooked(*) {
	ui.isHooked := 0
	
	for hookedColor in ui.hookedColor {
		if (checkPixel(ui.hookedX,ui.hookedY,hookedColor)) {
			log("HOOKED!")
			ui.isHooked := 1
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
	;modeHeader("Calibrate")
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

	
	log("Calibrate: Reel Speed",1)
	if !ui.autoFish
		return

	loop 6 {
		winWait("ahk_exe fishingPlanet.exe")
		sendNice("{click wheelDown}")
		sleep(50)
	}	 
	if !ui.autoFish
		return

	loop cfg.reelSpeed[cfg.profileSelected] {
		sendNice("{click wheelUp}") 
		sleep(50)
	}
	;log("Ready",1)
	if !ui.autoFish
		return
}

cast(*) {
	sleep(1500)
	if !ui.autoFish || ui.mode!="Cast"
		return
	log("Cast: Preparing",1,"Cast: Prepared")
	ui.statCastCount.text := format("{:03d}",ui.statCastCount.text+1)
	sleep500(10)

	errorLevel := sleep500(6)
	if !ui.autoFish || ui.mode!="Cast"
		return

	loop 10 {
		if !reeledIn() {
			(sleep500(2)) ? 0 : exit
		} else {
			break 
		}
		timeout := a_index
		if timeout == 30 {
			log("Retrieve: Timed Out Reeling In",2)
			log("Retrieve: Stopping AFK",2)
			setTimer () => autoFishStop(),-100
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
	;calibrate()
	if !ui.autoFish || ui.mode != "cast"
		return

	setTimer(calibrate,-100)
	log("Wait: Lure In-Flight",1)
	loop cfg.castTime[cfg.profileSelected] {
		(sleep500(2)) ? 0 : exit
	}
	log("Wait: Lure Sinking",1)
	if !ui.autoFish || ui.mode != "cast"
		return


	loop cfg.sinkTime[cfg.profileSelected] {
		(sleep500(2)) ? 0 : exit
	}
	log("Cast: Closing Bail")
	sendNice("{space down}")
	sleep(500)
	sendNice("{space up}")
	sleep(150)
	;setTimer () => reelIn(),-30000
	setTimer () => retrieve(1),-100
	
}

boatRotation(*) {
	sendNice("{1}")
	sleep(2500)
	sendNice("{space down}")
	sleep(2000)
	sendNice("{space up}")
	sleep(8000)

	sendNice("{space}")
	sleep(1500)
	loop 12 
		sendNice("{-}")
	loop cfg.dragLevel[cfg.profileSelected]
		sendNice("{+}")
	sleep(1500)
	log("Boat: Place Rod 1 in Holder",1)
	sendNice("{shift down}{1 down}")
	sleep(100)
	sendNice("{1 up}{shift up}")
	sleep(2000)
	log("Boat: Switch to Rod 2",1)
	sendNice("{2}")
	sleep(4500)
	log("Boat: Cast Rod 2",1)
	sendNice("{space down}")
	sleep(2000)
	sendNice("{space up}")
	sleep(8000)
	log("Boat: Closing Bail on Rod 2",1)
	sendNice("{space}")
	sleep(1500)
	log("Boat: Setting Drag on Rod 2",1)
	loop 12 
		sendNice("{WheelDown}")
	loop cfg.dragLevel[cfg.profileSelected]
		sendNice("{WheelUp}")
	sleep(1500)

	while ui.autoFish {
		sendNice("{shift down}{1}{shift up}")
		sleep(2000)
		while ui.autoFish && !isHooked() {
			sleep(500)
			if a_index > 40
				break
		}
		if isHooked() {
			sleep(700)
			landFish()
			return
		}
		log("Boat: Picking up Rod 2",1)
		sendNice("{shift down}{1}{shift up}")
		sleep(2000)
		while ui.autoFish && !isHooked() {
			sleep(500)
			if a_index > 40
				break
		}
		if isHooked() {
			sleep(1500)
			landFish()
			return
		}
	}
}

retrieve(*) {
	panelMode("retrieve")
	log("Starting: Retrieve")
	;modeHeader("Retrieve")
	if ui.mode != "retrieve"
		return
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
				sleep(1500)
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
		if ui.mode != "retrieve"
			return

		log("Retrieve: Starting",1,"Retrieve: Started")
		
		while !reeledIn() && ui.mode == "retrieve" {
			if isHooked() { 
				winActivate(ui.game)
				(sleep500(3)) ? exit : 0
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
									sleep(1500)
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
						(sleep500(3)) ? 0 : exit
						sendNice("{space up}")
						setKeyDelay(50)
			}
		}
	}

	timeOut := 0
	while !reeledIn() && timeOut && ui.mode != "off" < 20
		(sleep500(1)) ? 0 : exit
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
						; (sleep500(2)) ? 0 : exit
						; sendNice("{space up}")
					; }
			; }
			
			; if cfg.profileSelected <= cfg.%currMechanic%.length
					; if (mechanic.last == mechanic.current)
						; mechanic.repeats += 1
					; else
						; mechanic.repeats := 1
			; mechanic.last := mechanic.current	


reelIn(*) {
	;calibrate()
	log("Reel: Started")
;	panelMode("reel")
	if !ui.autoFish
		return
	sleep(1500)
	loop 10 {
		sendNice("{l}")
		sleep(200)
	}		

	while !reeledIn() {
		if !ui.autoFish
			return
		sendNice("{space down}")
		(sleep500(2)) ? 0 : exit
		sendNice("{space up}")
	}
	sendNice("{space up}")
	if !ui.autoFish
		return
	(sleep500(1)) ? 0 : exit
	log("Reel: Finished",2)
	reelButtonOff()
}

flashRetrieve(*) {
	(tmp.retrieveFlashOn := !tmp.retrieveFlashOn)
		? (ui.reelIconFS.value:="./img/icon_reel_flash.png",ui.retrieveButtonBg.opt("background" ui.trimColor[3]),ui.retrieveButton.opt("c482a11"),ui.retrieveButtonHotkey.opt("c482a11"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
		: (ui.reelIconFS.value:="./img/icon_reel_on.png",ui.retrieveButtonBg.opt("background" ui.trimDarkColor[3]),ui.retrieveButton.opt("c1f1105"),ui.retrieveButtonHotkey.opt("c1f1105"),ui.retrieveButtonBg.redraw(),ui.retrieveButton.redraw())
}

landFish(*) {
	log("Started: Land Fish",1)
	panelMode("land")
	log("Landing Fish")
	sendNice("{RButton down}")
	sleep500()
	sendNice("{space Down}")
	while !reeledIn() && ui.autoFish {
		sendNice("{RButton Down}")
		loop round(random(((cfg.landAggro[cfg.profileSelected]-2)*2),cfg.landAggro[cfg.profileSelected]*2))
			(sleep500(2)) ? 0 : exit
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
	if !fishCaught() {
		return
	}
	if !(DirExist("./fishPics"))
		dirCreate("./fishPics")
	
	ui.bigFishCaught.opt("hidden")
	ui.bigFishCaughtLabel.opt("hidden")
	ui.bigFishCaughtLabel2.opt("hidden")
	ui.fishLogAfkTime.opt("hidden")
	ui.fishLogAfkTimeLabel.opt("hidden")
	ui.fishLogAfkTimeLabel2.opt("hidden")
	
	log("Fish Caught!",0)
	picTimestamp := formatTime(,"yyyyMMddhhmmss")
	runWait("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "/fishPics/" picTimestamp ".png",,"hide")
	(sleep500(2)) ? 0 : exit
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
	((sleep500(3)) ? 0 : exit) ? 0 : exit
		
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
		sendNice("{t down}")
		(sleep500(1)) ? 0 : exit
		sendNice("{t up}")
		(sleep500(3)) ? 0 : exit

		mouseMove(620,590)
		(sleep500(1)) ? 0 : exit

		sendNice("{LButton Down}")
		(sleep500(1)) ? 0 : exit
		sendNice("{LButton Up}")
		(sleep500(1)) ? 0 : exit
		if !(round(pixelGetColor(350,100)) == ui.greenCheckColor) {
			mouseGetPos(&tmpX,&tmpY)
			mouseMove(620,590)
			(sleep500(1)) ? 0 : exit
			sendNice("{LButton Down}")
			(sleep500(1)) ? 0 : exit
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



sleep500(loopCount := 1) {
	errorLevel := 0
	while !(ui.mode=="off") && (a_index <= loopCount) && !reeledIn() {
		if isHooked() {
			landFish(),-100
			return 0
		}	
		sleep(500)
		errorLevel := 1
	}	
	return errorLevel
}

ui.appPaused:=false
sendNice(msg:="",gameWin:=ui.game) {
	if !winActive(gameWin) {
		log("Game: Paused")
		ui.appPaused:=true
	}
	while !winActive(gameWin) {
		(sleep500(2)) ? 0 : exit
	}
	if ui.appPaused {
		log("Game: Resumed")
		ui.appPaused:=false
	}
	if winActive(gameWin) {
		;msgBox(msg)
	sendInput(msg)
	}
}

resetKeystates(*) {
	sendNice("{space up}")
	sendNice("{lbutton up}")
	sendNice("{rbutton up}")
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
ui.mode:=mode
	;log(ui.lastMode ": Stopping",1,ui.lastMode ": Stopped")
	log("Ready",debugLevel)
	;log("<<<STOPPING: " strUpper(ui.lastMode) ">>>",debugLevel,"<<<STOPPED: " strUpper(ui.lastMode) ">>>")


	log("STARTING: " strUpper(ui.mode),debugLevel,"STARTED: " strUpper(ui.mode))
	log("Ready",debugLevel,"••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••")
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
		sendNice("{cfg.currentRod}")
	}
	
	^WheelUp:: {
		cfg.currentRod -= 1
		if cfg.currentRod < 1 
			cfg.currentRod := cfg.rodCount
		sendNice("{cfg.currentRod}")
	}

hotIf()




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
				sendNice("{escape}")
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
				sendNice("{escape down}")
				log("Closing: Ad Window",1)
				sleep(100)
				sendNice("{escape up}")
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
}
