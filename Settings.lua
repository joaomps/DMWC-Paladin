local DMW = DMW
DMW.Rotations.PALADIN = {}
local Paladin = DMW.Rotations.PALADIN
local UI = DMW.UI



function Paladin.Settings()
        UI.HUD.Options = {
                [1] = {
                    TargetLock = {
                        [1] = {Text = "Enemy Target Lock |cFF00FF00On", Tooltip = ""},
                        [2] = {Text = "Enemy Target Lock |cFFFFFF00Off", Tooltip = ""}
                        }
                    }
                }
		UI.AddHeader("Buffs")
		UI.AddToggle("Enable Buffing")
		UI.AddDropdown("Blessing of ", nil, {"Disabled", "Might", "Wisdom"}, 1, true)
		UI.AddDropdown("Aura of ", nil, {"Disabled", "Devotion", "Retribution", "Sanctity"}, 1, true)
        UI.AddHeader("Party Healing")
        UI.AddToggle("Five Second Rule", "Set time to not break 5 second rule")
        UI.AddRange("Five Second Cutoff", "Set time to not break 5 second rule", 0, 5, 0.1, 4.5)
        UI.AddBlank()
        UI.AddToggle("Party - Holy Light",nil)
        UI.AddRange("Party - Holy Light Percent", nil, 0, 100, 5 ,50)
        UI.AddToggle("Party - Flash of Light",nil)
        UI.AddRange("Party - Flash of Light Percent", nil, 0, 100, 5 ,50)
        UI.AddToggle("Party - Holy Shock",nil)
        UI.AddRange("Party - Holy Shock Percent", nil, 0, 100, 5 ,50)
        UI.AddBlank()
        UI.AddHeader("DPS")
        UI.AddToggle("DPS Stuff")
        UI.AddBlank()
		UI.AddToggle("Auto Target Quest Units", nil, false)
		UI.AddDropdown("Seal of ", nil, {"Disabled", "Righteousness", "Command", "Wisdom", "Light", "the Crusader", "Justice"}, 1, true)
		UI.AddDropdown("Judgement of ", nil, {"Disabled", "Crusader", "Light", "Wisdom"}, 1, true)
        UI.AddToggle("Seal of Command Rank 1", nil)
		UI.AddToggle("Hammer of Justice", nil)
        UI.AddToggle("Exorcism", nil)
        UI.AddToggle("Hammer of Wrath", nil)
        UI.AddBlank()
        UI.AddHeader("Defensives")
		UI.AddToggle("Auto Dispel", nil, 1)
		UI.AddToggle("Use Holy Light", nil, 1)
        UI.AddRange("Holy Light Percent", nil, 0, 100, 5, 40)
		UI.AddToggle("Use Flash of Light", nil, 0)
        UI.AddRange("Flash of Light Percent", nil, 0, 100, 5, 40)
		UI.AddToggle("Use Divine Shield", nil, 0)
        UI.AddRange("Divine Shield Percent", nil, 0, 100, 5, 20)
		UI.AddToggle("Use Lay on Hands", nil, 0)
        UI.AddRange("Lay on Hands Percent", nil, 0, 100, 5, 10)
end