include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.Types = {
    ["702"] = {
        "models/metrostroi_train/bogey/metro_bogey_702.mdl",
        Vector(0,0.0,-7),Angle(0,90,0),"models/metrostroi_train/bogey/metro_wheels_702.mdl",
        Vector(0,-61,-14),Vector(0,61,-14),
        nil,
        Vector(4.3,-63,-3.3),Vector(4.3,63,-3.3),
    },
    ["717"] = {
        "models/metrostroi_train/bogey/metro_bogey_717.mdl",
        Vector(0,0.0,-10),Angle(0,90,0),"models/metrostroi_train/bogey/metro_wheels_collector.mdl",
        Vector(0,-61,-14),Vector(0,61,-14),
        nil,
        Vector(4.3,-63,-3.3),Vector(4.3,63,-3.3),
    },
    ["720"] = {
        "models/metrostroi_train/bogey/metro_bogey_collector.mdl",
        Vector(0,0.0,-10),Angle(0,90,0),"models/metrostroi_train/bogey/metro_wheels_collector.mdl",
        Vector(0,-61,-14),Vector(0,61,-14),
        nil,
        Vector(4.3,-63,-3.3),Vector(4.3,63,-3.3),

    },
    ["722"] = {
        "models/metrostroi_train/bogey/metro_bogey_async.mdl",
        Vector(0,0.0,-10),Angle(0,90,0),"models/metrostroi_train/bogey/metro_wheels_collector.mdl",
        Vector(0,-61,-14),Vector(0,61,-14),
        nil,
        Vector(4.3,-63,-3.3),Vector(4.3,63,-3.3),
    },
    tatra={
        "models/metrostroi/tatra_t3/tatra_bogey.mdl",
        Vector(0,0.0,-3),Angle(0,90,0),nil,
        Vector(0,-61,-14),Vector(0,61,-14),
        nil,
        Vector(4.3,-63,-3.3),Vector(4.3,63,-3.3),
    },
    def={
        "models/metrostroi/metro/metro_bogey.mdl",
        Vector(0,0.0,-10),Angle(0,90,0),nil,
        Vector(0,-61,-14),Vector(0,61,-14),
        nil,
        Vector(4.3,-63,-3.3),Vector(4.3,63,-3.3),
    },
}

function ENT:Initialize()
    local typ = self.Types[self.BogeyType or "717"]

    self:SetRenderMode(RENDERMODE_NORMAL)
    self:SetModel(typ[1])
    self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

    local wheels = ents.Create("gmod_subway_sync_wheels")
    wheels.Model = typ[4]
    wheels:SetPos(self:LocalToWorld(typ[2]))
    wheels:SetAngles(self:LocalToWorldAngles(typ[3]))
    wheels.WheelType = self.BogeyType
    wheels:Spawn()

    wheels:SetParent(self)

    self.Wheels = wheels
end

function ENT:OnRemove()
    SafeRemoveEntity(self.Wheels)
end