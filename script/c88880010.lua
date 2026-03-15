--CREATION - Dimensional Rift
local s,id,o=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
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
	--An Xyz Monster that has this card as material gains the following effect:
	--● Once per turn (Quick Effect): Inflict Damage qual to half this cards ATK.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.xyzcon)
	--e4:SetCost(s.xyzcos)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
--pendulum effect functions
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.spellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove() and c:IsSetCard(0x8df)
end
function s.ovfilter(c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.ovfilter2,1,nil)
end
function s.ovfilter2(c)
	return c:IsSetCard(0x8df)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil) then
		if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil) end
	else
		if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil) then
		local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil)
		local sc=g:GetFirst()
		if sc and Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)~=0 then
			local code=sc:GetOriginalCodeRule()
			--Store the code in a flag effect
			tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,0,1,code)
			--Give the XYZ monster the ability to activate as the spell
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1)
			e1:SetCondition(s.spcon)
			e1:SetTarget(s.sptg)
			e1:SetOperation(s.spop)
			e1:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN)
			tc:RegisterEffect(e1)
		end
	else
		local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
		local sc=g:GetFirst()
		if sc and Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)~=0 then
			local code=sc:GetOriginalCodeRule()
			--Store the code in a flag effect
			tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,0,1,code)
			--Give the XYZ monster the ability to activate as the spell
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1)
			e1:SetCondition(s.spcon)
			e1:SetTarget(s.sptg)
			e1:SetOperation(s.spop)
			e1:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN)
			tc:RegisterEffect(e1)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local code=e:GetHandler():GetFlagEffectLabel(id)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_REMOVED,0,nil,code)
	if #g==0 then return false end
	local sc=g:GetFirst()
	if chkc then
		local te=sc:CheckActivateEffect(false,true,false)
		if not te then return false end
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then
		local te=sc:CheckActivateEffect(false,true,false)
		if not te then return false end
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		local tg=te:GetTarget()
		if tg then
			return tg(e,tp,eg,ep,ev,re,r,rp,0)
		end
		return true
	end
	local te=sc:CheckActivateEffect(false,true,false)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetHandler():GetFlagEffectLabel(id)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_REMOVED,0,nil,code)
	if #g==0 then return end
	local sc=g:GetFirst()
	local te=sc:CheckActivateEffect(false,true,false)
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
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
--An Xyz Monster that has this card as material gains the following effect:
--● Once per turn (Quick Effect): Inflict Damage qual to half this cards ATK.
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsType(TYPE_XYZ)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetAttack()/2
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end