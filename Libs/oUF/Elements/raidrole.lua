local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local unit = self.unit
	if(not UnitInRaid(unit)) then return end

	local raidrole = self.RaidRole
	if(raidrole.PreUpdate) then
		raidrole:PreUpdate()
	end

	local inVehicle = UnitHasVehicleUI(unit)
	if(GetPartyAssignment('MAINTANK', unit) and not inVehicle) then
		raidrole:Show()
		raidrole:SetTexture[[Interface\GROUPFRAME\UI-GROUP-MAINTANKICON]]
	elseif(GetPartyAssignment('MAINASSIST', unit) and not inVehicle) then
		raidrole:Show()
		raidrole:SetTexture[[Interface\GROUPFRAME\UI-GROUP-MAINASSISTICON]]
	else
		raidrole:Hide()
	end

	if(raidrole.PostUpdate) then
		return raidrole:PostUpdate(rinfo)
	end
end

local Path = function(self, ...)
	return (self.RaidRole.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local raidrole = self.RaidRole

	if(raidrole) then
		raidrole.__owner = self
		raidrole.ForceUpdate = ForceUpdate

		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		return true
	end
end

local Disable = function(self)
	local raidrole = self.RaidRole

	if(raidrole) then
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('RaidRole', Path, Enable, Disable)
