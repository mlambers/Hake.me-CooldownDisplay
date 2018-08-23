-------------------
--- Version 0.5 ---
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

CooldownDisplay.FixImages = {
	tusk_launch_snowball = "tusk_snowball",
	monkey_king_primal_spring_early = "monkey_king_primal_spring"
}

local FunctionFloor = math.floor
local memoize = nil
local memoizeImages = nil

local CalcTable = {}
local memoizeCalc = nil

local myHero = nil
local widthScreen, heightScreen = nil, nil

local Assets = {}
Assets.Images = {}

local TempTable = {}

local BoxValue = {}
BoxValue.Size = nil
BoxValue.Height = nil
BoxValue.FontCooldown = nil
BoxValue.FontSpellLevel = nil

function CooldownDisplay.Sum( ... )
	local arg = {...}
	return FunctionFloor((BoxValue.Size - arg[2]) * arg[1])
end

function CooldownDisplay.LoadImage(name)
	return Renderer.LoadImage("panorama/images/spellicons/" .. name .. "_png.vtex_c")
end


function CooldownDisplay.OnMenuOptionChange(option, old, new)
	if not option then return end
    if option == CooldownDisplay.offsetBoxSize or option == CooldownDisplay.offsetHeight then
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
	
	
	if myHero == nil then
		myHero = Heroes.GetLocal()
	end
	memoize = nil
	Assets.Images = {}
	memoizeImages = nil
	
	for k in pairs(CalcTable) do
		CalcTable[k] = nil
	end
	CalcTable = {}
	memoizeCalc = nil
	
	CooldownDisplay.ShouldDraw = false
	CooldownDisplay.NeedInit = true
end

function CooldownDisplay.OnGameEnd()
	BoxValue.Size = nil
	BoxValue.Height = nil
	BoxValue.FontCooldown = nil
	BoxValue.FontSpellLevel = nil
	widthScreen, heightScreen = nil, nil
	memoize = nil
	
	for i = #TempTable, 1, -1 do
		TempTable[i] = nil
	end
	TempTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	
	Assets.Images = {}
	memoizeImages = nil
	
	for k in pairs(CalcTable) do
		CalcTable[k] = nil
	end
	CalcTable = {}
	memoizeCalc = nil
	
	myHero = nil
	CooldownDisplay.ShouldDraw = false
	CooldownDisplay.NeedInit = true
end

function CooldownDisplay.OnScriptLoad()
	BoxValue.Size = nil
	BoxValue.Height = nil
	BoxValue.FontCooldown = nil
	BoxValue.FontSpellLevel = nil
	widthScreen, heightScreen = nil, nil
	memoize = nil
	
	for i = #TempTable, 1, -1 do
		TempTable[i] = nil
	end
	TempTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	
	Assets.Images = {}
	memoizeImages = nil
	
	for k in pairs(CalcTable) do
		CalcTable[k] = nil
	end
	CalcTable = {}
	memoizeCalc = nil
	
	myHero = nil
	CooldownDisplay.ShouldDraw = false
	CooldownDisplay.NeedInit = true
end

function CooldownDisplay.IsOnScreen(x, y)
	if (x < 1) or (y < 1) then 
		
		return false 
	end
	if (x > widthScreen) or ( y > widthScreen) then 
		
		return false
	end
	
	return true
end

function CooldownDisplay.draw_images(hero, ability, x, y, index, heightBox)
	local abilityName = Ability.GetName(ability)
	
	if CooldownDisplay.FixImages[abilityName] then
		abilityName = CooldownDisplay.FixImages[abilityName]
	end
	
	local realX = index + x + (index * BoxValue.Size)
    local castable = Ability.IsCastable(ability, NPC.GetMana(hero), true)
	
    -- default colors = can cast
	TempTable[2][1] = 255
	TempTable[2][2] = 255
	TempTable[2][3] = 255
	
	TempTable[3][1] = 0
	TempTable[3][2] = 255
	TempTable[3][3] = 0

    if not castable then
        if Ability.GetLevel(ability) == 0 then
			TempTable[2][1] = 125
			TempTable[2][2] = 125
			TempTable[2][3] = 125
			
			TempTable[3][1] = 255
			TempTable[3][2] = 0
			TempTable[3][3] = 0
           
        elseif Ability.GetManaCost(ability) > NPC.GetMana(hero) then
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
	Renderer.DrawImage(memoizeImages(abilityName), realX, y, BoxValue.Size, heightBox)
	
	-- Draw Border
    Renderer.SetDrawColor(TempTable[3][1], TempTable[3][2], TempTable[3][3], 255)
    Renderer.DrawOutlineRect(realX, y, BoxValue.Size, heightBox)
	
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
		local CooldownHeightBar = FunctionFloor(heightBox * cooldownRatio)
		
        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX, y + (heightBox - CooldownHeightBar), BoxValue.Size, CooldownHeightBar)

        -- Draw cooldown Text
		local CDWidth, CDHeight = Renderer.MeasureText(BoxValue.FontCooldown, FunctionFloor(Ability.GetCooldown(ability)))
			
		local CDPositionX = realX + memoizeCalc(0.5, CDWidth)
		local CDPositionY = y +  memoizeCalc(1.15, CDHeight)
		Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(BoxValue.FontCooldown, CDPositionX, CDPositionY, FunctionFloor(Ability.GetCooldown(ability)), 0)
    end
end

function CooldownDisplay.DrawDisplay(heroes_ent)
	local index_abilities = 0
	local origin = Entity.GetAbsOrigin(heroes_ent)
	local HBO = NPC.GetHealthBarOffset(heroes_ent) 
	origin:SetZ(origin:GetZ() + HBO)
	
	local hx, hy, heroV = Renderer.WorldToScreen(origin)
	if not heroV then return end
	
	local PosY = (hy - BoxValue.Height)
	
	for i = 0, 6 do
		local ability = NPC.GetAbilityByIndex(heroes_ent, i)

		if ability and Entity.IsAbility(ability) and (Ability.IsHidden(ability) == false) and (Ability.IsAttributes(ability) == false) then
			index_abilities = index_abilities + 1
			TempTable[1][index_abilities] = ability
		end
	end	
	
	local BoxPosX = hx - FunctionFloor( (index_abilities * 0.5) * BoxValue.Size )
	local BoxWidth = FunctionFloor(BoxValue.Size * index_abilities)
	local BoxHeight = BoxValue.Size
	Renderer.SetDrawColor(0, 0, 0, 150)
	Renderer.DrawFilledRect(BoxPosX, PosY, BoxWidth, BoxHeight)

	for i = #TempTable[1], 1, -1 do
		local value_abilities = TempTable[1][i]
		if value_abilities then
			CooldownDisplay.draw_images(heroes_ent, value_abilities, BoxPosX, PosY, (i - 1), BoxHeight )
			TempTable[1][i] = nil
		end
	end
end

function CooldownDisplay.OnUpdate()
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(CooldownDisplay.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	
	if CooldownDisplay.NeedInit == true then	
		if myHero == nil then
			myHero = Heroes.GetLocal()
		end
		memoize = require("Utility/memoize")
		memoizeImages = memoize(CooldownDisplay.LoadImage, Assets.Images)
		
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
		
		CooldownDisplay.ShouldDraw = true
		CooldownDisplay.NeedInit = false
	end
	
	if not myHero then return end
end

function CooldownDisplay.OnDraw()
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(CooldownDisplay.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	
	if not myHero then return end
	
	if CooldownDisplay.ShouldDraw then	
		for k = 1, Heroes.Count() do
			local HeroValue = Heroes.Get(k)
			
			if HeroValue and Entity.IsDormant(HeroValue) == false and Entity.IsAlive(HeroValue) and Entity.IsSameTeam(myHero, HeroValue) == false and NPC.IsIllusion(HeroValue) == false and  Entity.IsPlayer(Entity.GetOwner(HeroValue)) then
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