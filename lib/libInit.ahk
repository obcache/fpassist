#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../fpassist.ahk")
	ExitApp
	Return
}

initValues(*) {
	cfg.file 			:= a_appName ".ini"
	cfg.installDir 		:= a_mydocuments "\" a_appName "\"
	ui.gameExe 			:= "fishingPlanet.exe"
	ui.game 			:= "ahk_exe " ui.gameExe

	cfg.buttons 		:= ["startButton","castButton","retrieveButton","reelButton","cancelButton","reloadButton","exitButton"]
	cfg.profileSettings 	:= ["profileName","castLength","castTime","sinkTime","reelSpeed","dragLevel","twitchFreq","stopFreq","reelFreq","zoomEnabled","floatEnabled","bgModeEnabled"]
	cfg.profileDefaults 	:= ["NewProfile","1900","1","1","1","1","1","1","1","0","0","0"]

	cfg.emptyKeepnet 	:= false
	ui.cancelOperation 	:= false
	ui.isAFK 			:= false
	ui.reeledIn 		:= true
	ui.currDrag 		:= 0
	ui.loadingProgress 	:= 5
	ui.loadingProgress2 := 5
	ui.playAniStep 		:= 0
	

	defaultValue := 0

	for setting in cfg.profileSettings {
		switch setting {
			case "profileName":
				defaultValue := "Profile #1"
			case "castLength":
				defaultValue := "1900"
			case "reelFreq":
				defaultValue := "10"	
		 }
		 cfg.%setting% := strSplit(iniRead(cfg.file,"Game",setting,defaultValue),",")
	}

	cfg.profileSelected 	:= iniRead(cfg.file,"Game","ProfileSelected",1)
	cfg.debug 				:= iniRead(cfg.file,"System","Debug",2)
	cfg.rodCount 			:= iniRead(cfg.file,"Game","RodCount",6)
	cfg.currentRod 			:= iniRead(cfg.file,"Game","CurrentRod",1)

	ui.bgColor 				:= ["202020","333333","666666","C9C9C9","858585","999999"]
	ui.fontColor 			:= ["151415","AAAAAA","DFEFFF","666666","353535","151515"]
	ui.fontColor 			:= ["151415","AAAAAA","FFFFFF","666666","353535","151515"]
	ui.trimColor 			:= ["9595A5","501714","44DDCC","11EE11","EE1111","303030"]
	ui.trimDarkColor 		:= ["242325","2d0f0f","44DDCC","11EE11","EE1111","303030"]
	ui.trimFontColor 		:= ["282828","C09794","44DDCC","11EE11","EE1111","303030"]
	ui.trimDarkFontColor 	:= ["9595A5","9595A5","44DDCC","11EE11","EE1111","303030"]
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
			ui.loadingProgress2.value += 1
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
	winMove(0,0,1280*(a_screenDpi/96),720*(a_screenDpi/96),ui.game)
	sleep(1000)
	ui.loadingProgress.value += 4
	ui.loadingProgress2.value += 4
	winGetPos(&x,&y,&w,&h,ui.game)
	while w != 1280*(a_screenDpi/96) || h != 720*(a_screenDpi/96) {
		sleep(1000)
		if w == a_screenWidth && h == a_screenHeight {
			winActivate("ahk_exe fishingPlanet.exe")
			sendNice("{alt down}{enter}{alt up}")
			sleep(500)
			ui.loadingProgress.value += 2
			ui.loadingProgress2.value += 2
			winMove(0,0,1280*(a_screenDpi/96),720*(a_screenDpi/96),ui.game)
			sleep(500)
			ui.loadingProgress.value += 2
			ui.loadingProgress2.value += 2
			winGetPos(&x,&y,&w,&h,ui.game)
		}
	winSetStyle("-0xC00000",ui.game)
	winSetTransparent(0,ui.game) 
	}
}
