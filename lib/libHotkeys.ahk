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

	;hotkey("LShift",shiftDown)
	;hotkey("~shift up",shiftUp)
	hotkey("~f",stopFlashLightFlash)
	hotkey("^+f",toggleFlashlightFlash)
	hotKey(ui.exitKey,cleanExit)
	hotKey(ui.reloadKey,appReload)
	hotKey(ui.startKeyMouse,startButtonClicked)
	
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
hotIf()

ui.toggleRightEnabled:=false
ui.toggleLeftEnabled:=false
ui.toggleForwardEnabled:=false
ui.toggleBackwardEnabled:=false

~!Tab:: {
	sleep(500)
	(winActive(ui.game))
		? setCapslockState(ui.prevState)
		: 	(ui.prevState:=getKeyState("capslock"))
				? setCapslockState(false)
				: 0	
}

#hotIf WinActive(ui.game)	
	;Boat Steering
	XButton2::LAlt
	XButton1::LCtrl
	MButton::r
	!RButton:: {
		stopButtonClicked()
	}
	capsLock:: {
		toggleEnabled()
	}
	
	+a:: {
		setTimer(turnLeft,4000)
		turnLeft()
	}
	
	~a:: {
		setTimer(turnLeft,0)
		setTimer(turnRight,0)
		setTimer(throttleForward,0)
	}

	+d:: {
		setTimer(turnRight,4000)
		turnRight()
	}
	
	~d:: {
		setTimer(turnLeft,0)
		setTimer(turnRight,0)
		setTimer(throttleForward,0)
	}
	
	+w:: {
		setTimer(throttleForward,2500)
		throttleForward()
	}
	
	~w:: {
		setTimer(turnLeft,0)
		setTimer(turnRight,0)
		setTimer(throttleForward,0)
	}

	^WheelUp:: {
		if !getKeyState("RButton") {
			send("{wheelUp}")
			return
		}
		if ui.currentRod  > 1
			ui.currentRod -= 1
		else
			ui.currentRod := 7
		sendIfWinActive("{" ui.currentRod "}",ui.game)
	}
	^WheelDown:: {
		if !getKeyState("RButton") {
			send("{WheelDown}")
			return
		}
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
	
~RButton & WheelUp:: {
		sendIfWinActive("{LShift Down}",ui.game,true)
		sleep(200)
		sendIfWinActive("{3}",ui.game,true)
		sleep(200)
		sendIfWinActive("{LShift Up}",ui.game,true)
	}
	
~RButton & WheelDown:: {
		sendIfWinActive("{LShift Down}",ui.game,true)
		sleep(200)
		sendIfWinActive("{4}",ui.game,true)
		sleep(200)
		sendIfWinActive("{LShift Up}",ui.game,true)
	}
	


#hotIf

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
