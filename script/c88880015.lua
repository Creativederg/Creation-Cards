--CREATION-Eyes Atomic Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,2,2)--,s.ovfilter,aux.Stringid(s,0),2,s.xyzop)
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
	--When this card is Xyz Summoned using 2 monsters with different levels: add 2 "CREATION" Pendulum monsters from face-up in your extra deck or GY to your hand. 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.addcon)
	e1:SetTarget(s.addtg)
	e1:SetOperation(s.addop)
	c:RegisterEffect(e1)
	--You can use 2 materials: Special Summon, 2 "CREATION" monsters from your deck, or, if you control 1 other "CREATION" Xyz Monster, up to 2 monster(s) from  your deck or GY and if you do, destroy 1 card in your Pendulum Zone. During the end phase of the turn this effect was activated: Place this card in the Pendulum Zone.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.speco)
	e2:SetTarget(s.spetg)
	e2:SetOperation(s.speop)
	c:RegisterEffect(e2)
	--Once per turn: You can target 1 card you control and 1 card your opponent controls; Destroy those cards, then, if you destroyed a "CREATION" Pendulum monster, you can Special Summon 1 monster from your deck. 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--Once per turn: You can target 1 other card in a Pendulum Zone; this card's Pendulum Scale becomes equal to that target's Pendulum Scale, until the end of this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,6))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
end
s.pendulum_level=2
function s.ovfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_PZONE,0) and c:IsSetCard(0x8df) and (c:GetLeftScale()==2 or c:GetRightScale()==2)
end
function s.xyzcon(e,c,og)
	local tp=e:GetHandlerPlayer()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2 and tc1:IsSetCard(0x8df) and tc2:IsSetCard(0x8df)) then return false end
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	if scl1>scl2 then scl1,scl2=scl2,scl1 end
	return scl1==2 and scl2==2
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
--When this card is Xyz Summoned using 2 monsters with different levels: add 2 "CREATION" Pendulum monsters from face-up in your extra deck or GY to your hand. 
function s.valcheck(e,c)
	local g=c:GetMaterial()--:Filter(Card.IsLevel,nil)
	if g:GetClassCount(Card.GetLevel)==2 then e:GetLabelObject():SetLabel(1) end
end
function s.filter(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM) and c:IsPosition(POS_FACEUP)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	return e:GetHandler():IsXyzSummoned() and g:GetClassCount(Card.GetLevel)==2
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,2,2,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--You can use 2 materials: Special Summon, 2 "CREATION" monsters from your deck, or, if you control 1 other "CREATION" Xyz Monster, up to 2 monster(s) from  your deck or GY and if you do, destroy 1 card in your Pendulum Zone. During the end phase of the turn this effect was activated: Place this card in the Pendulum Zone.
function s.speco(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.spefil(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_MONSTER)
end
function s.spefil2(c)
	return c:IsType(TYPE_MONSTER)
end
function s.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x8df)
end
function s.spetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,0,1,nil) and (Duel.IsExistingMatchingCard(s.spefil,tp,LOCATION_DECK,0,2,nil) or Duel.IsExistingMatchingCard(s.spefil2,tp,LOCATION_DECK|LOCATION_GRAVE,0,2,nil))end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.speop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.spefil2,tp,LOCATION_DECK|LOCATION_GRAVE,0,2,2,nil)
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_EXTRA,0,1,1,nil)
			Duel.Destroy(g,REASON_EFFECT)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetOperation(s.pendop)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.spefil,tp,LOCATION_DECK,0,2,2,nil)
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
			Duel.Destroy(g,REASON_EFFECT)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetOperation(s.pendop)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.pendop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
--Once per turn: You can target 1 card you control and 1 card your opponent controls; Destroy those cards, then, if you destroyed a "CREATION" Pendulum monster, you can Special Summon 1 monster from your deck. 
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.monfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		local sg=g:GetFirst()
		if c:IsRelateToEffect(e) and sg:IsSetCard(0x8df) and sg:IsType(TYPE_PENDULUM) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			local tc=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
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
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
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