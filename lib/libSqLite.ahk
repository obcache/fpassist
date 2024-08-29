;sqlite test
#Requires AutoHotKey v2.0+
#SingleInstance


#include <Class_SQLiteDB>

SetWorkingDir(A_ScriptDir)

ncontrol := object()

db := SQLiteDB()


 

/* CREATE TABLE keybindProfile (
   KeybindProfileNum INTEGER PRIMARY KEY,
   KeybindProfileName TEXT,
   KeybindProfileDescription TEXT
); */