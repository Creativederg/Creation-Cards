--CREATION-Eyes Celestial Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--You can also Xyz Summon this card by using 2 scale 4 monsters from your pendulum zone as material. 
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	--This card gains 500 ATK/DEF for each Pendulum monster in the Pendulum Zones.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.adval)
	c:RegisterEffect(e1)
end
function s.ovfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_PZONE,0) and c:IsSetCard(0x8df) and (c:GetLeftScale()==4 or c:GetRightScale()==4)
end
function s.xyzcon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_PZONE,0,2,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
   if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_PZONE,0,2,nil) 
		and Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_PZONE,0,2,2,nil)
	if g1:GetCount()>0 then
		c:SetMaterial(og)
		Duel.Overlay(c,g1)
	end
	aux.Stringid(id,1)
end
function s.adval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_PZONE,LOCATION_PZONE)*500 
end