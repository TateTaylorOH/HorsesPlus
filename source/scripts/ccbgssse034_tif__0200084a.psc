;/ Decompiled by Champollion V1.0.1
Source   : ccBGSSSE034_TIF__0200084A.psc
ModIFied : 2021-08-19 11:15:00
Compiled : 2021-08-24 17:21:27
User     : builds
Computer : RKVBGSGPUVM04
/;
scriptName ccBGSSSE034_TIF__0200084A extends TopicInfo hidden

;-- Properties --------------------------------------
armor property SaddleStormcloak auto

;-- Variables ---------------------------------------

;-- FUNCTIONs ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GoToState

FUNCTION Fragment_0(ObjectReference akSpeakerRef)

	actor akSpeaker = akSpeakerRef as actor
	(self.GetOwningQuest() as ccbgssse034_saddlequestscript).ChangeHorseSaddle(SaddleStormcloak)
ENDFUNCTION
