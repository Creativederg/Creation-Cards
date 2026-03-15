--CREATION - World Wall
local s,id,o=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--When your opponent declares a direct attack, or when an opponent's monster declares an attack against your "CREATION" Xyz Monster: You can shuffle 1 banished "CREATION" card into the Deck; negate that attack, and if you do, increase or decrease this card's Scale by 1 until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.atcon)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
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
	--You can target 1 "CREATION" Pendulum Monster in your Pendulum Zone; add it to your hand, and if you do, you can either place this card in your Pendulum Zone, or, if you control a "CREATION" Xyz Monster, attach this card to 1 "CREATION" Xyz Monster you control as Xyz Material. 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.pptg)
	e3:SetOperation(s.ppop)
	c:RegisterEffect(e3)
	--While this card is attached to a "CREATION" Xyz Monster as material, it gains the following effect:
	--● This card gains 200 DEF for each card in your banishment.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.value)
	c:RegisterEffect(e4)
end
--When your opponent declares a direct attack, or when an opponent's monster declares an attack against your "CREATION" Xyz Monster: You can shuffle 1 banished "CREATION" card into the Deck; negate that attack, and if you do, increase or decrease this card's Scale by 1 until the end of this turn.
function s.shuffilter(c)
	return c:IsSetCard(0x8df) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local a = Duel.GetAttacker()
	local at = Duel.GetAttackTarget()
if at then
	return at:IsSetCard(0x8df) and at:IsType(TYPE_XYZ) and a:IsControler(1-tp)
else
	return a:IsControler(1-tp)
end
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shuffilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_REMOVED)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)local tc=Duel.SelectMatchingCard(tp,s.shuffilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	local c=e:GetHandler()
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		Duel.BreakEffect()
		Duel.NegateAttack()
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
--You can target 1 "CREATION" Pendulum Monster in your Pendulum Zone; add it to your hand, and if you do, you can either place this card in your Pendulum Zone, or, if you control a "CREATION" Xyz Monster, attach this card to 1 "CREATION" Xyz Monster you control as Xyz Material. 
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x8df)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x8df)
end
function s.pptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_PZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_PZONE,0,1,1,nil,tp)
end
function s.ppop(e,tp,eg,ep,ev,re,r,rp)
	local pend_chk=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if pend_chk then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			local txc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			Duel.Overlay(txc,c)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
--While this card is attached to a "CREATION" Xyz Monster as material, it gains the following effect:
--● This card gains 200 ATK for each card in your banishment.
function s.value(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*200
end