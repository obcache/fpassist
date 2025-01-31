#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

startButtonClicked(*) {
	;toggleOff()
	toggleOn()
	castButtonClicked()
}

stopButtonClicked(*) {
		setTimer () => toggleEnabled(),-10
		setTimer () => send("{capsLock}"),-350
		setTimer () => toggleEnabled(),-550

	
	;toggleOn()
	; ui.autoFish:=false
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
	cast()
	setTimer(startAfk,-100)
}

reelButtonClicked(*) {
	ui.autoFish:=true
	ui.mode:="reel"
	mode(ui.mode)
	ui.fishQ.push(ui.mode)
	;showQ()
	reelIn()
	setTimer(startAfk,-100)
}

showQ(*) {
	ui.qui:=gui()
	ui.qui.opt("toolWindow -caption -border owner" ui.fishGui.hwnd)
	ui.qui.backColor:="454545"
	ui.quiLb:=ui.qui.addListBox("",ui.fishQ)
	ui.qui.show()
}
retrieveButtonClicked(*) {
	ui.autoFish:=true
	ui.mode:="retrieve"
	mode(ui.mode)
	ui.fishQ.push(ui.mode)
	retrieve()
	startAfk()
}

castLengthChanged(*) {
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
	ui.toggleEnabledFS.value:="./img/toggle_horz_on.png"
	ui.toggleEnabledFSLabel.opt("hidden")
	;ui.toggleEnabledFS.move((a_screenWidth*.68)+450)
	ui.toggleEnabledFS.redraw()
	for this_obj in ui.fsObjects 
		this_obj.opt("-hidden")			
	ui.enableButtonToggle.value := "./img/toggle_on.png"
	guiVis(ui.disabledGui,false)
	;startAfk()
}
	
toggleOff(*) {
	;msgBox('toggleOff')
	;setcapsLockState(true)
	ui.toggleEnabledFS.value:="./img/toggle_horz_off.png"
	ui.toggleEnabledFSLabel.opt("-hidden")
	for this_obj in ui.fsObjects 
		this_obj.opt("hidden")
	;ui.toggleEnabledFS.move(a_screenWidth-50,,,)
	ui.toggleEnabledFS.redraw()
	ui.enableButtonToggle.value := "./img/toggle_off.png"
	if !ui.fullscreen {
		guiVis(ui.disabledGui,true)
		winSetTransparent(180,ui.disabledGui)         
	}
	endAfk()
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
		ui.rodHolderEnabled.value := cfg.rodHolderEnabled[cfg.profileSelected]
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

