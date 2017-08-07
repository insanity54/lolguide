#include <GUIConstantsEx.au3>
#Include "Json.au3"

Local $defaultSummonerName = "Xpect2GetRekt"

Local $guiLolguide = GUICreate("lolguide", 400, 200)
Local $btnOK = GUICtrlCreateButton("&Start", 300, 160, 85, 25)
Local $inputSummoner = GUICtrlCreateInput ( $defaultSummonerName, 10, 35, 256 )
Local $labelSummoner = GUICtrlCreateLabel ( "Please enter your summoner name", 10, 10 )
Local $labelInfo = GUICtrlCreateLabel ( "lolguide", 10, 170, 250 )
GUISetState(@SW_SHOW)


; Loop until the user clicks OK
While 1
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE
		 Exit 1223
	  Case $btnOK
		 ExitLoop
   EndSwitch
WEnd

;GUISetState(@SW_HIDE)
ConsoleWrite("summoner name is "&GUICtrlRead($inputSummoner)&@CRLF)
Local $summonerName = GUICtrlRead($inputSummoner)


; make a web request to get the summoner's id
$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
$oHTTP.Open("GET", "https://hook.io/insanity54/lol-summoner/"&$summonerName, False)
$oHTTP.Send()

; wait for status code 200
$oReceived = $oHTTP.ResponseText
$oStatusCode = $oHTTP.Status

Local $oSummoner = Json_Decode ($oReceived)
Local $summonerID = Json_Get ($oSummoner, '[id]')

If $oStatusCode == 200 then
   GUICtrlSetData ( $labelInfo, "Summoner id "&$summonerID&". Ready!" )
Else
   GUICtrlSetData ( $labelInfo, "There was a problem fetching data from the lolguide server." )
EndIf



ConsoleWrite("summoner id is "&$summonerID&@CRLF)

;WinWait("[TITLE:League of Legends (TM) Client; CLASS:RiotWindowClass]")
;MsgBox(0, "Info", "I see the client", 2)

; make a web request to see what champ the summoner is playing as
$oHTTP2 = ObjCreate("winhttp.winhttprequest.5.1")
$oHTTP2.Open("GET", "https://hook.io/insanity54/lol-spectatorbysummoner/"&$summonerID, False)
$oHTTP2.Send()

; wait for status code 200
$oReceived2 = $oHTTP2.ResponseText
$oStatusCode2 = $oHTTP2.Status

Local $oSpectator
Local $aParticipants
Local $oRelevantParticipant
Local $oStatus


If $oStatusCode2 == 200 then
   $oSpectator = Json_Decode ($oReceived2)
   $aParticipants = Json_Get ($oSpectator, '[participants]')
   $oStatus = Json_Get ($oSpectator, '[status][message]')
   If $oStatus == "Data not found" Then
	  ; the summoner is not in a game
	  GUICtrlSetData ( $labelInfo, "Summoner is not in a game" )
   Else

	  ; The summoner is in a game
	  GUICtrlSetData ( $labelInfo, "In-game. Detecting champion." )

	  Local $counter = 0
	  For $participant In $aParticipants
		 $counter = $counter + 1
		 ;ConsoleWrite("participant "&$counter&"-- "&$participant&" "&Json_Get($participant, '[summonerName]')&@CRLF)
		 If Json_Get($participant, '[summonerName]') == $summonerName Then
			$oRelevantParticipant = $participant
		 EndIf
	  Next


	  Local $championID = Json_Get($oRelevantParticipant, '[championId]')
	  ConsoleWrite("championID-- "&$championID&@CRLF)
	  ConsoleWrite($oRelevantParticipant&@CRLF)

	  ; make a web request to get the champion name
	  $oHTTP3 = ObjCreate("winhttp.winhttprequest.5.1")
	  $oHTTP3.Open("GET", "https://hook.io/insanity54/lol-champions/"&$championID, False)
	  $oHTTP3.Send()

	  ; wait for status code 200
	  $oReceived3 = $oHTTP3.ResponseText
	  $oStatusCode3 = $oHTTP3.Status

	  If $oStatusCode3 == 200 then
		 $oChampion = Json_Decode ($oReceived3)
		 $sChampionName = Json_Get ($oChampion, '[name]')
		 GUICtrlSetData ( $labelInfo, "Playing as "&$sChampionName )
	  Else
		 GUICtrlSetData ( $labelInfo, "Problem while getting champion name from lolguide server" )
		 ConsoleWrite("Problem while getting champion oname from lolguide server"&@CRLF)
	  EndIf

   EndIf
Else
   GUICtrlSetData ( $labelInfo, "There was a problem fetching spectator data from the lolguide server." )
EndIf



; open lolbuilder
ShellExecute("http://www.lolbuilder.net/"&$sChampionName)
