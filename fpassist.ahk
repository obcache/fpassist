A_FileVersion := "1.1.6.9"
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

cfg.file := "./fpassist.ini"
cfg.installDir := a_mydocuments "\fpassist\"
cfg.debug := iniRead(cfg.file,"System","Debug",false)
cfg.twitchToggleValue := iniRead(cfg.file,"Game","TwitchToggle",true)
cfg.waitToggleValue := iniRead(cfg.file,"Game","WaitToggle",true)
cfg.profileSelected := iniRead(cfg.file,"Game","ProfileSelected",1)
cfg.dragLevel := strSplit(iniRead(cfg.file,"Game","DragLevel","5,6,7"),",")
cfg.reelSpeed := strSplit(iniRead(cfg.file,"Game","ReelSpeed","1,2,2"),",")
cfg.castAdjust := strSplit(iniRead(cfg.file,"Game","CastAdjust","1950,1975,2000"),",")
ui.gameExe := "fishingPlanet.exe"
ui.game := "ahk_exe " ui.gameExe
ui.loadingProgress := 5
ui.reeledIn := true

#include <libGlobal>
#include <libGui>

verifyInstall()
if a_isCompiled && a_scriptName != "fpassist.exe"
	exitApp
startGame()
initGui()
createGui()

initGui(*) {
	ui.sessionStartTime := A_Now
	ui.autoFish := false
	ui.fishLogArr := array()
	ui.fishCount := 0
	ui.reeledIn := false
	ui.isCasting := false
	ui.autoclickerActive := false
	ui.bgColor := ["111111","333333","666666","","AAAAAA","C9C9C9","D2D2D2"]
	ui.fontColor := ["D2D2D2","AAAAAA","999999","666666","333333","111111"]
	ui.trimColor := ["22DD33","DDCC33","44DDCC","11EE11","EE1111","1111EE"]
	ui.startKey := "F3"
	ui.stopKey := "F4"
	ui.reloadKey := "F5"
	ui.twitchKey := "F6"
	ui.waitKey := "F7"
	ui.exitKey := "F8"
	hotIfWinActive(ui.game)
		hotKey(ui.startKey,autoFishStart)
		hotKey(ui.stopKey,autoFishStop)
		hotKey(ui.reloadKey,appReload)
		hotKey(ui.twitchKey,toggleTwitch)
		hotKey(ui.waitKey,toggleWait)
		hotKey(ui.exitKey,cleanExit)
	hotif()
	ui.castCount := 0
}

startGame(*) {
	if !winExist(ui.game) {
		run(getGamePath(),,"Hide")		
		winWait(ui.game)
		winMove(0,0,,,ui.game)
		winSetTransparent(1,ui.game)
		
		loop 60 {
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
	ui.fishStatusText.text := "Stopping"
	log("Stopped AFK")
	setTimer(updateAfkTime,0)
	ui.fishLogAfkTime.text := "00:00:00"
	ui.startButton.opt("-hidden")
	ui.startButtonHotkey.opt("-hidden")
	ui.stopButton.opt("hidden")
	ui.stopButtonHotkey.opt("hidden")
	ui.fishLogAfkTime.opt("+hidden")
	ui.fishLogAfkTimeLabel.opt("+hidden")
	ui.fishLogAfkTimeLabel2.opt("+hidden")
	ui.secondsElapsed := 0
	ui.startButtonBg.opt("background111111")
	ui.startButtonBg.redraw()
	if !fileExist(a_scriptDir "/logs/current_log.txt")
		fileAppend('"Session Start","AFK Start","AFK Duration","Fish Caught","Cast Count","Cast Length","Drag Level","Reel Speed"`n', a_scriptDir "/logs/current_log.txt")
	fileAppend(ui.statSessionStartTime.text "," ui.statAfkStartTime.text "," ui.statAfkDuration.text "," ui.statFishCount.text "," ui.statCastCount.text "," ui.statCastLength.text "," ui.statDragLevel.text "," ui.statReelSpeed.text "`n", a_scriptDir "/logs/current_log.txt")
	

}

autoFishStart(*) {
	ui.autoFish := 1
	ui.fishStatusText.text := "Starting"
	log("Started AFK")
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
	ui.startButtonBg.opt("background907010")
	ui.startButtonBg.redraw()
	
	ui.fishLogAfkTime.opt("-hidden")
	;timerFadeIn()
	if !reeledIn() {
		osdNotify("Line still out. Reeling In.")
		reelIn()
		sendIfWinActive("{space up}")
	}
	while ui.autoFish == 1 {
		(sleep500(4,0)) ? exit : 0
		cast()
		if !reeledIn()
		retrieve()
	}
}

reelIn(*) {
		ui.fishStatusText.text := "Reeling In"
		log("Reeling In")
		loop 5 {
			send("{l}")
			sleep(150)
		}
		
		while !reeledIn() {
			sendIfWinActive("{space down}",ui.game)
			sleep(1000)
		}
		sendIfWinActive("{space up}")
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
	errorLevel := 1
	loop loopCount {
		if ui.autoFish {
			if stopOnReel {
				if !reeledIn() {
					sleep(500)
					errorLevel := 0
				} else {
					errorLevel := 1
				}
			} else {
				sleep(500)
				errorLevel := 0
			} 
		} else {
			errorLevel := 0
		}
	}
	return errorLevel
}

calibrate(*) {
	ui.fishStatusText.text := "Calibrating"
	log("Adjusting Drag")
	loop 10 {
		winActivate(ui.game)
		send("{NumpadSub}")
		sleep(200)
	}
	loop cfg.dragLevel[cfg.profileSelected] {
		send("{NumpadAdd}")
		sleep(200)
	}
	
	log("Adjusting Reel Speed")
	loop 10 {
		winActivate(ui.game)
		click("wheelDown")
		sleep(200)
	}	 
	
	loop cfg.reelSpeed[cfg.profileSelected] {
		click("wheelUp") 
		sleep(200)
	}
	ui.fishStatusText.text := ""
}
	
	
cast(*) {
	if !(ui.autoFish) || !reeledIn() {
		return 1
	}
	ui.statCastCount.text += 1
	calibrate()
	
	ui.isCasting := true
	ui.fishStatusText.text := "Cleaning Up Screen"
	send("{backspace}")
	(sleep500(3)) ? exit : 0 
	log("Casting")
	ui.fishStatusText.text := "Cast"
	sendIfWinActive("{space down}",ui.game)
	sleep(cfg.castAdjust[cfg.profileSelected])
	sendIfWinActive("{space up}",ui.game)

	ui.isCasting := false
	log("Waiting for Lure to Settle")
	(sleep500(10)) ? exit : 0
	log("Casting Complete")
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
	if !(ui.autoFish) || (reeledIn()) {
		return 1
	}
	ui.fishStatusText.text := "Retrieving" 
	log("Retrieving")
	while !reeledIn() && ui.autoFish {
		jigMechanic := 5	
		if a_index < 90 && !(isHooked()) {
			jigMechanic := round(random(1,10))
		}
		switch jigMechanic {
			case 3,2: ;twitch
				if ui.twitchToggle.value {
					ui.fishStatusText.text := "Retrieve Mechanic: Twitch"
					log("Retrieve Mechanic: Twitch")
					loop round(random(1,2)) {
						send("{RShift down}")
						sleep(150)
						send("{RShift up}")
						sleep(round(random(200,400)))
					}
				}
			case 1,4: ;pause
				if ui.waitToggle.value {
				ui.fishStatusText.text := "Retrieve Mechanic: Pause"
					log("Retrieve Mechanic: Pause")
						sleep(1000)
						if !ui.autoFish
							return
					}
				sleep(round(random(1,999)))
			case 5,6,7,8,9,10,11,12: ;reel
				ui.fishStatusText.text := "Retrieve Mechanic: Reel"
				log("Retrieve Mechanic: Reel")
				if !ui.reeledIn
					sendIfWinActive("{space down}",ui.game)
					sleep500(8,1)
					sendIfWinActive("{space up}",ui.game)
			}
	}
	(sleep500(6)) ? exit : 0
	
	if fishCaught() {
		ui.fishLogCount.text += 1
		ui.statFishCount.text := ui.fishLogCount.text
		sendIfWinActive("{space}",ui.game)
		(sleep500(2)) ? exit : 0
		sendIfWinActive("{backspace}",ui.game)
		(sleep500(3)) ? exit : 0
	} else {	
		log("No Fish Detected.")
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
	if (ui.checkReel1 >= 16250871
		&& ui.checkReel2 >= 16250871
		&& ui.checkReel3 >= 16250871
		&& ui.checkReel4 >= 16250871
		&& ui.checkReel5 < 6250871) {
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
	log("Analyzing Catch: " fishCaughtPixel)
	if (fishCaughtPixel >= 16000000) {
		if !(DirExist("./fishPics"))
			DirCreate("./fishPics")
		run("./redist/ss.exe -wt fishingPlanet -o " a_scriptDir "/fishPics/" formatTime(,"yyMMddhhmmss") ".png",,"hide")
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


createGui(*) {
	ui.fishGui := gui()
	ui.fishGui.opt("-caption owner" winGetId(ui.game))
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
	ui.fishStatus := ui.fishGui.addText("x2 y752 w1580 h61 cBBBBBB background" ui.bgColor[1])
	drawButton(2,753,660,60)
	;ui.controlBox := ui.fishGui.addText("x2 y752 w660 h59 background111111")
	;ui.controlBox2 := ui.fishGui.addText("x3 y753 w658 h57 background888888")
	;ui.controlBox3 := ui.fishGui.addText("x4 y754 w656 h55 background111111")
	ui.twitchToggleButton := ui.fishGui.addPicture("section x20 y758 w49 h25 backgroundTrans",(cfg.twitchToggleValue) ? "./img/toggle_on.png" : "./img/toggle_off.png")
	ui.twitchToggleButton.onEvent("click",toggleTwitch)
	ui.twitchToggle := ui.fishGui.addText("x+5 ys+1 w130 h30 backgroundTrans c" ui.fontColor[3],"Twitch [F6]")
	ui.twitchToggle.setFont("s12")
	ui.waitToggleButton := ui.fishGui.addPicture("section x20 y785 w49 h25 backgroundTrans",(cfg.waitToggleValue) ? "./img/toggle_on.png" : "./img/toggle_off.png")
	ui.waitToggleButton.onEvent("click",toggleWait)
	ui.waitToggle := ui.fishGui.addText("section x+5 ys+1 w130 h30 backgroundTrans c" ui.fontColor[3],"Stop n Go [F7]")
	ui.waitToggle.setFont("s12")
	ui.castAdjustBg := ui.fishGui.addText("section x3 ys754 w140 h53 background111111")
	ui.castAdjustBg := ui.fishGui.addText("x194 y755 w138 h53 background111111")
	ui.castAdjustBg := ui.fishGui.addText("x195 y756 w136 h53 background111111")
	ui.castAdjust := ui.fishGui.addSlider("section toolTip background111111 buddy2ui.castAdjustText center x185 y755 w140 h18  range1000-2500",1910)
	ui.castAdjust.onEvent("change",castAdjustChanged)
	ui.castAdjustLabel := ui.fishGui.addText("xs-24 y+2 w80 h40 right backgroundTrans","Cast`nAdjust")
	ui.castAdjustLabel.setFont("s11 c" ui.fontColor[3])
	ui.castAdjustText := ui.fishGui.addText("x+10 ys+20 left w80 h30 backgroundTrans c" ui.fontColor[5],cfg.castAdjust[cfg.profileSelected])
	ui.castAdjustText.setFont("s20")
	castAdjustChanged(*) {
		cfg.castAdjust[cfg.profileSelected] := ui.castAdjust.value
		ui.castAdjustText.text := cfg.castAdjust[cfg.profileSelected]
		ui.profileIcon.focus()
	}
	ui.reelSpeed := ui.fishGui.addSlider("ys+0 x+10 w20 vertical h48 tickInterval1 range1-4 background111111 tooltip c" ui.fontColor[5],cfg.reelSpeed[cfg.profileSelected])
	ui.reelSpeed.onEvent("change",reelSpeedChanged)
	ui.reelSpeedText := ui.fishGui.addText("ys+40 x+-24 center w30 h13 backgroundTrans c" ui.fontColor[5],"Speed")
	ui.dragLevel := ui.fishGui.addSlider("ys+0 x+15 w20 vertical background111111 h48 tickInterval1 range2-12 tooltip c" ui.fontColor[5],cfg.dragLevel[cfg.profileSelected])
	ui.dragLevel.onEvent("change",dragLevelChanged)
	dragLevelChanged(*) {
		cfg.dragLevel[cfg.profileSelected] := ui.dragLevel.value
		ui.statDragLevel.text := ui.dragLevel.value
		ui.dragLevelText.redraw()
		ui.profileIcon.focus()
	}
	reelSpeedChanged(*) {
		cfg.reelSpeed[cfg.profileSelected] := ui.reelSpeed.value
		ui.statReelSpeed.text := ui.reelSpeed.value
		ui.reelSpeedText.redraw()
		ui.profileIcon.focus()
	}
	ui.dragLevelText := ui.fishGui.addText("ys+40 x+-27 center w30 h13 backgroundTrans c" ui.fontColor[5],"Drag")
	ui.profileIcon := ui.fishGui.addPicture("section x415 y762 w240 h42 backgroundTrans","./img/rod.png")
	cfg.profileSelected := iniRead(cfg.file,"Game","ProfileSelected",1)
	ui.profileText := ui.fishGui.addText("x478 y778 w240 h25 c" ui.fontColor[5] " backgroundTrans","Profile #" cfg.profileSelected)
	ui.profileText.setFont("s16","calibri")
	ui.profileIcon.onEvent("click",changeProfile)
	ui.profileText.onEvent("click",changeProfile)
	changeProfile(*) {
		switch cfg.profileSelected {
			case 1:
				cfg.profileSelected := 2
			case 2:
				cfg.profileSelected := 3
			case 3:
				cfg.profileSelected := 1
		}
		ui.dragLevel.value := cfg.dragLevel[cfg.profileSelected]
		ui.reelSpeed.value := cfg.reelSpeed[cfg.profileSelected]
		ui.castAdjust.value := cfg.castAdjust[cfg.profileSelected]
		ui.castAdjustText.text := cfg.castAdjust[cfg.profileSelected]
		ui.profileText.text := "Profile #" cfg.profileSelected
		ui.profileIcon.focus()
	}
	
	drawButton(1101,753,160,60)
	ui.startButtonBg := ui.fishGui.addText("x1103 y755 w156 h56 background111111")
	ui.startButton := ui.fishGui.addText("section x1101 center y765 w160 h60 cC9C9C9 backgroundTrans","Start")
	ui.startButton.setFont("s22","Helvetica")
	ui.startButtonHotkey := ui.fishGui.addText("x+-154 center ys-7 w20 h20 cC9C9C9 backgroundTrans","F3")
	ui.startButtonHotkey.setFont("s12","Helvetica")	
	ui.startButton.onEvent("click",startButtonClicked)
	startButtonClicked(*) {
		winActivate("ahk_exe fishingPlanet.exe")
		autoFishStart()
	}
	
	ui.stopButton := ui.fishGui.addText("section x1101 center y765 w160 h60 cBBBBBB hidden c111111 backgroundTrans","Stop")
	ui.stopButton.setFont("s22","Helvetica")
	ui.stopButtonHotkey := ui.fishGui.addText("x+-154 center ys-7 w20 h20 hidden c111111 backgroundTrans","F4")
	ui.stopButtonHotkey.setFont("s12","Helvetica")	
	ui.stopButton.onEvent("click",autoFishStop)
	
	drawButton(1261,753,160,60)
	ui.reloadButtonBg := ui.fishGui.addText("x1263 y755 w156 h56 background111111")
	ui.reloadButton := ui.fishGui.addText("section center x1261 ys+0 w160 h60 cC9C9C9 backgroundTrans","Reload")
	ui.reloadButton.setFont("s22","Helvetica")
	ui.reloadButtonHotkey := ui.fishGui.addText("x+-154 center ys-7 w20 h20 cC9C9C9 backgroundTrans","F5")
	ui.reloadButtonHotkey.setFont("s12","Helvetica")	
	ui.reloadButton.onEvent("click",appReload)
	
	drawButton(1421,753,160,60)
	ui.exitButtonBg := ui.fishGui.addText("x1423 y755 w156 h56 background111111")
	ui.exitButton := ui.fishGui.addText("section x1421 center ys+0 w160 h60 cC9C9C9 backgroundTrans","Exit")
	ui.exitButton.setFont("s22","Helvetica")	
	ui.exitButtonHotkey := ui.fishGui.addText("x+-154 center ys-7 w20 h20 cC9C9C9 backgroundTrans","F8")
	ui.exitButtonHotkey.setFont("s12","Helvetica")	
	ui.exitButton.onEvent("click",cleanExit)
	ui.fishLogHeader := ui.fishGui.addText("x2 y1 w296 h28 background222222")
	ui.fishLogHeaderSpace := ui.fishGui.addText("x300 y1 w1 h29 background" ui.bgColor[3])
	ui.fishLogHeaderText := ui.fishGui.addText("x10 y2 w300 h28 c353535 backgroundTrans","Activity")
	ui.fishLogHeaderText.setFont("s14 cAAAAAA","Bold")
	ui.fishLogCountLabel := ui.fishGui.addText("x215 y1 w40 h25 backgroundTrans right cAAAAAA"," Fish")
	ui.fishLogCountLabel.setFont("s11","Helvetica")
	ui.fishLogCountLabel2 := ui.fishGui.addText("x215 y12 w40 h25 backgroundTrans right cAAAAAA","Count")
	ui.fishLogCountLabel2.setFont("s11","Helvetica")
	ui.fishLogCount := ui.fishGui.addText("x264 y1 w40 h30 backgroundTrans cc1c1c1",ui.fishCount)
	ui.fishLogCount.setFont("s18","Impact") 
	ui.fishLog := ui.fishGui.addText("x1 y31 w296 h688 background353535")
	ui.fishLog := ui.fishGui.addText("x2 y32 w298 h686 background111111")
	
	ui.fishLogText := ui.fishGui.addListbox("x2 y33 w298 h680 -wrap 0x2000 0x100 -E0x200 background111111",[])
	ui.fishLogText.setFont("s13 c9C9C9C")
	;drawButton(1,721,298,30)
	ui.fishLogFooterOutline := ui.fishGui.addText("x1 y721 w298 h30 background" ui.bgColor[3])
	ui.fishLogFooterOutline2 := ui.fishGui.addText("x2 y722 w296 h28 background" ui.bgColor[1])
	ui.fishLogFooterOutline3 := ui.fishGui.addText("x3 y723 w294 h26 background" ui.bgColor[2])
	ui.fishLogFooter := ui.fishGui.addText("x4 y724 w293 h25 background9C9C9C") ;61823A
	ui.fishStatusText := ui.fishGui.addText("section x5 y723 w220 h23 c333333 backgroundTrans","Ready")
	ui.fishStatusText.setFont("s15","Calibri")
	ui.fishLogTimerOutline := ui.fishGui.addText("x1047 y710 w268 h40 background" ui.bgColor[3])
	ui.fishLogTimerOutline2 := ui.fishGui.addText("x1048 y711 w266 h38 background" ui.bgColor[1])
	ui.fishLogTimerOutline3 := ui.fishGui.addText("x1049 y712 w264 h36 background" ui.bgColor[2])
	ui.fishLogTimer := ui.fishGui.addText("x1050 y713 w263 h35 background3F3F3F") ;61823A
	ui.timerAnim := ui.fishGui.addText("x1047 y710 w268 h40 background010203")
	ui.fishLogAfkTimeLabel := ui.fishGui.addText("hidden section right x1019 y695 w80 h40 c" ui.fontColor[1] " backgroundTrans","AFK")
	ui.fishLogAfkTimeLabel.setFont("s16","Arial")
	ui.fishLogAfkTimeLabel2 := ui.fishGui.addText("hidden section right x1021 y707 w80 h40 c" ui.fontColor[1] " backgroundTrans","Timer")
	ui.fishLogAfkTimeLabel2.setFont("s19","Arial")
	ui.fishLogAfkTime := ui.fishGui.addText("hidden x1110 y688 w200 h60 c" ui.fontColor[1] " backgroundTrans","00:00:00")
	ui.fishLogAfkTime.setFont("s35","Arial")
	; ui.fishLogAfkTimeText1 := ui.fishGui.addText("section right x1048 y714 w80 h40 c" ui.fontColor[2] " backgroundTrans","AFK")
	; ui.fishLogAfkTimeText1.setFont("s16 Bold","Cambria")
	; ui.fishLogAfkTimeText2 := ui.fishGui.addText("section right x1052 y723 w80 h40 c" ui.fontColor[2] " backgroundTrans","Timer")
	; ui.fishLogAfkTimeText2.setFont("s19 Bold","Cambria")
	;ui.fishLogAfkTime2 := ui.fishGui.addText("x1140 y703 w200 h60 c" ui.fontColor[2] " backgroundTrans","00:00:00")
	;ui.fishLogAfkTime2.setFont("s35","Calibri")
	ui.waitToggle.onEvent("click",toggleWait)
	ui.twitchToggle.onEvent("click",toggleTwitch)
;	ui.timerOutline := ui.fishGui.addProgress("x1049 y714 w76 h36 background" ui.trimColor[6] " c010203")

	if winExist(ui.game) {
		winSetTransparent("Off",ui.game)
		winGetPos(&x,&y,&w,&h,ui.game)
	} else {
		exitApp
	}
	sleep(500)
	statPanel()
	ui.fishGui.show("x" x-300 " y" y+-30 " w1584 h814 noActivate")
	loadScreen(false)
	
}
