include("shared.lua")

ENT.ClientProps = {}

ENT.ClientProps["salon"] = {
    model = "models/metrostroi_train/81-717/interior_mvm_int.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=2,
}

ENT.ClientProps["seats_old"] = {
    model = "models/metrostroi_train/81-717/couch_old_int.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=1.5,
}
ENT.ClientProps["handrails_old"] = {
    model = "models/metrostroi_train/81-717/handlers_old_int.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=2,
}
ENT.ClientProps["seats_new"] = {
    model = "models/metrostroi_train/81-717/couch_new_int.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=1.5,
}
ENT.ClientProps["handrails_new"] = {
    model = "models/metrostroi_train/81-717/handlers_new_int.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=2,
}

ENT.ClientProps["seats_old_cap"] = {
    model = "models/metrostroi_train/81-717/couch_cap_l.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hideseat=0.8,
}
ENT.ClientProps["seats_old_cap_o"] = {
    model = "models/metrostroi_train/81-717/couch_cap_l.mdl",
    pos = Vector(-285,410,13),
    ang = Angle(0,70,-70),
    hideseat=0.8,
}
ENT.ClientProps["seats_new_cap"] = {
    model = "models/metrostroi_train/81-717/couch_new_cap.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hideseat=0.8,
}
ENT.ClientProps["seats_new_cap_o"] = {
    model = "models/metrostroi_train/81-717/couch_new_cap.mdl",
    pos = Vector(-285,410,13),
    ang = Angle(0,70,-70),
    hideseat=0.8,
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
    pos = Vector(459.2,-15.9,-2.7),
    ang = Angle(0,89.5,0),
    hide=2,
}

ENT.ClientProps["door2"] = {
    model = "models/metrostroi_train/81-717/door_torec.mdl",
    pos = Vector(-472.5,15.75,-2.7),
    ang = Angle(0,-90,0),
    hide=2,
}
ENT.ClientProps["otsek_cap_r"] = {
    model = "models/metrostroi_train/81-717/otsek_cap_r.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hideseat=0.8,
}

ENT.TrainInfo = {
    fpos_r = Vector(400, -68, -6),
    fang_r = Angle(0, 0, 90),
    rpos_r = Vector(-440, -68, -6),
    rang_r = Angle(0, 0, 90),
    fpos_l = Vector(415, 68, -6),
    fang_l = Angle(0, 180, 90),
    rpos_l = Vector(-400, 68, -6),
    rang_l = Angle(0, 180, 90),
    max = 2,
    haveroute = false,
}

function ENT:Initialize()
    self.BaseClass.Initialize(self)
end

function ENT:Think()
    self.BaseClass.Think(self)
    
    local dot5 = self:GetNW2Bool("Dot5")
    local lvz = self:GetNW2Bool("LVZ")
    local newSeats = self:GetNW2Bool("NewSeats")
    self:ShowHide("handrails_old",not dot5)
    self:ShowHide("handrails_new",dot5)
    self:ShowHide("seats_old",not newSeats)
    self:ShowHide("seats_new",newSeats)

    self:ShowHide("seats_old_cap_o",false)
    self:ShowHide("seats_new_cap_o",false)
    self:ShowHide("seats_old_cap",not newSeats)
    self:ShowHide("seats_new_cap",newSeats)

    self:ShowHide("otsek_cap_r", true)

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