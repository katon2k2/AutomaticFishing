### size: 960x540 ###
#include "Library\ImageSearch.au3"
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <AutoItConstants.au3>
#include <ComboConstants.au3>
#include <WinAPI.au3>
#include <Color.au3>

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("AUTO by KATON", 363, 273, 192, 124)
$Group1 = GUICtrlCreateGroup("", 8, 0, 345, 153)
$Label1 = GUICtrlCreateLabel("tên cửa sổ", 56, 19, 53, 17)
$tbNameWindow = GUICtrlCreateInput("", 120, 16, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $WS_BORDER), BitOR($WS_EX_CLIENTEDGE, $WS_EX_STATICEDGE))
$btnAdjust = GUICtrlCreateButton("căn chỉnh", 24, 48, 83, 41)
$btnComplete = GUICtrlCreateButton("hoàn tất", 24, 96, 83, 41)

$Group2 = GUICtrlCreateGroup("", 120, 40, 121, 97)
$btnUp = GUICtrlCreateButton("🠽", 165, 50, 30, 30)
GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
$btnDown = GUICtrlCreateButton("🠿", 165, 102, 30, 30)
GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
$btnLeft = GUICtrlCreateButton("🠼", 135, 75, 30, 30)
GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
$btnRight = GUICtrlCreateButton("🠾", 195, 75, 30, 30)
GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
GUICtrlCreateGroup("", -99, -99, 1, 1)

$Group3 = GUICtrlCreateGroup("", 247, 10, 100, 97)
$lbTypeSimulator = GUICtrlCreateLabel("loại giả lập", 273, 40, 55, 20)
$cbbTypeSimulator  = GUICtrlCreateCombo("LDPlayer", 251, 60, 90, 21, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL,$WS_BORDER), $WS_EX_STATICEDGE)
GUICtrlSetData($cbbTypeSimulator, "NOX")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$btnReste = GUICtrlCreateButton("reset", 256, 96, 83, 41)
GUICtrlCreateGroup("", -99, -99, 1, 1)

$btnStart = GUICtrlCreateButton("bắt đầu", 24, 168, 83, 41)
$btnPause = GUICtrlCreateButton("dừng", 24, 215, 83, 41)
$Label5 = GUICtrlCreateLabel("số cá câu được", 198, 168, 90, 20)
$tbDemCaCau = GUICtrlCreateInput(0, 208, 188, 50, 24, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $WS_BORDER), BitOR($WS_EX_CLIENTEDGE, $WS_EX_STATICEDGE))
$Label6 = GUICtrlCreateLabel("bán cá câu được", 195, 220, 90, 20)
$cbSellFish = GUICtrlCreateCheckbox("", 225, 240, 17, 17, -1, $WS_EX_CLIENTEDGE)

GUICtrlSetState($btnComplete, $GUI_DISABLE)
GUICtrlSetState($btnReste, $GUI_DISABLE)
GUICtrlSetState($btnPause, $GUI_DISABLE)
GUICtrlSetState($btnUp, $GUI_DISABLE)
GUICtrlSetState($btnDown, $GUI_DISABLE)
GUICtrlSetState($btnLeft, $GUI_DISABLE)
GUICtrlSetState($btnRight, $GUI_DISABLE)

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $title = ""
Global $deviceId = "emulator-5556"
Global $tRect
Global $paddingX
Global $paddingY
Global $colorFish
Global $positionX = 480
Global $positionY = 185
Global $interrupt = 0

Func _up()
	$positionY = ($positionY <= 0) ? 0 : $positionY - 2
EndFunc

Func _down()
	$positionY = ($positionY >= 540) ? 540 : $positionY + 2
EndFunc

Func _left()
	$positionX = ($positionX <= 0) ? 0 : $positionX - 2
EndFunc

Func _right()
	$positionX = ($positionX >= 960) ? 960 : $positionX + 2
EndFunc

Func _isChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func _TapScreen($deviceId, $x, $y, $WorkingDir = @ScriptDir & "\Adb\")
	Run($WorkingDir & "adb.exe -s "&$deviceId&" shell input tap "&$x&" "&$y, @ScriptDir, @SW_HIDE, $STDERR_MERGED)
EndFunc

#Region Định nghĩa và gán các Button muốn dùng để ngắt vòng lặp
GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND_BUTTON")
Func _WM_COMMAND_BUTTON($hWnd, $Msg, $wParam, $lParam)
	Switch BitAND($wParam, 0x0000FFFF)
		Case $btnPause
			WinSetOnTop($title, "", $WINDOWS_NOONTOP)
			$interrupt = 1
	EndSwitch
	Return 'GUI_RUNDEFMSG'
EndFunc
#EndRegion

#Region Tắt GUI khi vẫn còn đang chạy vòng lặp
GUIRegisterMsg($WM_SYSCOMMAND, "_WM_COMMAND_CLOSEBUTTON")
Func _WM_COMMAND_CLOSEBUTTON($hWnd, $Msg, $wParam, $lParam)
	If BitAND($wParam, 0x0000FFFF) = 0xF060 Then
		WinSetOnTop($title, "", $WINDOWS_NOONTOP)
		Exit
	EndIf
	Return 'GUI_RUNDEFMSG'
EndFunc
#EndRegion

Func _WinAPI_DrawRect($start_x, $start_y, $iWidth, $iHeight, $iColor)
	Local $hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
	$tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, 1, $start_x)
	DllStructSetData($tRect, 2, $start_y)
	DllStructSetData($tRect, 3, $iWidth + $start_x) ;  x-coordinate of the lower-right corner of the rectangle
	DllStructSetData($tRect, 4, $iHeight + $start_y) ;  y-coordinate of the lower-right corner of the rectangle
	Local $hBrush = _WinAPI_CreateSolidBrush($iColor)
	_WinAPI_FrameRect($hDC, DllStructGetPtr($tRect), $hBrush)
	_WinAPI_DeleteObject($hBrush)
	_WinAPI_ReleaseDC(0, $hDC)
EndFunc

Func _Adjust()
	$interrupt = 0
	GUICtrlSetState($btnComplete, $GUI_ENABLE)
	GUICtrlSetState($btnAdjust, $GUI_DISABLE)
	GUICtrlSetState($btnStart, $GUI_DISABLE)
	GUICtrlSetState($btnPause, $GUI_DISABLE)
	GUICtrlSetState($btnReste, $GUI_ENABLE)
	GUICtrlSetState($btnUp, $GUI_ENABLE)
	GUICtrlSetState($btnDown, $GUI_ENABLE)
	GUICtrlSetState($btnLeft, $GUI_ENABLE)
	GUICtrlSetState($btnRight, $GUI_ENABLE)
	HotKeySet("{UP}", "_up")
	HotKeySet("{DOWN}", "_down")
	HotKeySet("{LEFT}", "_left")
	HotKeySet("{RIGHT}", "_right")
	While $interrupt == 0
		$pos = WinGetPos($title)
		_WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), $tRect, 0, BitOR($RDW_INVALIDATE, $RDW_ALLCHILDREN))
		_WinAPI_DrawRect($pos[0] + $positionX - 30, $pos[1] + $positionY + 12, 5, 5, 0x0000FF)
		_WinAPI_DrawRect($pos[0] + $positionX, $pos[1] + $positionY, 5, 25, 0x0000FF)
		_WinAPI_DrawRect($pos[0] + $positionX + 30, $pos[1] + $positionY + 12, 5, 5, 0x0000FF)
		Switch GUIGetMsg()
			Case $btnUp
				$positionY = ($positionY <= 0) ? 0 : $positionY - 2
			Case $btnDown
				$positionY = ($positionY >= 540) ? 540 : $positionY + 2
			Case $btnLeft
				$positionX = ($positionX <= 0) ? 0 : $positionX - 2
			Case $btnRight
				$positionX = ($positionX >= 960) ? 960 : $positionX + 2
			Case $btnComplete
				ExitLoop
			Case $btnReste
				GUICtrlSetData($cbbTypeSimulator, 'LDPlayer')
				$positionX = 480
				$positionY = 185
		EndSwitch
	WEnd
	HotKeySet("{UP}")
	HotKeySet("{DOWN}")
	HotKeySet("{LEFT}")
	HotKeySet("{RIGHT}")
	GUICtrlSetState($btnReste, $GUI_DISABLE)
	GUICtrlSetState($btnStart, $GUI_ENABLE)
	GUICtrlSetState($btnUp, $GUI_DISABLE)
	GUICtrlSetState($btnDown, $GUI_DISABLE)
	GUICtrlSetState($btnLeft, $GUI_DISABLE)
	GUICtrlSetState($btnRight, $GUI_DISABLE)
	GUICtrlSetState($btnComplete, $GUI_DISABLE)
	GUICtrlSetState($btnAdjust, $GUI_ENABLE)
EndFunc

Func _Start()
	_Stop()
	WinActivate($title)
	WinSetOnTop($title, "", $WINDOWS_ONTOP)
	$interrupt = 0
	$paddingX = (GUICtrlRead($cbbTypeSimulator)=='LDPlayer') ? 0 : 0
	$paddingY = (GUICtrlRead($cbbTypeSimulator)=='LDPlayer') ? -32 : 0
	GUICtrlSetState($cbbTypeSimulator, $GUI_DISABLE)
	GUICtrlSetState($tbNameWindow, $GUI_DISABLE)
	GUICtrlSetState($tbDemCaCau, $GUI_DISABLE)
	GUICtrlSetState($btnAdjust, $GUI_DISABLE)
	GUICtrlSetState($btnStart, $GUI_DISABLE)
	GUICtrlSetState($btnPause, $GUI_ENABLE)
	While $interrupt == 0
		$pos = WinGetPos($title)
		$nutLam = _ImageSearch_Area("Img\nutLam.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
		$baLo = _ImageSearch_Area("Img\baLo.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
		If $nutLam[0] Then
			Sleep(500)
			$kichThuoc = _ImageSearch_Area("Img\kichThuoc.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
			If $kichThuoc[0] Then
				Sleep(500)
				$banNgay = _ImageSearch_Area("Img\banNgay.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
				If $banNgay[0] Then
					If GUICtrlRead($cbSellFish) = $GUI_CHECKED Then
						ControlClick($title, "", "", 'left', 1, $banNgay[1] - $pos[0] + $paddingX, $banNgay[2] - $pos[1] + $paddingY)
					Else
						GUICtrlSetData($tbDemCaCau, GUICtrlRead($tbDemCaCau) + 1)
						ControlClick($title, "", "", 'left', 1, $nutLam[1] - $pos[0] + $paddingX, $nutLam[2] - $pos[1] + $paddingY)
					EndIf
				Else
					GUICtrlSetData($tbDemCaCau, GUICtrlRead($tbDemCaCau) + 1)
					ControlClick($title, "", "", 'left', 1, $nutLam[1] - $pos[0] + $paddingX, $nutLam[2] - $pos[1] + $paddingY)
				EndIf
			Else
				ControlClick($title, "", "", 'left', 1, $nutLam[1] - $pos[0] + $paddingX, $nutLam[2] - $pos[1] + $paddingY)
				Sleep(500)
			EndIf
			Sleep(500)
		ElseIf $baLo[0] Then
			ControlClick($title, "", "", 'left', 1, 766 + $paddingX, 361 + $paddingY)
			Sleep(2500)
			$baLo = _ImageSearch_Area("Img\baLo.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
			While Not $baLo[0] And $interrupt == 0
				$nutLam = _ImageSearch_Area("Img\nutLam.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
				$baLo = _ImageSearch_Area("Img\baLo.bmp", $pos[0], $pos[1], $pos[0] + 960, $pos[1] + 540)
				$topColor = Hex(_ColorGetRed(PixelGetColor($pos[0] + $positionX + 3, $pos[1] + $positionY + 3)), 2)
				$bottomColor = Hex(_ColorGetRed(PixelGetColor($pos[0] + $positionX + 3, $pos[1] + $positionY + 22)), 2)
				$leftColor = Hex(_ColorGetRed(PixelGetColor($pos[0] + $positionX - 28, $pos[1] + $positionY + 14)), 2)
				$rightColor = Hex(_ColorGetRed(PixelGetColor($pos[0] + $positionX + 32, $pos[1] + $positionY + 14)), 2)
				If $nutLam[0] Then
					Sleep(1500)
					ExitLoop
				ElseIf (($topColor <> $rightColor) And ($topColor <> $leftColor) And ($topColor == $bottomColor)) Then
					ControlClick($title, "", "", 'left', 1, 845 + $paddingX, 508 + $paddingY)
					Sleep(2500)
					ExitLoop
				EndIf
				Sleep(200)
			WEnd
		EndIf
	WEnd
	GUICtrlSetState($cbbTypeSimulator, $GUI_ENABLE)
	GUICtrlSetState($tbNameWindow, $GUI_ENABLE)
	GUICtrlSetState($tbDemCaCau, $GUI_ENABLE)
	GUICtrlSetState($btnPause, $GUI_DISABLE)
	GUICtrlSetState($btnAdjust, $GUI_ENABLE)
	GUICtrlSetState($btnStart, $GUI_ENABLE)
EndFunc

Func _Stop()
	WinSetOnTop($title, "", $WINDOWS_NOONTOP)
	$interrupt = 1
EndFunc

HotKeySet("{HOME}", "_Start")
HotKeySet("{END}", "_Stop")

While 1
	$title = GUICtrlRead($tbNameWindow)
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btnAdjust
			_Adjust()
		Case $btnStart
			_Start()
	EndSwitch
WEnd