A_FileVersion := "1.2.5.3"
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
cfg.dragLevel 	:= strSplit(iniRead(cfg.file,"Game","DragLevel","5,6,7"),",")
cfg.reelSpeed 	:= strSplit(iniRead(cfg.file,"Game","ReelSpeed","1,2,2"),",")
cfg.castAdjust 	:= strSplit(iniRead(cfg.file,"Game","CastAdjust","1950,1975,2000"),",")
cfg.zoomEnabled := strSplit(iniRead(cfg.file,"Game","ZoomEnabled","0,0,0"),",")
cfg.debug 		:= iniRead(cfg.file,"System","Debug",false)

ui.fishLogArr := array()
ui.bgColor := ["111111","333333","666666","","AAAAAA","C9C9C9","D2D2D2"]
ui.fontColor := ["D2D2D2","AAAAAA","999999","666666","333333","111111"]
ui.trimColor := ["80aaff","DDCC33","44DDCC","11EE11","EE1111","1111EE"]

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
onExit(exitFunc)
detectPrompts()
;checkAds()
;checkRewards()

initGui(*) {
	ui.sessionStartTime := A_Now
	ui.autoFish := false
	ui.fullscreen := false
	ui.fishCount := 0
	ui.reeledIn := false
	ui.isCasting := false
	ui.autoclickerActive := false
	ui.startKey := "F3"
	ui.stopKey := "F4"
	ui.reloadKey := "F5"
	ui.castKey := "F6"
	ui.reelKey := "F7"
	ui.exitKey := "F9"
	ui.retrieveKey := "F8"
	ui.startKeyGlobal := "!LButton"
	ui.stopKeyGlobal := "!RButton"
	ui.retrieveKeyGlobal := "!NumpadEnter"
	ui.reelKeyGlobal := "!NumpadAdd"
	ui.castKeyGlobal := "!Numpad0"
	ui.retrieveKeyGlobal := "!NumpadEnter"
	hotKey(ui.reelKeyGlobal,singleReel)
	hotKey(ui.castKeyGlobal,singleCast)
	hotKey(ui.retrieveKeyGlobal,singleRetrieve)
	hotIfWinActive(ui.game)
		hotKey(ui.startKey,autoFishStart)
		hotKey(ui.startKeyGlobal,autoFishStart)
		hotKey(ui.stopKey,autoFishStop)
		hotKey(ui.stopKeyGlobal,autoFishStop)
		hotKey(ui.reloadKey,appReload)
		hotKey(ui.castKey,singleCast)
		hotKey(ui.reelKey,singleReel)
		hotKey(ui.retrieveKey,singleRetrieve)
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
			send("{alt down}{enter}{alt up}")
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

autoFishStop(*) {
	ui.autoFish := 0
	setTimer(updateAfkTime,0)
	ui.fishLogAfkTime.text := "00:00:00"
	ui.startButton.opt("-hidden")
	ui.startButtonHotkey.opt("-hidden")
	ui.stopButton.opt("hidden")
	ui.stopButtonHotkey.opt("hidden")
	ui.fishLogAfkTime.opt("+hidden")
	ui.fishLogAfkTimeLabel.opt("+hidden")
	ui.fishLogAfkTimeLabel2.opt("+hidden")
	ui.bigFishCaught.opt("+hidden")
	ui.bigFishCaughtLabel.opt("+hidden")
	ui.bigFishCaughtLabel2.opt("+hidden")	ui.secondsElapsed := 0
	ui.startButtonBg.opt("background" ui.bgColor[1])
	ui.startButtonBg.redraw()
	if !fileExist(a_scriptDir "/logs/current_log.txt")
		fileAppend('"Session Start","AFK Start","AFK Duration","Fish Caught","Cast Count","Cast Length","Drag Level","Reel Speed"`n', a_scriptDir "/logs/current_log.txt")
	fileAppend(ui.statSessionStartTime.text "," ui.statAfkStartTime.text "," ui.statAfkDuration.text "," ui.statFishCount.text "," ui.statCastCount.text "," ui.statCastLength.text "," ui.statDragLevel.text "," ui.statReelSpeed.text "`n", a_scriptDir "/logs/current_log.txt")
	

}

autoFishStart(*) {
	ui.autoFish := 1
	ui.fishStatusText.text := "AFK: Starting"
	ui.statCastCount.text += 1
	ui.secondsElapsed := 0
	ui.statAfkStartTime.text := formatTime(,"yyyyMMdd HH:mm:ss")
	setTimer(updateAfkTime,1000)
	ui.startButton.opt("hidden")
	ui.startButtonHotkey.opt("hidden")
	ui.stopButton.opt("-hidden")
	ui.stopButtonHotkey.opt("-hidden")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	ui.bigFishCaught.opt("-hidden")
	ui.bigFishCaughtLabel.opt("-hidden")
	ui.bigFishCaughtLabel2.opt("-hidden")
	ui.startButtonBg.opt("background" ui.trimColor[1])
	ui.startButtonBg.redraw()
	
	ui.fishLogAfkTime.opt("-hidden")
	;timerFadeIn()

	while ui.autoFish == 1 {
		detectPrompts()
		(sleep500(2,0)) ? exit : 0
		if ui.autoFish && !reeledIn()
			reelIn()
		if ui.autoFish && reeledIn()
			cast()
		analyzeCatch()
		log("___________________________________________________________________")
	}
	log("AFK: Stopping")
}

reelIn(isAFK:=true) {
	
		loop 5 {
			send("{l}")
			sleep(150)
		}
		
		while !reeledIn() {
			if (isAFK && !ui.autoFish)
				return 1
			sendIfWinActive("{space down}",ui.game)
			sleep(1000)
		}
		sendIfWinActive("{space up}",ui.game)
		sleep(500)
		log("Reel In")
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
	loop loopCount {
		if ui.autoFish {
			if stopOnReel {
				if !reeledIn() {
					sleep(500)
					errorLevel := 1
				} else {
					errorLevel := 0
				}
			} else {
				sleep(500)
				errorLevel := 1
			} 
		} else {
			errorLevel := 0
		}
	}
	return errorLevel
}

calibrate(*) {
	log("Calibration: Drag")
	loop 12 {
		winActivate(ui.game)
		send("{NumpadSub}")
		sleep(50)
	}
	loop cfg.dragLevel[cfg.profileSelected] {
		send("{NumpadAdd}")
		sleep(50)
	}
	
	log("Calibration: Reel Speed")
	loop 6 {
		winActivate(ui.game)
		click("wheelDown")
		sleep(50)
	}	 
	loop cfg.reelSpeed[cfg.profileSelected] {
		click("wheelUp") 
		sleep(50)
	}
log("___________________________________________________________________")

}
	
	
cast(isAFK:=true) {
	format("{:2di}",ui.statCastCount.text += 1)
	calibrate()
	
	ui.isCasting := true
	send("{backspace}")
	errorLevel := (!sleep500(3)) ? 1 : exit,0 
	log("Cast: Drawing Back Rod")
	sendIfWinActive("{space down}",ui.game)
	sleep(cfg.castAdjust[cfg.profileSelected])
	sendIfWinActive("{space up}",ui.game)
	log("Cast: Releasing Cast")
	ui.isCasting := false
	if isAFK {
	log("Cast: Cast in Progress")
	
	loop cfg.castTime[cfg.profileSelected] {
		(sleep500(2)) ? exit : 0
	}
	log("Cast: Lure Sinking")
	loop cfg.sinkTime[cfg.profileSelected] {
		(sleep500(2)) ? exit : 0
	}
	}
	
	if (ui.zoomToggle.value)
		send("{z}")
		sleep(150)
	
	log("___________________________________________________________________")


	if isAFK && ui.autoFish && !reeledIn()
		retrieve()
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
mechanic := object()
mechanic.last := ""
mechanic.repeats := 0
retrieve(isAFK:=true) {
	while !reeledIn() && ((isAFK && ui.autoFish) || !isAFK) {
		jigMechanic := 7	
		if a_index < 90 && !(isHooked()) {
			jigMechanic := round(random(1,12))
		}
		switch jigMechanic {
			case 1,2,3: ;twitch
				if (jigMechanic < cfg.twitchLevel[cfg.profileSelected] + 1) 
				&& (mechanic.last == "twitch" && mechanic.repeats < 3) 
				|| (mechanic.last != "twitch") {
					if mechanic.last == "twitch"  { 
						mechanic.repeats += 1
					} else {
						mechanic.last := "twitch"
						mechanic.repeats := 1
					}		
				
					log("Retrieve: Twitch")
					loop round(random(1,2)) {
						send("{RButton Down}")
						sleep(150)
						send("{RButton Up}")
						sleep(round(random(200,400)))
					if (isAFK && !ui.autoFish) || reeledIn()
					break
					}
				}
			case 4,5,6: ;pause
				if (jigMechanic < cfg.pauseLevel[cfg.profileSelected] + 4) 
				&& (mechanic.last == "pause" && mechanic.repeats < 3) 
				|| (mechanic.last != "pause") {
					if mechanic.last == "pause"  { 
						mechanic.repeats += 1
					} else {
						mechanic.last := "pause"
						mechanic.repeats := 1
					}		
				
					log("Retrieve: Pause")
					sleep(1000)
					if (isAFK && !ui.autoFish) || reeledIn()
						break
				}
				sleep(round(random(1,999)))
				
			case 7,8,9,10,11,12: ;reel
				if (mechanic.last == "reel" && mechanic.repeats < 3) 
				|| (mechanic.last != "reel") {
					if !ui.reeledIn
						sendIfWinActive("{space down}",ui.game)		
					
					if mechanic.last == "reel"  { 
						mechanic.repeats += 1
					} else {
						mechanic.last := "reel"
						mechanic.repeats := 1
					}		
				
					log("Retrieve: Reel")

					sleep500(8,1)
					sendIfWinActive("{space up}",ui.game)
					if (isAFK && !ui.autoFish) || reeledIn()
				break
			}
				
		}
	}
	log("___________________________________________________________________")
}

analyzeCatch(*) {
		if ui.reeledIn {
		(sleep500(6)) ? 0 : exit
		if fishCaught() {
			sendIfWinActive("{space}",ui.game)
			(sleep500(4)) ? exit : 0
			sendIfWinActive("{backspace}",ui.game)
			(sleep500(2)) ? exit : 0
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

isHooked(*) {
	hookedPixel := round(pixelGetColor(1220,230)) 
	if (hookedPixel > (round(0x3BCC3C) - 10000) && hookedPixel < (round(0x3BCC3C) + 10000)) {
		log("HOOKED!")
		ui.isHooked := 1
	} else
		ui.isHooked := 0
	return ui.isHooked
}

fishCaught(*) {
	fishCaughtPixel := round(pixelGetColor(450,575))
	if cfg.debug
		log("Analyzing Catch: " fishCaughtPixel)
	else
		log("Analyzing Catch")
	if (fishCaughtPixel >= 16000000) {
		if !(DirExist("./fishPics"))
			DirCreate("./fishPics")
		run("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "/fishPics/" formatTime(,"yyMMddhhmmss") ".png",,"hide")
		sleep(1000)
		log("Fish Caught!")

		if ui.fishLogCount.text < 999
			ui.fishLogCount.text += 1
			try
				ui.bigFishCaught.text := format("{:03i}",ui.fishLogCount.text)
			try
				ui.statFishCount.text := format("{:03i}",ui.fishLogCount.text)
			try
				ui.FishCaughtFS.text := format("{:03i}",ui.fishLogCount.text)
		return 1
	} else {
		return 0
	}
}

detectPrompts(*) {
	log("Prompts: Detecting Popups")
	ui.popUpFound := false
	while ui.popupFound == false && a_index < 10 {
		if round(pixelGetColor(75,180)) == 8311586 {
			log("Rewards: Reward Detected")
			ui.popupFound := true
			MouseMove(210,525)
			send("{LButton Down}")
			sleep(350)
			send("{LButton Up}")
			sleep(500)
			log("Rewards: Reward Claimed")
		}

		if round(pixelGetColor(75,50)) == 8311586 {
			log("Rewards: Reward Detected")
			ui.popupFound := true 
			MouseMove(215,630)
			send("{LButton Down}")
			sleep(350)
			send("{LButton Up}")
			sleep(500)
			log("Rewards: Reward Claimed")
		}
		
		if round(pixelGetColor(365,80)) == 8311586 {
			log("Trip: Trip Ended")
			ui.popupFound := true
			mouseMove(530,610)
			send("{LButton Down}")
			sleep(350)
			send("{LButton Up}")
			sleep(1000)
			log("Trip: Adding Day Trip")
			MouseMove(530,450)
			send("{LButton Down}")
			sleep(350)
			send("{LButton Up}")
			sleep(500)	
		}
		
		if cfg.debug
			log("Ad Screen Pixel: " AdScreenPixel)
		AdScreenPixel := round(pixelGetColor(1379,78))
		if (AdScreenPixel >= 16000000) {
			log("Ads: Ad Detected")
			ui.popupFound := true
			mouseGetPos(&x,&y)
			mouseMove(1379,78)
			send("{LButton down}")
			sleep(350)
			send("{LButton up}")
			sleep(500)
			mouseMove(x,y)
			log("Ads: Ad Closed")
		} 
	}
	log("Prompts: All Clear")
	log("___________________________________________________________________")
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
		send("{LShift down}")
		sleep(200)
		send("{1}")
		sleep(200)
		send("{LShift up}")
	}
	!WheelDown:: {
		send("{LShift down}")
		sleep(200)
		send("{2}")
		sleep(200)
		send("{LShift up}")
	}
	!MButton:: {
		send("{LShift down}")
		sleep(200)
		send("{3}")
		sleep(200)
		send("{LShift up}")
	}
hotIf()


createGui() {
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
	ui.profileLabelOutline := ui.fishGui.addText("x" ui.profilePos["x"]+149 " y" ui.profilePos["y"]+28 " w85 h21 background" ui.bgColor[4])
	;ui.profileBg := ui.fishGui.addText("section x" ui.profilePos["x"] " y" ui.profilePos["y"] " w" ui.profilePos["w"] " h" ui.profilePos["h"] " background" ui.bgColor[3]) 
	;ui.profileBg2 := ui.fishGui.addText("x+-" ui.profilePos["w"]-1 " ys+1 w" ui.profilePos["w"]-2 " h" ui.profilePos["h"]-2 " background" ui.bgColor[1]) 
	;ui.profileNewButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+203 " y" ui.profilePos["y"]+0 " w16 h16 backgroundTrans","./img/button_new.png")
	ui.profileNewButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+34 " y" ui.profilePos["y"]+33 " w16 h15 backgroundTrans","./img/button_new.png")
	ui.profileDeleteButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+71 " y" ui.profilePos["y"]+33 " w16 h15 backgroundTrans","./img/button_delete.png")
	ui.profileSaveCancelButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+34 " y" ui.profilePos["y"]+33 " w16 h15 backgroundTrans","./img/button_cancel.png")
	ui.profileSaveCancelButton.onEvent("click",cancelEditProfileName)
	ui.profileSaveButton := ui.fishGui.addPicture("hidden x" ui.profilePos["x"]+54 " y" ui.profilePos["y"]+33 " w16 h16 backgroundTrans","./img/button_save.png")
	;ui.profileEditButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+224 " y" ui.profilePos["y"]+0 " w16 h16 backgroundTrans","./img/button_edit.png")
	ui.profileEditButton := ui.fishGui.addPicture("x" ui.profilePos["x"]+53 " y" ui.profilePos["y"]+33 " w16 h15 backgroundTrans","./img/button_edit.png")
	ui.profileLArrow := ui.fishGui.addPicture("x" ui.profilePos["x"]+5 " y" ui.profilePos["y"]+0 " w25 h30 backgroundTrans","./img/button_arrowLeft.png")
	ui.profileRArrow := ui.fishGui.addPicture("x" (ui.profilePos["x"]+25)+(ui.profilePos["w"]-50) " y" ui.profilePos["y"]+0 " w25 h30 backgroundTrans","./img/button_arrowRight.png")
	ui.profileLArrow.onEvent("click",profileLArrowClicked)
	ui.profileRArrow.onEvent("click",profileRArrowClicked)
	;ui.profileLabel := ui.fishGui.addText("x" ui.profilePos["x"]+138 " y" ui.profilePos["y"]+28 " w95 h18 background" ui.bgColor[2] " c" ui.fontColor[4],"Profile")
	
	
	;ui.profileSaveButtonOutline := ui.fishGui.addText("hidden x406 y781 w157 h25 background" ui.fontColor[1])
	;ui.profileEdit := ui.fishGui.addEdit("hidden x408 y781 w125 h25 wantReturn c" ui.fontColor[3] " background" ui.bgColor[1],cfg.profileName[cfg.profileSelected])
	;ui.profileEdit.setFont("s14")
	ui.profileText := ui.fishGui.addText("x" ui.profilePos["x"]+33 " y" ui.profilePos["y"]+-1 " w200 h32 c" ui.fontColor[3] " center backgroundTrans")
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileIcon := ui.fishGui.addPicture("hidden x410 y765 w230 h42 backgroundCC3355","./img/rod.png")
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+31 " y" ui.profilePos["y"]+0 " w1 h30 background" ui.bgColor[3])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+31 " y" ui.profilePos["y"]+29 " w203 h1 background" ui.bgColor[3])
	ui.profileTextOutline1 := ui.fishGui.addText("x" ui.profilePos["x"]+31 " y" ui.profilePos["y"]+0 " w203 h1 background" ui.bgColor[3])
	ui.profileTextOutline2 := ui.fishGui.addText("x" ui.profilePos["x"]+233 " y" ui.profilePos["y"]+0 " w1 h30 background" ui.bgColor[3])
	ui.profileText.setFont("s18","calibri")
	ui.profileLabel := ui.fishGui.addText("x" ui.profilePos["x"]+151 " y" ui.profilePos["y"]+30 " center w82 h18 background" ui.bgColor[2] " c" ui.fontColor[3],"Profile")
	ui.profileLabel.setFont("s14","Courier New")
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
	ui.castAdjustText.text := cfg.castAdjust[cfg.profileSelected]
	ui.castAdjust.value := cfg.castAdjust[cfg.profileSelected]
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
	ui.startButtonBg := ui.fishGui.addText("x1103 y755 w116 h56 background" ui.bgColor[1])
	ui.startButton := ui.fishGui.addText("section x1101 center y770 w118 h60 cC9C9C9 backgroundTrans","Start")
	ui.startButton.setFont("s22","Helvetica")
	ui.startButtonHotkey := ui.fishGui.addText("x+-104 center ys-15 w20 h20 cC9C9C9 backgroundTrans","F3")
	ui.startButtonHotkey.setFont("s12","Helvetica")	
	ui.startButton.onEvent("click",startButtonClicked)
	ui.stopButton := ui.fishGui.addText("hidden section x1101 center y770 w118 h60 cC9C9C9 backgroundTrans","Stop")
	ui.stopButton.setFont("s22","Helvetica")
	ui.stopButtonHotkey := ui.fishGui.addText("hidden x+-104 center ys-15 w20 h20 cC9C9C9 backgroundTrans","F4")
	ui.stopButtonHotkey.setFont("s12","Helvetica")	
	ui.stopButton.onEvent("click",autoFishStop)
	drawButton(1224,753,100,29)
	ui.castButtonBg := ui.fishGui.addText("x1226 y755 w96 h25 background" ui.bgColor[1])
	ui.castButton := ui.fishGui.addText("section x1230 center y756 w91 h26 cC9C9C9 backgroundTrans","Cast")
	ui.castButton.setFont("s16","Helvetica")
	ui.castButtonHotkey := ui.fishGui.addText("x+-95 center ys-3 w20 h20 cC9C9C9 backgroundTrans","F6")
	ui.castButtonHotkey.setFont("s10","Helvetica")	
	ui.castButton.onEvent("click",singleCast)
	drawButton(1224,784,100,29)
	ui.reelButtonBg := ui.fishGui.addText("x1226 y786 w96 h25 background" ui.bgColor[1])
	ui.reelButton := ui.fishGui.addText("section x1230 center y786 w91 h26 cC9C9C9 backgroundTrans","Reel")
	ui.reelButton.setFont("s16","Helvetica")
	ui.reelButtonHotkey := ui.fishGui.addText("x+-95 center ys-2 w20 h20 cC9C9C9 backgroundTrans","F7")
	ui.reelButtonHotkey.setFont("s10","Helvetica")	
	ui.reelButton.onEvent("click",singleReel)
	drawButton(1326,753,115,29)
	ui.retrieveButtonBg := ui.fishGui.addText("x1328 y755 w111 h25 background" ui.bgColor[1])
	ui.retrieveButton := ui.fishGui.addText("section x1332 center y756 w106 h26 cC9C9C9 backgroundTrans"," Retrieve")
	ui.retrieveButton.setFont("s16","Helvetica")
	ui.retrieveButtonHotkey := ui.fishGui.addText("x+-110 center ys-3 w20 h20 cC9C9C9 backgroundTrans","F8")
	ui.retrieveButtonHotkey.setFont("s10","Helvetica")	
	ui.retrieveButton.onEvent("click",singleRetrieve)
	drawButton(1326,784,115,29)
	ui.reloadButtonBg := ui.fishGui.addText("x1328 y786 w111 h25 background" ui.bgColor[1]) 
	ui.reloadButton := ui.fishGui.addText("section x1332 center y786 w106 h26 cC9C9C9 backgroundTrans"," Reload")
	ui.reloadButton.setFont("s16","Helvetica")
	ui.reloadButtonHotkey := ui.fishGui.addText("x+-110 center ys-2 w20 h20 cC9C9C9 backgroundTrans","F5")
	ui.reloadButtonHotkey.setFont("s10","Helvetica")
	ui.reloadButton.onEvent("click",appReload)
	drawButton(1443,753,138,60)
	ui.exitButtonBg := ui.fishGui.addText("x1444 y755 w136 h54 background" ui.bgColor[1])
	ui.exitButton := ui.fishGui.addText("section x1441 center y770 w136 h58 cC9C9C9 backgroundTrans","Exit")
	ui.exitButton.setFont("s22","Helvetica")	
	ui.exitButtonHotkey := ui.fishGui.addText("x+-132 center ys-15 w20 h20 cC9C9C9 backgroundTrans","F9")
	ui.exitButtonHotkey.setFont("s12","Helvetica")	
	ui.exitButton.onEvent("click",cleanExit)

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
	ui.bigFishCaught := ui.fishGui.addText("hidden x1160 y666 w160 h300 backgroundTrans c" ui.fontColor[1],format("{:03i}","0"))
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
	ui.profileIcon.focus()
	statPanel()
	while ui.fishLogArr.length < 33 {
		ui.fishLogArr.push("")
		ui.fishLogText.delete()
		ui.fishLogText.add(ui.fishLogArr)
		ui.fishLogText.add([""])
	}
	ui.fishGui.show("x" x-300 " y" y+-30 " w1582 h814 noActivate")
	loadScreen(false)	
}

profileLArrowClicked(*) {
	if cfg.profileSelected > 1
	cfg.profileSelected -= 1
	else
		cfg.profileSelected := cfg.profileName.Length
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
	updateControls()
}
profileRArrowClicked(*) {
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
;editProfileName()
editProfileName(*) {
	ui.editProfileGui := gui()
	ui.editProfileGui.opt("-border -caption owner" ui.fishGui.hwnd)
	ui.editProfileEdit := ui.editProfileGui.addEdit("x-1 y-1 w205 h31 background" ui.bgColor[3] " -multi -wantReturn -wantTab limit -wrap -theme c" ui.fontColor[1],cfg.profileName[cfg.profileSelected])
	ui.editProfileEdit.setFont("s16")
	ui.profileText.opt("hidden")
	ui.profileNewButton.opt("hidden")
	ui.profileEditButton.opt("hidden")
	ui.profileDeleteButton.opt("hidden")
	ui.profileSaveButton.opt("-hidden")
	ui.profileSaveCancelButton.opt("-hidden")
	winGetPos(&x,&y,&w,&h,ui.fishGui)
	ui.editProfileGui.show("x" ui.profilePos["x"]+40-8 " y" ui.profilePos["y"]+2 " w202 h28")
	ui.editProfileEdit.focus()
}
;editProfileName()

startButtonClicked(*) { 
		winActivate("ahk_exe fishingPlanet.exe")
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
	try 
		ui.profileIcon.focus()
	
}

singleCast(*) {
	ui.castButtonBg.opt("background" ui.trimColor[1])
	ui.castButtonBg.redraw()
	cast(0)
	ui.castButtonBg.opt("background" ui.bgColor[1])
	ui.castButtonBg.redraw()
}

singleReel(*) {
	ui.reelButtonBg.opt("background" ui.trimColor[1])
	ui.reelButtonBg.redraw()
	reelIn(0)
	ui.reelButtonBg.opt("background" ui.bgColor[1])
	ui.reelButtonBg.redraw()
	}
	
singleRetrieve(*) {
	ui.retrieveButtonBg.opt("background" ui.trimColor[1])
	ui.retrieveButtonBg.redraw()
	retrieve(0)
	ui.retrieveButtonBg.opt("background" ui.bgColor[1])
	ui.retrieveButtonBg.redraw()
}

slider(name := random(1,999999),gui := ui.fishGui,x := 0,y := 0,w := 100,h := 20,range := 0-10,tickInterval := 1,default := 1,align := "center",label := "",orient := "",labelAlign := "r") {
	cfg.%name% := strSplit(iniRead(cfg.file,"Game",name,"1,1,1,1,1"),",")
	ui.%name% := gui.addSlider("section v" name " x" x " y" y " w" w " h" h " tickInterval" tickInterval " " orient " range" range " " align " toolTip",cfg.%name%[cfg.profileSelected])
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
