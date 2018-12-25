--------------------
--- Version 0.7 ---
--------------------

local CooldownDisplay = {
	------------------------
	----- *** Menu *** -----
	------------------------
	optionEnable = Menu.AddOption({"mlambers", "Cooldown display"}, "1. Enable.", "Enable/Disable this script."),
	offsetBoxSize = Menu.AddOption({"mlambers", "Cooldown display"}, "2. Size", "", 21, 64, 1),
	offsetHeight = Menu.AddOption({"mlambers", "Cooldown display"}, "3. Height", "", -150, 150, 1),
	NeedInit = true
}

local FunctionFloor = math.floor
local memoize = nil
local memoizeImages = nil

local CalcTable = {}
local memoizeCalc = nil

local myHero = nil
local widthScreen, heightScreen = nil, nil

local Assets = {}
local TempTable = {}

local BoxValue = {
	Size = nil,
	Height = nil,
	FontCooldown = nil,
	FontSpellLevel = nil
}

function CooldownDisplay.Sum(option1, option2)
	return FunctionFloor((BoxValue.Size - option2) * option1)
end

function CooldownDisplay.LoadImage(name)
	return Renderer.LoadImage("panorama/images/spellicons/" .. name .. "_png.vtex_c")
end

function CooldownDisplay.OnMenuOptionChange(option, old, new)
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(CooldownDisplay.optionEnable) == false then return end
	if Heroes.GetLocal() == nil then return end
	
	if not option then return end
	
    if option == CooldownDisplay.offsetBoxSize or option == CooldownDisplay.offsetHeight
	then
		memoizeCalc = nil
		for k in pairs(CalcTable) do
			CalcTable[k] = nil
		end
		CalcTable = {}
		memoizeCalc = memoize(CooldownDisplay.Sum, CalcTable)
		
		BoxValue.Size = Menu.GetValue(CooldownDisplay.offsetBoxSize)
		BoxValue.Height = Menu.GetValue(CooldownDisplay.offsetHeight)
		BoxValue.FontCooldown = Renderer.LoadFont("monospaceNumbersFont", memoizeCalc(0.6, 2), Enum.FontWeight.BOLD)
		BoxValue.FontSpellLevel = Renderer.LoadFont("Verdana", memoizeCalc(0.45, 2), Enum.FontWeight.BOLD)
    end
end

function CooldownDisplay.OnGameStart()
	BoxValue.Size = nil
	BoxValue.Height = nil
	BoxValue.FontCooldown = nil
	BoxValue.FontSpellLevel = nil
	
	for i = #TempTable, 1, -1 do
		TempTable[i] = nil
	end
	TempTable = {}
	
	for k in pairs(Assets) do
		Assets[k] = nil
	end
	Assets = {}
	memoizeImages = nil
	
	for k in pairs(CalcTable) do
		CalcTable[k] = nil
	end
	CalcTable = {}
	memoizeCalc = nil
	
	memoize = nil
	
	if myHero == nil then
		myHero = Heroes.GetLocal()
	end
	
	CooldownDisplay.NeedInit = true
end

function CooldownDisplay.OnGameEnd()
	BoxValue.Size = nil
	BoxValue.Height = nil
	BoxValue.FontCooldown = nil
	BoxValue.FontSpellLevel = nil
	widthScreen, heightScreen = nil, nil
	
	for i = #TempTable, 1, -1 do
		TempTable[i] = nil
	end
	TempTable = {}
	
	for k in pairs(Assets) do
		Assets[k] = nil
	end
	Assets = {}
	memoizeImages = nil
	
	for k in pairs(CalcTable) do
		CalcTable[k] = nil
	end
	CalcTable = {}
	memoizeCalc = nil
	
	memoize = nil
	
	myHero = nil

	collectgarbage("collect")
	CooldownDisplay.NeedInit = true
end

function CooldownDisplay.OnScriptLoad()
	BoxValue.Size = nil
	BoxValue.Height = nil
	BoxValue.FontCooldown = nil
	BoxValue.FontSpellLevel = nil
	widthScreen, heightScreen = nil, nil
	
	for i = #TempTable, 1, -1 do
		TempTable[i] = nil
	end
	TempTable = {}
	
	for k in pairs(Assets) do
		Assets[k] = nil
	end
	Assets = {}
	memoizeImages = nil
	
	for k in pairs(CalcTable) do
		CalcTable[k] = nil
	end
	CalcTable = {}
	memoizeCalc = nil
	
	memoize = nil
	
	myHero = nil

	CooldownDisplay.NeedInit = true
end

function CooldownDisplay.IsOnScreen(x, y)
	if (x < 1) or (y < 1) or (x > widthScreen) or (y > heightScreen) then 
		return false 
	end
	
	return true
end

local function DrawImages(hero, ability, realX, y)
    -- default colors = can cast
	TempTable[2][1] = 255
	TempTable[2][2] = 255
	TempTable[2][3] = 255
	
	TempTable[3][1] = 0
	TempTable[3][2] = 255
	TempTable[3][3] = 0

	local TargetMana = NPC.GetMana(hero)
    
	if Ability.IsCastable(ability, TargetMana, true) == false then
        if Ability.GetLevel(ability) == 0 then
			TempTable[2][1] = 125
			TempTable[2][2] = 125
			TempTable[2][3] = 125
			
			TempTable[3][1] = 255
			TempTable[3][2] = 0
			TempTable[3][3] = 0
           
        elseif Ability.GetManaCost(ability) > TargetMana then
			TempTable[2][1] = 150
			TempTable[2][2] = 150
			TempTable[2][3] = 255
			
			TempTable[3][1] = 0
			TempTable[3][2] = 0
			TempTable[3][3] = 255
        else
			TempTable[2][1] = 255
			TempTable[2][2] = 150
			TempTable[2][3] = 150
			
			TempTable[3][1] = 255
			TempTable[3][2] = 0
			TempTable[3][3] = 0
        end
    end
	
	-- Draw Ability image
    Renderer.SetDrawColor(TempTable[2][1], TempTable[2][2], TempTable[2][3], 255)
	Renderer.DrawImage(memoizeImages(Ability.GetTextureName(ability)), realX, y, BoxValue.Size, BoxValue.Size)
	
	-- Draw Border
    Renderer.SetDrawColor(TempTable[3][1], TempTable[3][2], TempTable[3][3], 255)
    Renderer.DrawOutlineRect(realX, y, BoxValue.Size, BoxValue.Size)
	
	local level = Ability.GetLevel(ability)
	
	if level > 0 then
		local LevelWidth, LevelHeight = Renderer.MeasureText(BoxValue.FontSpellLevel, level)
		local LevelPositionX = realX + memoizeCalc(0.05, LevelWidth)
		local LevelPositionY = y + memoizeCalc(0.05, LevelHeight)
		Renderer.SetDrawColor(255, 255, 255)
		Renderer.DrawText(BoxValue.FontSpellLevel, LevelPositionX, LevelPositionY, level, 0)
	end
	
	local cdLength = Ability.GetCooldownLength(ability)
	
	if Ability.IsReady(ability) == false and cdLength > 0.0 then
        local cooldownRatio = Ability.GetCooldown(ability) * (1 / cdLength)
		local CooldownHeightBar = FunctionFloor(BoxValue.Size * cooldownRatio)
		
        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX, y + (BoxValue.Size - CooldownHeightBar), BoxValue.Size, CooldownHeightBar)

        -- Draw cooldown Text
		local CDWidth, CDHeight = Renderer.MeasureText(BoxValue.FontCooldown, FunctionFloor(Ability.GetCooldown(ability)))
			
		local CDPositionX = realX + memoizeCalc(0.5, CDWidth)
		local CDPositionY = y +  memoizeCalc(1.15, CDHeight)
		
		Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(BoxValue.FontCooldown, CDPositionX, CDPositionY, FunctionFloor(Ability.GetCooldown(ability)), 0)
    end
end

local function DrawDisplay(ent, hx, hy, AbilityList, TempValue)
	local index_abilities = 0
	
	for idx = 0, 6 do
		TempValue = NPC.GetAbilityByIndex(ent, idx) or nil

		if TempValue ~= nil and Entity.IsAbility(TempValue) and (Ability.IsHidden(TempValue) == false) and (Ability.IsAttributes(TempValue) == false) then
			index_abilities = index_abilities + 1
			AbilityList[index_abilities] = TempValue
		end
	end	
	
	local BoxPosX = hx - FunctionFloor((index_abilities * 0.5) * BoxValue.Size)
	local BoxPosY = (hy - BoxValue.Height)
	local BoxWidth = FunctionFloor(BoxValue.Size * index_abilities)
	
	Renderer.SetDrawColor(0, 0, 0, 150)
	Renderer.DrawFilledRect(BoxPosX, BoxPosY, BoxWidth, BoxValue.Size)
	
	for k = #AbilityList, 1, -1 do
		TempValue = AbilityList[k]
		if TempValue ~= nil then
			DrawImages(ent, TempValue, ((k - 1) + BoxPosX + ((k - 1) * BoxValue.Size)), BoxPosY)
			AbilityList[k] = nil
		end
	end
end

local function DrawObject()
	local Object = nil
	local PositionAbsOrigin = nil
	local ZOffset = nil
	local WorldX, WorldY, WorldV = nil, nil, nil
	local AbilityList = {}
	local TempValue = nil
	
	for i = 1, Heroes.Count() do
		Object = Heroes.Get(i) or nil
			
		if Object ~= nil and Entity.IsDormant(Object) == false and Entity.IsAlive(Object) and Entity.IsSameTeam(myHero, Object) == false and NPC.IsIllusion(Object) == false and Entity.IsPlayer(Entity.GetOwner(Object)) then
			PositionAbsOrigin = Entity.GetAbsOrigin(Object)
			WorldX, WorldY, WorldV = Renderer.WorldToScreen(PositionAbsOrigin)

			if WorldV ~= nil and CooldownDisplay.IsOnScreen(WorldX, WorldY) then
				AbilityList = {nil, nil, nil, nil, nil, nil, nil}
				ZOffset = NPC.GetHealthBarOffset(Object)
				PositionAbsOrigin:SetZ(PositionAbsOrigin:GetZ() + ZOffset)
				WorldX, WorldY, WorldV = Renderer.WorldToScreen(PositionAbsOrigin)
				DrawDisplay(Object, WorldX, WorldY, AbilityList, TempValue)
			end		
		end
	end
end

function CooldownDisplay.OnUpdate()
	if Menu.IsEnabled(CooldownDisplay.optionEnable) == false then return end
	
	if CooldownDisplay.NeedInit == true then	
		memoize = require("Utility/memoize")
		memoizeImages = memoize(CooldownDisplay.LoadImage, Assets)
		
		memoizeCalc = memoize(CooldownDisplay.Sum, CalcTable)
		
		BoxValue.Size = Menu.GetValue(CooldownDisplay.offsetBoxSize)
		BoxValue.Height = Menu.GetValue(CooldownDisplay.offsetHeight)
		
		BoxValue.FontCooldown = Renderer.LoadFont("monospaceNumbersFont", memoizeCalc(0.6, 2), Enum.FontWeight.BOLD)
		BoxValue.FontSpellLevel = Renderer.LoadFont("Verdana", memoizeCalc(0.45, 2), Enum.FontWeight.BOLD)
		widthScreen, heightScreen = Renderer.GetScreenSize()
		
		TempTable = {
			{nil, nil, nil, nil, nil, nil}, 
			{nil, nil, nil}, 
			{nil, nil, nil}
		}
		
		if myHero == nil then
			myHero = Heroes.GetLocal()
		end
		
		CooldownDisplay.NeedInit = false
	end
	
	if myHero == nil then return end
end

function CooldownDisplay.OnDraw()
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(CooldownDisplay.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	
	if myHero == nil then return end
	
	DrawObject()
end

return CooldownDisplay