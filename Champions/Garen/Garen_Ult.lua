local myHero = GetMyHero()
if GetObjectName(myHero) ~= "Garen" then return end

require 'Interrupter'
d = require 'DLib'
local IsInDistance = d.IsInDistance
local ValidTarget = d.ValidTarget
local GetEnemyHeroes = d.GetEnemyHeroes
local CalcDamage = d.CalcDamage

local submenu = menu.addItem(SubMenu.new("simple garen"))
local combo = submenu.addItem(MenuKeyBind.new("combo key", string.byte(" ")))

local atkRange = GetRange(myHero)

-- testing
addInterrupterCallback(function(target, spellType, spell)
	if IsInDistance(target, atkRange) and CanUseSpell(myHero,_Q) == READY and spellType == CHANELLING_SPELLS then
		CastSpell(_Q)
		AttackUnit(target)
	end
end)

local rBuffTarget
OnUpdateBuff(function(object,buffProc)
	if buffProc.Name == "garenpassiveenemytarget" then
		-- PrintChat(GetObjectName(object).." "..buffProc.Name)
		rBuffTarget = GetObjectName(object)
	end
end)

local rDmgTable = {0.286, 0.333, 0.4}

OnTick(function(myHero)
	local rLv = GetCastLevel(myHero, _R)

	if CanUseSpell(myHero,_R) == READY then
		for _,target in pairs(GetEnemyHeroes()) do
			if ValidTarget(target, GetCastRange(myHero,_R)) then
				local hp = GetCurrentHP(target)
				local rDmg = 175 * rLv + ( GetMaxHP(target) - hp ) * rDmgTable[rLv]
				if GetObjectName(target) == rBuffTarget and rDmg > hp then
					CastTargetSpell(target, _R)
					break
				elseif CalcDamage(myHero, target, 0, rDmg) > hp then
					CastTargetSpell(target, _R)
					break
				end
			end
		end
	end
	
end)

require('simple orbwalk')
OnProcessSpellComplete(function(unit, spell)
  if unit == myHero and spell.name:lower():find("attack") and combo.getValue() then
   	if CanUseSpell(myHero,_Q) == READY then
   		CastSpell(_Q)
   	elseif CanUseSpell(myHero,_E) == READY and GetCastName(myHero, _E) == "GarenE" then
   		CastSpell(_E)
   	end
  end

  if unit == myHero and spell.name == "GarenQ" then
		resetAA()
  end
end)

PrintChat("Simple Garen Loaded")

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
