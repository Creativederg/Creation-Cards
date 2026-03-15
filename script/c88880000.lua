--CREATION - Harbinger Riko
local s,id,o=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--When an "OTNN" or "CREATION" Xyz Monster you control detaches material to activate its effect: You can attach this card to that Xyz Monster as Xyz Material. Also, if the detached material was a "CREATION" Pendulum Monster, shuffle that card into the Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DETACH_MATERIAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.reccon)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--Once per turn: You can target 1 other card in a Pendulum Zone; this card's Pendulum Scale becomes equal to that target's Pendulum Scale, until the end of this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	--If this card is Normal or Special Summoned, while you do not control an "OTNN" or "CREATION" Xyz Monster: You can either Tribute this card, OR, if you control exactly 1 "CREATION" Pendulum Monster in your Pendulum Zone, you can place this card in your Pendulum Zone; Special Summon 1 "OTNN" Xyz Monster or 1 "CREATION" Xyz Monster that is Rank 4 or lower, from your Extra Deck, using 1 "OTNN" monster you control that is not an Xyz Monster or 1 card in your Pendulum Zone as material. You can only use this effect of "CREATION - Harbinger Riko" once per turn. 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.sumcon)
	e3:SetCost(s.sumcost)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--An "OTNN" or "CREATION" Xyz Monster that has this card as material gains the following effect: ● If this card battles, this card gains half the atk of the attack target, during damage calculation only.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCondition(s.atkcon)
	e5:SetTarget(s.atktg)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
--When an "OTNN" or "CREATION" Xyz Monster you control detaches material to activate its effect: You can attach this card to that Xyz Monster as Xyz Material. Also, if the detached material was a "CREATION" Pendulum Monster, shuffle that card into the Deck.
function s.recfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8df) 
end
function s.ovfilter(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_LOST_TARGET==0 and re:IsMonsterEffect() and (re:GetHandler():IsSetCard(0x8df) or re:GetHandler():IsSetCard(0x993))
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	--local ct=Duel.GetMatchingGroupCount(s.recfilter,tp,LOCATION_GRAVE,0,nil)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
		if (tc:IsSetCard(0x8df) or tc:IsSetCard(0x993)) and tc:IsType(TYPE_XYZ) then
			local og=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil)
			Duel.SendtoDeck(og,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end 
	end
end
--Once per turn: You can target 1 other card in a Pendulum Zone; this card's Pendulum Scale becomes equal to that target's Pendulum Scale, until the end of this turn.
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
	local scl=tc:GetLeftScale()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LSCALE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(scl)
	e:GetHandler():RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RSCALE)
	e:GetHandler():RegisterEffect(e2)
end
----If this card is Normal or Special Summoned, while you do not control an "OTNN" or "CREATION" Xyz Monster: You can either Tribute this card, OR, if you control exactly 1 "CREATION" Pendulum Monster in your Pendulum Zone, you can place this card in your Pendulum Zone; Special Summon 1 "OTNN" Xyz Monster or 1 "CREATION" Xyz Monster that is Rank 4 or lower, from your Extra Deck, using 1 "OTNN" monster you control that is not an Xyz Monster or 1 card in your Pendulum Zone as material. You can only use this effect of "CREATION - Harbinger Riko" once per turn. 
function s.spfilter(c,e,tp)
  return (c:IsSetCard(0x993) or (c:IsSetCard(0x8df) and c:IsRankBelow(4))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_XYZ)
end
function s.spfilter2(c,e,tp)
  return ((c:IsSetCard(0x993) and e:GetHandler():IsCanBeXyzMaterial(c,tp) and c:IsLocation(LOCATION_MZONE)) or (c:IsType(TYPE_PENDULUM) and e:GetHandler():IsCanBeXyzMaterial(c,tp) and c:IsLocation(LOCATION_PZONE)))
end
function s.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and (c:IsSetCard(0x993) or c:IsSetCard(0x8df))
end
function s.sumpenfil(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.sumcon(e)
	return not Duel.IsExistingMatchingCard(s.sumfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local c=e:GetHandler()
	if c:GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>-1 and c:IsReleasable() end
	if Duel.IsExistingMatchingCard(s.sumpenfil,tp,LOCATION_PZONE,0,1,nil)==1 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		Duel.Release(c,REASON_COST)
	end
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local ov=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
		local sc=g:GetFirst()
		if sc then
			sc:SetMaterial(ov)
			Duel.Overlay(sc,ov)
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttacker()==e:GetHandler() and (e:GetHandler():IsSetCard(0x8df) or e:GetHandler():IsSetCard(0x993)) and Duel.GetAttackTarget()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local at=Duel.GetAttackTarget():GetAttack()/2
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE)
		e1:SetValue(at)
		c:RegisterEffect(e1)
	end
end