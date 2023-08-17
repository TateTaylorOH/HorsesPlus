Scriptname DES_OnLoadUpdateScript extends ReferenceAlias  
{Manages various aspects of the mod that may need updated when the Player reloads their game.}

GlobalVariable Property DES_PlayerOwnsHorse auto
Quest Property DES_HorseHandler Auto
Quest Property DES_HorseCallTutorialTracker Auto
Formlist Property DES_ValidWorldspaces auto
ReferenceAlias Property Alias_PlayersHorse auto
ReferenceAlias Property Alias_LastRiddenHorse auto
ReferenceAlias Property Alias_BSBrumaHostler auto
LeveledItem Property DES_LItemMiscHostlerItems75 auto
LeveledItem Property DES_MinimumHostler auto

EVENT OnPlayerLoadGame()
	GetBaseCarryWeight()
	RegisterKey()
	GetLastRiddenHorse()
	IF Game.GetFormFromFile(0xA764B, "BSHeartland.esm")
		ImportCyrodiil()
	ENDIF
ENDEVENT

FUNCTION GetBaseCarryWeight()
	Actor PlayersHorse = Game.GetPlayersLastRiddenHorse()
	(self.GetOwningQuest() as DES_HorseInventoryScript).BaseCarryWeight = PlayersHorse.GetBaseAV("CarryWeight") as int
	IF (self.GetOwningQuest() as DES_HorseInventoryScript).BaseCarryWeight == 0
		(self.GetOwningQuest() as DES_HorseInventoryScript).BaseCarryWeight = 999
	ENDIF
ENDFUNCTION

FUNCTION RegisterKey()
	(self.GetOwningQuest() as DES_HorseCallScript).horsekey = papyrusinimanipulator.PullIntFromIni("Data/H2Horse.ini", "General", "HorseKey", 35)
	DES_HorseHandler.UnregisterForKey((self.GetOwningQuest() as DES_HorseCallScript).horsekey)
	Utility.Wait(0.1)
	DES_HorseHandler.RegisterForKey((self.GetOwningQuest() as DES_HorseCallScript).horsekey)
ENDFUNCTION

FUNCTION GetLastRiddenHorse()
	Alias_LastRiddenHorse.Clear()
	Utility.Wait(0.1)
	Alias_LastRiddenHorse.ForceRefTo(Game.GetPlayersLastRiddenHorse())
ENDFUNCTION

FUNCTION ImportModdedWorldspace(Worldspace WorldToImport)
	IF !DES_ValidWorldspaces.HasForm(WorldToImport)
		DES_ValidWorldspaces.AddForm(WorldToImport)
	ENDIF
ENDFUNCTION

FUNCTION ImportModdedHostler(Actor HostlerToImport, ReferenceAlias HostlerToImportAlais, Faction ModdedMerchantFaction)
	HostlerToImport.AddToFaction(ModdedMerchantFaction)
	HostlerToImportAlais.ForceRefTo(HostlerToImport)
ENDFUNCTION

FUNCTION ImportCyrodiil()
	Actor BSBrumaHostler = Game.GetFormFromFile(0x65115, "BSHeartland.esm") As Actor
	Faction CYRJobMerchantFaction = Game.GetFormFromFile(0x5BBDE, "BSHeartland.esm") As Faction
	Form BSHeartland = Game.GetFormFromFile(0xA764B, "BSHeartland.esm") as Worldspace
	MiscObject BSHorseshoe = Game.GetFormFromFile(0x723B8, "BSHeartland.esm") As MiscObject
	ImportModdedWorldspace(BSHeartland as Worldspace)
	IF BSBrumaHostler != Alias_BSBrumaHostler.getactorRef()
		ImportModdedHostler(BSBrumaHostler, Alias_BSBrumaHostler, CYRJobMerchantFaction)
	ENDIF
	IF !(DES_HorseCallTutorialTracker as DES_HorseCallTutorialTrackerScript).BSHorseshoeAdded == true
		DES_MinimumHostler.AddForm(BSHorseshoe, 1, 4)
		DES_LItemMiscHostlerItems75.AddForm(BSHorseshoe, 1, 4)
	ENDIF
ENDFUNCTION