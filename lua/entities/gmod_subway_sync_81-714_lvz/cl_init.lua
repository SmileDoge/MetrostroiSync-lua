include("shared.lua")

ENT.ClientProps = {}

ENT.ClientProps["salon"] = {
    model = "models/metrostroi_train/81-717/interior_mvm_int.mdl",
    pos = Vector(0,0,0),
    ang = Angle(0,0,0),
    hide=2,
}

ENT.ClientProps["body_additional"] = {
    model = "models/metrostroi_train/81-717/714_body_additional.mdl",
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
    callback = function(ent)
        ent.NewBlueSeats = false
    end,
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
    callback = function(ent)
        ent.NewBlueSeats = false
    end,
}
ENT.ClientProps["seats_new_cap_o"] = {
    model = "models/metrostroi_train/81-717/couch_new_cap.mdl",
    pos = Vector(-285,410,13),
    ang = Angle(0,70,-70),
    hideseat=0.8,
    callback = function(ent)
        ent.NewBlueSeats = false
    end,
}
ENT.ClientProps["door0x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos1.mdl",
    pos = Vector(338.445+1.2-2.2,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door1x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos2.mdl",
    pos = Vector(108.324+1.2-2.2,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door2x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos3.mdl",
    pos = Vector(-122.182+1.6-2.2,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door3x1"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos4.mdl",
    pos = Vector(-351.531+0.8-2.2,65.164,0.807),
    ang = Angle(0,-90,0),
    hide = 2.0,
}
ENT.ClientProps["door0x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos4.mdl",
    pos = Vector(338.445+1.2,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}
ENT.ClientProps["door1x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos3.mdl",
    pos = Vector(108.324+1.2,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}
ENT.ClientProps["door2x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos2.mdl",
    pos = Vector(-122.182+1.6,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}
ENT.ClientProps["door3x0"] = {
    model = "models/metrostroi_train/81-717/81-717_doors_spb_pos1.mdl",
    pos = Vector(-351.531+0.8,-65.164,0.807),
    ang = Angle(0,90,0),
    hide = 2.0,
}

function ENT:Initialize()
    self.BaseClass.Initialize(self)
end

function ENT:Think()
    self.BaseClass.Think(self)

    local kvr = self:GetNW2Bool("KVR")
    local newSeats = self:GetNW2Bool("NewSeats")

    
    self:ShowHide("handrails_old",not kvr)
    self:ShowHide("handrails_new",kvr)
    self:ShowHide("seats_old",not newSeats)
    self:ShowHide("seats_new",newSeats)

    self:ShowHide("seats_old_cap",not newSeats)
    self:ShowHide("seats_new_cap",newSeats)
    
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