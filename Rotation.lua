local DMW = DMW
local Paladin = DMW.Rotations.PALADIN
local Player, Buff, Debuff, Health, Power, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local ShootTime = GetTime()


--------------
----Locals----
--------------
local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Health = Player.Health
    HP = Player.HP
    Power = Player.PowerPct
    Spell = Player.Spells
    Talent = Player.Talents
    Trait = Player.Traits
    Item = Player.Items
    Target = Player.Target or false
    GCD = Player:GCD()
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player40Y, Player40YC = Player:GetEnemies(40)
    MeleeAggro = false
    HasTarget = Target and Target.ValidEnemy and Target.Facing and not Target.Dead
    for _, Unit in ipairs(Player40Y) do
        if Unit.Distance < 6 and Player.Pointer == Unit.Target then
            MeleeAggro = true
        end
    end
end

local ExorcismCastable = {
	["Undead"] = true,
	["Demon"] = true
}

----------------
--Smart Recast--
----------------
local function smartRecast(spell,unit)
    if (not Spell[spell]:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or 
        not UnitIsUnit(Spell[spell].LastBotTarget, unit.Pointer)) then 
            if Spell[spell]:Cast(unit) then return true end
    end
end


--------------
--5 Sec Rule--
--------------
local function FiveSecond()
    if FiveSecondRuleTime == nil then
        FiveSecondRuleTime = DMW.Time 
    end
    local FiveSecondRuleCount = DMW.Time - FiveSecondRuleTime
    if FiveSecondRuleCount > 6.5 then
        FiveSecondRuleTime = DMW.Time 
    end
    if Setting("Five Second Rule") and ((FiveSecondRuleCount) >= Setting("Five Second Cutoff") or (FiveSecondRuleCount <= 0.4)) then return true end
    --print(FiveSecondRuleCount)
end

---------------
----Healing----
---------------
local function HealingParty()
    if Friends40YC > 1 then
        -- Cycle Party HP Values
        for _, Friend in ipairs(Friends40Y) do
            -- Party Holy Light
            if Setting("Party - Holy Light") and not Player.Moving and Spell.HolyLight:IsReady() and Friend.HP < Setting("Party - Holy Light Percent") then
                if smartRecast("HolyLight",Friend) then FiveSecondRuleTime = DMW.Time return true end
            end
            -- Party Flash of Light
            if Setting("Party - Flash of Light") and not Player.Moving and Spell.FlashOfLight:IsReady() and Friend.HP < Setting("Party - Flash of Light Percent") then
                if smartRecast("FlashOfLight",Friend) then FiveSecondRuleTime = DMW.Time return true end
            end
            -- Party Holy Shock
            if Setting("Party - Holy Shock") and not Player.Moving and Spell.HolyShock:IsReady() and Friend.HP <= Setting("Party - Holy Shock Percent") then
                if smartRecast("HolyShock",Friend) then FiveSecondRuleTime = DMW.Time return true end
            end
        end
    end
end

--------------
---DPS Code---
--------------
local function Damage()
	-- Judgements
	if Power > 20 then
		if Setting("Judgement of ") == 2 and HasTarget and Spell.SealCrusader:IsReady() and not Debuff.JudgementOfTheCrusader:Exist(Target) and Spell.SealCrusader:Cast(Player) and Target.Health > 5 then
			return true
		end
		
		if Setting("Judgement of ") == 3 and HasTarget and Spell.SealOfLight:IsReady() and not Debuff.JudgementOfLight:Exist(Target) and Spell.SealOfLight:Cast(Player) and Target.Health > 5 then
			return true
		end
		
		if Setting("Judgement of ") == 4 and HasTarget and Spell.SealOfWisdom:IsReady() and not Debuff.JudgementOfWisdom:Exist(Target) and Spell.SealOfWisdom:Cast(Player) and Target.Health > 5 then
			return true
		end
	end
	
	-- Use Hammer of Justice For Additional DPS
	if Setting("Hammer of Justice") and HasTarget and Spell.HammerJustice:IsReady() and Spell.Judgement:CD() < 2 and Buff.SealCommand:Exist(Player) and Spell.HammerJustice:Cast(Target) then
		return true
	end
	
	-- Cast Judgement
	if HasTarget and Spell.Judgement:IsReady() and ((not Debuff.JudgementOfWisdom:Exist(Target) and not Debuff.JudgementOfLight:Exist(Target) and not Debuff.JudgementOfTheCrusader:Exist(Target) or Setting("Judgement of ") == 1) or (Buff.SealCommand:Exist(Player) or Buff.SealOfRight:Exist(Player))) and Spell.Judgement:Cast(Target) then
		return true
	end
	
	-- Use Hammer of Wrath
	if Setting("Hammer of Wrath") and HasTarget and Spell.HammerWrath:IsReady() and (Target.Health < 20 and Target.Health > 12) and Spell.HammerWrath:Cast(Target) then
		return true
	end
	
	-- Cast Exorcism (Untested)
	if Setting("Exorcism") and HasTarget and Spell.Exocism:IsReady() and ExorcismCastable[Target.CreatureType] and Spell.Exocism:Cast(Target) then
		return true
	end
	
	-- Seals
	if Setting("Seal of ") == 2 and Spell.SealOfRight:IsReady() and not Buff.SealOfRight:Exist(Player) and Spell.SealOfRight:Cast(Player) and Target.Health > 5 then
		return true
	end
	
	if Setting("Seal of ") == 3 and Setting("Seal of Command Rank 1") and Spell.SealCommand:IsReady(1) and not Buff.SealCommand:Exist(Player) and Spell.SealCommand:Cast(Player, 1) and Target.Health > 5 then
		return true 
	end
	
	if Setting("Seal of ") == 3 and not Setting("Seal of Command Rank 1") and Spell.SealCommand:IsReady() and not Buff.SealCommand:Exist(Player) and Spell.SealCommand:Cast(Player) and Target.Health > 5 then
		return true 
	end
	
	if Setting("Seal of ") == 4 and Spell.SealOfWisdom:IsReady() and not Buff.SealOfWisdom:Exist(Player) and Spell.SealOfWisdom:Cast(Player) and Target.Health > 5 then
		return true
	end
	
	if Setting("Seal of ") == 5 and Spell.SealOfLight:IsReady() and not Buff.SealOfLight:Exist(Player) and Spell.SealOfLight:Cast(Player) and Target.Health > 5 then
		return true
	end
	
	if Setting("Seal of ") == 6 and Spell.SealCrusader:IsReady() and not Buff.SealCrusader:Exist(Player) and Spell.SealCrusader:Cast(Player) and Target.Health > 5 then
		return true
	end
	
	if Setting("Seal of ") == 7 and Spell.SealOfJustice:IsReady() and not Buff.SealOfJustice:Exist(Player) and Spell.SealOfJustice:Cast(Player) and Target.Health > 5 then
		return true
	end

end

local function Defensive_Buffing()
    -- Blessings
    if Setting("Blessing of ") == 2 and not Buff.BlessingMight:Exist(Player) and Spell.BlessingMight:IsReady() and Spell.BlessingMight:Cast(Player) then
		return true
    end
	
	if Setting("Blessing of ") == 3 and not Buff.BlessingWisdom:Exist(Player) and Spell.BlessingWisdom:IsReady() and Spell.BlessingWisdom:Cast(Player) then 
        return true
    end

	-- Auras
	if Setting("Aura of ") == 2 and not Buff.DevotionAura:Exist(Player) and Spell.DevotionAura:Cast(Player) then 
        return true
    end
	
	if Setting("Aura of ") == 3 and not Buff.RetriAura:Exist(Player) and Spell.RetriAura:Cast(Player) then 
        return true
    end
	
	if Setting("Aura of ") == 4 and not Buff.SanctityAura:Exist(Player) and Spell.SanctityAura:Cast(Player) then 
        return true
    end
	
	-- Cleanse
	if Setting("Auto Dispel") and Spell.Cleanse:IsReady() and Player:Dispel(Spell.Cleanse) and Spell.Cleanse:Cast(Player) then
		return true
	end
	
    -- Defensive Holy Light
    if Setting("Use Holy Light") and (HP <= Setting("Holy Light Percent") or (not Player.Combat and HP < 55)) and Power > 40 and not Spell.HolyLight:LastCast() and not Player.Moving then
        if Spell.HolyLight:Cast(Player) then FiveSecondRuleTime = DMW.Time return true end
    end
	
    -- Defensive Flash of Light
    if Setting("Use Flash of Light") and HP <= Setting("Flash of Light Percent") and Power > 15 and not Spell.FlashOfLight:LastCast() and not Player.Moving then
        if Spell.FlashOfLight:Cast(Player) then FiveSecondRuleTime = DMW.Time return true end
    end
	
	-- Defensive Divine Shield
	if Setting("Use Divine Shield") and HP <= Setting("Divine Shield Percent") and Spell.DivineShield:IsReady() and Spell.DivineShield:Cast(Player) then
		return true
	end
	
	-- Defensive Lay on Hands
	if Setting("Use Lay on Hands") and HP <= Setting("Lay on Hands Percent") and Spell.LayOnHands:IsReady() and Spell.LayOnHands:Cast(Player) then
		return true
	end
end

function Paladin.Rotation()
    Locals()
    if Rotation.Active() then
        -----------------
        --Out Of Combat--
        -----------------
		-- Buffs / Defensive Actions
        if Defensive_Buffing() then return true end
        -- Heal Party
        if HealingParty() then return true end
        if FiveSecond() then return true end
		-- Quest Targeting
		if Setting("Auto Target Quest Units") and Player.HP > 90 and Player.PowerPct > 80 then
            if Player:AutoTargetQuest(30, true) then
                return true
            end
        end
        -----------------
        -----Combat------
        -----------------
        if Player.Combat then
			-- Auto Attack
			if HasTarget and not IsCurrentSpell(6603) and Target.Distance <= 5 then
				StartAttack()
			end
            if Setting("DPS Stuff") then
                -- Auto Target Enemy regardless of target
                Player:AutoTarget(40, true)
                if HUD.TargetLock == 1 and UnitIsFriend("player", "target") then
                    TargetLastEnemy()
                end
                -- Dmg Rotation
                if Damage() then return true end
            end
        end
    end
end