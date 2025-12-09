--CREATION - Dimensional Ship
local s,id,o=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Once per turn: you can Banish 1 "CREATION" monster, (or 1 monster if you control an Xyz Monster with a "CREATION" card as material), from your hand or GY; until the end of your opponents turn, when a "CREATION" Pendulum monster(s) in your pendulum zone is destroyed by a card effect, you can place "CREATION" Pendulum Monsters from your Face Up extra deck, GY or Bannishment into your pendulum zone, up to the number of monsters destroyed.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.recos)
	e1:SetOperation(s.reop)
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
	--An Xyz Monster that has this card as material gains the following effect:
	--● Once per turn, when this card destroys an opponent's monster by battle: you can banish 1 card on the field; It can make a second attack during this Battle Phase.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetCost(s.atkcos)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
--Once per turn: you can Banish 1 "CREATION" monster, (or 1 monster if you control an Xyz Monster with a "CREATION" card as material), from your hand or GY; until the end of your opponents turn, when a "CREATION" Pendulum monster(s) in your pendulum zone is destroyed by a card effect, you can place "CREATION" Pendulum Monsters from your Face Up extra deck, GY or Bannishment into your pendulum zone, up to the number of monsters destroyed.
function s.banfil(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_MONSTER)
end
function s.banfil2(c)
	return c:IsType(TYPE_MONSTER)
end
function s.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.xyzfilter2,1,nil)
end
function s.xyzfilter2(c)
	return c:IsSetCard(0x8df)
end
function s.pfilter(c)
	return c:IsSetCard(0x8df) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.recos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and Duel.IsExistingMatchingCard(s.banfil,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,e:GetHandler())  end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) then
		local g=Duel.SelectMatchingCard(tp,s.banfil2,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,e:GetHandler())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	else
		local g=Duel.SelectMatchingCard(tp,s.banfil,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,e:GetHandler())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.revcon)
	e1:SetOperation(s.revop)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.revfilter(c,tp)
	return c:IsPreviousSetCard(0x8df) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsReason(REASON_EFFECT)
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.revfilter,1,nil,tp)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local pd=eg:FilterCount(s.revfilter,nil,tp)
	local ct=0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct+1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct+1 end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE|LOCATION_REMOVED,0,ct,pd,nil)
	local pc=g:GetFirst()
	for pc in g:Iter() do
		Duel.MoveToField(pc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
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
--An Xyz Monster that has this card as material gains the following effect:
--● Once per turn, when this card destroys an opponent's monster by battle: you can banish 1 card on the field; It can make a second attack during this Battle Phase.
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler() and aux.bdocon(e,tp,eg,ep,ev,re,r,rp)
end
function s.atkcos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToBattle() and c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	--Can make a second attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3201)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
	c:RegisterEffect(e1)
end