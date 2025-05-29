A_FileVersion := "1.3.9.9"
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
#include <libProfileEditor>
#include <libHotkeys>
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
profileEditor()
winActivate(ui.game)
; winActivate(ui.game)
; ui.isActiveWindow:=""
;setTimer () => ((ui.lastCapsLockState:=getKeyState("capslock")),ui.isActiveWindow:=(winActive(ui.game)) ? (ui.isActiveWindow) ? 1 : (setCapsLockState(ui.lastCapslockState),1) : (ui.isActiveWindow) ? (0,setCapsLockState(0)) : 0),500

onExit(exitFunc)
;analyzeCatch()
setStoreCapslockMode(0)


;ui.fullscreen := false

mode(mode) {
	ui.mode:=mode	

	switch mode {
		case "cast":
			reelButtonOff()
			retrieveButtonOff()
			ui.retrieveButton.text:="Retrieve"
			ui.actionBg.opt("background00C6FD")
			ui.action.text:="Cast"
			ui.action.setFont("c08238c")
			castButtonOn()
			startButtonOn()
			cancelButtonOn()
		
		case "land":
			reelButtonOff()
			castButtonOff()
			ui.retrieveButton.text:="Landing"
			retrieveButtonOn()
			startButtonOn()
			cancelButtonOn()
			ui.actionBg.opt("backgroundF29400")
			ui.action.setFont("c4e2314")
			ui.action.text:="Land"
			flashretrieve()
			setTimer(flashRetrieve,1500)

		case "retrieve":
			ui.retrieveButton.text:="Retrieve"
			reelButtonOff()
			castButtonOff()
			ui.actionBg.opt("background0024eb")
			ui.action.setFont("cf1f3ff")
			ui.action.text:="Lure"

			startButtonOn()
			cancelButtonOn()
			retrieveButtonOn()
		
		
		
		case "reel":
			ui.retrieveButton.text:="Retrieve"

			ui.actionBg.opt("backgroundF1F3FF")
			ui.action.setFont("c0024EB")
			ui.action.text:="Reel"
			retrieveButtonOff()
			startButtonOn()
			cancelButtonOn()
			reelButtonOn()
		
		case "afk":
			startButtonOn()
		
		case "off":
			setTimer(flashCancel,0)
			ui.retrieveButton.text:="Retrieve"
			cancelButtonOff()
			startButtonOff()
			retrieveButtonOff()
			ui.actionBg.opt("backgroundb0bab5")
			ui.action.text:="Idle"
			ui.action.setFont("c565f6e")
			castButtonOff()
			reelButtonOff()
			return
	}
	cancelButtonOn()
}

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

shiftDown(*) {
	ui.shiftHotkeyBg2.opt("backgroundFF8800")
	ui.shiftHotkey.setFont("c" ui.fontColor[5])
	ui.reelButtonHotkey.setFont("c" ui.trimFontColor[6])
	ui.castButtonHotkey.setFont("c" ui.trimFontColor[6])
	ui.retrieveButtonHotkey.setFont("c" ui.trimFontColor[6])
	ui.cancelButtonHotkey.setFont("c" ui.trimFontColor[6])
	ui.startButtonHotkey.setFont("c" ui.trimFontColor[6])
	keywait("LShift")
	shiftUp()
}
shiftUp(*) {
	ui.shiftHotkeyBg2.opt("background" ui.trimColor[1])
	ui.startButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	ui.shiftHotkey.setFont("c" ui.trimFontColor[1])
	ui.reelButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	ui.castButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	ui.retrieveButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	ui.cancelButtonHotkey.setFont("c" ui.trimDarkFontColor[1])
	send("{LShift Up}")
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
	setTimer(updateAfkTime,0)
	setTimer(flashCancel,1400)
	mode("off")
	ui.retrieveButton.text := "Retrie&ve"
	ui.secondsElapsed := 0
	ui.fishLogAfkTime.text := "00:00:00"
	setTimer(flashCancel,0)
}

autoFishRestart(*) {
	killAfk()
	sleep(2000)
	startAfk()
}

endAfk(*) {
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
	;toggleEnabled()
	exit
}

killAfk(*) {
	ui.autoFish:=false
	ui.enabled:=false
	mode("off")
	setTimer(updateAfkTime,0)
	setTimer(flashCancel,0)
	setTimer(flashRetrieve,0)
	setTimer(flashCast,0)
	setTimer(turnLeft,0)
	setTimer(turnRight,0)
	setTimer(throttleForward,0)
	ui.toggleEnabledFS.value:="./img/toggle_off.png"
	for this_obj in ui.fsObjects 
		this_obj.opt("hidden")
	;toggleEnabled()
	resetKeyStates()
	exit
}

resetKeyStates(*) {
	send("{shift up}")
	send("{lshift up}")
	send("{rshift up}")
	send("{ctrl up}")
	send("{lctrl up}")
	send("{rctrl up}")
	send("{space up}")
	setCapsLockState(true)
	return 1
}


;setTimer(processQ,-100)

; processQ(*) {
		; loop {

		; if ui.fishQ.length>0 {
			; this_step:=ui.fishQ[1]
			; ui.fishQ.delete(1)
			; switch this_step {
				; case "cast":
					; cast()
				; case "retrieve":
					; retrieve()
				; case "land":
					; landFish()
				; case "reel":
					; reelIn()
				; case "clearQ":
					; ui.fishQ.delete()
				; case "stopQ":
					; setTimer(processQ,0)
			; }
			; sleep(500)
		; }
	; }
; }																																																																																																																			

this:=object()
startAfk(this_mode:="cast",*) {
	mode(this_mode)
	ui.enabled:=true
	ui.fishCountIcon.opt("-hidden")
	setTimer(updateAfkTime,1000)
	log("AFK: Started")
	send("{LButton Up}")
	send("{RButton Up}")
	send("{Shift Up}")
	send("{LShift Up}")
	send("{Space Up}")
	send("{CapsLock Up}")
	ui.statAfkStartTime.text 	:= formatTime(,"yyyy-MM-dd@hh:mm:ss")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	ui.bigfishCount.opt("-hidden")
	ui.bigfishCountLabel.opt("-hidden")
	ui.bigfishCountLabel2.opt("-hidden")

	loop 5 {
		send("{+}")
		sleep(150)
	}
	
	while ui.enabled && !reeledIn {
		send("{space down}")
		sleep(500)
	}
	errorLevel:=(ui.enabled) ? 0 : killAfk()
	
	while ui.enabled  {
		if reeledIn() {
			errorLevel:=(ui.enabled) ? 0 : killAfk()
			send("{backspace}")
			sleep500(2)
			cast()
		} else {
			reelIn()
		}

		if !reeledIn() {
			retrieve()
		}	
	cast()
	}
	errorLevel:=(ui.enabled) ? 0 : killAfk()
	sleep500(3)
	analyzeCatch()
	sleep500(3)
	killAfk()
}

isHooked(*) {
	lineTension:=round(pixelGetColor(ui.hookedX,ui.hookedY))
	;log("Line Tension: " lineTension "`tLooking For: " ui.hookedColor[1])
	if lineTension==ui.hookedColor[1] {
		;if (checkPixel(ui.hookedX2,ui.hookedY2,ui.hookedColor[2])) {
			;log("HOOKED!")
			;setTimer(isHooked,0)
		;landFish()
			return 1
		;}
	}
	return 0
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
		sendNice("{NumpadSub}")
		sleep(50)
	}
	sleep500(1)
	ui.currDrag := 0
	loop cfg.dragLevel[cfg.profileSelected] {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		sendNice("{NumpadAdd}")
		sleep(100)
	}
	
	log("Calibrate: Reel Speed",1)
	loop 6 {
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
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
	checkKeepnet()
	mode("cast")
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
			if !reeledIn() && ui.enabled {
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
			if !reeledIn() {
				log("Cast: Closing Bail")
				sendNice("{space down}")
				sleep(500)
				sendNice("{space up}")
				sleep(150)
			}
		}
	} else {
	
		while !reeledIn() && ui.enabled {
			castButtonDim()
			reelButtonOn()
			reelIn()
			reelButtonOff()
			castButtonOn()
			sleep500(2)
		}

		log("Cast: Prepared")
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
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
		retrieve()
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
	;setTimer(detectPrompts,0)
	errorLevel:=(ui.enabled) ? 0 : killAfk()	
	mode("retrieve")
	log("Started: Retrieve")
	switch {
		case ui.rodHolderEnabled.value:
			log("Watch: Monitoring Bait",1)
			ui.retrieveButton.text := "Watch"
			ui.editorGui_retrieveButton.text:="Watch"
			while !reeledIn() && winActive(ui.game) {
				sleep500(6)
				rotateRodStands()
				sleep500(8)
				sleep500(10)
			}
	
		case cfg.floatEnabled[cfg.profileSelected]:
			log("Watch: Monitoring Bait",1)
			try
				ui.retrieveButton.text := "Watch"
			try
				ui.editorGui_retrieveButton.text:="Watch"
			while !reeledIn() {
				errorLevel:=(ui.enabled) ? 0 : killAfk()	
				if round(a_index) > round(cfg.recastTime[cfg.profileSelected]*60) {
					log("Cast: Idle. Recasting")
					reelIn()
					return
				}
				sleep500(1)

			}
			try
				ui.retrieveButton.text := "Retrie&ve"
			try
				ui.editorGui_retrieveButton.text:="Lure"
			return
	checkState(*) {
		(isHooked()) ? landFish() : 0
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
	}
		
	case !ui.floatEnabled.value:
		
		mechanic.names:=["twitchFreq","stopFreq","reelFreq"]
		mechanic.count := 0
		mechanic.last := ""
		mechanic.repeats := 0
		mechanic.current := ""
		mechanic.number := 0
		stopFreq:=cfg.stopFreq[cfg.profileSelected]
		twitchFreq:=cfg.twitchFreq[cfg.profileSelected]
		reelFreq:=10
		stopRatio:=round(stopFreq)
		twitchRatio:=round(twitchFreq)
		reelRatio:=round(30-(stopFreq+twitchFreq))
		
		;msgBox(twitchRatio "`n" stopRatio "`n" reelRatio)
		
		log("Retrieve: Starting",1,"Retrieve: Started")
		while !reeledIn() {
			mechanic.number:=round(random(1,30))
			errorLevel:=(ui.enabled) ? 0 : killAfk()	
			checkState()
			
			
			if cfg.twitchFreq[cfg.profileSelected] == 10 {
				send("{space down}")
				mechanic.number:=round(random(1,10))
				if mechanic.number > 3
					mechanic.number:=1
			} 
			
			
			mechanic.strength := round(random(1,10))
			
			if mechanic.number == mechanic.last {
				mechanic.repeats += 1
			} else {
				mechanic.repeats := 0
			}
			
			errorLevel:=(ui.enabled) ? 0 : killAfk()	
			mechanic.last := mechanic.number
			
			if isHooked() {
				sleep500(1)
				landFish()
				return
			}
			
			
			if mechanic.repeats < 2 {	
				;msgBox(mechanic.number "`n" twitchRatio "`n" reelRatio "`n" stopRatio)
				switch {
						case 0:
							;do nothing
						case mechanic.number <= twitchRatio:
						log("Retrieve: Twitch",1)
							loop round(random(1,1)) {
								if isHooked() {
									sleep500(1)
									landFish()
									return
								}
								;sendNice("{space down}")
								sendNice("{RButton Down}")
								sleep(round(random(50,150)))
								sendNice("{RButton Up}")
								;sendNice("{space up}")
							}
					case mechanic.number > twitchRatio && mechanic.number <= stopRatio+twitchRatio:
						log("Retrieve: Pause",1)
						sendNice("{space up}")
						sleep500(round(random(1,2)))
					case mechanic.number > stopRatio+twitchRatio:
						log("Retrieve: Reel",1)
						setKeyDelay(0)
						sendNice("{space down}")       
						sleep500(round(random(1,2)))
						sendNice("{space up}")
						setKeyDelay(50)
				}
			} else {
				
			}
			send("{space up}")
		;sleep500(2)
		}	
		analyzeCatch()
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
	
	log("Landing Fish")
	loop 10 {
		sendNice("{l}")
		sleep(100)
	}	
	sendNice("{RButton down}")
	sleep(300)
	sendNice("{space Down}")
	noLineTension:=0
	while !reeledIn() {
		if !isHooked() {
			noLineTension+=1
		}
		if noLineTension>=5 {
			noLineTension:=0
			return
		}
		
		sendNice("{space Down}")
		errorLevel:=(ui.enabled) ? 0 : killAfk()	
		sendNice("{RButton Down}")
		;loop round(random(((cfg.landAggro[cfg.profileSelected]-2)*2),cfg.landAggro[cfg.profileSelected]*2))
		sleep(random((((cfg.landAggro[cfg.profileSelected]-2)*2),cfg.landAggro[cfg.profileSelected]*2)*500)*.6)
		errorLevel:=(ui.enabled) ? 0 : killAfk()	

		sendNice("{RButton Up}")
		sleep((((4-cfg.landAggro[cfg.profileSelected])/2)*500)*2.5)
		errorLevel:=(ui.enabled) ? 0 : killAfk()	

	}
	
	sendNice("{space Up}")
	setTimer(flashRetrieve,0)
	ui.retrieveButtonBg.opt("background" ui.trimDarkColor[1])
	ui.retrieveButton.opt("c" ui.trimDarkFontColor[1])
	ui.retrieveButtonHotkey.opt("c" ui.trimDarkFontColor[1])
	ui.retrieveButtonBg.redraw()
	ui.retrieveButtonHotkey.redraw()
	ui.retrieveButton.redraw()
	sleep(1500)
	analyzeCatch()
}	


analyzeCatch(*) {  
	send("{shift up}{ctrl up}{space up}{rbutton up}")
	sleep(1500)
	loop 5 {
		if landedFish() {	
			sleep(2000)
			break
		} else {
			log("Analyze: No Fish")
			return
		}
	}
	if !(DirExist("./fishPics"))
		DirCreate("./fishPics")
	ui.bigfishCount.opt("hidden")
	ui.bigfishCountLabel.opt("hidden")
	ui.bigfishCountLabel2.opt("hidden")
	ui.fishLogAfkTime.opt("hidden")
	ui.fishLogAfkTimeLabel.opt("hidden")
	ui.fishLogAfkTimeLabel2.opt("hidden")
	ui.fishCountText.opt("hidden")
	log("Fish Caught!",0)
	picTimestamp := formatTime(,"yyyyMMddhhmmss")
	runWait("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "/fishPics/" picTimestamp ".png",,"hide")
	sleep(1500)
	log("Screenshot: " a_scriptDir "/fishPics/" picTimestamp ".png",1)
	ui.fishCountText.opt("-hidden")
	ui.bigfishCount.opt("-hidden")
	ui.bigfishCountLabel.opt("-hidden")
	ui.bigfishCountLabel2.opt("-hidden")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	if ui.fishLogCount.text < 99999 {
		ui.fishLogCount.text := format("{:05i}",ui.fishLogCount.text + 1)
		iniWrite(ui.fishLogCount.text,cfg.file,"Game","fishCount")
		try
			ui.bigfishCount.text := format("{:05i}",ui.fishLogCount.text)
		try
			ui.statFishCount.text := format("{:05i}",ui.fishLogCount.text)
	}
	sleep(1500)
	sendNice("{space}")
	sleep(1500)
	send("{shift up}")
	send("{lshift up}")
	send("{rshift up}")
	send("{ctrl up}")
	send("{lctrl up}")
	send("{rctrl up}")
	send("{space up}")
}

ui.fishCountX:=450
ui.fishCountY:=575
ui.fishCountColor:=[0xFFFFFF,0x797A7E]

landedFish(*) {
	this_color:=round(pixelGetColor(ui.fishCaughtCoord1[1],ui.fishCaughtCoord1[2]))
	if (this_color > ui.fishCaughtColor[1]-300000 && this_color < ui.fishCaughtColor[1]+300000) || 
		(this_color > ui.fishCaughtColor[2]-300000 && this_color < ui.fishCaughtColor[2]+300000) {
		log("Analyze Catch: Coord1 (is: " this_color " needs " ui.fishCaughtColor[1] " or " ui.fishCaughtColor[2] ")")
		log("Analyze Catch: Match Found")
		return 1
	} else {
		log("Analyze Catch: Coord1 (is: " this_color " needs " ui.fishCaughtColor[1] " or " ui.fishCaughtColor[2] ")")
		log("No Fish Detected.",2)
		return 0
	}
}

checkKeepnet(*) {
	thisColor := pixelGetColor(116,288)
	ui.keepNetCoordX:=116 
	ui.keepNetCoordY:=288
	log("Keepnet: Check Coords [" ui.keepNetCoordX "," ui.keepNetCoordY "]: Is [" thisColor "] Full [0xFFC300]")
	if thisColor=="0xFFC300" {
		stopButtonClicked()
		log("Keepnet: Full",0)
		log("Keepnet: Skipping to next morning.",0)
		sleep(1000)
		winActivate(ui.game)
		send("{t}")
		sleep(1500)
		log("Pressed t down")
		mouseMove(1750,1150)
		sleep(500)
		sendNice("{LButton Down}")
		sleep(500)
		sendNice("{LButton Up}")
		sleep(500)
		if !(round(pixelGetColor(350,100)) == ui.greenCheckColor) {
			mouseGetPos(&tmpX,&tmpY)
			mouseMove(1750,1150)
			sleep(500)
			sendNice("{LButton Down}")
			sleep(500)
			sendNice("{LButton Up}")
			mouseMove(1500,1200)
			sleep(1000)
			sendNice("{LButton Down}")
			sleep(500)
			sendNice("{LButton Up}")
			sleep(1000)
			MouseMove(1500,900)
			sleep(500)
			sendNice("{LButton Down}")
			sleep(500)
			sendNice("{LButton Up}")
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
	if pixelGetColor(ui.reeledInCoord1[1],ui.reeledInCoord1[2])=="0xF7F7F7"
	&& pixelGetColor(ui.reeledInCoord2[1],ui.reeledInCoord2[2])=="0xF7F7F7"
	&& pixelGetColor(ui.reeledInCoord3[1],ui.reeledInCoord3[2])=="0xF7F7F7"
	&& pixelGetColor(ui.reeledInCoord4[1],ui.reeledInCoord4[2])=="0xF7F7F7"
	&& pixelGetColor(ui.reeledInCoord5[1],ui.reeledInCoord5[2])!="0xF7F7F7"
		return 1
	else
		return 0
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
		if !ui.mode || ui.mode=="off" || !ui.enabled {
			ui.mode:="off"
			killAfk()
		}
		if isHooked() {
			landFish()
			sleep(1400)
			return
		}	
		sleep(500)
		errorLevel := 0
	}	
	return errorLevel
}

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
