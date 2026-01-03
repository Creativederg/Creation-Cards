--CREATION - Celestial Weaver
local s,id,o=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Once per turn, if a "CREATION" card is banished: you can either Special Summon 1 "CREATION" monster from your hand or deck, or, if you control a "CREATION" Xyz Monster, you can attach 1 banished "CREATION" monster to that Xyz Monster as material.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.bcon)
	e1:SetTarget(s.btg)
	e1:SetOperation(s.bop)
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
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(s.pptg)
	e4:SetOperation(s.ppop)
	c:RegisterEffect(e4)
	--While this card is attached to a "CREATION" Xyz Monster as material, it gains the following effect:
	--● Any card sent to the opponents gy is banished instead.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,0xff)
	e5:SetValue(LOCATION_REMOVED)
	e5:SetTarget(s.xyztg)
	c:RegisterEffect(e5)
end
--Once per turn, if a "CREATION" card is banished: you can either Special Summon 1 "CREATION" monster from your hand or deck, or, if you control a "CREATION" Xyz Monster, you can attach 1 banished "CREATION" monster to that Xyz Monster as material.
function s.pfilter(c,e)
	return c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)
end
function s.bfilter(c,e)
	return c:IsSetCard(0x8df) and c:IsLocation(LOCATION_REMOVED)
end
function s.xcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8df) and c:IsType(TYPE_XYZ)
end
function s.thfilter(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_MONSTER)
end

function s.banfilter(c)
	return c:IsFaceup() and not c:IsPreviousLocation(LOCATION_REMOVED)
end
function s.bcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.banfilter,1,nil)
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(s.pfilter,1,nil,e)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local xyz_chk=Duel.IsExistingMatchingCard(s.xcfilter,tp,LOCATION_MZONE,0,1,nil)
	if xyz_chk then
		local sel=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		if sel==0 then
			local g=Duel.SelectMatchingCard(tp,s.bfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
			local txc=Duel.SelectMatchingCard(tp,s.xcfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			Duel.Overlay(txc,g)
		else
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end


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
	--● Any card sent to the opponents gy is banished instead.
function s.xyztg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end