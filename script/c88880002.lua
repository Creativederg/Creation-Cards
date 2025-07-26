--Rafaquel, the eternal City of Evolution
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--If you control a "CREATION" Xyz monster that has a "Ringshoku - Evolutions Engineer" as material: All "CREATION" monsters you control gain 100 ATK for each card you control.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Once per turn, if you do not have any cards in your pendulum zones, or if you control at least 1 "CREATION" Pendulum monster in your Pendulum Zone: you can target 1 "Ringshoku - Evolutions Engineer" in your Deck or GY, then activate 1 of the following effects based on its current location:
	--● Deck: add the targeted monster to hand.
	--● GY: Special Summon the targeted monster.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_TYPE_ACTIVATE)
	e2:SetCountLimit(1)
	--e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	--e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.xyzfilter2(c)
	return c:IsCode(88880001)
end
function s.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayGroup():IsExists(s.xyzfilter2,1,nil) and c:IsSetCard(0x8df)
end
function s.atkcon(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.atktg(e,c)
	return c:IsSetCard(0x8df)
end
function s.atkval(e,c)
	local ct=Duel.GetMatchingGroupCount(nil,c:GetControler(),LOCATION_ONFIELD,0,nil)
	if ct>0 then
		return ct*100
	else
		return 0
	end
end
--Once per turn, if you do not have any cards in your pendulum zones, or if you control at least 1 "CREATION" Pendulum monster in your Pendulum Zone: you can target 1 "Ringshoku - Evolutions Engineer" in your Deck or GY, then activate 1 of the following effects based on its current location:
--● Deck: add the targeted monster to hand.
--● GY: Special Summon the targeted monster.

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) or Duel.IsExistingTarget(s.filter,tp,LOCATION_DECK,0,1,nill,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end