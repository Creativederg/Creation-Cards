--Ringshoku - Codexer of Evolution
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2)
	--You can also Link Summon this card by using 2 Scale 8 "CREATION" Pendulum Monsters in your Pendulum Zone, or 2 "CREATION" Pendulum Monsters in your Pendulum Zone whose total Scale equals 8. 
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.linkcon)
	e0:SetOperation(s.linkop)
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	--During your Main Phase: You can Special Summon 1 face-up "CREATION" Pendulum Monster from your Extra Deck or GY to a zone this card points to.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--When a "CREATION" Pendulum Monster is Summoned to a zone this card points to, except by its this cards effect: You can target 1 "CREATION" monster in your GY or face-up in your Extra Deck; shuffle that card into the Deck, then draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.zptcon(aux.FilterBoolFunction(s.sumfil)))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,lc,sumtype,tp) and c:IsSetCard(0x8df,lc,sumtype,tp)
end
--You can also Link Summon this card by using 2 Scale 8 "CREATION" Pendulum Monsters in your Pendulum Zone, or 2 "CREATION" Pendulum Monsters in your Pendulum Zone whose total Scale equals 8. 
function s.lmfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_PZONE,0) and c:IsSetCard(0x8df)
end
function s.linkcon(e)
	local tp=e:GetHandlerPlayer()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2 and tc1:IsSetCard(0x8df) and tc2:IsSetCard(0x8df)) then return false end
	local scl1=tc1:GetScale()
	local scl2=tc2:GetScale()
	if tc1:GetScale()+tc2:GetScale()==8 then lm=8 end
	if scl1>scl2 then scl1,scl2=scl2,scl1 end
	return (scl1==8 and scl2==8) or lm==8
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lmfilter,tp,LOCATION_PZONE,0,2,nil) 
		and Duel.IsExistingTarget(s.lmfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
	local sc=Duel.SelectMatchingCard(tp,s.lmfilter,tp,LOCATION_PZONE,0,2,2,nil)
	if sc then
		Duel.SendtoGrave(sc,REASON_LINK)
		Duel.LinkSummon(tp,sc:GetFirst())
	end
end
--During your Main Phase: You can Special Summon 1 face-up "CREATION" Pendulum Monster from your Extra Deck or GY to a zone this card points to.
function s.filter(c,e,tp,zone)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM) and c:IsPosition(POS_FACEUP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		return zone~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
--When a "CREATION" Pendulum Monster is Summoned to a zone this card points to: You can target 1 "CREATION" monster in your GY or face-up in your Extra Deck; shuffle that card into the Deck, then draw 1 card.
function s.sumfil(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM)
end
function s.sumfil2(c)
	return c:IsSetCard(0x8df) and c:IsType(TYPE_PENDULUM) and c:IsPosition(POS_FACEUP)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		return zone~=0 and Duel.IsExistingMatchingCard(s.sumfil2,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,zone)
	end
	--local g=Duel.SelectTarget(tp,s.sumfil2,tp,LOCATION_EXTRA|LOCATION_GRAVE,LOCATION_PZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.sumfil2,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end