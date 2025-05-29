a_appName := "fpassist"

#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../" a_appName ".ahk")
	; ExitApp
	Return
}

slider(name := random(1,999999),gui := ui.fishGui,x := 0,y := 0,w := 100,h := 20,range := 0-10,tickInterval := 1,default := 1,align := "center",label := "",orient := "",labelAlign := "r",fontSize := "9") {
	ui.sliderList.push(gui.name "_" name)
	varName:= name
	cfg.%varName% := strSplit(iniRead(cfg.file,"Game",name,"1,1,1,1,1"),",")
	;msgBox(gui.name)
	ui.%gui.name%_%name% := gui.addSlider("section v" name " x" x " y" y " w" w " h" h " background" ui.bgColor[3] " tickInterval" tickInterval " " orient " range" range " " align " toolTip")
	while cfg.profileSelected > cfg.%varname%.length {
		cfg.%varName%.push(ui.%gui.name%_%name%.value)
	}
	ui.%gui.name%_%name%.value := cfg.%varName%[cfg.profileSelected]
	ui.%gui.name%_%name%.onEvent("change",sliderChange)  
	if (label)
	switch substr(labelAlign,1,1) {
		case "r":
			ui.%gui.name%_%name%Label := gui.addText("x+-2 ys+6 w60 backgroundTrans c" ui.fontColor[2],label)
			ui.%gui.name%_%name%Label.setFont("s" fontSize-2)
		case "b":
			if orient=="vertical" {
				ui.%gui.name%_%name%Label := gui.addText("xs+3 y+-7 backgroundTrans c" ui.fontColor[2],label)
			} else {
				ui.%gui.name%_%name%label := gui.addText("xs-3 y+1 w" w " backgroundTrans " align " c" ui.fontColor[2],label)
			}
			ui.%gui.name%_%name%Label.setFont("s" fontSize)
		case "l":
			ui.%gui.name%_%name%Label := gui.addText("right x+-" w+62 " ys+4 w62 h15 backgroundTrans c" ui.fontColor[2],label)
			ui.%gui.name%_%name%Label.setFont("s" fontSize-2)		
	} 
}

sliderChange(this_slider,*) {
	name := this_slider.name
	gui := this_slider.gui
	ui.tmp%name%Str := ""
	if cfg.%name%.length <= cfg.profileSelected
		cfg.%name%.push(this_slider.value)
	else
		cfg.%name%[cfg.profileSelected] := this_slider.value
	ui.%gui.name%_%this_slider.name%Label.redraw()
	iniWrite(cfg.%name%[cfg.profileSelected],cfg.file,"Game",name)
	ui.fpBg.focus()
}

saveSliderValues(*) {
for this_slider in ui.sliderList {
	try {
		gui := ui.%this_slider%.gui
		if cfg.%strSplit(this_slider,"_")[2]%.length < cfg.profileSelected
			cfg.%strSplit(this_slider,"_")[2]%[cfg.profileSelected] := ui.%this_slider%.value
		else
			cfg.%strSplit(this_slider,"_")[2]%.push(ui.%this_slider%.value)
	}
	}
}
