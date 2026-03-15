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
	--Once per turn, if you do not have any cards in your pendulum zones, or if you control at least 1 "CREATION" Pendulum monster in your Pendulum Zone: you can target 1 "Ringshoku - Evolutions Engineer" in your deck or gy, either add that card to your hand, or, if you control a "CREATION" Pendulum monster in the pendulum zone, Special Summon it to your field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
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
--Once per turn, if you do not have any cards in your pendulum zones, or if you control at least 1 "CREATION" Pendulum monster in your Pendulum Zone: you can target 1 "Ringshoku - Evolutions Engineer" in your deck or gy, either add that card to your hand, or, if you control a "CREATION" Pendulum monster in the pendulum zone, Special Summon it to your field.
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	 if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==0 or Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x8df) then return true end
end
function s.thfilter(c)
	return c:IsCode(88880001) and c:IsAbleToHand()
end
function s.pcfilter(c)
	return c:IsSetCard(0x8df)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local pend_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_PZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	if g:GetCount()>0 then
		if pend_chk then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end