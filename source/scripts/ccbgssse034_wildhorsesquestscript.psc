;/ Decompiled by Champollion V1.0.1
Source   : ccBGSSSE034_WildHorsesQuestScript.psc
Modified : 2021-08-19 11:15:00
Compiled : 2021-08-24 17:21:27
User     : builds
Computer : RKVBGSGPUVM04
/;
scriptName ccBGSSSE034_WildHorsesQuestScript extends Quest
{Main script that handles quest, tutorial, horse renaming}

;-- Properties --------------------------------------
Quest property ccBGSSSE034_Misc_Horse01_Chestnut auto
keyword property SpecialHorseKeyword auto
referencealias[] property ArrayHorseNames auto
globalvariable property TamedHorseCounter auto
message property ccBGSSSE034_MessageMustBeTamedRename auto
message property MessageHorseNamed auto
referencealias property WildHorseNotes auto
Quest property ccBGSSSE034_Misc_Horse02_Black auto
faction property PlayerFaction auto
referencealias property NewHorseName auto
referencealias property WildHorseMap auto
Quest property ccBGSSSE034_Misc_Horse04_Pale auto
referencealias[] property WildHorseAliases auto
Quest property ccBGSSSE034_Misc_Horse06_WhiteSpotted auto
referencealias property StablesPlayersHorse auto
Quest property ccBGSSSE034_Misc_Horse07_BrownSpotted auto
Quest property ccBGSSSE034_Misc_Horse05_RedBrown auto
message property HelpWildHorseTutorial auto
faction property PlayerHorseFaction auto
Quest property ccBGSSSE034_Misc_Horse03_GreyBlack auto

;-- Variables ---------------------------------------
Bool HasTutorialDisplayed = false

;-- Functions ---------------------------------------

function CheckAndClearQuestItems()
{Since each horse has a separate misc quest, we have to check as each completes to ensure all are finished before we clear the map and journal as quest items.}

	if ccBGSSSE034_Misc_Horse01_Chestnut.GetStageDone(0) && ccBGSSSE034_Misc_Horse02_Black.GetStageDone(0) && ccBGSSSE034_Misc_Horse03_GreyBlack.GetStageDone(0) && ccBGSSSE034_Misc_Horse04_Pale.GetStageDone(0) && ccBGSSSE034_Misc_Horse05_RedBrown.GetStageDone(0) && ccBGSSSE034_Misc_Horse06_WhiteSpotted.GetStageDone(0) && ccBGSSSE034_Misc_Horse07_BrownSpotted.GetStageDone(0)
		WildHorseMap.Clear()
		WildHorseNotes.Clear()
	endIf
endFunction

function UpdateTamedHorseCount()
{increments global value displayed in quest objective}

	self.ModObjectiveGlobal(1 as Float, TamedHorseCounter, 10, -1.00000, true, true, true)
	if TamedHorseCounter.GetValueInt() == 7
		self.SetStage(20)
	endIf
endFunction

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

function ShowTutorial()

	if !HasTutorialDisplayed
		HasTutorialDisplayed = true
		HelpWildHorseTutorial.Show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	endIf
endFunction

function RenameLastRiddenHorse()
{Forces the horse into a random unused RefAlias containing name data}

	actor HorseToRename = game.GetPlayersLastRiddenHorse()
	if HorseToRename != none && HorseToRename.HasKeyword(SpecialHorseKeyword) && HorseToRename.IsInFaction(PlayerHorseFaction)
		ccbgssse034_wildhorserefaliasscript HorseRefAlias = self.GetHorseRefAlias(HorseToRename)
		if HorseRefAlias
			Int i
			Bool bFoundAvailableName = false
			Int MaxTries = 50
			Int NameAttempCounter = 0
			while bFoundAvailableName == false && NameAttempCounter < MaxTries
				i = utility.RandomInt(0, ArrayHorseNames.length - 1)
				if ArrayHorseNames[i].GetActorReference()
					NameAttempCounter += 1
				else
					bFoundAvailableName = true
				endIf
			endWhile
			if bFoundAvailableName
				if HorseRefAlias.CurrentName
					HorseRefAlias.CurrentName.Clear()
				endIf
				ArrayHorseNames[i].ForceRefTo(HorseToRename as objectreference)
				HorseRefAlias.CurrentName = ArrayHorseNames[i]
				MessageHorseNamed.Show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
			endIf
		endIf
	else
		ccBGSSSE034_MessageMustBeTamedRename.Show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	endIf
endFunction

ccbgssse034_wildhorserefaliasscript function GetHorseRefAlias(actor HorseActorRef)
{Loops over the horse ref aliases to match the supplied actor ref}

	ccbgssse034_wildhorserefaliasscript thisHorseAlias
	Int i = 0
	while i <= WildHorseAliases.length - 1
		if HorseActorRef == WildHorseAliases[i].GetActorReference()
			thisHorseAlias = WildHorseAliases[i] as ccbgssse034_wildhorserefaliasscript
		endIf
		i += 1
	endWhile
	return thisHorseAlias
endFunction
