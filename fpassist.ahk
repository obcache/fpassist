A_FileVersion := "1.2.9.6"
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
cfg.profile 		:= array()
ui.fishLogArr 		:= array()
ui.sliderList 		:= array()
#include <libInit>
initValues()

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

onExit(exitFunc)

startGame()
initGui()
createGui()
initGui(*) {
	ui.sessionStartTime 	:= A_Now
	ui.fishCount 			:= 000
	ui.enabled 				:= true
	ui.isFS 				:= false
	ui.autoFish 			:= false
	ui.reeledIn 			:= false
	ui.casting 				:= false
	ui.autoclickerActive 	:= false
	ui.fullscreen 			:= false
	ui.startKey 			:= "f"
	ui.cancelKey 			:= "q"
	ui.reloadKey 			:= "F5"
	ui.castKey 				:= "c"
	ui.reelKey 				:= "r"
	ui.exitKey 				:= "F4"
	ui.retrieveKey 			:= "v"
	ui.flashlight 			:= "+F"
	ui.startKeyMouse 		:= "!LButton"
	ui.stopKeyMouse 		:= "!RButton"
	ui.greenCheckColor 		:= round(0x7ED322)
	ui.secondsElapsed 		:= 0
	isEnabled(*) {
		if winActive(ui.game)
			return ui.enabled
		else 
			return 0
	}
	
	hotIfWinActive(ui.game)
		hotkey("CapsLock",toggleEnabled)
	hotIf()
	
	hotIf(isEnabled)
		hotkey(ui.reelKey,singleReel)
		hotKey(ui.startKey,autoFishStart)
		hotKey(ui.startKeyMouse,autoFishStart)
		hotKey(ui.stopKeyMouse,autoFishStop)
		hotKey(ui.reloadKey,appReload)
		hotKey(ui.castKey,singleCast)
		hotKey(ui.reelKey,singleReel)
		hotKey(ui.retrieveKey,singleRetrieve)
		hotkey(ui.cancelKey,autoFishStop)
		hotKey(ui.exitKey,cleanExit)
		hotKey("+Esc",stopBgMode)
		hotKey("F11",toggleFS)
	hotif()
	ui.castCount := 000
}

toggleFS(*) {
	(ui.isFS := !ui.isFS) ? goFS() : noFS()
}

stopBgMode(*) {
	autoFishStop()
	winActivate(ui.game)
	winWait(ui.game)
}

autoFishStop(restart*) {
	log("AFK: Stopping",1,"AFK: Stopped")
	
	setTimer(isHooked,0)
	setTimer(landFish,0)
	setTimer(updateAfkTime,0)
	ui.retrieveButton.text := "Retrie&ve"
	ui.cancelOperation 	:= true
	ui.autoFish 		:= false
	ui.isAFK 			:= false
	ui.reeling 			:= false
	ui.casting 			:= false
	ui.retrieving 		:= false

	setTimer () => detectPrompts(),-8000
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

	; if !fileExist(a_scriptDir "/logs/current_log.txt")
		; fileAppend('"Session Start","AFK Start","AFK Duration","Fish Caught","Cast Count","Cast Length","Drag Level","Reel Speed"`n', a_scriptDir "/logs/current_log.txt")
	; fileAppend(ui.statSessionStartTime.text "," ui.statAfkStartTime.text "," ui.statAfkDuration.text "," ui.statFishCount.text "," ui.statCastCount.text "," ui.statCastLength.text "," ui.statDragLevel.text "," ui.statReelSpeed.text "`n", a_scriptDir "/logs/current_log.txt")

	if restart=="restart" {
		autoFishStart()
	} else {
		panelMode("off")
		ui.secondsElapsed := 0
		ui.fishLogAfkTime.text := "00:00:00"
	}
}

autoFishRestart(*) {
	autoFishStop("restart")
}

autoFishStart(*) {
	modeHeader("AFK")
	setTimer(updateAfkTime,1000)
	ui.statAfkStartTime.text := formatTime(,"yyyy-MM-dd@hh:mm:ss")
	ui.cancelOperation 		:= false
	ui.autoFish 			:= true
	ui.isAFK				:= true
	ui.reeledIn 			:= false
	ui.casting 				:= false
	ui.retrieving 			:= false
	ui.cycleAFK := false
	panelMode("afk")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	ui.bigFishCaught.opt("-hidden")
	ui.bigFishCaughtLabel.opt("-hidden")
	ui.bigFishCaughtLabel2.opt("-hidden")
	send("{space up}")
	send("{lshift up}")
	send("{lbutton up}")
	send("{rbutton up}")
	setTimer(detectPrompts,15000)
	while ui.autoFish == 1 && !ui.cancelOperation {
		detectPrompts(1)
		(sleep500(2,0)) ? exit : 0
		(!reeledIn()) 
			? reelIn(1) 
			: (cast(1)
				,(!reeledIn()) 
					? retrieve(1) 
					: 0)
	}
	send("{LButton Up}{RButton Up}{space up}")
	sleep(1500)
	analyzeCatch()
	sleep(1500)
	checkKeepnet()
	ui.cycleAFK := true
	if !ui.autoFish || ui.cancelOperation {
		autoFishStop()
		ui.cancelOperation := false
	} else {
		panelMode("off")
	}
}

isHooked(*) {
if (checkPixel(1090,510,"0x1EA9C3")) || (checkPixel(1090,510,"0x419AAC")) {
		log("HOOKED!")
		ui.isHooked := 1	
		setTimer(landFish,-100)
		reelIn()
	} else {
		ui.isHooked := 0
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
analyzeCatch(logWork:=true) { 
	sleep(1500)
	if fishCaught(logWork) {
		sendNice("{space}")
		sleep(3000)
		sendNice("{backspace}")
		sleep(2000)
	} else {	
		;log("No Fish Detected.")
	}
}
fishCaught(logWork:=true) {
	fishCaughtPixel := round(pixelGetColor(450,575))
	log("Analyzing: Catch",1,"Analyzed: Catch")
	if checkWhite := checkPixel(450,575,"0xFFFFFF") || checkGrey := checkPixel(450,575,"0x797A7E") {
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
		run("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "/fishPics/" picTimestamp ".png",,"hide")
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
		send("{LButton Down}")
		sleep500(1)
		send("{LButton Up}")
		sleep500(1)
		if !(round(pixelGetColor(350,100)) == ui.greenCheckColor) {
			mouseMove(620,590)
			sleep500(1)
			send("{LButton Down}")
			sleep500(1)
			send("{LButton Up}")
			detectPrompts()
			autoFishStart()
		} 
		} else {
		log("Keepnet: Not Full",2)
	}
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
	;log("Prompts: Detecting Popups",1)
	ui.popupFound := false

	while ui.popupFound == false && a_index < 10 {
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
			MouseMove(215,630)
			sendIfWinActive("{LButton Down}",ui.game,true)
			sleep(350)
			sendIfWinActive("{LButton Up}",ui.game,true)
			sleep(500)
			log("Rewards: Reward Claimed",1)
		}

		tmpColor1 := pixelGetColor(480,590)
		tmpColor2 := pixelGetColor(680,590)
		if (round(tmpColor1) > round(0xF79A45)-10000 &&
			round(tmpColor1) < round(0xF79A45)+10000)
		&&	(round(tmpColor2) > round(0x45606C)-10000 &&
			round(tmpColor2) < round(0x45606C)+10000) {
				log("Popup: Ad Detected",1,"Popup: Ad Dismissed")
				send("{escape}")
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
		}
		
		if pixelGetColor(541,590) == "0xFFFFFF" {
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
	}
}

panelMode(mode) {
	startButtonOff()
	castButtonOff()
	retrieveButtonOff()
	reelButtonOff()
	cancelButtonOff()
	if ui.autoFish
		startButtonOn()
	switch mode {
		case "cast":
			castButtonOn()
		case "retrieve":
			retrieveButtonOn()
		case "reel":
			reelButtonOn()
		case "afk":
			startButtonOn()
		case "off":
			return
	}
	cancelButtonOn()
}
osdNotify(msg) {
	winGetPos(&x,&y,&w,&h,ui.fishGui)	
	msgWidth := strLen(msg)*5
	ui.osdNotify := ui.fishGui.addText("-hidden x" (w/2)-(msgWidth/2) " y100 w" msgWidth " h50 backgroundTrans cEEEEEE",msg)
	setTimer () => ui.osdNotify.opt("hidden"),-5000
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
	beenPaused := false
	loop {
		if winActive(gameWin) {
			if beenPaused
				log("Game: Resuming",1,"Game: Resumed")
			send(payload)
			return 1
		} else {
			beenPaused := true
			log("Game: Pausing",1,"Game: Paused")
			sleep500(2)
		}
		sendIfWinActive(payload,gameWin:=ui.game,true)
	}
}

calibrate(*) {
	modeHeader("Calibrate")
	if ui.cancelOperation
		return
	log("Calibrate: Drag",1)
	loop 13 {
		winWait("ahk_exe fishingplanet.exe")
		sendNice("{-}")
		sleep(50)
	}
	ui.currDrag := 0
	loop cfg.dragLevel[cfg.profileSelected] {
		sendNice("{+}")
		sleep(100)
	}
	if ui.cancelOperation
		return
	log("Calibrate: Reel Speed",1)
	loop 6 {
		winWait("ahk_exe fishingPlanet.exe")
		sendNice("{click wheelDown}")
		sleep(50)
	}	 
	loop cfg.reelSpeed[cfg.profileSelected] {
		sendNice("{click wheelUp}") 
		sleep(50)
	}
	if ui.cancelOperation
		return
	
	log("Ready",1)
}
cast(isAFK:=true,*) {
	ui.autoFish := isAFK
	modeHeader("Cast")
	panelMode("cast")
	ui.statCastCount.text := format("{:03d}",ui.statCastCount.text+1)
	sendIfWinActive("{backspace}",ui.game,true)
	errorLevel := sleep500(3)
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
		sleep500(2)
	}
	log("Wait: Lure Sinking",1)
	loop cfg.sinkTime[cfg.profileSelected] {
		sleep500(2)
	}
	send("{space down}")
	sleep(500)
	send("{space up}")
	
	if (ui.zoomEnabled.value)
		sendNice("{z}")
		sleep(150)
	if !ui.autoFish
		panelMode("Off")
}          
retrieve(isAFK:=true) {
	modeHeader("Retrieve")
	setTimer(isHooked,500)
	ui.autoFish := isAFK
	if ui.cancelOperation
		return
	panelMode("retrieve")
	if ui.floatEnabled.value {
		log("Retrieve: Watching Float",1,"Retrieve: Watched Float")
		ui.retrieveButton.text := "Float"
		while !ui.cancelOperation && !reeledIn() {
			if !ui.isHooked 
				sleep(500)
		} else {
				ui.retrieveButton.text := "Retrie&ve"
				landFish()
				return
		} 
		} else {
		mechanic.last := ""
		mechanic.repeats := 0
		mechanic.current := ""
		mechanic.number := 1
		
		log("Retrieve: Starting",1,"Retrieve: Started")
		while !ui.cancelOperation && !reeledIn() {
			if ui.isHooked { 
				winActivate(ui.game)
				landFish()
				setTimer(isHooked,0)
				return
			}
			
		mechanic.number := round(random(1,30))
		mechanic.current := "reelFreq"
		if mechanic.number < 11 
			mechanic.current := "twitchFreq"
		if mechanic.number > 19
			mechanic.current := "stopFreq"
		currMechanic := mechanic.current
		switch mechanic.number {
			case 1,2,3,4,5,6,7,8,9,10:
				if (mechanic.number < cfg.%currMechanic%[cfg.profileSelected]) 
				&& (mechanic.last != mechanic.current || mechanic.repeats <= 3) {
					if ui.isHooked {
						landFish()
						return
					}
					log("Retrieve: Twitch",1)
					sendNice("{space down}")
					sendNice("{RButton Down}")
					sleep(round(random(100,300)))
					sendNice("{RButton Up}")
					sendNice("{space up}")
				}
			case 21,22,23,24,25,26,27,28,29,30:
				mechanic.number -= 20
				if (mechanic.number < cfg.%currMechanic%[cfg.profileSelected]) 
				&& (mechanic.last != mechanic.current || mechanic.repeats <= 3) {
				if ui.isHooked {
					landFish()
					return
				}
				log("Retrieve: Pause",1)
					sendNice("{space up}")
					sleep500(random(2,3))
					sleep(round(random(1-499)))
				}
			case 11,12,13,14,15,16,17,18,19,20:
				mechanic.number -= 10
				if (mechanic.last != mechanic.current || mechanic.repeats < 3) {
					if ui.isHooked {
						landFish()
						return
					}	
					log("Retrieve: Reel",1)
					sendNice("{space down}")
					sleep500(3)
					sendNice("{space up}")
				}
			}
		
			if cfg.profileSelected <= cfg.%currMechanic%.length
				if (mechanic.last == mechanic.current)
					mechanic.repeats += 1
				else
					mechanic.repeats := 1
				mechanic.last := mechanic.current	
		}
	}
	panelMode("off")
}
reelIn(isAFK:=true,*) {
	ui.autoFish := isAFK
	modeHeader("Reel")
	panelMode("reel")
	loop 5 {
		sendNice("{l}")
		sleep(150)
	}		

	while !reeledIn() {
		if ui.cancelOperation
			break
		sendNice("{space down}")
		sleep(1000)
		sendNice("{space up}")
	}
	sendNice("{space up}")
	sleep(500)
	setTimer(landFish,0)
	analyzeCatch()
	log("Reel: Finished",2)
	if ui.cancelOperation
		return
	if !ui.autoFish {
		panelMode("off")
		autoFishStop()
	}
}
landFish(*) {
	modeHeader("Land Fish")
	while !reeledIn() && ui.autoFish && !ui.cancelOperation {
		sendNice("{LButton Down}")
		sendNice("{RButton Down}")
		sleep(random(1000,4000))
		sendNice("{RButton Up}")
		sleep(random(500,1500))
	}
	sendNice("{LButton Up}")
	sleep(1500)
	analyzeCatch()
	sleep(1500)
	checkKeepnet()
	ui.cancelOperation := false
}	

slider2(this_name,this_gui:=ui.fishGui,this_x:=0,this_y:=0,this_w:=100,this_h:=20,thumbImg:="") {
	global
	cSlider := object()
	cSlider.x := this_x
	cSlider.w := this_w    
	cSlider.h := this_h
	cslider.%this_name%Bg := this_gui.addPicture("x" this_x " y" this_y " w" this_w " h" this_h " background" ui.bgColor[5])
	if thumbImg {
		cslider.%this_name%Thumb := this_gui.addPicture("v" this_name " x" this_x-4 " y" this_y-4 " w" this_h+8 " backgroundTrans h" this_h+8,thumbImg)
	} else {
		cslider.%this_name%Thumb := this_gui.addPicture("v" this_name " background" ui.trimColor[1] " x" this_x+4 " y" this_y-4 " w10 backgroundTrans h" this_h+4)
	}
	cslider.%this_name%Thumb.onEvent("click",sliderMoved)
	cslider.%this_name%Thumb.redraw()
}
sliderMoved(this_slider,info*) {
	;msgBox('here')
	button_down := true
	while button_down {
		button_down := getKeyState("LButton")
		mouseGetPos(&x,&y)
		;cslider.%this_slider%.getPos(&slider_x,,,)
		if x>cSlider.x+cSlider.w-cSlider.h
			x:=cSlider.x+cSlider.w-cSlider.h
		if x<cSlider.x
			x:=cSlider.x
		this_slider.move(x,,,)
		sleep(10)
	}
}

ui.mode := ""
ui.lastMode := ui.mode
modeHeader(mode,debugLevel:=1) {
	ui.mode := mode
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

createGui() {
	while cfg.profileSelected > cfg.profileName.Length
		cfg.profileName.push("Profile #" cfg.profileName.length+1)
	ui.fishGui := gui()
	ui.fishGui.opt("-caption owner" winGetId(ui.game))
	ui.fishGui.backColor := ui.bgColor[1]
	winSetTransColor("010203",ui.fishGui.hwnd)
	ui.appFrame := ui.fishGui.addText("x300 y32 w1281 h719 c" ui.fontColor[3] " background" ui.bgColor[3])
	ui.appFrame2 := ui.fishGui.addText("x301 y33 w1279 h717 c" ui.fontColor[1] " background" ui.bgColor[1])
	ui.fpBg := ui.fishGui.addText("x302 y34 w1278 h715 c010203 background010203")
	ui.titleBarOutline := ui.fishGui.addText("x299 y0 w1282 h30 background" ui.bgColor[1])
	ui.titleBarOutline2 := ui.fishGui.addText("x300 y1 w1281 h30 background" ui.bgColor[3])
	ui.titleBarOutline3 := ui.fishGui.addText("x301 y2 w1279 h28 background" ui.bgColor[1])
	ui.titleBar := ui.fishGui.addText("x305 y4 w1222 h24 cC7C7C7 background" ui.bgColor[1])
	ui.titleBar.onEvent("click",wm_lbuttonDown_callback)
	ui.titleBarText := ui.fishGui.addText("x305 y6 w900 h24 cC7C7C7 backgroundTrans","Fishing Planet`t(fpassist v" a_fileVersion ")")
	ui.titleBarText.setFont("s13","Arial Bold")
	ui.titleBarFullscreenButton := ui.fishGui.addPicture("x1524 y2 w29 h29 center backgroundTrans","./img/button_fs.png")
	ui.titleBarFullScreenButton.onEvent("click",goFS)
	ui.titleBarExitButton := ui.fishGui.addPicture("x1554 y4 w25 h25 center backgroundTrans","./img/button_close.png")
	ui.titleBarExitButton.onEvent("click",cleanExit)
	ui.fishStatus := ui.fishGui.addText("x2 y752 w1580 h61 cBBBBBB background" ui.bgColor[1])
	drawButton(1,753,395,60)
	drawButton(398,753,264,60)
	ui.profilePos := map("x",396,"y",759,"w",261,"h",50)
	ui.profileBg := ui.fishGui.addText("x" ui.profilePos["x"]+2 " y" ui.profilePos["y"]-4 " w" ui.profilePos["w"] " h" ui.profilePos["h"]+8 " background" ui.bgColor[3])
	ui.profileBg2 := ui.fishGui.addText("x" ui.profilePos["x"]+3 " y" ui.profilePos["y"]-4 " w" ui.profilePos["w"] " h" ui.profilePos["h"]+7 " background" ui.trimColor[6])
	ui.profileNewButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+29 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_new.png")
	ui.profileDeleteButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+70 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_delete.png")
	ui.profileSaveCancelButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+29 " y" ui.profilePos["y"]+31 " w16 h16 backgroundTrans","./img/button_cancel.png")
	ui.profileSaveCancelButton.onEvent("click",cancelEditProfileName)
	ui.profileSaveButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+51 " y" ui.profilePos["y"]+31 " w16 h17 backgroundTrans","./img/button_save.png")
	ui.profileEditButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+51 " y" ui.profilePos["y"]+31 " w15 h16 backgroundTrans","./img/button_edit.png")
	ui.profileLArrow := ui.fishGui.addPicture("x" ui.profilePos["x"]+5 " y" ui.profilePos["y"]+3 " w20 h22 backgroundTrans","./img/button_arrowLeft.png")
	ui.profileRArrow := ui.fishGui.addPicture("x" (ui.profilePos["x"]+30)+(ui.profilePos["w"]-50) " y" ui.profilePos["y"]+3 " w20 h22 backgroundTrans","./img/button_arrowRight.png")
	ui.profileLArrow.onEvent("click",profileLArrowClicked)
	ui.profileRArrow.onEvent("click",profileRArrowClicked)
	ui.profileText := ui.fishGui.addText("x" ui.profilePos["x"]+30 " y" ui.profilePos["y"]+4 " w207 h20 c" ui.fontColor[3] " center background" ui.bgColor[1])
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileIcon := ui.fishGui.addPicture("hidden x410 y765 w230 h42 backgroundCC3355","")
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+28 " y" ui.profilePos["y"]+3 " w1 h22 background" ui.bgColor[3])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+28 " y" ui.profilePos["y"]+24 " w209 h1 background" ui.bgColor[3])
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+28 " y" ui.profilePos["y"]+3 " w209 h1 background" ui.bgColor[3])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+236 " y" ui.profilePos["y"]+3 " w1 h22 background" ui.bgColor[3])
	ui.profileText.setFont("s12","calibri")
	ui.profileNumStr := "Profile[" cfg.profileSelected "/" cfg.profileName.length "]"
	ui.profileNum := ui.fishGui.addText("x" ui.profilePos["x"]+74 " y" ui.profilePos["y"]+29 " right w160 h20 backgroundTrans",ui.profileNumStr)
	ui.profileNum.setFont("s13 c" ui.fontColor[2],"courier new")
	ui.profileSaveButton.onEvent("click",saveProfileName)
	ui.profileEditButton.onEvent("click",editProfileName)
	ui.profileNewButton.onEvent("click",newProfileName)
	ui.profileDeleteButton.onEvent("click",deleteProfileName)
	ui.fishGui.onEvent("escape",cancelEditProfileName)
	ui.castLength := ui.fishGui.addSlider("section toolTip background" ui.bgColor[1] " buddy2ui.castLengthText altSubmit center x62 y756 w176 h16  range1000-2500",1910)
	ui.castLength.onEvent("change",castLengthChanged)
	ui.castLengthLabel := ui.fishGui.addText("xs+3 y+6 w40 h13 right backgroundTrans","Cast")
	ui.castLengthLabel.setFont("s11 c" ui.fontColor[4])
	ui.castLengthLabel2 := ui.fishGui.addText("xs+3 y+-1 w40 h20 right backgroundTrans","Adjust")
	ui.castLengthLabel2.setFont("s11 c" ui.fontColor[4])
	ui.castLengthText := ui.fishGui.addText("x+2 ys+18 left w70 h32 backgroundTrans c" ui.fontColor[3])
	while cfg.profileSelected > cfg.castLength.Length
		cfg.castLength.push("2000")
	ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
	ui.castLength.value := cfg.castLength[cfg.profileSelected]
	
	ui.castLengthText.setFont("s24")
	
	slider("reelSpeed",,6,755,20,50,"1-4",1,1,"left","Reel","vertical","b")
	slider("dragLevel",,33,755,20,50,"1-12",1,1,"center","Drag","vertical","b")
	slider("twitchFreq",,295,768,50,15,"0-10",1,1,"center","Twitch")
	slider("stopFreq",,295,786,50,15,"0-10",1,1,"center","Stop && Go")
	slider("castTime",,240,755,20,50,"2-6",1,1,"center","Cast","vertical","b")
	slider("sinkTime",,267,755,20,50,"1-10",1,1,"center","Sink","vertical","b")
	
	slider("reelFreq",,0,0,0,0,"0-10",1,10,"center","Reel")
	ui.reelFreq.value := 10
	ui.reelFreq.opt("hidden")
	ui.zoomEnabled := ui.fishGui.addCheckBox("x189 y791 w15 center h15")
	ui.zoomEnabled.onEvent("click",toggledZoom)
	ui.zoomEnabledLabel := ui.fishGui.addText("x204 y792 w30 h15 backgroundTrans c" ui.fontColor[4],"Zoom")
	ui.zoomEnabledLabel.setFont("s8")	
	
	ui.floatEnabled := ui.fishGui.addCheckBox("x189 y777 w15 center h15",cfg.floatEnabled[cfg.profileSelected])
	ui.floatEnabled.onEvent("click",toggledFloat)
	ui.floatEnabledLabel := ui.fishGui.addText("x204 y778 w30 h15 backgroundTrans c" ui.fontColor[4],"Float")
	ui.floatEnabledLabel.setFont("s8")

	ui.bgModeEnabled := ui.fishGui.addCheckBox("x381 y757 w12 h12 right")
	ui.bgModeEnabledLabel := ui.fishGui.addText("x328 y758 w50 h12 right backgroundTrans c" ui.fontColor[4],"Bg Mode")
	ui.bgModeEnabled.onEvent("click",bgModeChanged)
	ui.bgModeEnabledLabel.setFont("s6","Small Fonts")
	
	toggledFloat(*) {
		while cfg.floatEnabled.length < cfg.profileSelected
			cfg.floatEnabled.push(false)
		cfg.floatEnabled[cfg.profileSelected] := ui.floatEnabled.value
		floatEnabledStr := ""
	}

	toggledZoom(*) {
		while cfg.zoomEnabled.length < cfg.profileSelected
			cfg.zoomEnabled.push(false)
		cfg.zoomEnabled[cfg.profileSelected] := ui.zoomEnabled.value
	}
	
	bgModeChanged(*) {
		while cfg.profileSelected > cfg.bgModeEnabled.Length
			cfg.bgModeEnabled.push(ui.bgModeEnabled.value)
		cfg.bgModeEnabled[cfg.profileSelected] := ui.bgModeEnabled.value
	}



	

	;drawButton(1101,753,121,60)
	cp := object()
	cp.x := 1103
	cp.y := 755
	cp.w := 442
	cp.h := 56
	cp.wCol1 := 122
	cp.wCol2 := 117
	cp.wCol3 := 118
	cp.wCol4 := 89
	
	drawButton(1101,753,121,60)
	ui.startButtonBg := ui.fishGui.addText("x1103 y755 w117 h56 background" ui.trimDarkColor[1])
	ui.startButton := ui.fishGui.addText("section x1092 center y754 w120 h60 c" ui.trimDarkFontColor[1] " backgroundTrans","A&FK")
	ui.startButton.setFont("s34 bold","Trebuchet MS")
	ui.startButton.onEvent("click",startButtonClicked)
	ui.startButtonHotkey := ui.fishGui.addText("x+-108 ys-1 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[F]")
	ui.startButtonHotkey.setFont("s9","Palatino Linotype")
	ui.startButtonStatus := ui.fishGui.addPicture("x1190 y775 w26 h14 backgroundTrans","./img/play_ani_0.png")
	drawButton(1224,753,105,29)
	ui.castButtonBg := ui.fishGui.addText("x1226 y755 w101 h25 background" ui.trimDarkColor[1])
	ui.castButton := ui.fishGui.addText("section x1230 center y755 w96 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","&Cast")
	ui.castButton.setFont("s14 bold","Trebuchet MS")
		ui.castButtonHotkey := ui.fishGui.addText("x+-99 ys-2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[C]")
	ui.castButtonHotkey.setFont("s9","Palatino Linotype")	
	;ui.castButtonStatus := ui.fishGui.addPicture("x1310 y760 w26 h14 backgroundTrans","./img/play_ani_0.png")
	ui.castButton.onEvent("click",singleCast)
	ui.castButtonBg.onEvent("click",singleCast)
	drawButton(1224,784,105,29)
	ui.reelButtonBg := ui.fishGui.addText("x1226 y786 w101 h25 background" ui.trimDarkColor[1])
	ui.reelButton := ui.fishGui.addText("section x1226 center y786 w105 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","&Reel")
	ui.reelButton.setFont("s14 bold","Trebuchet MS")
	ui.reelButtonHotkey := ui.fishGui.addText("x+-104 ys-2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[R]")
	ui.reelButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.reelButton.onEvent("click",singlereel)
	ui.reelButtonBg.onEvent("click",singlereel)
	drawButton(1331,753,124,29)
	ui.retrieveButtonBg := ui.fishGui.addText("x1333 y755 w120 h25 background" ui.trimDarkColor[1])
	ui.retrieveButton := ui.fishGui.addText("section x1342 center y755 w113 h26 c" ui.trimDarkFontColor[1] " backgroundTrans","Retrie&ve")
	ui.retrieveButton.setFont("s14 bold","Trebuchet MS")
	ui.retrieveButtonHotkey := ui.fishGui.addText("x+-121 ys-2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[V]")
	ui.retrieveButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.retrieveButtonBg.onEvent("click",singleretrieve)
	ui.retrieveButton.onEvent("click",singleretrieve)
	drawButton(1331,784,124,29)
	ui.cancelButtonBg := ui.fishGui.addText("x1333 y786 w120 h25 background" ui.trimDarkColor[2]) 
	ui.cancelButton := ui.fishGui.addText("section x1342 center y786 w113 h26 c" ui.trimDarkFontColor[2] " backgroundTrans","Cancel")
	ui.cancelButton.setFont("s14 bold","Trebuchet MS")
	ui.cancelButtonHotkey := ui.fishGui.addText("x+-121 ys-2 w40 h20 c" ui.trimDarkFontColor[2] " backgroundTrans","[Q]")
	ui.cancelButtonHotkey.setFont("s9","Palatino Linotype")
	ui.cancelButtonBg.onEvent("click",autoFishStop)
	ui.cancelButton.onEvent("click",autoFishStop)
	drawButton(1457,753,94,19)
	ui.reloadButtonBg := ui.fishGui.addText("x1458 y755 w92 h15 background" ui.trimDarkColor[1])
	ui.reloadButton := ui.fishGui.addText("section x1469 center y751 w85 h19 c" ui.trimDarkFontColor[1] " backgroundTrans","Reload")
	ui.reloadButton.setFont("s12 Bold","Trebuchet MS")	
	ui.reloadButtonHotkey := ui.fishGui.addText("x+-94 ys+2 w40 h20 c" ui.trimDarkFontColor[1] " backgroundTrans","[F5]")
	ui.reloadButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.reloadButton.onEvent("click",appReload)
	ui.reloadButtonBg.onEvent("click",appReload)
	drawButton(1457,774,94,39)
	ui.exitButtonBg := ui.fishGui.addText("x1458 y776 w92 h35 background" ui.trimDarkColor[1])
	ui.exitButton := ui.fishGui.addText("section x1468 center y775 w85 h39 c" ui.trimDarkFontColor[1] " backgroundTrans","Exit")
	ui.exitButton.setFont("s20 Bold","Trebuchet MS")	
	ui.exitButtonHotkey := ui.fishGui.addText("x+-93 ys-1 w40 h30 c" ui.trimDarkFontColor[1] " backgroundTrans","[F4]")
	ui.exitButtonHotkey.setFont("s9","Palatino Linotype")	
	ui.exitButton.onEvent("click",cleanExit)
	ui.exitButtonBg.onEvent("click",cleanExit)
	drawButton(1553,753,28,60)	
	ui.enableButtonToggle := ui.fishGui.addPicture("x1558 y776 w18 h33 backgroundTrans c" ui.fontColor[2],"./img/toggle_on.png")
	ui.enableButtonHotkey := ui.fishGui.addText("x1553 y753 w28 h20 center backgroundTrans c" ui.fontColor[2],"Caps`nLock")
	ui.enableButtonHotkey.setFont("s6","Small Fonts")
	ui.enableButtonToggle.onEvent("click",toggleEnabled)
	
	ui.fishLogHeaderOutline := ui.fishGui.addText("x1 y1 w298 h30 background" ui.bgColor[3])
	ui.fishLogHeaderOutline2 := ui.fishGui.addText("x2 y2 w296 h28 background" ui.bgColor[1])
	ui.fishLogHeaderOutline3 := ui.fishGui.addText("x3 y3 w294 h26 background" ui.bgColor[5])
	ui.fishLogOutline := ui.fishGui.addText("x1 y32 w298 h687 background" ui.bgColor[3])
	ui.fishLogOutline2 := ui.fishGui.addText("x2 y33 w296 h685 background" ui.bgColor[1])
	ui.fishLogHeaderText := ui.fishGui.addText("x10 y3 w300 h28 c" ui.fontColor[5] " backgroundTrans","Activity")
	ui.fishLogHeaderText.setFont("s14 q5 c" ui.fontColor[5],"Bold")
	ui.fishLogCountLabel := ui.fishGui.addText("x215 y4 w40 h25 backgroundTrans right c" ui.fontColor[5]," Fish")
	ui.fishLogCountLabel.setFont("s10 q5","Helvetica")
	ui.fishLogCountLabel2 := ui.fishGui.addText("x215 y12 w40 h25 backgroundTrans right c" ui.fontColor[5],"Count")
	ui.fishLogCountLabel2.setFont("s10 q5","Helvetica")
	ui.fishLogCount := ui.fishGui.addText("x258 y2 w40 h30 backgroundTrans c" ui.fontColor[5],"000")
	ui.fishLogCount.setFont("s18 q5","Impact") 
	ui.fishLog := ui.fishGui.addText("x2 y34 w296 h680 background" ui.bgColor[1])
	ui.fishLogText := ui.fishGui.addListbox("readOnly x3 y35 w294 h682 -wrap 0x2000 0x100 -E0x200 background" ui.bgColor[1],ui.fishLogArr)
	ui.fishLogText.setFont("s11 q5 c" ui.fontColor[2])
	ui.fishLogFooterOutline := ui.fishGui.addText("x1 y721 w298 h30 background" ui.bgColor[3])
	ui.fishLogFooterOutline2 := ui.fishGui.addText("x2 y722 w296 h28 background" ui.bgColor[1])
	ui.fishLogFooterOutline3 := ui.fishGui.addText("x3 y723 w294 h26 background" ui.bgColor[2])
	ui.fishLogFooter := ui.fishGui.addText("x3 y724 w294 h25 background" ui.bgColor[5]) ;61823A
	ui.fishStatusText := ui.fishGui.addText("section x5 y723 w290 h25 center c" ui.fontColor[5] " backgroundTrans","Ready")
	ui.fishStatusText.setFont("s16 bold","Miriam Fixed")
	;ui.fishLogTimerOutline := ui.fishGui.addText("x1047 y710 w268 h40 background" ui.bgColor[3])
	;ui.fishLogTimerOutline2 := ui.fishGui.addText("x1048 y711 w266 h38 background" ui.bgColor[1])
	;ui.fishLogTimerOutline3 := ui.fishGui.addText("x1049 y712 w264 h36 background" ui.bgColor[2])
	;ui.fishLogTimer := ui.fishGui.addText("x1050 y713 w263 h35 background3F3F3F") ;61823A
	;ui.timerAnim := ui.fishGui.addText("x1047 y710 w268 h40 background010203")
	ui.fishLogAfkTimeLabel := ui.fishGui.addText("hidden section right x751 y695 w80 h40 c" ui.fontColor[3] " backgroundTrans","AFK")
	ui.fishLogAfkTimeLabel.setFont("s16 q5","Arial")
	ui.fishLogAfkTimeLabel2 := ui.fishGui.addText("hidden section right x751 y707 w80 h40 c" ui.fontColor[3] " backgroundTrans","Timer")
	ui.fishLogAfkTimeLabel2.setFont("s19 q5","Arial")
	ui.fishLogAfkTime := ui.fishGui.addText("hidden x835 y688 w200 h60 c" ui.fontColor[3] " backgroundTrans","00:00:00")
	ui.fishLogAfkTime.setFont("s35 q5","Arial")
	ui.bigFishCaught := ui.fishGui.addText("hidden x1160 y666 w160 h300 backgroundTrans c" ui.fontColor[3],format("{:03i}","000"))
	ui.bigFishCaught.setFont("s54 q5")
	ui.bigFishCaughtLabel := ui.fishGui.addText("hidden right x1053 y677 w100 h40 backgroundTrans c" ui.fontColor[3],"Fish")
	ui.bigFishCaughtLabel.setFont("s24 q5")
	ui.bigFishCaughtLabel2 := ui.fishGui.addtext("hidden right x1055 y696 w100 h40 backgroundTrans c" ui.fontColor[3],"Count")
	ui.bigFishCaughtLabel2.setFont("s28 q5")

	if winExist(ui.game) {
		winSetTransparent(255,ui.game)
		winGetPos(&x,&y,&w,&h,ui.game)
	} else {
		exitApp
	}
	sleep(500)
	ui.profileIcon.focus()
	statPanel()
	while ui.fishLogArr.length < 41 {
		ui.fishLogArr.push("")
		ui.fishLogText.delete()
		ui.fishLogText.add(ui.fishLogArr)
		ui.fishLogText.add([""])
	}

	updateControls()
	ui.fishGui.show("x" x-300 " y" y+-30 " w1582 h814 noActivate")
	ui.fishLogAfkTime.text := "00:00:00"
	
	loadScreen(false)	
}

ui.enabled := true

profileLArrowClicked(*) {
	saveSliderValues()
	if cfg.profileSelected > 1
		cfg.profileSelected -= 1
	else
		cfg.profileSelected := cfg.profileName.Length
	
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	for setting in cfg.profileSettings {
		while cfg.%setting%.length < cfg.profileName.length
			cfg.%setting%.push(cfg.profileDefaults[a_index])
	}
	updateControls()
}

ui.enabled := true
toggleEnabled(*) {
		(ui.enabled := !ui.enabled) ? toggleOn() : toggleOff()
		toggleOn(*) {
			ui.enableButtonToggle.value := "./img/toggle_on.png"
			ui.disabledGui.destroy()
		}
		toggleOff(*) {
			ui.enableButtonToggle.value := "./img/toggle_off.png"
			ui.disabledGui := gui()
			ui.disabledGui.opt("-caption -border toolWindow owner" ui.fishGui.hwnd)
			ui.disabledGui.backColor := ui.bgColor[3]
			ui.disabledGui.addText("x1 y1 w448 h58 background353535")
			winSetTransparent(225,ui.disabledGui)
			ui.disabledGui.show("x1102 y754 w450 h60 noActivate")
		}
}
	
profileRArrowClicked(*) {
	saveSliderValues()
	if cfg.profileSelected < cfg.profileName.length
		cfg.profileSelected += 1
	else
		cfg.profileSelected := 1
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	for setting in cfg.profileSettings {
		while cfg.%setting%.length < cfg.profileName.length
			cfg.%setting%.push(cfg.profileDefaults[a_index])
	}
	updateControls()
}	

deleteProfileName(*) {
	if cfg.profileName.length > 1 {
		try 
			cfg.profileName.removeAt(cfg.profileSelected)
		try
			cfg.castLength.removeAt(cfg.profileSelected)
		try
			cfg.twitchFreq.removeAt(cfg.profileSelected)
		try
			cfg.stopFreq.removeAt(cfg.profileSelected)
		try
			cfg.dragLevel.removeAt(cfg.profileSelected)
		try
			cfg.reelSpeed.removeAt(cfg.profileSelected)
		try
			cfg.zoomEnabled.removeAt(cfg.profileSelected)

		if cfg.profileSelected > cfg.profileName.length {
			cfg.profileSelected := 1
		}
		try
			ui.profileText.text := cfg.profileName[cfg.profileSelected]
		try
			ui.castLength.value := cfg.castLength[cfg.profileSelected]
		try
			ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
		try	
			ui.castTime.value := cfg.castTime[cfg.profileSelected]
		try
			ui.sinkTime.value := cfg.sinkTime[cfg.profileSelected]
		try
			ui.twitchFreq.value := cfg.twitchFreq[cfg.profileSelected]
		try
			ui.stopFreq.value := cfg.stopFreq[cfg.profileSelected]
		try
			ui.dragLevel.value := cfg.dragLevel[cfg.profileSelected]
		try
			ui.reelSpeed.value := cfg.reelSpeed[cfg.profileSelected]
		try
			ui.zoomEnabled.value := cfg.zoomEnabled[cfg.profileSelected]
		try
			ui.bgModeEnabled.value := cfg.bgModeEnabled[cfg.profileSelected]
	} else {
		notifyOSD("Can't Delete Only Profile",ui.profileText)
		;msgBox("Can't Delete Only Profile")
	}
}

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
	for setting in cfg.profileSettings {
		cfg.%setting%.insertAt(cfg.profileSelected,cfg.profileDefaults[a_index])
	}
	cfg.profileName[cfg.profileSelected] := "Profile #" cfg.profileName.length
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
		ui.twitchFreq.value := cfg.twitchFreq[cfg.profileSelected]
	try 
		ui.stopFreq.value := cfg.stopFreq[cfg.profileSelected]
	try 
		ui.dragLevel.value := cfg.dragLevel[cfg.profileSelected]
	try 
		ui.reelSpeed.value := cfg.reelSpeed[cfg.profileSelected]
	try 
		ui.castTime.value := cfg.castTime[cfg.profileSelected]
	try 
		ui.sinkTime.value := cfg.sinkTime[cfg.profileSelected]
	try
		ui.zoomEnabled.value := cfg.zoomEnabled[cfg.profileSelected]
	try
		ui.floatEnabled.value := cfg.floatEnabled[cfg.profileSelected]
	try
		ui.castLength.value := cfg.castLength[cfg.profileSelected]
	try 
		ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
	try
		ui.bgModeEnabled.value := cfg.bgModeEnabled[cfg.profileSelected]
	try 
		ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileNum.text := "Profile[" cfg.profileSelected "/" cfg.profileName.length "]"
	try 
		ui.profileIcon.focus()
}

singleCast(*) {
 	ui.cancelOperation := false
	panelMode("off")
	autoFishStop()
	cast(0)
}

singleReel(*) {
	ui.cancelOperation := false
	panelMode("off")
	autoFishStop()
	reelIn(0)
}
singleRetrieve(*) {
	ui.cancelOperation := false
	panelMode("off")
	autoFishStop()
	retrieve(0)
}

castLengthChanged(*) {
		while cfg.profileSelected > cfg.castLength.Length
			cfg.castLength.push("2000")
		
		cfg.castLength[cfg.profileSelected] := ui.castLength.value
		ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
		ui.profileIcon.focus()
}


;slider2("testSlider",ui.fishGui,50,800,100,10,"./img/slider_thumb.png")
		; if cfg.bgModeEnabled[cfg.profileSelected]
		; {
			; mouseGetPos(&x,&y)
			; currWinHwnd := winActive("A")
			; winActivate(ui.game)
			; winWait(ui.game)
			; send("{space down}")	
			; winActivate(currWinHwnd)
			; winWait(currWinHwnd)
			; mouseMove(x,y)	
			; sleep(random(2000,3000))	
			; mouseGetPos(&x,&y)
			; currWinHwnd := winActive("A")
			; winActivate(ui.game)
			; winWait(ui.game)
			; send("{space up}")
			; winActivate(currWinHwnd)
			; winWait(currWinHwnd)
			; mouseMove(x,y)
			
			; sleep(random(2000,3000))
			; } else {
