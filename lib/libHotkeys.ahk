#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

a_fileName:="libHotkeys.ahk"

if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

hotif(isHot)

	^+l:: {
		ui.autoFish:=true
		landFish()
	}

	hotkey("~shift",shiftDown)
	;hotkey("~shift up",shiftUp)
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


ui.toggleRightEnabled:=false
ui.toggleLeftEnabled:=false
ui.toggleForwardEnabled:=false
ui.toggleBackwardEnabled:=false

hotIfWinActive(ui.game)	
	;Boat Steering
	
	+a:: {
		setTimer(turnLeft,3500)
	}
	
	~a:: {
		setTimer(turnLeft,0)
	}

	+d:: {
		toggleRight()
	}
	
	~d:: {
		 setTimer(turnRight,0)
	}
	
	+w:: {
		setTimer(throttleForward,2500)
	}
	
	~w:: {
		setTimer(throttleForward,0)
	}


	toggleRight(*) {
		(ui.toggleRightEnabled:=!ui.toggleRightEnabled)
		? setTimer(turnRight,4500)
		: setTimer(turnRight,0)
	}
	toggleLeft(*) {
		(ui.toggleLeftEnabled:=!ui.toggleLeftEnabled)
		? setTimer(turnLeft,4500)
		: setTimer(turnLeft,0)
	}
	toggleForward(*) {
		(ui.toggleForwardEnabled:=!ui.toggleForwardEnabled)
		? setTimer(throttleForward,2500)
		: setTimer(throttleForward,0)
	}
	toggleBackward(*) {
		(ui.toggleBackwardEnabled:=!ui.toggleBackwardEnabled)
		? setTimer(throttleBackward,2500)
		: setTimer(throttleBackward,0)
	}
	
	throttleForward(*) {
		if ui.enabled {
			send("{w down}")
			sleep(750)
			send("{w up}")
			sleep(500)
			send("{s down}")
			sleep(750)
			send("{s up}")
			sleep(500)
		}
	}

	turnLeft(*) {
		if ui.enabled {
			sendEvent("{left down}")
			sleep(2500)
			sendEvent("{left up}")
		}
	}

	turnRight(*) {
		if ui.enabled {
			sendEvent("{right down}")
			sleep(2500)
			sendEvent("{right up}")
		}
	}
	;END Boat Steering
	
	hotkey("~CapsLock",toggleEnabled)

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


