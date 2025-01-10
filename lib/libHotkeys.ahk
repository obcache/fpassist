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


	
;Boat Steering
	+left::
	+a:: {
		setTimer(turnLeft,3500)
	}
	; ~left::
	; ~a:: {
		; setTimer(turnLeft,0)
	; }
	+right::
	+d:: {
		toggleRight()
	}
	; ~right::
	; ~d:: {
		; setTimer(turnRight,0)
	; }
	
	^w:: {
		setTimer(throttleForward,2500)
	}
	
	~w:: {
		setTimer(throttleForward,0)
	}
	ui.toggleRightEnabled:=false
	toggleRight(*) {
		(ui.toggleRightEnabled:=!ui.toggleRightEnabled)
		? setTimer(turnRight,4500)
		: setTimer(turnRight,0)
	}
	ui.toggleLeftEnabled:=false
	toggleLeft(*) {
		(ui.toggleLeftEnabled:=!ui.toggleLeftEnabled)
		? setTimer(turnLeft,4500)
		: setTimer(turnLeft,0)
	}
	ui.toggleForwardEnabled:=false
	toggleForward(*) {
		(ui.toggleForwardEnabled:=!ui.toggleForwardEnabled)
		? setTimer(throttleForward,2500)
		: setTimer(throttleForward,0)
	}
	ui.toggleBackwardEnabled:=false
	toggleBackward(*) {
		(ui.toggleBackwardEnabled:=!ui.toggleBackwardEnabled)
		? setTimer(throttleBackward,2500)
		: setTimer(throttleBackward,0)
	}
	
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
		sendPlay("{d down}")
		sleep(2500)
		sendPlay("{d up}")
	}

turnRight(*) {
		sendEvent("{d down}")
		sleep(2500)
		sendEvent("{d up}")
	}
;END Boat Steering

hotIf()

hotIfWinActive(ui.game)
	hotkey("~CapsLock",toggleEnabled)
hotIf()


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


