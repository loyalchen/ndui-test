local B, C, L, DB = unpack(select(2, ...))

--[[
	职业大厅图标，取代自带的信息条
]]
local hall = CreateFrame("Frame", "NDuiOrderHallIcon", UIParent)
hall:SetSize(50, 50)
hall:SetPoint("TOPLEFT", 30, -30)
B.CreateMF(hall)
hall.Icon = hall:CreateTexture(nil, "ARTWORK")
hall.Icon:SetAllPoints()
hall.Icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
hall.Icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[DB.MyClass]))
hall.Category = {}

local function refreshCurrency(self)
	local currency = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	self.name, self.amount, self.texture = GetCurrencyInfo(currency)
end

local function refreshCategory(self)
	local categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	self.numCategory = #categoryInfo
	for i, category in ipairs(categoryInfo) do
		self.Category[i] = {category.name, category.count, category.limit, category.description, category.icon}
	end
end

hall:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
hall:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
hall:RegisterEvent("GARRISON_FOLLOWER_ADDED")
hall:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
hall:RegisterEvent("GARRISON_TALENT_UPDATE")
hall:RegisterEvent("GARRISON_TALENT_COMPLETE")
hall:RegisterUnitEvent("UNIT_AURA", "player")
hall:RegisterUnitEvent("UNIT_PHASE", "player")
hall:RegisterEvent("PLAYER_ENTERING_WORLD")
hall:RegisterEvent("ADDON_LOADED")
hall:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "Blizzard_OrderHallUI" then
		OrderHallCommandBar:Hide()
		OrderHallCommandBar.Show = B.Dummy
		GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		refreshCurrency(self)
	elseif event == "UNIT_AURA" or event == "PLAYER_ENTERING_WORLD" then
		local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
		self:SetShown(inOrderHall)
		if inOrderHall then
			C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
			refreshCurrency(self)
			refreshCategory(self)
		end
	elseif event == "GARRISON_TALENT_COMPLETE" or event == "GARRISON_TALENT_UPDATE" or event == "UNIT_PHASE" then
		C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	elseif event == "GARRISON_FOLLOWER_CATEGORIES_UPDATED" or event == "GARRISON_FOLLOWER_ADDED" or event == "GARRISON_FOLLOWER_REMOVED" then
		refreshCategory(self)
	end
end)

hall:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, -5)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(DB.MyColor.._G["ORDER_HALL_"..DB.MyClass])
	GameTooltip:AddLine(" ")
	local icon = " |T"..self.texture..":12:12:0:0:50:50:4:46:4:46|t "
	GameTooltip:AddDoubleLine(self.name, self.amount..icon, 1,1,1, 1,1,1)
	local blank
	for i = 1, self.numCategory do
		if not blank then
			GameTooltip:AddLine(" ")
			blank = true
		end
		local name, count, limit, description, texture = unpack(self.Category[i])
		GameTooltip:AddDoubleLine(name, count.."/"..limit, 1,1,1, 1,1,1)
		if IsShiftKeyDown() then
			GameTooltip:AddLine(description, .6,.8,1,true)
		end
	end
	GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
	GameTooltip:AddDoubleLine(" ", HOLD_SHIFT_FOR_DETAILS, 1,1,1, .6,.8,1)
	GameTooltip:Show()
end)
hall:SetScript("OnLeave", GameTooltip_Hide)