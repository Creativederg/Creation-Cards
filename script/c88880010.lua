--CREATION - Dimensional Rift
local s,id,o=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	--e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
end
--pendulum effect functions
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.spellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove() and c:IsSetCard(0x8df)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_DECK,0,1,1,nil)
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