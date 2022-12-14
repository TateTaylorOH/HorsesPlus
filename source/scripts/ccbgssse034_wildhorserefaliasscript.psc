;/ Decompiled by Champollion V1.0.1
Source   : ccBGSSSE034_WildHorseRefAliasScript.psc
Modified : 2021-08-19 11:15:00
Compiled : 2021-08-24 17:21:27
User     : builds
Computer : RKVBGSGPUVM04
/;
scriptName ccBGSSSE034_WildHorseRefAliasScript extends ReferenceAlias
{Handles the "mini-game" for taming wild horses.}

;-- Properties --------------------------------------
Int property UniqueQuestStageToSet = 0 auto
faction property PlayerFaction auto
faction property ccBGSSSE034_WildHorseFaction auto
faction property PlayerHorseFaction auto
idle property HorseIdleRearUp auto
Int property HorseBuckMin = 5 auto
message property WildHorseMessageTamed auto
Bool property HasUniqueQuest = false auto
ReferenceAlias property CurrentName auto hidden
{Pointer to the current RefAlias name being used on the horse. This must be cleared before a new name can apply, so this pointer helps us avoid more loops while renaming.}
Int property HorseBuckMax = 8 auto
ccbgssse034_wildhorsesquestscript property WildHorsesQuestScript auto
Bool property IsHorseTamed = false auto hidden
quest property UniqueQuest auto
sound property NPCHorseHeadShakeTamed auto

;-- Variables ---------------------------------------
Int ChancePlayerEjected = 30
Actor PlayerREF
Int HorseBuckTimeMin = 2
Actor HorseActorREF
Bool SkipTamingMiniGame = false
Int HorseBuckTameThreshold
Int HorseBuckCount = 0
Int MaxTimesEjectPlayer = 2
Int HorseBuckTimeMax = 5
Int PlayerEjectCount = 0

;-- Functions ---------------------------------------

function TameHorse()
{Moves horse into player faction, stops it from bucking, etc.}

	debug.trace("ccBGSSSE034: Player has tamed horse, stopping mini-game.", 0)
	self.GetActorReference().SetFactionRank(PlayerHorseFaction, 1)
	self.GetActorReference().SetFactionOwner(PlayerFaction)
	game.IncrementStat("Horses Owned", 1)
	utility.Wait(0.500000)
	WildHorseMessageTamed.Show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	IsHorseTamed = true
	self.GotoState("HorseTamed")
	if HasUniqueQuest
		UniqueQuest.SetStage(UniqueQuestStageToSet)
		WildHorsesQuestScript.CheckAndClearQuestItems()
	endIf
endFunction

function DoHorseBuck()

	if self.IsPlayerMountedOnThisHorse() && !IsHorseTamed
		Int Roll = utility.RandomInt(0, 100)
		self.GetActorReference().PlayIdle(HorseIdleRearUp)
		HorseBuckCount += 1
		if HorseBuckCount >= HorseBuckTameThreshold
			self.TameHorse()
		endIf
		if !IsHorseTamed && Roll <= ChancePlayerEjected && PlayerEjectCount < MaxTimesEjectPlayer
			utility.Wait(0.350000)
			self.BuckPlayerFromHorse()
			self.UnregisterForUpdate()
		else
			self.RegisterForSingleUpdate(utility.RandomInt(HorseBuckTimeMin, HorseBuckTimeMax) as Float)
		endIf
	endIf
endFunction

; Skipped compiler generated GotoState

function BuckPlayerFromHorse()
{Launches the player backward off the horse by inverting their Z axis and getting the sin/cos, then applying ragdoll+Havok impulse that direction.}

	debug.trace("ccBGSSSE034: Player is being ejected from horse, stopping mini-game.", 0)
	PlayerEjectCount += 1
	Int PlayerAngleOffset = (PlayerREF.GetAngleZ() as Int + 180) % 360
	Float offsetX = math.sin(PlayerAngleOffset as Float)
	Float offsetY = math.cos(PlayerAngleOffset as Float)
	Int distanceToMove = 25
	Int angleToMove = 45
	Float horseOffsetX = distanceToMove as Float * math.sin(self.GetRef().GetAngleZ() + angleToMove as Float)
	Float horseOFfsetY = distanceToMove as Float * math.cos(self.GetRef().GetAngleZ() + angleToMove as Float)
	PlayerREF.PushActorAway(PlayerREF, 8 as Float)
	PlayerREF.ApplyHavokImpulse(offsetX, offsetY, 0.500000, 135 as Float)
	PlayerREF.ApplyHavokImpulse(offsetX, offsetY, 0.500000, 135 as Float)
	HorseActorREF.MoveTo(HorseActorREF as objectreference, horseOffsetX, horseOFfsetY, 0 as Float, true)
endFunction

function OnInit()

	HorseBuckTameThreshold = utility.RandomInt(HorseBuckMin, HorseBuckMax)
	PlayerREF = game.GetPlayer()
endFunction

function StopHorseFastTravel()

	debug.trace("ccBGSSSE034: Resetting horse ownership to try and stop fast travel", 0)
	HorseActorREF.SetFactionOwner(ccBGSSSE034_WildHorseFaction)
endFunction

; Skipped compiler generated GetState

Bool function IsPlayerMountedOnThisHorse()
{Determines if player is mounted or in the act of getting off a horse, which still counts as being mounted.}

	utility.Wait(0.100000)
	if self.GetActorReference().IsBeingRidden() && PlayerREF.IsOnMount() && PlayerREF.GetSitState() != 4
		return true
	else
		return false
	endIf
endFunction

;-- State -------------------------------------------
auto state HorseWild

	function OnActivate(objectreference akActionRef)

		HorseActorREF = self.GetActorReference()
		debug.trace(HorseActorREF as String, 0)
		if akActionRef == PlayerREF as objectreference
			if SkipTamingMiniGame
				self.TameHorse()
			else
				utility.Wait(4.00000)
				if self.IsPlayerMountedOnThisHorse()
					debug.trace("ccBGSSSE034: Player is on horse, start bucking mini-game", 0)
					WildHorsesQuestScript.ShowTutorial()
					utility.Wait(1.00000)
					self.DoHorseBuck()
				else
					debug.trace("ccBGSSSE034: Player is not on horse, stop bucking mini-game", 0)
					self.UnregisterForUpdate()
				endIf
			endIf
		endIf
	endFunction

	function OnUpdate()

		self.DoHorseBuck()
	endFunction
endState

;-- State -------------------------------------------
state HorseTamed
endState
