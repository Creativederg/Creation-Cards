--CREATION-Eyes Celestial Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,6,2)--,s.ovfilter,aux.Stringid(s,0),2,s.xyzop)
	c:EnableReviveLimit()
	--You can also Xyz Summon this card by using 2 scale 8 monsters from your pendulum zone as material. 
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	--When this card is Xyz Summoned, excavate the top 5 cards of your deck, if there is at least 1 "CREATION" Pendulum Monster in the excavated cards add up to 2 of those monsters to your hand then return the rest to your deck in any order. If not, send the excavated cards to the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--If this card is involved in battle, you can use 1 material: destroy all cards in the pendulum zones and if you do this card gains 300 ATK/DEF for the combined scale of all destroyed monsters, then, all monsters you control gain 100 ATK/DEF for the combined scale of all destroyed monsters.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCost(s.desco)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.ovfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_PZONE,0) and c:IsSetCard(0x8df) and (c:GetLeftScale()==6 or c:GetRightScale()==6)
end
function s.xyzcon(e,c,og)
	local tp=e:GetHandlerPlayer()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2 and tc1:IsSetCard(0x8df) and tc2:IsSetCard(0x8df)) then return false end
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	if scl1>scl2 then scl1,scl2=scl2,scl1 end
	return scl1==6 and scl2==6
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
	aux.Stringid(id,0)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_PZONE,0,2,nil) 
		and Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_PZONE,0,2,2,nil)
	if g1:GetCount()>0 then
		c:SetMaterial(og)
		Duel.Overlay(c,g1)
	end
end
--When this card is Xyz Summoned, excavate the top 5 cards of your deck, if there is at least 1 "CREATION" Pendulum Monster in the excavated cards add up to 2 of those monsters to your hand then return the rest to your deck in any order. If not, send the excavated cards to the GY.
function s.selfil(c)
	return c:IsSetCard(0x8df) and (c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER))
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g<1 then return end
	if g:IsExists(s.selfil,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,2,nil)
		if sg:GetFirst():IsAbleToHand() then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.SortDecktop(tp,tp,(5-sg:GetCount()))
		else
			Duel.SendtoGrave(sg,REASON_RULE)
		end
	else
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
--If this card is involved in battle, you can use 1 material: destroy all cards in the pendulum zones and if you do this card gains 300 ATK/DEF for the combined scale of all destroyed monsters, then, all monsters you control gain 100 ATK/DEF for the combined scale of all destroyed monsters, until the end of the turn.
function s.desco(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	local atk=sg:GetSum(Card.GetScale)
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	Duel.BreakEffect()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(atk*300)
		c:RegisterEffect(e1)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetValue(atk*100)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_UPDATE_DEFENSE)
		Duel.RegisterEffect(e4,tp)
	end
end