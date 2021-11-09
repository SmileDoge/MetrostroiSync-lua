ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""
ENT.Category        = "Metrostroi (utility)"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false


function ENT:SetupDataTables()
	self._NetData = {{},{}}
end

function ENT:SetPackedRatio(idx,value)
	if self._NetData[2][idx] ~= nil and self._NetData[2][idx] == math.floor(value*500) then return end
	self:SetNW2Int(idx,math.floor(value*500))
end

function ENT:GetPackedRatio(idx)
	return self:GetNW2Int(idx)/500
end

function ENT:SetPackedBool(idx,value)
	if self._NetData[1][idx] ~= nil and self._NetData[1][idx] == value then return end
	self:SetNW2Bool(idx,value)
end

function ENT:GetPackedBool(idx)
	return self:GetNW2Bool(idx)
end