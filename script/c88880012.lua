--CREATION - Atomic Aetherion
local s,id,o=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--When an opponents card effect activates, while you control an Xyz Monster with a "CREATION" monster as material, you can make the activated effect become "Attach 1 monster you control to 1 Xyz Monster your opponent controls as material". This effect of "CREATION - Atomic Aetherion" can only be activated once per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
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
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.pptg)
	e3:SetOperation(s.ppop)
	c:RegisterEffect(e3)
	--While this card is attached to an Xyz Monster as material, it gains the following effect:
	--● Your opponent must pay 300 LP to activate card effects.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ACTIVATE_COST)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.xyzcon)
	e4:SetCost(s.costchk)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
--When an opponents card effect activates, while you control an Xyz Monster with a "CREATION" monster as material, you can make the activated effect become "Attach 1 monster you control to 1 Xyz Monster your opponent controls as material". This effect of "CREATION - Atomic Forest" can only be activated once per turn.
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp 
end
function s.plfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.plfilter2,1,nil)
end
function s.plfilter2(c)
	return c:IsSetCard(0x8df)
end
function s.plfilter3(c)
	return c:IsType(TYPE_XYZ)
end
function s.plfilter4(c)
	return c:IsType(TYPE_MONSTER)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,rp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.pfilter4,rp,LOCATION_MZONE,0,1,nil) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	local tg=Duel.SelectMatchingCard(tp,s.plfilter3,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	--if #g>0 then
		Duel.HintSelection(g)
		Duel.Overlay(tg,g)
	--end
end
--Once per turn: You can target 1 other card in a Pendulum Zone; this card's Pendulum Scale becomes equal to that target's Pendulum Scale, until the end of this turn.
function s.penfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and s.atkfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.penfilter,tp,LOCATION_PZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
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
--Your opponent must pay 300 LP to activate card effects.
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsType(TYPE_XYZ)
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*300)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,300)
end