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

slider(name := random(1,999999),gui := ui.fishGui,x := 0,y := 0,w := 100,h := 20,range := 0-10,tickInterval := 1,default := 1,align := "center",label := "",orient := "",labelAlign := "r") {
	ui.sliderList.push(name)
	cfg.%name% := strSplit(iniRead(cfg.file,"Game",name,"1,1,1,1,1"),",")
	ui.%name% := gui.addSlider("section v" name " x" x " y" y " w" w " h" h " tickInterval" tickInterval " " orient " range" range " " align " toolTip")
	while cfg.profileSelected > cfg.%name%.length {
		cfg.%name%.push(ui.%name%.value)
	}
	ui.%name%.value := cfg.%name%[cfg.profileSelected]
	ui.%name%.onEvent("change",sliderChange)
	if (label)
	switch substr(labelAlign,1,1) {
		case "r":
			ui.%name%Label := gui.addText("x+-4 ys+6 backgroundTrans c" ui.fontColor[4],label)
			ui.%name%Label.setFont("s9")
		case "b":
			ui.%name%Label := gui.addText("xs+3 y+-7 backgroundTrans c" ui.fontColor[4],label)
			ui.%name%Label.setFont("s9")
	}
}

sliderChange(this_slider,*) {
	name := this_slider.name
	ui.tmp%name%Str := ""
	if cfg.%name%.length <= cfg.profileSelected
		cfg.%name%.push(this_slider.value)
	else
	cfg.%name%[cfg.profileSelected] := this_slider.value
	loop cfg.%name%.length {
		ui.tmp%name%Str .= cfg.%name%[a_index] ","
	}
		iniWrite(rtrim(ui.tmp%name%Str,","),cfg.file,"Game",name)
	ui.%name%Label.redraw()
	ui.profileIcon.focus()
}

saveSliderValues(*) {
for this_slider in ui.sliderList {
		if cfg.%this_slider%.length < cfg.profileSelected
			cfg.%this_slider%[cfg.profileSelected] := ui.%this_slider%.value
		else
			cfg.%this_slider%.push(ui.%this_slider%.value)
	}
}
