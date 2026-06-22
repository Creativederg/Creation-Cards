--Blink that Reveals CREATION
local s,id,o=GetID()
function s.initial_effect(c)
	--If you Control 2 "CREATION" Pendulum monsyers with the same scale in your Pendulum Zone: Target 1 Pendulum Monster you control; Draw cards Equal to half the targeted monsters pendulum scale, then, if you control an Xyz monster with a "CREATION" Pendulum Monster as material, attach the targeted card to 1 of those monsters as an Xyz Material.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is Banished: target 1 Card your opponent controls (if possible); regardless, draw 1 card and shuffle this card into the deck, and if you do, You can send the targeted card to the GY (if any), then, shuffle 1 "CREATION" Pendulum Monster from your GY  or face-up Extra Deck into the deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
--If you Control 2 "CREATION" Pendulum monsyers with the same scale in your Pendulum Zone: Target 1 Pendulum Monster you control; Draw cards Equal to half the targeted monsters pendulum scale, then, if you control an Xyz monster with a "CREATION" Pendulum Monster as material, attach the targeted card to 1 of those monsters as an Xyz Material.
function s.ovfilter(c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.ovfilter2,1,nil)
end
function s.ovfilter2(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.scfilter(c)
	return c:IsType(TYPE_XYZ)
end
function s.condition(e,c,og)
	local tp=e:GetHandlerPlayer()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2 and tc1:IsSetCard(0x8df) and tc2:IsSetCard(0x8df)) then return false end
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	if scl1>scl2 then scl1,scl2=scl2,scl1 end
	return scl1==scl2 and scl2==scl1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,e:GetHandler())
	local dc=g:GetFirst():GetScale()/2
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(dc)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	Duel.BreakEffect()
	if Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil) then
		local tc=Duel.GetFirstTarget()
		local sc=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,c):GetFirst()
		Duel.Overlay(sc,tc)
	end
end
--If this card is Banished: target 1 Card your opponent controls (if possible); regardless, draw 1 card and shuffle this card into the deck, and if you do, You can send the targeted card to the GY (if any), then, shuffle 1 "CREATION" Pendulum Monster from your GY  or face-up Extra Deck into the deck.
function s.monfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToGrave() end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	if Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) then
		local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW+CATEGORY_TOGRAVE,g,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Draw(tp,1,REASON_EFFECT)
	local tc=Duel.GetFirstTarget()
	if Duel.SendtoDeck(c,nil,2,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil) and tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
		Duel.BreakEffect()
		local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoDeck(g:GetFirst(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end