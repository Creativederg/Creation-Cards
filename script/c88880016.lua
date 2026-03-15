--CREATION-Eyes Aether Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,8,2)--,s.ovfilter,aux.Stringid(s,0),2,s.xyzop)
	c:EnableReviveLimit()
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
	--Once per turn, you can target 1 Face-Up Pendulum Monster you control: Destroy it, and if you do, this card gains 500 ATK, then, all monsters you control gains 300 ATK and DEF for each of that monsters scales until the end of the turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Each time a Pendulum monster is destroyed by a "CREATION" Xyz Monsters effect: You can target 1 card your opponent controls; destroy it.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.revcon)
	e1:SetTarget(s.revtg)
	e1:SetOperation(s.revop)
	c:RegisterEffect(e1)
	--Twice per turn (Quick Effect): you can use 1 material: Draw 1 card and reveal it. If you revealed a "CREATION" Pendulum monster: You can Special Summon it, then, all monsters your opponent controls lose 300 ATK for its scale.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetCost(s.draco)
	e2:SetTarget(s.dratg)
	e2:SetOperation(s.draop)
	c:RegisterEffect(e2)
end
function s.ovfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_PZONE,0) and c:IsSetCard(0x8df) and (c:GetLeftScale()==8 or c:GetRightScale()==8)
end
function s.xyzcon(e,c,og)
	local tp=e:GetHandlerPlayer()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2 and tc1:IsSetCard(0x8df) and tc2:IsSetCard(0x8df)) then return false end
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	if scl1>scl2 then scl1,scl2=scl2,scl1 end
	return scl1==8 and scl2==8
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
--Once per turn, you can target 1 Face-Up Pendulum Monster you control: Destroy it, and if you do, this card gains 500 ATK, then, all monsters you control gains 300 ATK and DEF for each of that monsters scales until the end of the turn.
function s.desfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetScale()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetValue(atk*300)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		Duel.RegisterEffect(e3,tp)
	end
end
--Each time a Pendulum monster is destroyed by a "CREATION" Xyz Monsters effect: You can target 1 card your opponent controls; destroy it.
function s.revfilter(c,tp)
	return  c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_DESTROY)
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.revfilter,1,nil,tp) and re and re:GetHandler():IsSetCard(0x8df)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local pd=eg:FilterCount(s.revfilter,nil,tp)
	local ct=0
	local tc=Duel.GetFirstTarget()
		Duel.Destroy(tc,REASON_EFFECT)
end
--Twice per turn (Quick Effect): you can use 1 material: Draw 1 card and reveal it. If you revealed a "CREATION" Pendulum monster: You can Special Summon it, then, all monsters your opponent controls lose 300 ATK for its scale.
function s.draco(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.dratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.draop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,dc)
	if dc:IsMonster() and (dc:IsSetCard(0x8df) and dc:IsType(TYPE_PENDULUM)) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
		Duel.BreakEffect()
		local atk=dc:GetScale()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetValue(atk*-300)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
	Duel.ShuffleHand(tp)
end