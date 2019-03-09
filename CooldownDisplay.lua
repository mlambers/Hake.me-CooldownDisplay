---------------------------------------
--- CooldownDisplay.lua Version 0.9 ---
---------------------------------------

local CooldownDisplay = {
	OptionEnable = Menu.AddOption({"mlambers", "Cooldown display"}, "1. Enable.", "Enable/Disable this script."),
	OffsetBoxSize = Menu.AddOption({"mlambers", "Cooldown display"}, "2. Size", "", 21, 64, 1),
	OffsetHeight = Menu.AddOption({"mlambers", "Cooldown display"}, "3. Height", "", -150, 150, 1),
	NeedInit = true
}

local mFloor = math.floor

--[[
	1 -> MyHero
	2 -> widthScreen
	3 -> heightScreen
	4 -> HeroObject
	5 -> HeroAbsOrigin
	6 -> Xw2s
	7 -> Yw2s
	8 -> AbilityObject
	9 -> AbilitiesList
	10 -> {BoxPosX, BoxPosY, BoxWidth}
	11 -> Color RGB {}
		  1-3 for draw Ability image(R, G, B)
		  1-3 level, LevelWidth, LevelHeight
		  1-3 cdLength, cooldownRatio, CooldownHeightBar
		  1-3 CDWidth, CDHeight, CDPositionX
		  4 CDPositionY
		  4-6 for draw Ability border(R, G, B)
		  4-6 LevelPositionX, LevelPositionY
--]]
local gObject = {
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	{},
	{nil, nil, nil},
	{nil, nil, nil, nil, nil, nil}
}

--[[
	1 -> Size
	2 -> Height
	3 -> FontCooldown
	4 -> FontSpellLevel
--]]
local BoxValue = {
	nil, nil, nil, nil
}


function CooldownDisplay.OnMenuOptionChange(option, old, new)
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(CooldownDisplay.OptionEnable) == false then return end
	if gObject[1] == nil then return end
	
	if not option then return end
	
    if option == CooldownDisplay.OffsetBoxSize or option == CooldownDisplay.OffsetHeight
	then
		BoxValue[1] = Menu.GetValue(CooldownDisplay.OffsetBoxSize)
		BoxValue[2] = Menu.GetValue(CooldownDisplay.OffsetHeight)
		BoxValue[3] = Renderer.LoadFont("monospaceNumbersFont", CooldownDisplay.Sum(0.6, 2), Enum.FontWeight.BOLD)
		BoxValue[4] = Renderer.LoadFont("Verdana", CooldownDisplay.Sum(0.45, 2), Enum.FontWeight.BOLD)
    end
end

function CooldownDisplay.OnScriptLoad()
	gObject[1] = nil
	gObject[2], gObject[3] = nil, nil
	gObject[4], gObject[5], gObject[6], gObject[7] = nil, nil, nil, nil
	gObject[8] = nil
	
	for i = #gObject[9], 1, -1 do
		gObject[9][i] = nil
	end
	gObject[9] = {}
	
	gObject[10] = {nil, nil, nil}
	gObject[11] = {nil, nil, nil, nil, nil, nil}
	
	for i = 4, 1, -1 do
		BoxValue[i] = nil
	end
	
	CooldownDisplay.NeedInit = true
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ CooldownDisplay.lua ] [ Version 0.9 ] Script load.")
end

function CooldownDisplay.OnGameEnd()
	gObject[1] = nil
	gObject[2], gObject[3] = nil, nil
	gObject[4], gObject[5], gObject[6], gObject[7] = nil, nil, nil, nil
	gObject[8] = nil
	
	for i = #gObject[9], 1, -1 do
		gObject[9][i] = nil
	end
	gObject[9] = {}
	
	gObject[10] = {nil, nil, nil}
	gObject[11] = {nil, nil, nil, nil, nil, nil}
	
	for i = 4, 1, -1 do
		BoxValue[i] = nil
	end
	
	CooldownDisplay.NeedInit = true
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ CooldownDisplay.lua ] [ Version 0.9 ] Game end. Reset all variable.")
end

function CooldownDisplay.IsOnScreen(tempX, tempY)
	if (tempX < 1) or (tempY < 1) or (tempX > gObject[2]) or (tempY > gObject[3]) then 
		return false 
	end
	
	return true
end

function CooldownDisplay.Sum(option1, option2)
	return mFloor((BoxValue[1] - option2) * option1)
end

function CooldownDisplay.DrawImages(realX, realY, tempHero, tempAbility)
	--[[ 
		This is default colors = can cast
	--]]
	gObject[11][1] = 255
	gObject[11][2] = 255
	gObject[11][3] = 255
	
	gObject[11][4] = 0
	gObject[11][5] = 255
	gObject[11][6] = 0

	local TargetMana = NPC.GetMana(tempHero)
    
	if Ability.IsCastable(tempAbility, TargetMana, true) == false then
        if Ability.GetLevel(tempAbility) == 0 then
			gObject[11][1] = 125
			gObject[11][2] = 125
			gObject[11][3] = 125
			
			gObject[11][4] = 255
			gObject[11][5] = 0
			gObject[11][6] = 0
        elseif Ability.GetManaCost(tempAbility) > TargetMana then
			gObject[11][1] = 150
			gObject[11][2] = 150
			gObject[11][3] = 255
			
			gObject[11][4] = 0
			gObject[11][5] = 0
			gObject[11][6] = 255
        else
			gObject[11][1] = 255
			gObject[11][2] = 150
			gObject[11][3] = 150
			
			gObject[11][4] = 255
			gObject[11][5] = 0
			gObject[11][6] = 0
        end
    end
	
	--[[
		Draw Ability image.
	--]]
	Renderer.SetDrawColor(gObject[11][1], gObject[11][2], gObject[11][3], 255)
	Renderer.DrawImage(Renderer.LoadImage("panorama/images/spellicons/" .. Ability.GetTextureName(tempAbility) .. "_png.vtex_c"), realX, realY, BoxValue[1], BoxValue[1])
	
	--[[
		Draw Ability border.
	--]]
	Renderer.SetDrawColor(gObject[11][4], gObject[11][5], gObject[11][6], 255)
	Renderer.DrawOutlineRect(realX, realY, BoxValue[1], BoxValue[1])
	
	gObject[11][1] = Ability.GetLevel(tempAbility)
	
	if gObject[11][1] > 0 then
		gObject[11][2], gObject[11][3] = Renderer.MeasureText(BoxValue[4], gObject[11][1])
		
		gObject[11][4] = realX + CooldownDisplay.Sum(0.05, gObject[11][2])
		gObject[11][5] = realY + CooldownDisplay.Sum(0.05, gObject[11][3])
		
		--[[
			Draw black background for ability level.
		--]]
		Renderer.SetDrawColor(0, 0, 0, 255)
		Renderer.DrawFilledRect(gObject[11][4], gObject[11][5] + 1, gObject[11][2], gObject[11][3])
		
		--[[
			Draw ability level.
		--]]
		Renderer.SetDrawColor(255, 255, 255)
		Renderer.DrawText(BoxValue[4], gObject[11][4], gObject[11][5], gObject[11][1], 0)
	end
	
	gObject[11][1] = Ability.GetCooldownLength(tempAbility)
	
	if Ability.IsReady(tempAbility) == false and gObject[11][1] > 0.0 then
        gObject[11][2] = Ability.GetCooldown(tempAbility) * (1 / gObject[11][1])
		gObject[11][3] = mFloor(BoxValue[1] * gObject[11][2])
		
        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX, realY + (BoxValue[1] - gObject[11][3]), BoxValue[1], gObject[11][3])

        -- Draw cooldown Text
		gObject[11][1], gObject[11][2] = Renderer.MeasureText(BoxValue[3], mFloor(Ability.GetCooldown(tempAbility)))
			
		gObject[11][3] = realX + CooldownDisplay.Sum(0.5, gObject[11][1])
		gObject[11][4] = realY +  CooldownDisplay.Sum(1.15, gObject[11][2])
		
		Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(BoxValue[3], gObject[11][3], gObject[11][4], mFloor(Ability.GetCooldown(tempAbility)), 0)
    end
end

function CooldownDisplay.DrawDisplay(hEntity)
	gObject[5] = Entity.GetAbsOrigin(hEntity)
	gObject[6], gObject[7] = Renderer.WorldToScreen(gObject[5])
	
	if CooldownDisplay.IsOnScreen(gObject[6], gObject[7]) == false then return end
	
	gObject[9] = {}
	
	for idx = 0, 6 do
		gObject[8] = NPC.GetAbilityByIndex(hEntity, idx) or nil

		if 
			gObject[8] ~= nil
			and Entity.IsAbility(gObject[8])
			and Ability.IsHidden(gObject[8]) == false
			and Ability.IsAttributes(gObject[8]) == false
		then
			gObject[9][#gObject[9] + 1] = gObject[8]
		end
	end
	
	gObject[5]:SetZ(gObject[5]:GetZ() + NPC.GetHealthBarOffset(hEntity))
	gObject[6], gObject[7] = Renderer.WorldToScreen(gObject[5])
	
	gObject[10][1] = gObject[6] - mFloor((#gObject[9] * BoxValue[1]) * 0.5)
	gObject[10][2] = gObject[7] - BoxValue[2]
	gObject[10][3] = mFloor(BoxValue[1] * #gObject[9]) + (#gObject[9] - 1)
	
	--[[
		This is draw black background.
	--]]
	Renderer.SetDrawColor(0, 0, 0, 150)
	Renderer.DrawFilledRect(gObject[10][1], gObject[10][2], gObject[10][3], BoxValue[1])

	for k = #gObject[9], 1, -1 do
		if gObject[9][k] ~= nil then
			CooldownDisplay.DrawImages(((k - 1) + gObject[10][1] + ((k - 1) * BoxValue[1])), gObject[10][2], hEntity, gObject[9][k])
		end
	end
end

function CooldownDisplay.OnDraw()
	if Menu.IsEnabled(CooldownDisplay.OptionEnable) == false then return end
	if Engine.IsInGame() == false then return end
	--if GameRules.GetGameState() < 4 then return end
	--if GameRules.GetGameState() > 5 then return end
	
	if gObject[1] == nil then
		gObject[1] = Heroes.GetLocal() or nil
	end
	
	if CooldownDisplay.NeedInit == true then
		gObject[2], gObject[3] = Renderer.GetScreenSize()
		
		gObject[4], gObject[5], gObject[6], gObject[7] = nil, nil, nil, nil
		gObject[8] = nil
		
		for i = #gObject[9], 1, -1 do
			gObject[9][i] = nil
		end
		gObject[9] = {}
		
		gObject[10] = {nil, nil, nil}
		gObject[11] = {nil, nil, nil, nil, nil, nil}
		
		BoxValue[1] = Menu.GetValue(CooldownDisplay.OffsetBoxSize)
		BoxValue[2] = Menu.GetValue(CooldownDisplay.OffsetHeight)
		BoxValue[3] = Renderer.LoadFont("monospaceNumbersFont", CooldownDisplay.Sum(0.6, 2), Enum.FontWeight.BOLD)
		BoxValue[4] = Renderer.LoadFont("Verdana", CooldownDisplay.Sum(0.45, 2), Enum.FontWeight.BOLD)
		
		CooldownDisplay.NeedInit = false

		Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ CooldownDisplay.lua ] [ Version 0.9 ] Game started, init script done.")
	end
	
	if gObject[1] == nil then return end
	
	for i = 1, Heroes.Count() do
		gObject[4] = Heroes.Get(i) or nil
		
		if 
			gObject[4] ~= nil
			and Entity.IsDormant(gObject[4]) == false
			and Entity.IsAlive(gObject[4])
			and Entity.IsSameTeam(gObject[1], gObject[4]) == false
			and Entity.GetField(gObject[4], "m_bIsIllusion") == false
			and NPC.IsIllusion(gObject[4]) == false
			and Entity.IsPlayer(Entity.GetOwner(gObject[4])) 
		then
			CooldownDisplay.DrawDisplay(gObject[4])
		end
	end
end

return CooldownDisplay