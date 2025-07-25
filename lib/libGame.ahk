#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

startButtonClicked(*) {
	ui.enabled:=true
	ui.mode:="retrieve"
	mode(ui.mode)
	setTimer(startAfk,-100)
}

stopButtonClicked(*) {
	setTimer () => toggleOff(), -100
	setTimer () => send("{capsLock}"),-350
	setTimer () => toggleOn(),-550 
	ui.mode:="off"	 
	;toggleOn()
	; ui.mode:="off"
	; mode(ui.mode)
	; ui.toggleEnabledFS.move(a_screenWidth-50,,,)
	; ui.toggleEnabledFS.redraw()
	; ui.enableButtonToggle.value := "./img/toggle_off.png"
	; if !ui.fullscreen {
		; guiVis(ui.disabledGui,true)
		; winSetTransparent(180,ui.disabledGui)
	; }
	; sleep(1000)
	; setcapsLockState(true)
	; killAfk() 
	; exit
}

startTask(mode) {
	ui.enabled:=true
	mode(mode)
	setTimer () => startAfk(mode),-100
}

castButtonClicked(*) {
	ui.enabled:=true
	mode("cast")
	setTimer () => startAfk("cast"),-100
}

reelButtonClicked(*) {
	mode("reel")
	reelIn()
	setTimer () => startAfk("reel"),-100
}


retrieveButtonClicked(*) {
	mode("retrieve")
	setTimer () => startAfk("retrieve"),-100
}

editorCastLengthChanged(*) {
		while cfg.profileSelected > cfg.castLength.Length
			cfg.castLength.push("2250")
		
		cfg.castLength[cfg.profileSelected] := ui.fs_castLength.value
		ui.fs_castLengthText.text := cfg.castLength[cfg.profileSelected]
		ui.profileSelectedFS.focus()
}

CastLengthChanged(*) {
		while cfg.profileSelected > cfg.castLength.Length
			cfg.castLength.push("2250")
		
		cfg.castLength[cfg.profileSelected] := ui.castLength.value
		ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
		ui.profileSelectedFS.focus()
}

appReload(*) {
	reload()
}


rodsIn(*) {
	sleep(500)
	send("{i}")
	sleep(500)
	mouseMove(125,120)
	send("{LButton Down}")
	sleep(150)
	send("{LButton Up}")
	sleep(250)
	
	mouseMove(255,550)
	sleep(100)
	send("{LButton Down}")
	sleep(150)
	send("{LButton Up}")	
	sleep(250)
	
	mouseMove(255,615)
	sleep(100)
	send("{LButton Down}")
	sleep(150)
	send("{LButton Up}")	
	sleep(250)

	send("{i}")
	sleep(250)
	
	mouseMove(155,550)
	send("{LButton Down}")
	sleep(150)
	send("{LButton Up}")
	sleep(250)
	
	mouseMove(155,615)
	sleep(100)
	send("{LButton Down}")
	sleep(150)
	send("{LButton Up}")	
}


toggleEnabled(*) {
	(ui.enabled := !ui.enabled) 
		? toggleOn() 
		: toggleOff()
}

ui.paused:=false
pauseOff(*) {

	for this_obj in ui.fsObjects 
		this_obj.opt("-hidden")
	ui.toggleLabel.opt("hidden")
	ui.toggleLabelBg.opt("hidden")
	ui.toggleLabelOutline.opt("hidden")
	;guiVis(ui.disabledGui,false)
	if ui.editorVisible
		guiVis(ui.editorGui,true)
}

toggleOn(*) {
	ui.enabled:=true
	setTimer () => startAfk("Cast"),-100
	; ui.toggleEnabledFS.value:="./img/toggle_horz_on.png"
	; ui.toggleEnabledFSLabel.opt("hidden")
	; ui.toggleEnabledFS.redraw()
}

toggleOff(*) {
	ui.enabled:=false
	mode("Off")
	log("AFK: Stopped")	
	setTimer(killAfk,-100)
	; ui.toggleEnabledFS.value:="./img/toggle_horz_off.png"
	; ui.toggleEnabledFS.redraw()

}
	
pauseOn(*) {
	if ui.editorVisible
		guiVis(ui.editorGui,false)
	ui.toggleLabel.opt("-hidden")
	ui.toggleLabelBg.opt("-hidden")
	ui.toggleLabelOutline.opt("-hidden")
	ui.fishCountText.opt("+hidden")
	; ui.fishLogAfkTime.opt("+hidden")
	; ui.fishLogAfkTimeLabel.opt("+hidden")
	; ui.fishLogAfkTimeLabel2.opt("+hidden")
	; ui.bigfishCount.opt("+hidden")
	; ui.bigfishCountLabel.opt("+hidden")
	; ui.bigfishCountLabel2.opt("+hidden")
	for this_obj in ui.fsObjects 
		this_obj.opt("hidden")

	toggleOff()
	killAfk()
}

updateControls(*) {
	
	try
		ui.fs_CastLengthText.text:=cfg.castLength[cfg.profileSelected]
		try
		ui.fs_reelSpeed.value:=cfg.reelSpeed[cfg.profileSelected]
	try
		ui.fs_dragLevel.value:=cfg.dragLevel[cfg.profileSelected]
	try	
		ui.fs_twitchFreq.value:=cfg.twitchFreq[cfg.profileSelected]
	try
		ui.fs_stopFreq.value:=cfg.stopFreq[cfg.profileSelected]
	try
		ui.fs_castTime.value:=cfg.castTimer[cfg.profileSelected]
	try
		ui.fs_sinkTim.value:=cfg.sinkTime[cfg.profileSelected]
	try
		ui.fs_recastTime.value:=cfg.recastTimer[cfg.profileSelected]
	try
		ui.fs_reelFreq.value:=cfg.reelFreq[cfg.profileSelected]
	try
		ui.fs_keepnetEnabled.value:=cfg.keepnetEnabled[cfg.profileSelected]
	try
		ui.fs_floatEnabled.value :=cfg.floatEnabled[cfg.profileSelected]
	try
		ui.fs_profileText.text := cfg.profileName[cfg.profileSelected]

	try 
		ui.fishGuiFS_twitchFreq.value := cfg.twitchFreq[cfg.profileSelected]
	try 
		ui.fishGuiFS_stopFreq.value := cfg.stopFreq[cfg.profileSelected]
	try 
		ui.fishGuiFS_dragLevel.value := cfg.dragLevel[cfg.profileSelected]
	try 
		ui.fishGuiFS_reelSpeed.value := cfg.reelSpeed[cfg.profileSelected]
	try 
		ui.fishGuiFS_castTime.value := cfg.castTime[cfg.profileSelected]
	try 
		ui.fishGuiFS_sinkTime.value := cfg.sinkTime[cfg.profileSelected]
	try
		ui.fishGuiFS_keepnetEnabled.value := cfg.keepnetEnabled[cfg.profileSelected]
	try
		ui.fishGuiFS_floatEnabled.value := cfg.floatEnabled[cfg.profileSelected]
	try
		ui.fishGuiFS_castLength.value := cfg.castLength[cfg.profileSelected]
	try 
		ui.fishGuiFS_castLengthText.text := cfg.castLength[cfg.profileSelected]
	try
		ui.fishGuiFS_bgModeEnabled.value := cfg.bgModeEnabled[cfg.profileSelected]
	try 
		ui.fishGuiFS_profileText.text := cfg.profileName[cfg.profileSelected]
	
	
	try 
		ui.fishGui_twitchFreq.value := cfg.twitchFreq[cfg.profileSelected]
	try 
		ui.fishGui_stopFreq.value := cfg.stopFreq[cfg.profileSelected]
	try 
		ui.fishGui_dragLevel.value := cfg.dragLevel[cfg.profileSelected]
	try 
		ui.fishGui_reelSpeed.value := cfg.reelSpeed[cfg.profileSelected]
	try 
		ui.fishGui_castTime.value := cfg.castTime[cfg.profileSelected]
	try 
		ui.fishGui_sinkTime.value := cfg.sinkTime[cfg.profileSelected]
	try
		ui.fishGui_keepnetEnabled.value := cfg.keepnetEnabled[cfg.profileSelected]
	try
		ui.fishGui_floatEnabled.value := cfg.floatEnabled[cfg.profileSelected]
	try
		ui.fishGui_castLength.value := cfg.castLength[cfg.profileSelected]
	try 
		ui.fishGui_castLengthText.text := cfg.castLength[cfg.profileSelected]
	try
		ui.fishGui_bgModeEnabled.value := cfg.bgModeEnabled[cfg.profileSelected]
	try 
		ui.fishGui_profileText.text := cfg.profileName[cfg.profileSelected]
	try
		ui.profileNum.text := "Profile[" cfg.profileSelected "/" cfg.profileName.length "]"
	try 
		ui.profileSelectedFS.focus()
}

profileLArrowClicked(*) {
	saveSliderValues()
	if cfg.profileSelected > 1
		cfg.profileSelected -= 1
	else
		cfg.profileSelected := cfg.profileName.Length
	
	;ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileSelectedFS.text := cfg.profileName[cfg.profileSelected]
	for setting,default in cfg.profileSetting {
		while cfg.%setting%.length < cfg.profileName.length
			cfg.%setting%.push(default)
	}
	updateControls()
}

profileRArrowClicked(*) {
	saveSliderValues()
	if cfg.profileSelected < cfg.profileName.length
		cfg.profileSelected += 1
	else
		cfg.profileSelected := 1
	;ui.profileText.text := cfg.profileName[cfg.profileSelected]
	ui.profileSelectedFS.text := cfg.profileName[cfg.profileSelected]
	for setting,default in cfg.profileSetting {
		while cfg.%setting%.length < cfg.profileName.length
			cfg.%setting%.push(default)
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
			cfg.keepnetEnabled.removeAt(cfg.profileSelected)

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
			ui.keepnetEnabled.value := cfg.keepnetEnabled[cfg.profileSelected]
		try
			ui.bgModeEnabled.value := cfg.bgModeEnabled[cfg.profileSelected]
	} else {
		notifyOSD("Can't Delete Only Profile",ui.profileText)
		;msgBox("Can't Delete Only Profile")
	}
	
}

deleteProfileNameFS(*) {
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
			cfg.keepnetEnabled.removeAt(cfg.profileSelected)

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
			ui.keepnetEnabled.value := cfg.keepnetEnabled[cfg.profileSelected]
		try
			ui.bgModeEnabled.value := cfg.bgModeEnabled[cfg.profileSelected]
	} else {
		notifyOSD("Can't Delete Only Profile")
		;msgBox("Can't Delete Only Profile")
	}
	profileRArrowClicked()
	profileLArrowClicked()
}

editProfileName(*) {
	ui.editProfileGui := gui()
	ui.editProfileGui.opt("-border -caption owner" winGetId(ui.game))
	ui.editProfileBg := ui.editProfileGui.addText("x0 y0 w210 h30 background" ui.trimColor[6])
	ui.editProfileEdit := ui.editProfileGui.addEdit("x0 y0 w209 center h23 background" ui.bgColor[3] " -multi -wantReturn -wantTab limit -wrap -theme c" ui.fontColor[3],cfg.profileName[cfg.profileSelected])
	ui.editProfileEdit.setFont("s12","calibri")	
	ui.profileText.opt("hidden")
	ui.profileNewButton.opt("hidden")
	ui.profileEditButton.opt("hidden")
	ui.profileDeleteButton.opt("hidden")
	ui.profileSaveButton.opt("-hidden")
	ui.profileSaveCancelButton.opt("-hidden")
	ui.fishGuiFS.onEvent("Escape",cancelEditProfileName)
	winGetPos(&x,&y,&w,&h,ui.fishGui)
	ui.editProfileGui.show("x" ui.fsIcons.x[a_screenwidth]+130 " y" ui.fsIcons.y[a_screenwidth]+3 " w340 h28")
	
	;ui.profilePos["x"]+27 " y" ui.profilePos["y"]+4 " w208 h22")
	ui.editProfileEdit.focus()
}

newProfileName(*) {
	for setting,default in cfg.profileSetting {
		cfg.%setting%.insertAt(cfg.profileSelected,default)
	}
	cfg.profileName[cfg.profileSelected] := "Profile #" cfg.profileName.length
	updateControls()
	editProfileName()
}

saveProfileName(*) {
	cfg.profileName[cfg.profileSelected] := ui.editProfileEdit.text
	ui.profileSelectedFS.text := cfg.profileName[cfg.profileSelected]
	ui.profileSelectedFS.opt("-hidden")
	ui.fs_profileSaveButton.opt("hidden")
	ui.fs_profileSaveCancelButton.opt("hidden")
	ui.fs_profileEditButton.opt("-hidden")
	ui.fs_profileNewButton.opt("-hidden")
	ui.fs_profileDeleteButton.opt("-hidden")
	try
		ui.editProfileGui.destroy()
}

cancelEditProfileName(*) {
	cfg.profileName[cfg.profileSelected] := ui.profileSelectedFS.text 
	try
		ui.editProfileGui.destroy()
	ui.profileSelectedFS.opt("-hidden")
	ui.fs_profileSaveButton.opt("hidden")
	ui.fs_profileSaveCancelButton.opt("hidden")
	ui.fs_profileEditButton.opt("-hidden")
	ui.fs_profileNewButton.opt("-hidden")
	ui.fs_profileDeleteButton.opt("-hidden")
	
}

editProfileNameFS(*) {
	ui.editProfileGui := gui()
	ui.editProfileGui.opt("-border -caption owner" ui.fishGuiFS.hwnd)
	ui.editProfileBg := ui.editProfileGui.addText("x0 y0 w350 h28 background" ui.trimColor[6])
	ui.editProfileEdit := ui.editProfileGui.addEdit("x0 y1 w350 center h26 background" ui.bgColor[3] " -multi -wantReturn -wantTab limit -wrap -theme c" ui.fontColor[3],cfg.profileName[cfg.profileSelected])
	ui.editProfileEdit.setFont("s14","calibri")	
	ui.profileSelectedFS.opt("hidden")
	ui.fs_profileNewButton.opt("hidden")
	ui.fs_profileEditButton.opt("hidden")
	ui.fs_profileDeleteButton.opt("hidden")
	ui.fs_profileSaveButton.opt("-hidden")
	ui.fs_profileSaveCancelButton.opt("-hidden")
	ui.fishGuiFS.onEvent("Escape",cancelEditProfileName)
	winGetPos(&x,&y,&w,&h,ui.fishGuiFS)
	ui.fsIcons.x := map(3440,2630,2560,1800,1920,1164)
	ui.fsIcons.y := map(3440,6,2560,5,1920,1)
	ui.editProfileGui.show("x" ui.fsIcons.x[a_screenwidth]+130 " y" ui.fsIcons.y[a_screenwidth]+6 " w340 h28")
	;ui.editProfileGui.show("center x" ui.fsIcons.x[a_screenwidth]+355+x " y" ui.fsIcons.y[a_screenwidth]+30 " w350 h26")
	ui.editProfileEdit.focus()
	ui.editProfileNameActive:=true
}

ui.editProfileNameActive:=false

editProfileNameActive(*) {
	return ui.editProfileNameActive
}

hotIf(editProfileNameActive)
	hotkey("Enter",saveProfileNameFS)
	hotkey("Esc",cancelEditProfileNameFS)
hotIf()

newProfileNameFS(*) {
	for setting,default in cfg.profileSetting {
		cfg.%setting%.insertAt(cfg.profileSelected,default)
	}
	cfg.profileName[cfg.profileSelected] := "Profile #" cfg.profileName.length
	updateControls()
	editProfileNameFS()
}

saveProfileNameFS(*) {
	cfg.profileName[cfg.profileSelected] := ui.editProfileEdit.text
	ui.profileSelectedFS.text := cfg.profileName[cfg.profileSelected]
	ui.profileSelectedFS.opt("-hidden")
	ui.fs_profileSaveButton.opt("hidden")
	ui.fs_profileSaveCancelButton.opt("hidden")
	ui.fs_profileEditButton.opt("-hidden")
	ui.fs_profileNewButton.opt("-hidden")
	ui.fs_profileDeleteButton.opt("-hidden")
	try
		ui.editProfileGui.destroy()
	ui.editProfileNameActive:=false
}

cancelEditProfileNameFS(*) {
	cfg.profileName[cfg.profileSelected] := ui.profileSelectedFS.text 
	try
		ui.editProfileGui.destroy()
	ui.profileSelectedFS.opt("-hidden")
	ui.fs_profileSaveButton.opt("hidden")
	ui.fs_profileSaveCancelButton.opt("hidden")
	ui.fs_profileEditButton.opt("-hidden")
	ui.fs_profileNewButton.opt("-hidden")
	ui.fs_profileDeleteButton.opt("-hidden")
	ui.editProfileNameActive:=false
}
