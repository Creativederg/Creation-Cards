--Ringshoku - Evolutions Engineer 
local s,id,o=GetID()
function s.initial_effect(c)
	--When this card is Normal Summoned or Special Summoned, while you either do not control a card(s) in your pendulum zone, or you control at least 1 "CREATION" Pendulum monster in the pendulum zone: add 1 "CREATION" Pendulum monster from your deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCondition(s.summoncon)
	e1:SetTarget(s.summontag)
	e1:SetOperation(s.summoneff)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--When you Xyz summon a "CREATION" Xyz monster using monsters in your pendulum zone as materials, you can target 1 "CREATION"Xyz monster you control (quick effect): attach this card to the target.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_ONFIELD)
	e3:SetCondition(s.matcn)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
	--A "CREATION" Xyz Monster that has this card as material gains the following effect:   
	--● This card is unaffected by your opponents cards or effects that would change this cards ATK/DEF.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_XMATERIAL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(s.xyzcon)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end

--When this card is Normal Summoned or Special Summoned, while you either do not control a card(s) in your pendulum zone, or you control at least 1 "CREATION" Pendulum monster in the pendulum zone: add 1 "CREATION" Pendulum monster from your deck to your hand.
function s.summoncon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==0 or Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x8df) then return true end
end
function s.filter(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.summontag(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.summoneff(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--When you Xyz summon a "CREATION" Xyz monster using monsters in your pendulum zone as materials, you can target 1 "CREATION"Xyz monster you control (quick effect): attach this card to the target.
function s.eqcfilter(c,tp)
	return  c:IsType(TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp) --and c:IsSetCard(0x8df)
end
function s.matfilter(c)
	return c:IsFaceup()  and c:IsType(TYPE_XYZ) --and c:IsSetCard(0x8df)
end
function s.matcn(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqcfilter,1,nil,tp)

end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	--if(e:GetHandler():IsLocation(LOCATION_GRAVE)) then
		--Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	--end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end
--A "CREATION" Xyz Monster that has this card as material gains the following effect:   
--● This card is unaffected by your opponents cards or effects that would change a monster's' ATK/DEF.
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSetCard(0x8df) and e:GetHandler():IsType(TYPE_XYZ)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and (te:IsHasCategory(CATEGORY_ATKCHANGE) or te:IsHasCategory(CATEGORY_DEFCHANGE))
end