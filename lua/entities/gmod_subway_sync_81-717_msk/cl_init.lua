include("shared.lua")

ENT.ClientProps = {}

ENT.ClientProps["salon"] = {
    model = "models/metrostroi_train/81-717/interior_mvm.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=2,
}
ENT.ClientProps["cabine_mvm"] = {
    model = "models/metrostroi_train/81-717/cabine_mvm.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=2,
}
ENT.ClientProps["door0x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos1.mdl",
    pos = Vector(338.445,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door1x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos2.mdl",
    pos = Vector(108.324,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door2x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos3.mdl",
    pos = Vector(-121.682,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door3x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos4.mdl",
    pos = Vector(-351.531,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door0x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos4.mdl",
    pos = Vector(338.445,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}
ENT.ClientProps["door1x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos3.mdl",
    pos = Vector(108.324,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}
ENT.ClientProps["door2x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos2.mdl",
    pos = Vector(-121.682,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}
ENT.ClientProps["door3x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_pos1.mdl",
    pos = Vector(-351.531,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}


ENT.ClientProps["door1"] = {
    model = "models/metrostroi_train/81-717/door_torec.mdl",
    pos = Vector(-472.5,15.75,-2.7),
    ang = Angle(0,-90,0),
    hide=2,
}
ENT.ClientProps["door2"] = {
    model = "models/metrostroi_train/81-717/cab_door.mdl",
    pos = Vector(377.322,28.267,-1.599),
    ang = Angle(0,-90,0),
    hide=2,
}
ENT.ClientProps["door3"] = {
    model = "models/metrostroi_train/81-717/door_cabine.mdl",
    pos = Vector(443.493,65.111,0.277),
    ang = Angle(0,-90,0),
    hide=2,
}

ENT.ClientProps["seats_old"] = {
    model = "models/metrostroi_train/81-717/couch_old.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=1.5,
}
ENT.ClientProps["seats_old_cap"] = {
    model = "models/metrostroi_train/81-717/couch_cap_l.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hideseat=0.8,
}
ENT.ClientProps["seats_new"] = {
    model = "models/metrostroi_train/81-717/couch_new.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=1.5,
}
ENT.ClientProps["seats_new_cap"] = {
    model = "models/metrostroi_train/81-717/couch_new_cap.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hideseat=0.8,
}
ENT.ClientProps["handrails_old"] = {
    model = "models/metrostroi_train/81-717/handlers_old.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=1.5,
}
ENT.ClientProps["handrails_new"] = {
    model = "models/metrostroi_train/81-717/handlers_new.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=1.5,
}

ENT.ClientProps["mask22_mvm"] = {
    model = "models/metrostroi_train/81-717/mask_22.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    nohide=true,
}
ENT.ClientProps["mask222_mvm"] = {
    model = "models/metrostroi_train/81-717/mask_222.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    nohide=true,
}
ENT.ClientProps["mask222_lvz"] = {
    model = "models/metrostroi_train/81-717/mask_spb_222.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    nohide=true,
}
ENT.ClientProps["mask141_mvm"] = {
    model = "models/metrostroi_train/81-717/mask_141.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    nohide=true,
}

ENT.ClientProps["route"] = {
    model = "models/metrostroi_train/common/routes/ezh/route_holder.mdl",
    pos = Vector(-8,0,-5.65),
    ang = Angle(0,1,0),
    hide = 2,
}

ENT.ClientProps["route1"] = {
    model = "models/metrostroi_train/common/routes/ezh/route_number1.mdl",
    pos = ENT.ClientProps["route"].pos,
    ang = ENT.ClientProps["route"].ang,
    skin=6,
    hide = 2,
    callback = function(ent)
        ent.RouteNumberReloaded = false
    end,
}
ENT.ClientProps["route2"] = {
    model = "models/metrostroi_train/common/routes/ezh/route_number2.mdl",
    pos = ENT.ClientProps["route"].pos,
    ang = ENT.ClientProps["route"].ang,
    skin=1,
    hide = 2,
    callback = function(ent)
        ent.RouteNumberReloaded = false
    end,
}

ENT.TrainInfo = {
    fpos_r = Vector(400, -68, -6),
    fang_r = Angle(0, 0, 90),
    rpos_r = Vector(-440, -68, -6),
    rang_r = Angle(0, 0, 90),
    fpos_l = Vector(409, 68, -6),
    fang_l = Angle(0, 180, 90),
    rpos_l = Vector(-400, 68, -6),
    rang_l = Angle(0, 180, 90),
    max = 2,
    haveroute = true,
}

function ENT:Initialize()
    self.BaseClass.Initialize(self)

    self.RouteNumber = 0
    self.RouteNumberReloaded = false
end

function ENT:RouteNumberFunc()
    local scents = self.ClientEnts
    if self.RouteNumber ~= self:GetNW2String("RouteNumber","000") then
        self.RouteNumber = self:GetNW2String("RouteNumber","000")
        self.RouteNumberReloaded = false
    end
    if not scents["route1"] or self.RouteNumberReloaded then return end
    self.RouteNumberReloaded = true
    local rn = Format("%03d",tonumber(self.RouteNumber) or 0)
    for i=1, 2 do
        if IsValid(scents["route"..i]) then
            scents["route"..i]:SetSkin(rn[i] or 0)
        end
    end
end

function ENT:Think()
    self.BaseClass.Think(self)

    local dot5 = self:GetNW2Bool("Dot5")
    local lvz = self:GetNW2Bool("LVZ")
    local newSeats = self:GetNW2Bool("NewSeats")
    local mask = self:GetNW2Bool("Mask")
    local mask22 = self:GetNW2Bool("Mask22")
    
    self:ShowHide("mask222_mvm",not mask and not lvz and not mask22)
    self:ShowHide("mask222_lvz",not mask and lvz and not mask22)
    self:ShowHide("mask141_mvm",mask and not mask22)
    self:ShowHide("mask22_mvm",mask22 and not mask)
    
    self:ShowHide("seats_old",not newSeats)
    self:ShowHide("seats_old_cap",not newSeats)
    self:ShowHide("seats_new",newSeats)
    self:ShowHide("seats_new_cap",newSeats)

    self:ShowHide("handrails_old",not dot5)
    self:ShowHide("handrails_new",dot5)

    self:RouteNumberFunc()

    for i=0,3 do
        for k=0,1 do
            local st = k==1 and "DoorL" or "DoorR"
            local id,sid = st..(i+1),"door"..i.."x"..k
            local state = self:GetPackedRatio(id)

            local n_l = "door"..i.."x"..k

            self:SetCSPoseParameter(n_l, state)
        end
    end
end