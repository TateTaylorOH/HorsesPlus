;/ Decompiled by Champollion V1.0.1
Source   : ccVSVSSE001_DeedScript.psc
Modified : 2021-08-19 11:15:44
Compiled : 2021-08-25 05:50:30
User     : builds
Computer : RKVBGSGPUVM04
/;
scriptName ccVSVSSE001_DeedScript extends ObjectReference

;-- Properties --------------------------------------
referencealias property Alias_Reindeer auto
globalvariable property deedActive auto
ObjectReference property merchantChest auto
referencealias property PlayerHorse auto
faction property PlayerFaction auto
faction property PlayerHorseFaction auto
referencealias property PlayerReindeer auto

;-- Variables ---------------------------------------

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

function OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)

	if akOldContainer == merchantChest && akNewContainer == game.GetPlayer() as ObjectReference
		Alias_Reindeer.GetActorRef().SetFactionRank(PlayerHorseFaction, 1)
		Alias_Reindeer.GetActorRef().SetFactionOwner(PlayerFaction)
		PlayerHorse.Clear()
		PlayerReindeer.ForceRefTo(Alias_Reindeer.GetActorRef() as ObjectReference)
		game.IncrementStat("Horses Owned", 1)
		deedActive.SetValue(100 as Float)
		(Quest.GetQuest("DES_RenameHorseQuest") as DES_RenameHorseQuestScript).renameReindeer()
		Formlist DES_HorseMiscItems = game.GetFormFromFile(0xDD6, "H2Horse.esp") as Formlist
		Formlist DES_HorseArmors = game.GetFormFromFile(0xDD7, "H2Horse.esp") as Formlist
		Formlist DES_HorseAllForms = game.GetFormFromFile(0xDD8, "H2Horse.esp") as Formlist
		Armor ReindeerSaddle = game.GetFormFromFile(0x804, "ccvsvsse001-winter.esl") as Armor
		DES_HorseMiscItems.AddForm(ReindeerSaddle)
		DES_HorseArmors.AddForm(ReindeerSaddle)
		DES_HorseAllForms.AddForm(ReindeerSaddle)
	endIf
endFunction

; Skipped compiler generated GotoState
