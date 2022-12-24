Scriptname DES_RenameHorseQuestScript extends Quest  

;INVENTORY OBJECTS
MiscObject Property CCHorseArmorMiscArmorSteel auto
MiscObject Property CCHorseArmorMiscArmorElven auto
MiscObject Property DES_Saddle auto
MiscObject Property DES_WhiteSaddle auto
MiscObject Property DES_ImperialSaddle auto
MiscObject Property DES_StormcloakSaddle auto
MiscObject Property DES_DarkBrotherhoodSaddle auto

;ARMOR TO EQUIP
Armor Property CCHorseArmorElven auto
Armor Property CCHorseArmorSteel auto
Armor Property HorseSaddle auto
Armor Property ccBGSSSE034_HorseSaddleLight auto
Armor Property HorseSaddleImperial auto
Armor Property ccBGSSSE034_HorseSaddleStormcloak auto
Armor Property HorseSaddleShadowmere auto

ReferenceAlias Property Alias_PlayersHorse auto
ReferenceAlias Property Alias_BYOHDawnstarHorse auto
ReferenceAlias Property Alias_BYOHFalkreathHorse auto
ReferenceAlias Property Alias_BYOHMorthalHorse auto
ReferenceAlias Property PlayersHorseEquipAlias auto
String[] Property HorseNamesList auto
String[] Property HorseFemaleNamesList auto
GlobalVariable Property DES_PlayerOwnsHorse auto
GlobalVariable Property CCHorseArmorIsInstalled auto
Outfit Property DES_EmptyHorseOutfit auto
Quest Property ccBGSSSE034_HorseSaddleQuest auto
Quest Property CCHorseArmorDialogueQuest auto
Quest Property DES_RenameHorseQuest auto
Formlist Property DES_OwnedHorses auto
Spell Property DES_TrampleCloak auto
Spell Property DES_HorseFear auto
Spell Property DES_HorseRally auto

float property messageDuration = 3.0 auto
float property messageInterval = 1.0 auto
Message[] Property HelpMessages Auto

bool function renameHorse(Actor horse, string defaultName = "Honse")
	EquipHorse()
	string newName = ((self as Form) as UILIB_1).showTextInput("Name Your Horse", DefaultName)
	if newName != ""
		horse.setDisplayName(newName, true)
		return true
	endIf
	return false
endFunction

string function getRandomName(string[] names = None)
	if(names == None)
		names = HorseNamesList
	endIf
	int i = Utility.randomInt(0, names.length - 1)
	return names[i]
endFunction

function renameFemaleHorse()
	Actor PlayersHorse = Alias_PlayersHorse.getActorReference()
	String defaultName = getRandomName(HorseFemaleNamesList)
	renameHorse(PlayersHorse, defaultName)
endFunction

Function RenameWhiterunHorse()
	Actor PlayersHorse = Alias_PlayersHorse.getActorReference()
	String defaultName = "Queen Alfsigr"
	renameHorse(PlayersHorse, defaultName)
EndFunction

function renameBYOHDawnstarHorse()
	Actor PlayersHorse = Alias_BYOHDawnstarHorse.getActorReference()
	String defaultName = getRandomName(HorseNamesList)
	renameHorse(PlayersHorse, defaultName)
endFunction

function renameBYOHFalkreathHorse()
	Actor PlayersHorse = Alias_BYOHFalkreathHorse.getActorReference()
	String defaultName = getRandomName(HorseNamesList)
	renameHorse(PlayersHorse, defaultName)
endFunction

function renameBYOHMorthalHorse()
	Actor PlayersHorse = Alias_BYOHMorthalHorse.getActorReference()
	String defaultName = getRandomName(HorseNamesList)
	renameHorse(PlayersHorse, defaultName)
endFunction

function renameWildHorse()
	Actor PlayersHorse = game.GetPlayersLastRiddenHorse()
	String defaultName = getRandomName(HorseNamesList)
	renameHorse(PlayersHorse, defaultName)
endFunction

function renameCyrodiilHorse()
	Actor PlayersHorse = Game.GetFormFromFile(0x65108, "BSHeartland.esm") as Actor
	String defaultName = getRandomName(HorseFemaleNamesList)
	renameHorse(PlayersHorse, defaultName)
endFunction

Function EquipHorse()
	Actor PlayersHorse = Alias_PlayersHorse.getActorReference()
	IF !DES_OwnedHorses.HasForm(PlayersHorse)
		DES_OwnedHorses.AddForm(PlayersHorse)
	ENDIF
	DES_PlayerOwnsHorse.SetValue(1)
	IF PlayersHorse.IsEquipped(CCHorseArmorElven)
		EquipArmor()
		PlayersHorse.AddItem(CCHorseArmorMiscArmorElven, 1)
		(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).ChangeHorseArmor(0)
	ELSEIF PlayersHorse.IsEquipped(CCHorseArmorSteel)
		EquipArmor()
		PlayersHorse.AddItem(CCHorseArmorMiscArmorSteel, 1)
		(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).ChangeHorseArmor(1)	
	ELSEIF PlayersHorse.IsEquipped(HorseSaddle)
		EquipSaddle()
		PlayersHorse.AddItem(DES_Saddle, 1)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(HorseSaddle)
	ELSEIF PlayersHorse.IsEquipped(ccBGSSSE034_HorseSaddleLight) 
		EquipSaddle()
		PlayersHorse.AddItem(DES_WhiteSaddle, 1)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(ccBGSSSE034_HorseSaddleLight)
	ELSEIF PlayersHorse.IsEquipped(HorseSaddleImperial)
		EquipSaddle()
		PlayersHorse.AddItem(DES_ImperialSaddle, 1)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(HorseSaddleImperial)
	ELSEIF PlayersHorse.IsEquipped(ccBGSSSE034_HorseSaddleStormcloak)
		EquipSaddle()
		PlayersHorse.AddItem(DES_StormcloakSaddle, 1)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(ccBGSSSE034_HorseSaddleStormcloak)
	ELSEIF PlayersHorse.IsEquipped(HorseSaddleShadowmere)
		EquipSaddle()
		PlayersHorse.AddItem(DES_DarkBrotherhoodSaddle, 1)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(HorseSaddleShadowmere)
	ENDIF
EndFunction

Function EquipArmor()
	Actor PlayersHorse = Alias_PlayersHorse.getActorReference()
	(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).RemoveHorseArmor()
	(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(none)
	PlayersHorse.SetAV("CarryWeight", 0.0)
	PlayersHorse.AddSpell(DES_HorseRally)
	PlayersHorse.AddSpell(DES_TrampleCloak)
	(PlayersHorseEquipAlias as DES_HorseEquipScript).SaddleBags = False
EndFunction

Function EquipSaddle()
	Actor PlayersHorse = Alias_PlayersHorse.getActorReference()
	PlayersHorse.SetAV("CarryWeight", 100.0)
	PlayersHorse.AddSpell(DES_HorseFear)
	(PlayersHorseEquipAlias as DES_HorseEquipScript).SaddleBags = True
EndFunction