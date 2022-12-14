Scriptname DES_HorseEquipScript extends ReferenceAlias  

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

Formlist Property DES_HorseMiscItems auto
Formlist Property DES_HorseArmors auto
Formlist Property DES_HorseAllForms auto
Bool Property UnequipRunning auto
Actor Property PlayerRef auto
Spell Property DES_TrampleCloak auto
Spell Property DES_HorseFear auto
Spell Property DES_HorseRally auto
Quest Property CCHorseArmorDialogueQuest auto
Quest Property ccBGSSSE034_HorseSaddleQuest auto
Keyword Property DES_ArmorKeyword auto
Keyword Property DES_SaddleKeyword auto
Quest Property DES_RenameHorseQuest auto

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	Actor PlayersHorse = self.GetActorReference()
	if !DES_HorseAllForms.HasForm(akBaseItem) && (DES_RenameHorseQuest as DES_HorseInventoryScript).SaddleBags == False
		PlayersHorse.RemoveItem(akBaseItem, aiItemCount, True, akSourceContainer)
		Debug.Notification(PlayersHorse.GetDisplayName() +  " isn't wearing a saddle.")
	elseif DES_HorseMiscItems.HasForm(akBaseItem) && PlayersHorse.IsEquipped(DES_HorseArmors)
		PlayersHorse.RemoveItem(akBaseItem, aiItemCount, True, akSourceContainer)
		Debug.Notification(PlayersHorse.GetDisplayName() +  " is already equipped.")
		return
	elseif akBaseItem == CCHorseArmorMiscArmorElven
		PlayersHorse.RemoveItem(DES_HorseArmors)
		(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).ChangeHorseArmor(0)
		EquipHorseArmor()
	elseif akBaseItem == CCHorseArmorMiscArmorSteel
		PlayersHorse.RemoveItem(DES_HorseArmors)
		(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).ChangeHorseArmor(1)
		EquipHorseArmor()
	elseif akBaseItem == DES_Saddle
		PlayersHorse.RemoveItem(DES_HorseArmors)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(HorseSaddle)
		EquipHorseSaddle()
	elseif akBaseItem == DES_WhiteSaddle
		PlayersHorse.RemoveItem(DES_HorseArmors)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(ccBGSSSE034_HorseSaddleLight)
		EquipHorseSaddle()
	elseif akBaseItem == DES_ImperialSaddle
		PlayersHorse.RemoveItem(DES_HorseArmors)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(HorseSaddleImperial)
		EquipHorseSaddle()		
	elseif akBaseItem == DES_StormcloakSaddle
		PlayersHorse.RemoveItem(DES_HorseArmors)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(ccBGSSSE034_HorseSaddleStormcloak)
		EquipHorseSaddle()
	elseif akBaseItem == DES_DarkBrotherhoodSaddle
		PlayersHorse.RemoveItem(DES_HorseArmors)
		(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(HorseSaddleShadowmere)
		EquipHorseSaddle()
	endif
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	Actor PlayersHorse = self.GetActorReference()
	if DES_HorseMiscItems.HasForm(akBaseItem) && PlayersHorse.GetItemCount(DES_HorseMiscItems) >= 1
		return
	elseif akBaseItem.HasKeyword(DES_ArmorKeyword) || akBaseItem.HasKeyword(DES_SaddleKeyword)
		UnequipRunning = true
		UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", "ContainerMenu")
		PlayersHorse.RemoveItem(DES_HorseAllForms)
		(CCHorseArmorDialogueQuest as CCHorseArmorChangeScript).RemoveHorseArmor()
		IF PlayersHorse.GetNumItems() > 0 && akBaseItem.HasKeyword(DES_SaddleKeyword)
			Debug.Notification(PlayersHorse.GetDisplayName() + "'s saddle has been emptied into your inventory.")
			PlayersHorse.RemoveAllItems(akTransferTo = PlayerRef)
		ENDIF
		UnequipHorse()
	endif
EndEvent

Function UnequipHorse()
	Actor PlayersHorse = self.GetActorReference()
	(ccBGSSSE034_HorseSaddleQuest as ccbgssse034_saddlequestscript).ChangeHorseSaddle(none)
	PlayersHorse.SetAV("CarryWeight", 999.0)
	PlayersHorse.RemoveSpell(DES_TrampleCloak)
	PlayersHorse.RemoveSpell(DES_HorseRally)
	PlayersHorse.RemoveSpell(DES_HorseFear)
	UnequipRunning = False
EndFunction

Function EquipHorseArmor()
	Actor PlayersHorse = self.GetActorReference()
	PlayersHorse.SetAV("CarryWeight", 0.0)
	PlayersHorse.AddSpell(DES_TrampleCloak)
	PlayersHorse.AddSpell(DES_HorseRally)
	(DES_RenameHorseQuest as DES_HorseInventoryScript).SaddleBags = false
EndFunction

Function EquipHorseSaddle()
	Actor PlayersHorse = self.GetActorReference()
	PlayersHorse.SetAV("CarryWeight", 100.0)
	PlayersHorse.AddSpell(DES_HorseFear)
	(DES_RenameHorseQuest as DES_HorseInventoryScript).SaddleBags = true
EndFunction