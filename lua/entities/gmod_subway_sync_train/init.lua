include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
    if self:GetModel() == "models/error.mdl" then
        self:SetModel("models/props_lab/reciever01a.mdl")
    end

    self:SetRenderMode(RENDERMODE_NORMAL)
    self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end    

    self:SetNW2Int("TrainType", self.Type)
end


function ENT:CreateBogey(pos, ang, typ)
    local bogey = ents.Create("gmod_subway_sync_bogey")

    bogey:SetPos(self:LocalToWorld(pos))
    bogey:SetAngles(self:GetAngles() + ang)
    bogey.BogeyType = typ
    bogey:Spawn()

    bogey:SetParent(self)

    return bogey
end

function ENT:UpdateTextures()
    self.Texture = self:GetNW2String("Texture")
    self.PassTexture = self:GetNW2String("PassTexture")
    self.CabTexture = self:GetNW2String("CabTexture")
    local texture = Metrostroi.Skins["train"][self.Texture]
    local passtexture = Metrostroi.Skins["pass"][self.PassTexture]
    local cabintexture = Metrostroi.Skins["cab"][self.CabTexture]
    for k in pairs(self:GetMaterials()) do self:SetSubMaterial(k-1,"") end
    for k,v in pairs(self:GetMaterials()) do
        local tex = v:gsub("^.+/","")
        if self.GetAdditionalTextures then
            local tex = self:GetAdditionalTextures(tex)
            if tex then
                self:SetSubMaterial(k-1,tex)
                goto cont
            end
        end
        if cabintexture and cabintexture.textures and cabintexture.textures[tex] then
            self:SetSubMaterial(k-1,cabintexture.textures[tex])
        end
        if passtexture and passtexture.textures and passtexture.textures[tex] then
            self:SetSubMaterial(k-1,passtexture.textures[tex])
        end
        if texture and texture.textures and texture.textures[tex] then
            self:SetSubMaterial(k-1,texture.textures[tex])
        end

        ::cont::
    end

    if texture and texture.postfunc then texture.postfunc(self) end
    if passtexture and passtexture.postfunc then passtexture.postfunc(self) end
    if cabintexture and cabintexture.postfunc then cabintexture.postfunc(self) end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_PVS
end