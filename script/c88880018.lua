--CREATION-Eyes Dimensional Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,10,2)--,s.ovfilter,aux.Stringid(s,0),2,s.xyzop)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	--You can also Xyz Summon this card by using 2 scale 4 monsters from your pendulum zone as material. 
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	--If this card is Xyz Summoned using 2 monsters in the pendulum zone: Add 2 "CREATION" Pendulum  monsters from your deck to your hand. This Effect of "CREATION-Eyes Dimensional Dragon" can only be used once per turn. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.addcon)
	e1:SetTarget(s.addtg)
	e1:SetOperation(s.addop)
	c:RegisterEffect(e1)
	--You can use 1 material and shuffle 1 spell card in your GY or banishment: add 1 Spell card from your deck to your hand with a different name, but cards with that name are banished when they leave the field, then, this card gains 100 ATK for each card on the field until the end of the turn. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.spetg)
	e2:SetOperation(s.speop)
	c:RegisterEffect(e2)
	--If this card would be destroyed, you can destroy all cards in the pendulum zones and if you do, gain 300 LP for the comnbined scale the destroyed monsters had on the field, then place this card in the pendulum scale.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	--(Pendulum Effects)
	--You can discard 1 "CREATION" spell card or banish 1 "CREATION" Spell card from your GY: Special Summon 1 "CREATION" Pendulum Monster from your Pendulum Zone, then, if you banished a "CREATION" Spell card to activate this effect, you can add 1 "CREATION" Spell Card from your deck to your hand, or if you control a Xyz Monster With a "CREATION" monster as material, 1 Spell Card from your deck or GY. This Effect of "CREATION-Eyes Dimensional Dragon" can only be used once per turn.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,1})
	e4:SetCost(s.pspco)
	e4:SetTarget(s.psptg)
	e4:SetOperation(s.pspop)
	c:RegisterEffect(e4)
	--Once per turn: You can target 1 other card in a Pendulum Zone; all cards in the Pendulum Zones Pendulum Scale becomes equal to that target's Pendulum Scale, until the end of this turn. 
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,6))
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
end
s.pendulum_level=10
function s.ovfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_PZONE,0) and c:IsSetCard(0x8df) and (c:GetScale()==10)
end
function s.xyzcon(e,c,og)
	local tp=e:GetHandlerPlayer()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2 and tc1:IsSetCard(0x8df) and tc2:IsSetCard(0x8df)) then return false end
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	if scl1>scl2 then scl1,scl2=scl2,scl1 end
	return scl1==10 and scl2==10
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
	aux.Stringid(id,0)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_PZONE,0,2,nil) 
		and Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_PZONE,0,2,2,nil)
	if g1:GetCount()>0 then
		c:SetMaterial(og)
		Duel.Overlay(c,g1)
	end
end
--If this card is Xyz Summoned using 2 monsters in the pendulum zone: Add 2 "CREATION" Pendulum  monsters from your deck to your hand. This Effect of "CREATION-Eyes Dimensional Dragon" can only be used once per turn. 
function s.filter(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	return e:GetHandler():IsXyzSummoned() and g:GetFirst():IsPreviousLocation(LOCATION_PZONE) and g:GetCount()==2
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,2,2,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--You can use 1 material: target 1 spell card in your GY; shuffle that card into the deck, then, add 1 Spell card from your deck to your hand with a different name, but cards with that name are banished when they leave the field, and if you do, this card gains 100 ATK for each card on the field until the end of the turn.
function s.tgspefil(c,tp)
	return c:IsType(TYPE_SPELL) and Duel.IsExistingMatchingCard(s.spefil,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.spefil(c,code)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand() and not c:IsCode(code)
end
function s.spefil1(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
function s.spetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spefil,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.spefil1,tp,LOCATION_GRAVE,0,1,nil)end
	local tc=Duel.SelectTarget(tp,s.tgspefil,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,LOCATION_DECK)
end
function s.speop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.BreakEffect()
	local g=Duel.SelectMatchingCard(tp,s.spefil,tp,LOCATION_DECK,0,1,1,nil,code)
	local code2=g:GetFirst():GetCode()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3300)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTarget(function(_,c) return c:IsCode(code2) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetValue(LOCATION_REMOVED)
	Duel.RegisterEffect(e1,tp,true)
	if Duel.SendtoHand(g,nil,REASON_EFFECT) then
		local ct=Duel.GetMatchingGroupCount(nil,c:GetControler(),LOCATION_ONFIELD,0,nil)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
	end
	Duel.ConfirmCards(1-tp,g)
end
--If this card would be destroyed, you can destroy all cards in the pendulum zones and if you do, gain 300 LP for the comnbined scale the destroyed monsters had on the field, then place this card in the pendulum scale.
function s.repfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsDestructable()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(repfil,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil,c) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,nil,c)
	if Duel.SelectEffectYesNo(tp,c,96) then
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.repfilter,tp,LOCATION_PZONE,LOCATION_PZONE,nil,c,e)
	Duel.Destroy(g,REASON_EFFECT|REASON_REPLACE)
	if #g>0 then
		local val=g:GetSum(Card.GetScale)*300
		Duel.Recover(tp,val,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end 
--You can discard 1 "CREATION" spell card or banish 1 "CREATION" Spell card from your GY: Special Summon 1 "CREATION" Pendulum Monster from your Pendulum Zone, then, if you banished a "CREATION" Spell card to activate this effect, you can add 1 "CREATION" Spell Card from your deck to your hand, or if you control a Xyz Monster With a "CREATION" monster as material, 1 Spell Card from your deck or GY. This Effect of "CREATION-Eyes Dimensional Dragon" can only be used once per turn.
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x8df) and c:IsDiscardable()
end
function s.cfilter2(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x8df)
end
function s.pspfil(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x8df)
end
function s.spefilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand() and c:IsSetCard(0x8df)
end
function s.spefilter2(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.ovfilt(c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.ovfilt2,1,nil)
end
function s.ovfilt2(c)
	return c:IsSetCard(0x8df)
end
function s.pspco(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,nil) then
		if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) then
			local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
			Duel.Remove(g,POS_FACEUP,REASON_COST)
			e:SetLabel(1)
		else
			if Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
				local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
				Duel.Remove(g,POS_FACEUP,REASON_COST)
				e:SetLabel(1)
			else
				Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST|REASON_DISCARD)
				e:SetLabel(0)
			end
		end
	else
		Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST|REASON_DISCARD)
		e:SetLabel(0)
	end
end
function s.psptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.pspfil,tp,LOCATION_PZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function s.pspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.pspfil,tp,LOCATION_PZONE,0,1,1,nil)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		if e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.spefillter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			if Duel.IsExistingMatchingCard(s.ovfilt,tp,LOCATION_MZONE,0,1,nil) then
				Duel.BreakEffect()
				local tc=Duel.SelectMatchingCard(tp,s.spefilter2,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			else
				Duel.BreakEffect()
				local tc=Duel.SelectMatchingCard(tp,s.spefilter,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	end
end
--Once per turn: You can target 1 other card in a Pendulum Zone; all cards in the Pendulum Zones Pendulum Scale becomes equal to that target's Pendulum Scale, until the end of this turn. 
function s.penfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and s.atkfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.penfilter,tp,LOCATION_PZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.penfilter,tp,LOCATION_PZONE,0,1,1,c)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local scl=tc:GetScale()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_LSCALE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetTargetRange(LOCATION_PZONE,LOCATION_PZONE)
	e1:SetValue(scl)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RSCALE)
	Duel.RegisterEffect(e2,tp)
end