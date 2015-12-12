if GetObjectName(myHero) ~= "Garen" then return end

require('Inspired')

Config = Menu("Garen", "Garen")
Config:SubMenu("c", "Combo")
Config.c:Boolean("R", "Use R", true)
Config.c:Boolean("D", "Draw RDmg", true)

OnTick (function (myHero)
	for _,target in pairs(GetEnemyHeroes()) do		
		if Config.c.R:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(target, GetCastRange(myHero,_R)) then
			if GetCurrentHP(target)+GetDmgShield(target) < GetRDmg(target) then
				CastTargetSpell(target,_R)
			end
		end	
	end
end)

OnDraw (function (myHero)
	for _,target in pairs(GetEnemyHeroes()) do
		if Config.c.D:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(target,1500) then
		 bar=nil
			if GetRDmg(target)>=GetCurrentHP(target) then
				bar=GetCurrentHP(target)
			else
				bar=GetRDmg(target)
			end
			DrawDmgOverHpBar(target,GetCurrentHP(target),0,bar,0xffffffff)
		end
	end
end)

function passiveCheck(target)
	if GotBuff(target,"garenpassivegrit")>0 then
		local isMarked=true
	elseif GotBuff(target,"garenpassivegrit")<1 then
		local isMarked=false
	end
	return isMarked
end

function GetRDmg(target)
	local RDmg=174*GetCastLevel(myHero,_R) + ((GetMaxHP(target)-GetCurrentHP(target))*(0.219+0.067*GetCastLevel(myHero, _R)))
	if not isMarked then
		RDmg=CalcDamage(myHero, target, 0, RDmg)
	end
	return RDmg
end

PrintChat("Garen Auto R - Logge")
