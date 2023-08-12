Scriptname DES_HorseCallScript extends Quest
{Controls the horse call mechanic.}

Actor Property PlayerRef Auto
bool Property Debugging  auto
bool Property HorseSelectTutorial  auto
Faction Property PlayerHorseFaction Auto
Formlist Property DES_OwnedHorses auto
Formlist Property DES_ValidWorldspaces auto
int property horseKey auto
ReferenceAlias Property Alias_PlayersHorse auto
Sound Property DES_HorseCallMarker auto
Sound Property DES_HorseStayMarker auto

Message[] Property HelpMessages Auto
float property messageDuration = 3.0 auto
float property messageInterval = 1.0 auto
float horseAngle = 180.0 ; where the horse should appear relative to the player, clockwise from north.
float horseDistance = 512.0

Event OnKeyUp(Int KeyCode, Float HoldTime)
{Sends an event when HorseKey is raised up. The actor called will be the last owned horse the player rode. There are checks to prevent the horse getting called into interiors as well as a mechanics to select a specific horse from a SkyUILib list menu.}
	Actor LastRiddenHorse = Game.GetPlayersLastRiddenHorse()
	Debugging = papyrusinimanipulator.PullboolFromIni("Data/H2Horse.ini", "General", "Debugging", False)
	IF Debugging
		Debug.Notification("LastRiddenHorse is " + LastRiddenHorse.getDisplayName())
	ENDIF
	IF (KeyCode == horseKey && !Utility.IsInMenuMode() && !UI.IsTextInputEnabled()) && !Game.GetCurrentCrosshairRef() && !PlayerRef.IsOnMount(); this is a valid keypress
		IF (!PlayerRef.IsInInterior() && DES_ValidWorldspaces.HasForm(PlayerRef.getWorldSpace())) ; this is a valid place to summon the horse
			IF HoldTime < papyrusinimanipulator.PullFloatFromIni("Data/H2Horse.ini", "General", "HoldTime", 0.9000) 
				IF (LastRiddenHorse && LastRiddenHorse.IsInFaction(PlayerHorseFaction)) && !LastRiddenHorse.IsDead(); there is a last horse, it's the players, and it's not dead
					HorseCall(LastRiddenHorse)
				ENDIF
			ELSE
				SelectHorse()
			ENDIF
		ELSE
			IF (LastRiddenHorse && LastRiddenHorse.IsInFaction(PlayerHorseFaction)) ; there is a last horse, and it's the players
				Debug.Notification(LastRiddenHorse.GetDisplayName() + " cannot be called here.")
			ENDIF
		ENDIF
	ENDIF
endEvent

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
{This event clears the H2Horse alias and reverts control of the horse's AI to the "stables" quest.}
    if (akSource == PlayerRef) && (asEventName == "tailHorseMount")
        GoToState("CalledHorse")
        UnregisterForAnimationEvent(PlayerRef, "tailHorseMount")
        Alias_PlayersHorse.Clear()
    endif
EndEvent

Function HorseCall(Actor LastRiddenHorse)
{This function controls switching between calling the horse and telling the horse to stay.}
		RegisterForAnimationEvent(PlayerRef, "tailHorseMount") ;Registered to track dismount, which will remove the Horse from the H2Horse alias.
		Debug.Notification("You call for " + LastRiddenHorse.GetDisplayName() + ".")
		HorseWhistle(LastRiddenHorse)
		IF !PlayerRef.HasLOS(LastRiddenHorse)
			float az = addAngles(PlayerRef.getAngleZ(), horseAngle)
			LastRiddenHorse.moveTo(PlayerRef, horseDistance * math.sin(az), horseDistance * Math.cos(az), 0.0, true)
		ENDIF
		IF !DES_OwnedHorses.HasForm(LastRiddenHorse)
			DES_OwnedHorses.addForm(LastRiddenHorse)
		ENDIF
		IF DES_OwnedHorses.GetSize() > 1 && !HorseSelectTutorial ;A tutorial regarding the horse selection list will play if the Player has UI Extentions installed. It will only play if HorseKey is H since the tutorial specifically refers to the key.
			IF Game.GetFormFromFile(0xE05, "UIExtensions.esp") && HorseKey == 35
				Utility.Wait(1)
				HelpMessages[0].ShowAsHelpMessage("HorseSelectTutorial", messageDuration, 1.0, 1)
				HorseSelectTutorial = True
			ENDIF
		ENDIF
		GoToState("CalledHorse")
endFunction

Function SelectHorse()
{If the Player has UI Extensions installed, this function will allowed them to pick from a list of their owned horses to call to them.}
	 Actor LastRiddenHorse = Game.GetPlayersLastRiddenHorse()
	IF Game.GetFormFromFile(0xE05, "UIExtensions.esp")
		int n = DES_OwnedHorses.getSize()
		while n > 0
			Actor OwnedHorse = DES_OwnedHorses.GetAt(n) as actor
			IF OwnedHorse && OwnedHorse.IsDead()
				DES_OwnedHorses.RemoveAddedForm(OwnedHorse)
			ENDIF
			n -= 1
		endwhile
		int nHorses = DES_OwnedHorses.getSize()
		IF nHorses > 1
			UISelectionMenu menu = UIExtensions.GetMenu("UISelectionMenu") as UISelectionMenu	
			menu.OpenMenu(aForm=DES_OwnedHorses)
			Actor SelectedHorse = menu.GetResultForm() as Actor
			RegisterForAnimationEvent(PlayerRef, "tailHorseMount")
			Debug.Notification("You call for " + SelectedHorse.GetDisplayName() + ".")
			HorseCall(SelectedHorse)
		ENDIF
	ELSE
		HorseCall(LastRiddenHorse)
	ENDIF
endFunction

Function HorseWhistle(Actor LastRiddenHorse)
{This function plays the whistling sound when the Player calls for their horse, then forces the horse to H2Horse's alias so that follow AI can take over. Code is present here for patchless compatibility with Animated Whistling.}
    bool doingExtraBullshit = !PlayerRef.IsWeaponDrawn() && PlayerRef.GetSitState() == 0
    Alias_PlayersHorse.Clear()
    IF doingExtraBullshit
        Debug.SendAnimationEvent(PlayerRef, "Whistling")
        MfgConsoleFunc.SetPhoneMe(PlayerRef, 6, 30)
    ENDIF
    IF !(GetState() == "CalledHorse")
		DES_HorseCallMarker.Play(PlayerRef)
		Alias_PlayersHorse.ForceRefTo(LastRiddenHorse)
    ELSE
		DES_HorseStayMarker.Play(PlayerRef)
        Alias_PlayersHorse.Clear()
    ENDIF
    IF doingExtraBullshit
        Utility.Wait(1.0)
        MfgConsoleFunc.ResetPhonemeModifier(PlayerRef)
        Debug.SendAnimationEvent(PlayerRef, "OffsetStop")
    ENDIF
    LastRiddenHorse.EvaluatePackage()
endFunction

float function addAngles(float angle, float turn)
{This function controls the angles at which the horse is spawned if the Player doesn't currently have LOS on it.}
    angle += turn
    while(angle >= 360.0)
        angle -= 360.0
    endWhile
    while(angle < 0.0)
        angle += 360.0
    endWhile
    return angle
endFunction

State CalledHorse
	Function HorseCall(Actor LastRiddenHorse)
		UnregisterForAnimationEvent(PlayerRef, "tailHorseMount")
		Debug.Notification("You tell "+ LastRiddenHorse.GetDisplayName() + " to wait.")
		HorseWhistle(LastRiddenHorse)
		GoToState("")
	endFunction
EndState