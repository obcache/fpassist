A_FileVersion := "1.3.3.4"
A_AppName := "fpassist"
#requires autoHotkey v2.0+
#singleInstance
#maxThreadsPerHotkey 1

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

if ui.fullscreen
	goFS()
	
hotIfWinActive(ui.game)
	; ~LCtrl:: {
		; winActivate(ui.fishGui)
	; }
	
	hotkey("CapsLock",toggleEnabled)
hotIf()

ui.fullscreen := false

isEnabled(*) {
		if ui.enabled && winActive(ui.game) && !ui.fullscreen
			return 1
		else
			return 0
}

isEnabledFS(*) {
		if ui.enabled && winActive(ui.game) && ui.fullscreen
			return 1
		else
			return 0
}

isHot(*) {
	if winActive(ui.game) && ui.enabled
		return 1
	else
		return 0
	}

ui.flashLightEnabled:=false
toggleFlashlightFlash(*) {
	(ui.flashLightEnabled := !ui.flashLightEnabled)
		? startFlashLightFlash()
		: stopFlashLightFlash()
}
	
startFlashLightFlash(*) {
	setTimer(flashLightFlash,100)
}

stopFlashLightFlash(*) {
	setTimer(flashLightFlash,0)
}

flashLightFlash(*) {
	send("{f}")
}

hotif(isHot)
	hotkey("~f",stopFlashLightFlash)
	hotkey("^+f",toggleFlashlightFlash)
	hotKey(ui.exitKey,cleanExit)
	hotKey(ui.reloadKey,appReload)
	hotKey(ui.startKeyMouse,startButtonClicked)
	hotKey(ui.stopKeyMouse,killAfk)
	hotkey("+" ui.cancelKey,killAfk)
	hotkey("+" ui.reelKey,reelButtonClicked)
	hotKey("+" ui.startKey,startButtonClicked)
	hotKey("+" ui.castKey,castButtonClicked)
	hotKey("+" ui.retrieveKey,retrieveButtonClicked)
	hotKey("F11",toggleFS)
	hotKey("Home",appReload)
	hotKey("^End",rodsIn)
	hotKey("^a",turnLeft)
	hotKey("^d",turnRight)

	^+l:: {
		ui.autoFish:=true
		landFish()
	}
	
	
	^a:: {
		setTimer(turnLeft,2500)
	}
	~a:: {
		setTimer(turnLeft,0)
	}
	
	^d:: {
		setTimer(turnRight,2500)
	}
	~d:: {
		setTimer(turnRight,0)
	}
	
	^w:: {
		setTimer(throttleForward,2500)
	}
	
	~w:: {
		setTimer(throttleForward,0)
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
	sleep500(3)
	sendNice("{a up}")
}
turnRight(*) {
	sendNice("{d down}")
	sleep500(3)
	sendNice("{d up}")
}
toggleFS(*) {
	(ui.isFS := !ui.isFS) ? goFS() : noFS()
}

stopBgMode(*) {
	stopAfk()
	winActivate(ui.game)
	winWait(ui.game)
}


ui.modeName := ["off","cast","retrieve","land","reel"]

modeChanged(*) {
	mode(ui.mode)
}
	
stopAfk(restart:="",*) {
	setTimer(flashCancel,1400)
	mode("off")
	ui.mode:="off"
	ui.autoFish 		:= false

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
	
	ui.secondsElapsed := 0
	ui.fishLogAfkTime.text := "00:00:00"

}

^+r:: {
	autoFishRestart()
}

autoFishRestart(*) {
	killAfk()
	sleep(2000)
	startAfk()
}

killAfk(*) {
	ui.autoFish:=false
	ui.enabled:=false
	mode("off")
	setTimer(updateAfkTime,0)
	setTimer(flashCancel,0)
	setTimer(flashRetrieve,0)
	setTimer(flashCast,0)
	ui.toggleEnabledFS.value:="./img/toggle_off.png"
	ui.toggleEnabledFSLabel.opt("hidden")
	for this_obj in ui.fsObjects 
		this_obj.opt("hidden")
	ui.enabled:=true
	exit
}

;setTimer(processQ,-100)

processQ(*) {
		loop {
		if !ui.autoFish
			break
		if ui.fishQ.length>0 {
			this_step:=ui.fishQ[1]
			ui.fishQ.delete(1)
			switch this_step {
				case "cast":
					cast()
				case "retrieve":
					retrieve()
				case "land":
					landFish()
				case "reel":
					reelIn()
				case "clearQ":
					ui.fishQ.delete()
				case "stopQ":
					setTimer(processQ,0)
			}
			sleep(500)
		}
	}
}																																																																																																																			

this:=object()
startAfk(this_mode:="cast",*) {
	mode(this_mode)
	ui.enabled:=true
	ui.autoFish:=true
	setTimer(updateAfkTime,1000)
	log("AFK: Started")
	ui.statAfkStartTime.text 	:= formatTime(,"yyyy-MM-dd@hh:mm:ss")

	ui.FishCaughtFS.opt("-hidden")
	ui.fishCaughtLabelFS.opt("-hidden")
	ui.fishCaughtLabel2FS.opt("-hidden")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	ui.bigFishCaught.opt("-hidden")
	ui.bigFishCaughtLabel.opt("-hidden")
	ui.bigFishCaughtLabel2.opt("-hidden")

	while ui.enabled  {
		;detectPrompts()

		(ui.enabled) ? 0 : killAfk()
		ui.mode:="cast"
		if reeledIn() {
			cast()
		}
		
		(ui.enabled) ? 0 : killAfk()
		ui.mode:="retrieve"
		if !reeledIn() {
			retrieve()
		}
	
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
	}

	sleep500(3)
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	analyzeCatch()
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	sleep500(3)
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	checkKeepnet()

	killAfk()
}

isHooked(*) {
	ui.isHooked := 0
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
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
	;modeHeader("Calibrate")
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	log("Calibrate: Drag",1)
	loop 13 {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		winWait("ahk_exe fishingplanet.exe")
		sendNice("{-}")
		sleep(50)
	}
	if !ui.autoFish
		return
	ui.currDrag := 0
	loop cfg.dragLevel[cfg.profileSelected] {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		sendNice("{+}")
		sleep(100)
	}
	
	log("Calibrate: Reel Speed",1)
	loop 6 {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		winWait("ahk_exe fishingPlanet.exe")
		sendNice("{click wheelDown}")
		sleep(50)
	}	 

	loop cfg.reelSpeed[cfg.profileSelected] {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		sendNice("{click wheelUp}") 
		sleep(50)
	}
}

; ui.q:=array()
; ])

ui.fishQ:=array()


cast(*) {
	if ui.rodHolderEnabled.value {
		rodCount:=4
		loop rodCount {
			send("{" a_index "}")
			sleep500(6)
			send("{lshift down}")
			sleep(100)
			send("{" a_index "}")
			sleep(100)
			send("{lshift up}")
			sleep500(6)
			if !reeledIn() && ui.enabled && ui.autoFish {
				castButtonDim()
				reelButtonOn()
			
				reelIn()
			
				reelButtonOff()
				castButtonOn()
			}

			sleep500(4)

			errorLevel:=(ui.enabled) ? 0 : killAfk()	
			
			log("Cast: Prepared")
			ui.statCastCount.text := format("{:03d}",ui.statCastCount.text+1)
			sleep500(3)
			
			log("Cast: Drawing Back Rod",1)
			sendNice("{space down}")
			(cfg.profileSelected <= cfg.castLength.length)  
				? sleep(cfg.castLength[cfg.profileSelected])
				: sleep(cfg.castLength[cfg.castLength.length])
			sendNice("{space up}")
			
			log("Cast: Releasing Cast",1)
			setTimer(calibrate,-100)
			
			log("Wait: Lure In-Flight",1)
			loop cfg.castTime[cfg.profileSelected] {
				errorLevel:=(ui.enabled) ? 0 : killAfk()	
				sleep500(2)
			}
			
			log("Wait: Lure Sinking",1)
			loop cfg.sinkTime[cfg.profileSelected] {
				errorLevel:=(ui.enabled) ? 0 : killAfk()	
				sleep500(2)
			}
			
			log("Cast: Closing Bail")
			sendNice("{space down}")
			sleep(500)
			sendNice("{space up}")
			sleep(150)
		}
	} else {
		if !reeledIn() && ui.enabled && ui.autoFish {
			castButtonDim()
			reelButtonOn()
		
			reelIn()
		
			reelButtonOff()
			castButtonOn()
		}

		sleep500(2)

		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		
		log("Cast: Prepared")
		ui.statCastCount.text := format("{:03d}",ui.statCastCount.text+1)
		sleep500(3)
		
		log("Cast: Drawing Back Rod",1)
		sendNice("{space down}")
		(cfg.profileSelected <= cfg.castLength.length)  
			? sleep(cfg.castLength[cfg.profileSelected])
			: sleep(cfg.castLength[cfg.castLength.length])
		sendNice("{space up}")
		
		log("Cast: Releasing Cast",1)
		setTimer(calibrate,-100)
		
		log("Wait: Lure In-Flight",1)
		loop cfg.castTime[cfg.profileSelected] {
			errorLevel:=(ui.enabled) ? 0 : killAfk()	
			sleep500(2)
		}
		
		log("Wait: Lure Sinking",1)
		loop cfg.sinkTime[cfg.profileSelected] {
			errorLevel:=(ui.enabled) ? 0 : killAfk()	
			sleep500(2)
		}
		
		log("Cast: Closing Bail")
		sendNice("{space down}")
		sleep(500)
		sendNice("{space up}")
		sleep(150)
	}
}

rotateRodStands(rodCount:=4) {
	static this_rodStand := 0
	this_rodStand += 1
	if this_rodStand > rodCount
		this_rodStand := 1
	send("{lshift down}")
	sleep(100)
	send("{" this_rodStand "}")
	sleep(100)
	send("{lshift up}")
	
}

retrieve(*) {
	setTimer(detectPrompts,0)
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	mode("retrieve")
	log("Started: Retrieve")
	switch {
		case ui.rodHolderEnabled.value:
			log("Watch: Monitoring Bait",1)
			ui.retrieveButton.text := "Watch"
			while !reeledIn() && winActive(ui.game) {
				sleep500(6)
				rotateRodStands()
				sleep500(8)
				if isHooked() {
					landFish()
					return
				}
				sleep500(10)
			}

				
	case ui.floatEnabled.value:
		log("Watch: Monitoring Bait",1)
		ui.retrieveButton.text := "Watch"
		while !reeledIn() {
			errorLevel:=(ui.enabled) ? 0 : killAfk()	
			sleep500(2)
			if round(a_index) > round(ui.recastTime.value*60) {
				log("Cast: Idle. Recasting")
				reelIn()
				return
			}
		}
		ui.retrieveButton.text := "Retrie&ve"
		return
		
		
	case !ui.floatEnabled.value:
		mechanic.names:=["twitchFreq","stopFreq","reelFreq"]
		mechanic.count := 0
		mechanic.last := ""
		mechanic.repeats := 0
		mechanic.current := ""
		mechanic.number := 0
		log("Retrieve: Starting",1,"Retrieve: Started")
		while !reeledIn() {
			errorLevel:=(ui.enabled) ? 0 : killAfk()	
			if isHooked() { 
				winActivate(ui.game)
				sleep(1500)
				errorLevel:=(ui.enabled) ? 0 : killAfk()	
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
			errorLevel:=(ui.enabled) ? 0 : killAfk()	
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
						sleep500(3)
						sendNice("{space up}")
						setKeyDelay(50)
			}
		sleep500(2)
		}	
	}
}

reelIn(*) {
	log("Reel: Started")
	mode("reel")
	sleep(500)
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	loop 10 {
		sendNice("{l}")
		sleep(200)
	}		

	while !reeledIn() {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		sendNice("{space down}")
		sleep500(2)
		sendNice("{space up}")
	}
	sendNice("{space up}")
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	sleep500(1)
	log("Reel: Finished",2)
	reelButtonOff()
}

landFish(*) {
	log("Started: Land Fish",1)
	mode("land")
	ui.mode:="land"
	log("Landing Fish")
	sendNice("{RButton down}")
	sleep(500)
	sendNice("{space Down}")
	while !reeledIn()  {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		sendNice("{RButton Down}")
		;loop round(random(((cfg.landAggro[cfg.profileSelected]-2)*2),cfg.landAggro[cfg.profileSelected]*2))
		sleep(random(((cfg.landAggro[cfg.profileSelected]-2)*2),cfg.landAggro[cfg.profileSelected]*2)*500)
		errorLevel:=(ui.enabled) ? 0 : killAfk()	

		sendNice("{RButton Up}")
		sleep(((4-cfg.landAggro[cfg.profileSelected])/2)*500)
		errorLevel:=(ui.enabled) ? 0 : killAfk()	

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


analyzeCatch(*) { 
	send("{shift up}{ctrl up}{space up}{capslock up}")
	sleep(1500)
	if !fishCaught() {
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
	sleep(1500)
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

fishCaught(*) {
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
		stopButtonClicked()
		log("Keepnet: Full",0)
		sendNice("{t down}")
		sleep500(1)
		sendNice("{t up}")
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
			startButtonClicked()
			return 1
		} 
	} else {
		log("Keepnet: Not Full",2)
		
		return 0
	}
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
		} else { 
			log("Game: Pausing",1,"Game: Paused")
			while !winActive(ui.game) {
				sleep500(2)
			}
			log("Game: Resuming",1,"Game: Resumed") 
			sendIfWinActive(payload,gameWin:=ui.game,true)
		}
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


detectPrompts(*) {
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
		if ((round(tmpColor1) > round(0xF79A45)-10000 
		&&	round(tmpColor1) < round(0xF79A45)+10000)
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

sleep500(loopCount := 1,stopOnReel := false) {
	errorLevel := 0
	while a_index <= loopCount {
		if !ui.mode
			ui.mode:="off"
		if !ui.enabled || ui.mode=="off"
			killAfk()
		if isHooked() {
			landFish()
			return
		}	
		sleep(500)
		errorLevel := 0
	}	
	return errorLevel
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
	!+WheelUp:: {
		if ui.currentRod  > 1
			ui.currentRod -= 1
		else
			ui.currentRod := 7
		sendIfWinActive("{" ui.currentRod "}",ui.game)
	}
	!+WheelDown:: {
		if ui.currentRod < 7
			ui.currentRod += 1
		else 
			ui.currentRod:=1
		sendIfWinActive("{" ui.currentRod "}",ui.game)
	}
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


hotIf()


