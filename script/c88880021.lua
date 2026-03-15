--Forge that Binds CREATION
local s,id,o=GetID()
function s.initial_effect(c)
	--Add 1 "CREATION" Pendulum Monster from your deck to your hand, then, Change the Pendulum Scales of all Pendulum monsters you control to be equal to the added monsters pendulum scale. 
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is banished: Shuffle this card into the deck; Draw 1 card. Then, you can Shuffle 1 "CREATION" Pendulum monster from your GY or Face up Extra Deck into the deck: Special Summon, 1 "CREATION" monster from your Face Up Extra Deck or GY. Each effect of "Forge that binds CREATION" can only be activated once per turn.
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
--Add 1 "CREATION" Pendulum Monster from your deck to your hand, then, Change the Pendulum Scales of all Pendulum monsters you control to be equal to the added monsters pendulum scale. 
function s.filter(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		local scl=g:GetFirst():GetScale()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetTargetRange(LOCATION_PZONE,0)
		e1:SetValue(scl)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		Duel.RegisterEffect(e2,tp)
	end
end
--If this card is banished: Shuffle this card into the deck; Draw 1 card. Then, you can Shuffle 1 "CREATION" Pendulum monster from your GY or Face up Extra Deck into the deck: Special Summon, 1 "CREATION" monster from your Face Up Extra Deck or GY. Each effect of "Forge that binds CREATION" can only be activated once per turn.
function s.monfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.BreakEffect()
	if Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,2,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil)
		if Duel.SendtoDeck(g:GetFirst(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.monfilter,tp,0,LOCATION_EXTRA|LOCATION_GY,1,nil) then
			local tc=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_EXTRA|LOCATION_GY,0,1,1,nil)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end