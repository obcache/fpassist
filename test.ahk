#requires autoHotkey v2.0+
#singleInstance

winActivate("ahk_exe fishingPlanet.exe")
msgBox(round(pixelGetColor(450,575)))
