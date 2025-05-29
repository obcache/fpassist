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
	if getKeyState("capslock") {
		setTimer () => toggleOff(), -100
		setTimer () => send("{capsLock}"),-350
		setTimer () => toggleOn(),-550 
	} else 
		setTimer () => toggleOn(), -100
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

castButtonClicked(*) {
	ui.enabled:=true
	ui.mode:="cast"
	mode(ui.mode)
	setTimer(startAfk,-100)
}

reelButtonClicked(*) {
	ui.mode:="reel"
	mode(ui.mode)
	ui.fishQ.push(ui.mode)
	;showQ()
	reelIn()
	setTimer(startAfk,-100)
}


retrieveButtonClicked(*) {
	mode("retrieve")
	;ui.fishQ.push(ui.mode)
	;retrieve()
	startAfk("retrieve")
}

editorCastLengthChanged(*) {
		while cfg.profileSelected > cfg.castLength.Length
			cfg.castLength.push("2000")
		
		cfg.castLength[cfg.profileSelected] := ui.editorGui_castLength.value
		ui.editorGui_castLengthText.text := cfg.castLength[cfg.profileSelected]
		ui.profileIcon.focus()
}

CastLengthChanged(*) {
		while cfg.profileSelected > cfg.castLength.Length
			cfg.castLength.push("2000")
		
		cfg.castLength[cfg.profileSelected] := ui.castLength.value
		ui.castLengthText.text := cfg.castLength[cfg.profileSelected]
		ui.profileIcon.focus()
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

toggleOn(*) {
	;msgBox('toggleOn')
	;setcapsLockState(true)
	ui.toggleEnabledFS.value:="./img/toggle_on.png"
	ui.toggleEnabledFSLabel.opt("hidden")
	;ui.toggleEnabledFS.move((a_screenWidth*.68)+450)
	ui.toggleEnabledFS.redraw()
	for this_obj in ui.fsObjects 
		this_obj.opt("-hidden")
	ui.toggleLabel.opt("hidden")
	ui.toggleLabelBg.opt("hidden")
	ui.toggleLabelOutline.opt("hidden")
	ui.enableButtonToggle.value := "./img/toggle_on.png"
	guiVis(ui.disabledGui,false)
	; ui.fishCountIcon.opt("-hidden")
	; ui.fishCount1.opt("-hidden")
	; ui.fishCount2.opt("-hidden")
	; ui.fishCount3.opt("-hidden")
	; ui.fishCount4.opt("-hidden")
	; ui.fishCount5.opt("-hidden")
	; ui.fishCountIcon.opt("-hidden")
	ui.bigfishCount.opt("-hidden")
	ui.bigfishCountLabel.opt("-hidden")
	ui.bigfishCountLabel2.opt("-hidden")
	ui.fishLogAfkTime.opt("-hidden")
	ui.fishLogAfkTimeLabel.opt("-hidden")
	ui.fishLogAfkTimeLabel2.opt("-hidden")
	if ui.editorVisible
		guiVis(ui.editorGui,true)
	
	;startAfk()
}
	
toggleOff(*) {
	;msgBox('toggleOff')
	;setcapsLockState(true)
	if ui.editorVisible
		guiVis(ui.editorGui,false)
	ui.toggleEnabledFS.value:="./img/toggle_off.png"
	;ui.toggleEnabledFSLabel.opt("-hidden")
	ui.toggleLabel.opt("-hidden")
	ui.toggleLabelBg.opt("-hidden")
	ui.toggleLabelOutline.opt("-hidden")
	ui.fishCountText.opt("+hidden")
	; ui.fishCount1.opt("+hidden")
	; ui.fishCount2.opt("+hidden")
	; ui.fishCount3.opt("+hidden")
	; ui.fishCount4.opt("+hidden")
	; ui.fishCount5.opt("+hidden")
	; ui.fishCountIcon.opt("+hidden")
	; ui.fishCountLabelFS.opt("+hidden")
	; ui.fishCountLabel2FS.opt("+hidden")
	ui.fishLogAfkTime.opt("+hidden")
	ui.fishLogAfkTimeLabel.opt("+hidden")
	ui.fishLogAfkTimeLabel2.opt("+hidden")
	ui.bigfishCount.opt("+hidden")
	ui.bigfishCountLabel.opt("+hidden")
	ui.bigfishCountLabel2.opt("+hidden")
	for this_obj in ui.fsObjects 
		this_obj.opt("hidden")
	;ui.toggleEnabledFS.move(a_screenWidth-50,,,)
	ui.toggleEnabledFS.redraw()
	ui.enableButtonToggle.value := "./img/toggle_off.png"
	if !ui.fullscreen {
		guiVis(ui.disabledGui,true)
		winSetTransparent(180,ui.disabledGui)         
	}
	log("AFK: Stopped")
	endAfk()
}

updateControls(*) {
	
	try
		ui.editorGui_CastLengthText.text:=cfg.castLength[cfg.profileSelected]
	try
		ui.editorGui_reelSpeed.value:=cfg.reelSpeed[cfg.profileSelected]
	try
		ui.editorGui_dragLevel.value:=cfg.dragLevel[cfg.profileSelected]
	try	
		ui.editorGui_twitchFreq.value:=cfg.twitchFreq[cfg.profileSelected]
	try
		ui.editorGui_stopFreq.value:=cfg.stopFreq[cfg.profileSelected]
	try
		ui.editorGui_castTime.value:=cfg.castTimer[cfg.profileSelected]
	try
		ui.editorGui_sinkTim.value:=cfg.sinkTime[cfg.profileSelected]
	try
		ui.editorGui_recastTime.value:=cfg.recastTimer[cfg.profileSelected]
	try
		ui.editorGui_reelFreq.value:=cfg.reelFreq[cfg.profileSelected]
	try
		ui.editorGui_rodHolderEnabled.value:=cfg.rodHolderEnabled[cfg.profileSelected]
	try
		ui.editorGui_floatEnabled.value :=cfg.floatEnabled[cfg.profileSelected]
	try
		ui.editorGui_profileText.text := cfg.profileName[cfg.profileSelected]

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
		ui.fishGuiFS_rodHolderEnabled.value := cfg.rodHolderEnabled[cfg.profileSelected]
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
		ui.fishGui_rodHolderEnabled.value := cfg.rodHolderEnabled[cfg.profileSelected]
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
	ui.profileNum.text := "Profile[" cfg.profileSelected "/" cfg.profileName.length "]"
	try 
		ui.profileIcon.focus()
}

profileLArrowClicked(*) {
	saveSliderValues()
	if cfg.profileSelected > 1
		cfg.profileSelected -= 1
	else
		cfg.profileSelected := cfg.profileName.Length
	
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
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
	ui.profileText.text := cfg.profileName[cfg.profileSelected]
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
			cfg.rodHolderEnabled.removeAt(cfg.profileSelected)

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
			ui.rodHolderEnabled.value := cfg.rodHolderEnabled[cfg.profileSelected]
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
	ui.editProfileEdit := ui.editProfileGui.addEdit("x0 y0 w209 center h23 background" ui.bgColor[3] " -multi -wantReturn -wantTab limit -wrap -theme c" ui.fontColor[3],cfg.profileName[cfg.profileSelected])
	ui.editProfileEdit.setFont("s12","calibri")	
	ui.profileText.opt("hidden")
	ui.profileNewButton.opt("hidden")
	ui.profileEditButton.opt("hidden")
	ui.profileDeleteButton.opt("hidden")
	ui.profileSaveButton.opt("-hidden")
	ui.profileSaveCancelButton.opt("-hidden")
	ui.editProfileEdit.onEvent("escape",cancelEditProfileName)
	winGetPos(&x,&y,&w,&h,ui.fishGui)
	ui.editProfileGui.show("x" ui.profilePos["x"]+27 " y" ui.profilePos["y"]+4 " w208 h22")
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

