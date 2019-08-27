#Persistent
#SingleInstance

SetCapsLockState("AlwaysOff")
HotKey("Capslock", (*) => CapsEscCtrl())
CapsEscCtrl() {
	currentTime := A_Now
	Send ("{Blind}{LControl Down}")
	while (GetKeyState("Capslock", "P")) {
		Sleep(1)
	}
	Send ("{LControl Up}")
	if (A_PriorKey = "Capslock" and (A_Now - currentTime) < 2) {
		Send ("{Esc}")
	}
	SetCapsLockState("AlwaysOff")
}
Hotkey("~LShift & ~RShift", (*) => SetCapsLockState("AlwaysOn"))
Hotkey("~RShift & ~LShift", (*) => SetCapsLockState("AlwaysOn"))
Hotkey("~LShift", (*) => SetCapsLockState("AlwaysOff"))
Hotkey("~RShift", (*) => SetCapsLockState("AlwaysOff"))