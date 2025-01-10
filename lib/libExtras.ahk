#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

a_fileName:="libExtras.ahk"

if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}



{ ;extra features
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
}

