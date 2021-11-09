include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
    self:SetModel("models/metrostroi_train/81-717/81-717_mvm_int.mdl")
    self.BaseClass.Initialize(self)
    
    self.FrontBogey = self:CreateBogey(Vector( 317-11,0,-80),Angle(0,180,0),"717")
    self.RearBogey  = self:CreateBogey(Vector(-317+0,0,-80) ,Angle(0, 0, 0),"717")
end