Scriptname DES_HorseInventoryScript extends Quest  
{Controls everything to do with equiping horses and managing their inventory.}

Actor Property DES_HorseStomachRef auto
Actor Property HorseToEquip auto
Actor Property PlayerRef auto
Bool Property Debugging auto
Bool Property EquipRunning auto
Bool Property RegistryTutorial auto
Bool Property UnequipRunning auto
Faction Property DES_RegisteredHorses auto
Faction Property PlayerHorseFaction auto
Formlist Property DES_CarFood auto
Formlist Property DES_HorseAllForms auto
Formlist Property DES_HorseArmors auto
Formlist Property DES_HorseFood auto
Formlist Property DES_HorseMiscItems auto
Formlist Property DES_OwnedHorses auto
GlobalVariable Property DES_PlayerOwnsHorse auto
idle property HorseIdleRearUp auto
int Property BaseCarryWeight auto
Keyword Property CCHorseArmorKeyword auto
Keyword Property DES_ArmorKeyword auto
Keyword Property DES_SaddleKeyword auto
Outfit Property DES_NakedHorseOutfit auto
Quest Property ccBGSSSE034_HorseSaddleQuest auto
Quest Property CCHorseArmorDialogueQuest auto
Quest Property DES_HorseHandler auto
ReferenceAlias Property Alias_PlayersHorse auto
Spell Property DES_HorseFear auto
Spell Property DES_HorseRally auto

Message Property DES_HorseRegistryTutorial Auto
float property messageDuration = 3.0 auto
float property messageInterval = 1.0 auto

Race Property DwarvenHorse
    race Function Get()
        return Game.GetFormFromFile(0x38D5, "cctwbsse001-puzzledungeon.esm") As Race
    EndFunction
EndProperty

Race Property Reindeer
    race Function Get()
        return Game.GetFormFromFile(0xD61, "ccvsvsse001-winter.esl") as Race
    EndFunction
EndProperty

EVENT OnKeyUp(Int KeyCode, Float HoldTime)
{This event controls opening and closing the horse's inventory. It will check to see that the actor in your crosshair is a horse you own, then force it to H2Horse's alias, and then open the inventory. IF horsekey is held, it will open the gIFt menu so you can feed the horse.}
	IF KeyCode == (DES_HorseHandler as DES_HorseCallScript).horsekey && !Utility.IsInMenuMode() && !UI.IsTextInputEnabled() && Game.GetCurrentCrosshairRef()
	Alias_PlayersHorse.ForceRefTo(Game.GetCurrentCrosshairRef())
	Actor PlayersHorse = Alias_PlayersHorse.getActorReference()
		IF PlayersHorse && PlayersHorse.IsInFaction(PlayerHorseFaction) && !PlayersHorse.IsDead()
			IF HoldTime < papyrusinimanipulator.PullFloatFromIni("Data/H2Horse.ini", "General", "HoldTime", 0.9000)
				IF PlayersHorse.GetRace() != DwarvenHorse
					RegisterForMenu("ContainerMenu")
					SetCarryWeight(PlayersHorse)
					PlayersHorse.OpenInventory(true)
				ELSE
					Alias_PlayersHorse.Clear()
				ENDIF
			ELSE
				RegisterForMenu("GiftMenu")
				IF PlayersHorse.GetRace() != DwarvenHorse
					DES_HorseStomachRef.ShowGIFtMenu(true, DES_HorseFood)
				ELSE
					DES_HorseStomachRef.ShowGIFtMenu(true, DES_CarFood)
				ENDIF
			ENDIF
		ELSE
			return
		ENDIF
	ELSE
		return
	ENDIF
ENDEVENT

EVENT OnMenuClose(String MenuName)
{This event controls unregistering the relevant menu and clearing H2Horse's alias.}
	IF MenuName == "ContainerMenu"
		UnregisterForMenu("InventoryMenu")
		while UnequipRunning == true
			utility.wait(0.1)
		endwhile
		Alias_PlayersHorse.Clear()
		((DES_HorseHandler as Quest) as DES_HorseCallScript).GoToState("Waiting")
	ELSEIF MenuName == "GIFtMenu"
		UnregisterForMenu("GIFtMenu")
		Alias_PlayersHorse.Clear()
		((DES_HorseHandler as Quest) as DES_HorseCallScript).GoToState("Waiting")
	ENDIF
ENDEVENT

;This function is intentionally empty and is overridden by the three equip states.
FUNCTION SetCarryWeight(Actor PlayersHorse)
{This function is called when the Player opens the horse's inventory. It will set the horse into the proper equip mode and set the proper carryweight.}
ENDFUNCTION

FUNCTION FirstTimeEquipHorse(Actor PlayersHorse)
{This will prepare the horse for use within the H2Horse framework. It will set the horse's outfit to be blank, then check what armor the horse was wearing, give that horse the matching miscitem and reequip their inital gear. It is then handed of to the equip script to set carry weight and AI.}
	Debugging = papyrusinimanipulator.PullboolFromIni("Data/H2Horse.ini", "General", "Debugging", False)
	IF !PlayersHorse.IsInFaction(PlayerHorseFaction)
		PlayersHorse.SetFactionRank(PlayerHorseFaction, 1)
	ENDIF
	IF !PlayersHorse.IsInFaction(DES_RegisteredHorses)
		PlayersHorse.AddToFaction(DES_RegisteredHorses)
	ENDIF
	PlayersHorse.SetActorOwner(PlayerRef.GetActorBase())
	IF !DES_OwnedHorses.HasForm(PlayersHorse)
		DES_OwnedHorses.AddForm(PlayersHorse)
	ENDIF
	DES_PlayerOwnsHorse.SetValue(1)
	BaseCarryWeight = PlayersHorse.GetBaseAV("CarryWeight") as int
	IF BaseCarryWeight == 0
		BaseCarryWeight = 999
	ENDIF
	Int i = DES_HorseArmors.Find(PlayersHorse.GetEquippedArmorInSlot(45))
	IF Debugging
		Debug.Notification(i + " " + (DES_HorseArmors.GetAt(i)).GetName() + " " + (DES_HorseMiscItems.GetAt(i)).GetName())
	ENDIF
	IF PlayersHorse.GetRace() == Reindeer
		SaddleMode(PlayersHorse)
	ELSEIF PlayersHorse.GetRace() == DwarvenHorse
		ArmorMode(PlayersHorse)
	ELSEIF PlayersHorse.IsEquipped(DES_HorseArmors) && PlayersHorse.GetItemCount(DES_HorseMiscItems) == 0
		IF Debugging
			Debug.Notification(PlayersHorse.GetDisplayName() + " is being equipped for the first time.")
		ENDIF
		PlayersHorse.RemoveAllItems()
		PlayersHorse.AddItem(DES_HorseMiscItems.GetAt(i), 1)
		IF (PlayersHorse.GetEquippedArmorInSlot(45)).HasKeyword(CCHorseArmorKeyword)
			IF Debugging
				Debug.Notification(PlayersHorse.GetDisplayName() + " is wearing armor.")
			ENDIF
			(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).ChangeHorseArmor(i)
			ArmorMode(PlayersHorse)
		ELSEIF PlayersHorse.IsEquipped(DES_HorseArmors)
			IF Debugging
				Debug.Notification(PlayersHorse.GetDisplayName() + " is wearing a saddle.")
			ENDIF
			(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(DES_HorseArmors.GetAt(i) as Armor)
			SaddleMode(PlayersHorse)
		ENDIF
	ENDIF
	Alias_PlayersHorse.Clear()
ENDFUNCTION

FUNCTION EquipItem(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, Actor PlayersHorse)
{This function prevents the Player from placing items on their horses unless they have a saddle. Placing the appropriate miscitems on the horse will cause This function to match the proper visual armor and equip it. Called in an OnItemAdded EVENT.}
	IF DES_HorseMiscItems.HasForm(akBaseItem) && !PlayersHorse.IsInFaction(DES_RegisteredHorses) && PlayersHorse.GetRace() != Reindeer
		PlayersHorse.RemoveItem(akBaseItem, aiItemCount, True, akSourceContainer)
		UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", "ContainerMenu")
		Utility.Wait(0.5)
		IF RegistryTutorial
			Debug.Notification("This horse is not registered.")
		ELSE
			DES_HorseRegistryTutorial.ShowAsHelpMessage("RegistryTutorial", messageDuration, 1.0, 1)
			RegistryTutorial = true
		ENDIF
		PlayersHorse.PlayIdle(HorseIdleRearUp)
	ELSEIF !DES_HorseAllForms.HasForm(akBaseItem) && !(GetState() == "Saddled")
		PlayersHorse.RemoveItem(akBaseItem, aiItemCount, True, akSourceContainer)
		Debug.Notification(PlayersHorse.GetDisplayName() +  " isn't wearing a saddle.")
	ELSEIF DES_HorseMiscItems.HasForm(akBaseItem) && PlayersHorse.IsEquipped(DES_HorseArmors) || DES_HorseMiscItems.HasForm(akBaseItem) && PlayersHorse.GetRace() == Reindeer
		PlayersHorse.RemoveItem(akBaseItem, aiItemCount, True, akSourceContainer)
		Debug.Notification(PlayersHorse.GetDisplayName() +  " is already equipped.")
		return
	ELSEIF akBaseItem.HasKeyword(DES_ArmorKeyword)
		Int i = DES_HorseMiscItems.Find(akBaseItem as MiscObject)
		(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).ChangeHorseArmor(i)
		ArmorMode(PlayersHorse)
	ELSEIF akBaseItem.HasKeyword(DES_SaddleKeyword)
		Int i = DES_HorseMiscItems.Find(akBaseItem as MiscObject)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(DES_HorseArmors.GetAt(i) as Armor)
		SaddleMode(PlayersHorse)
	ENDIF
ENDFUNCTION

FUNCTION UnequipItem(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer, Actor PlayersHorse)
{This function monitors the horse for when the appropriate miscitems are removed. Upon removal it will revert the horse to a bareback STATE. Called in an OnItemRemoved EVENT.}
	IF DES_HorseMiscItems.HasForm(akBaseItem) && PlayersHorse.GetItemCount(DES_HorseMiscItems) >= 1 || PlayersHorse.GetRace() == Reindeer
		return
	ELSEIF akBaseItem.HasKeyword(DES_ArmorKeyword) || akBaseItem.HasKeyword(DES_SaddleKeyword)
		UnequipRunning = true
		UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", "ContainerMenu")
		PlayersHorse.RemoveItem(DES_HorseAllForms)
		(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).RemoveHorseArmor()
		IF PlayersHorse.GetNumItems() > 0 && akBaseItem.HasKeyword(DES_SaddleKeyword)
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s saddle has been emptied into your inventory.")
			PlayersHorse.RemoveAllItems(akTransferTo = PlayerRef)
		ENDIF
		UnequipMode(PlayersHorse)
	ENDIF
ENDFUNCTION

;These functions will swap the horse between the various STATEs of saddled, armored, and unequipped. The empty "ChangingHorse" STATE simply ensures that OnBeginSTATE and OnENDSTATE triggers appropriately.
FUNCTION SaddleMode(Actor PlayersHorse)
	GoToState("ChangingHorse")
	HorseToEquip = PlayersHorse
	GoToState("Saddled")
ENDFUNCTION

FUNCTION ArmorMode(Actor PlayersHorse)
	GoToState("ChangingHorse")
	HorseToEquip = PlayersHorse
	GoToState("Armored")
ENDFUNCTION

FUNCTION UnequipMode(Actor PlayersHorse)
	GoToState("ChangingHorse")
	HorseToEquip = PlayersHorse
	GoToState("Unequipped")
ENDFUNCTION

;This state will put the horse into the "Saddled Mode". It will set the carryweight to 105 (or whatever is specIFied in the INI) and make it so the horse will flee in combat.
STATE Saddled
	EVENT OnBeginSTATE()
		Actor PlayersHorse = HorseToEquip
		IF PlayersHorse == none
			PlayersHorse = Alias_PlayersHorse.getActorReference()
		ENDIF
		Debugging = papyrusinimanipulator.PullboolFromIni("Data/H2Horse.ini", "General", "Debugging", False)
		IF Debugging
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s state changed: Saddled")
		ENDIF
		PlayersHorse.SetAV("CarryWeight", (papyrusinimanipulator.PullFloatFromIni("Data/H2Horse.ini", "General", "CarryWeight", 105.0)))
		PlayersHorse.AddSpell(DES_HorseFear)
	ENDEVENT
	
	EVENT OnENDSTATE()
		Actor PlayersHorse = HorseToEquip
		IF PlayersHorse == none
			PlayersHorse = Alias_PlayersHorse.getActorReference()
		ENDIF
		PlayersHorse.RemoveSpell(DES_HorseFear)
	ENDEVENT
	
	FUNCTION SetCarryWeight(Actor PlayersHorse)
		SaddleMode(PlayersHorse)	
		IF Debugging
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s current state: Saddled")
		ENDIF
		PlayersHorse.SetAV("CarryWeight", (papyrusinimanipulator.PullFloatFromIni("Data/H2Horse.ini", "General", "CarryWeight", 105.0)))
	ENDFUNCTION
ENDSTATE

;This state will put the horse into the "Armored Mode". It will set the carryweight to 0, prEVENT items from being placed on it, and make it so the horse will fight alongside you. A damage buff is given to the horse as well.
STATE Armored
	EVENT OnBeginSTATE()
		Actor PlayersHorse = HorseToEquip
		IF PlayersHorse == none
			PlayersHorse = Alias_PlayersHorse.getActorReference()
		ENDIF
		Debugging = papyrusinimanipulator.PullboolFromIni("Data/H2Horse.ini", "General", "Debugging", False)
		IF Debugging
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s state changed: Armored")
		ENDIF
		PlayersHorse.SetAV("CarryWeight", 0.0)
		PlayersHorse.AddSpell(DES_HorseRally)
	ENDEVENT
	
	EVENT OnENDSTATE()
		Actor PlayersHorse = HorseToEquip
		IF PlayersHorse == none
			PlayersHorse = Alias_PlayersHorse.getActorReference()
		ENDIF
		PlayersHorse.RemoveSpell(DES_HorseRally)
	ENDEVENT
	
	FUNCTION SetCarryWeight(Actor PlayersHorse)
		ArmorMode(PlayersHorse)
		IF Debugging
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s current state: Armored")
		ENDIF
		PlayersHorse.SetAV("CarryWeight", 0.0)
	ENDFUNCTION
ENDSTATE

;This state will put the horse into the "Unequipped Mode". It will remove all visual items from the horse and it will appear bareback. From there the horse is essentially reverted to vanilla behavior.
STATE Unequipped
	EVENT OnBeginSTATE()
		Actor PlayersHorse = HorseToEquip
		IF PlayersHorse == none
			PlayersHorse = Alias_PlayersHorse.getActorReference()
		ENDIF
		Debugging = papyrusinimanipulator.PullboolFromIni("Data/H2Horse.ini", "General", "Debugging", False)
		IF Debugging
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s state changed: Unequipped")
		ENDIF
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(none)
		PlayersHorse.SetOutfit(DES_NakedHorseOutfit)
		PlayersHorse.SetAV("CarryWeight", BaseCarryWeight)		
		UnequipRunning = False
	ENDEVENT
	
	FUNCTION SetCarryWeight(Actor PlayersHorse)
		UnequipMode(PlayersHorse)
		IF Debugging
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s current state: Unequipped")
		ENDIF
		PlayersHorse.SetAV("CarryWeight", BaseCarryWeight)
	ENDFUNCTION
ENDSTATE

;This state is intentionally empty.
STATE ChangingHorse

ENDSTATE