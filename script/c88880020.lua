--Blink that Reveals CREATION
local s,id,o=GetID()
function s.initial_effect(c)
	--Target 1 "CREATION" Xyz monster, (or 1 Xyz monster if you control an Xyz Monster with a "CREATION" Pendulum Monster as material), you control: Attach this card to it as material, also, Special Summon 1 "CREATION" Pendulum Monster from your Face Up Extra Deck or your GY, but shuffle it into the deck at the end of the turn.
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is banished: Shuffle this card into the deck; Draw 1 card. Then, you can Shuffle 1 "CREATION" Pendulum monster from your GY or Face up Extra Deck into the deck: Send 1 card your opponent controls into the GY. Each effect of "Blink that Reveals CREATION" can only be activated once per turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfToDeck)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
--Target 1 "CREATION" Xyz monster, (or 1 Xyz monster if you control an Xyz Monster with a "CREATION" Pendulum Monster as material), you control: Attach this card to it as material, also, Special Summon 1 "CREATION" Pendulum Monster from your Face Up Extra Deck or your GY, but shuffle it into the deck at the end of the turn.
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x8df)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.ovfilter(c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.ovfilter2,1,nil)
end
function s.ovfilter2(c)
	return c:IsSetCard(0x8df)
end
function s.monfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.monfilter2(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and (s.filter(chkc) or s.filter2(chkc)) end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and (Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) or Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil)) and (Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_EXTRA,0,1,nil) or Duel.IsExistingMatchingCard(s.monfilter2,tp,LOCATION_GRAVE,0,1,nil)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	if Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil) then
		Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	else
		Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
		c:CancelToGrave()
		Duel.Overlay(tc,c)
		Duel.BreakEffect()
		local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil)
		Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE|PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_MZONE)
			e1:SetOperation(s.shop)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
--If this card is banished: Shuffle this card into the deck; Draw 1 card. Then, you can Shuffle 1 "CREATION" Pendulum monster from your GY or Face up Extra Deck into the deck: Send 1 card your opponent controls into the GY. Each effect of "Blink that Reveals CREATION" can only be activated once per turn.
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.BreakEffect()
	if Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil)
		if Duel.SendtoDeck(g:GetFirst(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) then
			local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end