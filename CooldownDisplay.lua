-------------------
--- Version 0.4 ---
-------------------

local CooldownDisplay = {}

------------------------
----- *** Menu *** -----
------------------------
CooldownDisplay.optionEnable = Menu.AddOption({"mlambers", "Cooldown display"}, "1. Enable.", "Enable/Disable this script.")
CooldownDisplay.offsetBoxSize = Menu.AddOption({"mlambers", "Cooldown display"}, "2. Size", "", 21, 64, 1)
CooldownDisplay.offsetHeight = Menu.AddOption({"mlambers", "Cooldown display"}, "3. Height", "", -150, 150, 1)

CooldownDisplay.NeedInit = true
CooldownDisplay.ShouldDraw = false

local Assets = {}
Assets.Images = {}
Assets.Path = "panorama/images/spellicons/"
Assets.Count = 0

local boxValue = {}
boxValue.BoxSize = Menu.GetValue(CooldownDisplay.offsetBoxSize)
boxValue.BoxHeight = Menu.GetValue(CooldownDisplay.offsetHeight)
boxValue.levelBoxSize = 0
boxValue.FontSpellLevel = nil
boxValue.FontCooldown = nil

local function_floor = math.floor

function CooldownDisplay.InitConfig()
	boxValue.BoxSize = Menu.GetValue(CooldownDisplay.offsetBoxSize)
	boxValue.levelBoxSize = function_floor(boxValue.BoxSize * 0.2)
    boxValue.FontSpellLevel = Renderer.LoadFont("Verdana", function_floor((boxValue.BoxSize - 2) * 0.45), Enum.FontWeight.BOLD)
	boxValue.FontCooldown = Renderer.LoadFont("Verdana", function_floor((boxValue.BoxSize - 2) * 0.643), Enum.FontWeight.BOLD)
	boxValue.BoxHeight = Menu.GetValue(CooldownDisplay.offsetHeight)
end

function CooldownDisplay.OnMenuOptionChange(option, old, new)
	if not option then return end
    if option == CooldownDisplay.offsetBoxSize or option == CooldownDisplay.offsetHeight then
		CooldownDisplay.InitConfig()
    end
end

function CooldownDisplay.LoadImage(prefix, name, path)
	local imageHandle = Assets.Images[prefix .. name]

	if (imageHandle == nil) then
		
		imageHandle = Renderer.LoadImage(path .. name .. "_png.vtex_c")
		Assets.Images[prefix .. name] = imageHandle
	end
end

function CooldownDisplay.LoadImagesTable()
	local PlayersTableName = {nil}
	local EntityDataHeroes = require("Utility/CooldownDisplay_DataNew")
	
	for k = 1, Heroes.Count() do
		local HeroValue = Heroes.Get(k)
		
		if HeroValue and not Entity.IsSameTeam(Heroes.GetLocal(), HeroValue) then
			PlayersTableName[1] = NPC.GetUnitName(HeroValue)
			for key = 1, #EntityDataHeroes[PlayersTableName[1]] do
				local TableData = EntityDataHeroes[PlayersTableName[1]][key]
				if TableData then
					
					Assets.Count = Assets.Count + 1
					CooldownDisplay.LoadImage("abilities_", TableData, Assets.Path)
					
				end
			end
			PlayersTableName[1] = nil
		end
	end
	
	PlayersTableName = nil
	EntityDataHeroes = nil
end

function CooldownDisplay.IsOnScreen(x, y)
	
	if (x < 1) or (y < 1) then 
		
		return false 
	end
	local widthScreen, heightScreen = Renderer.GetScreenSize()
	if (x > widthScreen) or ( y > widthScreen) then 
		
		return false
	end
	
	return true
end

function CooldownDisplay.OnGameStart()
	boxValue.BoxSize = Menu.GetValue(CooldownDisplay.offsetBoxSize)
	boxValue.BoxHeight = Menu.GetValue(CooldownDisplay.offsetHeight)
	boxValue.levelBoxSize = 0
	boxValue.FontSpellLevel = nil
	boxValue.FontCooldown = nil
	
	for k, v in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	Assets.Count = 0
	
	CooldownDisplay.ShouldDraw = false
	CooldownDisplay.NeedInit = true
	
	Console.Print("\n===================================")
	Console.Print("===   " .. os.date() .. "  ===")
	Console.Print("===================================")
	Console.Print("=== CooldownDisplay.OnGameStart ===")
	Console.Print("===================================")
	Console.Print("\n")
end

function CooldownDisplay.OnGameEnd()
	boxValue.BoxSize = Menu.GetValue(CooldownDisplay.offsetBoxSize)
	boxValue.BoxHeight = Menu.GetValue(CooldownDisplay.offsetHeight)
	boxValue.levelBoxSize = 0
	boxValue.FontSpellLevel = nil
	boxValue.FontCooldown = nil
	
	for k, v in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	Assets.Count = 0
	
	CooldownDisplay.ShouldDraw = false
	CooldownDisplay.NeedInit = true
	
	Console.Print("\n=================================")
	Console.Print("=== " .. os.date() .. "  ===")
	Console.Print("=================================")
	Console.Print("=== CooldownDisplay.OnGameEnd ===")
	Console.Print("=================================")
	Console.Print("\n")
end

function CooldownDisplay.OnScriptLoad()
	boxValue.BoxSize = Menu.GetValue(CooldownDisplay.offsetBoxSize)
	boxValue.BoxHeight = Menu.GetValue(CooldownDisplay.offsetHeight)
	boxValue.levelBoxSize = 0
	boxValue.FontSpellLevel = nil
	boxValue.FontCooldown = nil
	
	for k, v in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	Assets.Count = 0
	
	CooldownDisplay.ShouldDraw = false
	CooldownDisplay.NeedInit = true
	
	Console.Print("\n====================================")
	Console.Print("===   " .. os.date() .. "   ===")
	Console.Print("====================================")
	Console.Print("=== CooldownDisplay.OnScriptLoad ===")
	Console.Print("====================================")
	Console.Print("\n")
end

function CooldownDisplay.OnUpdate()
	if not Menu.IsEnabled(CooldownDisplay.optionEnable) then return end
	if not Engine.IsInGame() then return end
	local MyHero = Heroes.GetLocal()
	if not MyHero then return end
	
	if CooldownDisplay.NeedInit == true then
		CooldownDisplay.InitConfig()
		CooldownDisplay.LoadImagesTable()
		--Console.Print(Assets.Count)
		CooldownDisplay.ShouldDraw = true
		CooldownDisplay.NeedInit = false
	end

end

function CooldownDisplay.draw_images(hero, ability, x, y, index)
	local abilityName = Ability.GetName(ability)
	local realX = index + x + (index * boxValue.BoxSize)
	
    local castable = Ability.IsCastable(ability, NPC.GetMana(hero), true)

    -- default colors = can cast
    local imageColor = { 255, 255, 255 }
    local outlineColor = { 0, 255 , 0 }

    if not castable then
        if Ability.GetLevel(ability) == 0 then
            imageColor = { 125, 125, 125 }
            outlineColor = { 255, 0, 0 }
        elseif Ability.GetManaCost(ability) > NPC.GetMana(hero) then
            imageColor = { 150, 150, 255 }
            outlineColor = { 0, 0, 255 }
        else
            imageColor = { 255, 150, 150 }
            outlineColor = { 255, 0, 0 }
        end
    end
	
	-- Draw Ability image
    Renderer.SetDrawColor(imageColor[1], imageColor[2], imageColor[3], 255)
	if Assets.Images["abilities_" .. abilityName] then
		Renderer.DrawImage(Assets.Images["abilities_" .. abilityName], realX, y, boxValue.BoxSize, boxValue.BoxSize)
	else
		CooldownDisplay.LoadImage("abilities_", abilityName, Assets.Path)
		Renderer.DrawImage(Assets.Images["abilities_" .. abilityName], realX, y, boxValue.BoxSize, boxValue.BoxSize)
	end
	
	-- Draw Border
    Renderer.SetDrawColor(outlineColor[1], outlineColor[2], outlineColor[3], 255)
    Renderer.DrawOutlineRect(realX, y, boxValue.BoxSize, boxValue.BoxSize)
	
	-- Draw level value
	local level = Ability.GetLevel(ability)
	local LevelWidth, LevelHeight = Renderer.MeasureText(boxValue.FontSpellLevel, level)
	local LevelPositionX = realX + function_floor((boxValue.BoxSize - LevelWidth) * 0.05)
	local LevelPositionY = y + function_floor((boxValue.BoxSize - LevelHeight) * 0.05)
	Renderer.SetDrawColor(255, 255, 255)
	Renderer.DrawText(boxValue.FontSpellLevel, LevelPositionX, LevelPositionY, level, 0)
	
	local cdLength = Ability.GetCooldownLength(ability)
	
	if not Ability.IsReady(ability) and cdLength > 0.0 then
        local cooldownRatio = Ability.GetCooldown(ability) / cdLength
        local CooldownHeightBar = function_floor(boxValue.BoxSize * cooldownRatio)
		
        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX, y + (boxValue.BoxSize - CooldownHeightBar), boxValue.BoxSize, CooldownHeightBar)

        -- Draw cooldown Text
		local CDWidth, CDHeight = Renderer.MeasureText(boxValue.FontCooldown, function_floor(Ability.GetCooldown(ability)))
		local CDPositionX = realX + function_floor((boxValue.BoxSize - CDWidth) * 0.5)
		local CDPositionY = y + function_floor((boxValue.BoxSize - CDHeight) * 1.1)
		Renderer.SetDrawColor(255, 255, 255)
        Renderer.DrawText(boxValue.FontCooldown, CDPositionX, CDPositionY, function_floor(Ability.GetCooldown(ability)), 0)
    end
end


function CooldownDisplay.DrawDisplay(heroes_ent)
	local AbilityTable = {}
	local index_abilities = 0
	local origin = Entity.GetAbsOrigin(heroes_ent)
	local HBO = NPC.GetHealthBarOffset(heroes_ent) 
	origin:SetZ(origin:GetZ() + HBO)
	--origin:SetY(origin:GetY() - 50.0)
			
	local hx, hy, heroV = Renderer.WorldToScreen(origin)
	if not heroV then return end
	
	local PosY = (hy - boxValue.BoxHeight)
	
	for i = 0, 6 do
		local ability = NPC.GetAbilityByIndex(heroes_ent, i)

		if ability and Entity.IsAbility(ability) and (Ability.IsHidden(ability) == false) and (Ability.IsAttributes(ability) == false) then
			index_abilities = index_abilities + 1
			AbilityTable[index_abilities] = ability
		end
	end	
	
	hx = hx - function_floor(#AbilityTable * boxValue.BoxSize * 0.5)
	local BoxWidth = function_floor(boxValue.BoxSize * #AbilityTable)
	Renderer.SetDrawColor(0, 0, 0, 150)
	Renderer.DrawFilledRect((hx - 2), PosY, BoxWidth, boxValue.BoxSize)
				
	Renderer.SetDrawColor(0, 0, 0, 255)
	Renderer.DrawOutlineRect((hx - 2), PosY, BoxWidth, boxValue.BoxSize)
				
	for i = 1, #AbilityTable do
		local value_abilities = AbilityTable[i]
		
		CooldownDisplay.draw_images(heroes_ent, value_abilities, (hx - 2), PosY, (i - 1) )
		AbilityTable[i] = nil
	end
	AbilityTable = nil
end

function CooldownDisplay.OnDraw()
	if not Menu.IsEnabled(CooldownDisplay.optionEnable) then return end
	if not Engine.IsInGame() then return end
	local MyHero = Heroes.GetLocal()
	if not MyHero then return end
	
	if CooldownDisplay.ShouldDraw == true then
		for k = 1, Heroes.Count() do
			local HeroValue = Heroes.Get(k)
			
			if HeroValue and not Entity.IsDormant(HeroValue) and Entity.IsAlive(HeroValue) and ( (not NPC.IsIllusion(HeroValue) and not Entity.IsSameTeam(MyHero, HeroValue) ) or ( NPC.GetUnitName(HeroValue) == "npc_dota_hero_morphling" and NPC.HasModifier(HeroValue, "modifier_morphling_replicate_manager") and not Entity.IsSameTeam(MyHero, HeroValue)) ) then
				local visibilityCheck = Entity.GetAbsOrigin(HeroValue)
				local visibilityCheckX, visibilityCheckY, visibilityCheckV = Renderer.WorldToScreen(visibilityCheck)
				
				if visibilityCheckV and CooldownDisplay.IsOnScreen(visibilityCheckX, visibilityCheckY) then
					CooldownDisplay.DrawDisplay(HeroValue)
				end
			end
		end
	end
end

return CooldownDisplay