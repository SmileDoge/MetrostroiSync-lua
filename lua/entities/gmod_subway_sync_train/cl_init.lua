include("shared.lua")

function ENT:GetBodyColor()
    return Vector(1, 1, 1)
end

function ENT:GetDirtLevel()
    return 0
end

ENT.ClientProps = {}
ENT.ClientEnts = {}

local C_SoftDraw            = GetConVar("metrostroi_softdrawmultipier")
local C_RenderDistance      = GetConVar("metrostroi_renderdistance")
local C_MinimizedShow       = GetConVar("metrostroi_minimizedshow")
local C_ScreenshotMode      = GetConVar("metrostroi_screenshotmode")

function ENT:Initialize()
    self.Hidden = {
        anim = {},button = {},override = {},
    }
    self.SpawnTime = SysTime()
end


function ENT:SetCSPoseParameter(k, val)
    if IsValid(self.ClientEnts[k]) then
        self.ClientEnts[k]:SetPoseParameter("position", val or 0)
    end
end

function ENT:ShouldRenderClientEnts()
    --print(not self:IsDormant(), math.abs(LocalPlayer():GetPos().z - self:GetPos().z) < 500, (system.HasFocus() or C_MinimizedShow:GetBool()), (not Metrostroi or not Metrostroi.ReloadClientside))
    return not self:IsDormant() and math.abs(LocalPlayer():GetPos().z - self:GetPos().z) < 500 and (system.HasFocus() or C_MinimizedShow:GetBool()) and (not Metrostroi or not Metrostroi.ReloadClientside)
end

function ENT:ShouldDrawClientEnt(v)
    local distance =  LocalPlayer():GetPos():Distance(self:LocalToWorld(v.pos))
    local renderDist = C_RenderDistance:GetFloat()
    if v.nohide then return true end
    if v.hideseat then
        local seat = LocalPlayer():GetVehicle()
        if IsValid(seat) and self ~= seat:GetParent() then
            return false
        end
        if v.hideseat ~= true then
            return distance <= renderDist*v.hideseat
        end
    elseif v.hide then
        return distance <= renderDist*v.hide
    else
        return distance <= renderDist
    end
end

function ENT:SpawnCSEnt(k)
    local v = self.ClientProps[k]
    local con = v and k ~= "BaseClass" and not IsValid(self.ClientEnts[k]) and not self.Hidden[k] and self:ShouldDrawClientEnt(self.ClientProps[k]) and v.model ~= ""
    if con then
        local cent = ClientsideModel(v.model ,RENDERGROUP_OPAQUE)
        cent:SetParent(self)
        cent:SetPos(self:LocalToWorld(v.pos))
        cent:SetAngles(self:LocalToWorldAngles(v.ang))
    
        local texture = Metrostroi.Skins["train"][self:GetNW2String("Texture")]
        local passtexture = Metrostroi.Skins["pass"][self:GetNW2String("PassTexture")]
        local cabintexture = Metrostroi.Skins["cab"][self:GetNW2String("CabTexture")]
        for k1,v1 in pairs(cent:GetMaterials() or {}) do
            local tex = v1:gsub("^.+/","")
            if cabintexture and cabintexture.textures and cabintexture.textures[tex] then
                if type(cabintexture.textures[tex]) ~= "table" then
                    cent:SetSubMaterial(k1-1,cabintexture.textures[tex])
                end
            end
            if passtexture and passtexture.textures and passtexture.textures[tex] then
                cent:SetSubMaterial(k1-1,passtexture.textures[tex])
            end
            if texture and texture.textures and texture.textures[tex] then
                cent:SetSubMaterial(k1-1,texture.textures[tex])
            end
        end

        self.ClientEnts[k] = cent
        return true
    end
    return false
end

local elapsed = SysTime()
hook.Add("Think","SpwanElasped-sync",function() elasped = SysTime() end)
function ENT:CreateCSEnts()
    local count = 0
    local time = C_SoftDraw:GetFloat()/100*0.001
    for k in pairs(self.ClientProps) do
        if k ~= "BaseClass" and not IsValid(self.ClientEnts[k]) then
            if count > 5 and SysTime()-elapsed > time then return false end
            if self:SpawnCSEnt(k) then count = count + 1 end
        end
    end
    return true
end

function ENT:RemoveCSEnt(k)
    if self.ClientEnts[k] then
        SafeRemoveEntity(self.ClientEnts[k])
        self.ClientEnts[k] = nil
    end
end

function ENT:RemoveCSEnts()
    if self.ClientEnts then
        for _,v in pairs(self.ClientEnts) do
            if IsValid(v) then
                v:Remove()
            end
        end
    end

    self.ClientEnts = {}
end


function ENT:ShowHide(clientProp, value, over)
    if self.Hidden.override[clientProp] then return end
    if value == true and (self.Hidden[clientProp] or over) then
        self.Hidden[clientProp] = false
        if not IsValid(self.ClientEnts[clientProp]) and self:SpawnCSEnt(clientProp) then
            self.UpdateRender = true
        end
        return true
    elseif value ~= true and (not self.Hidden[clientProp] or over) then
        if IsValid(self.ClientEnts[clientProp]) then
            self.ClientEnts[clientProp]:Remove()
        end
        self.Hidden[clientProp] = true
        return true
    end
end

function ENT:UpdateTextures()
    self.Texture = self:GetNW2String("Texture")
    self.PassTexture = self:GetNW2String("PassTexture")
    self.CabinTexture = self:GetNW2String("CabTexture")

    local texture = Metrostroi.Skins["train"][self.Texture]
    local passtexture = Metrostroi.Skins["pass"][self.PassTexture]
    local cabintexture = Metrostroi.Skins["cab"][self.CabinTexture]
    for id,ent in pairs(self.ClientEnts) do
        if IsValid(ent) then 
            if self.ClientProps[id].callback then self.ClientProps[id].callback(self,ent) end
            for k in pairs(ent:GetMaterials()) do ent:SetSubMaterial(k-1,"") end
            for k,v in pairs(ent:GetMaterials()) do
                local tex = string.Explode("/",v)
                tex = tex[#tex]
                if cabintexture and cabintexture.textures and cabintexture.textures[tex] then
                    ent:SetSubMaterial(k-1,cabintexture.textures[tex])
                end
                if passtexture and passtexture.textures and passtexture.textures[tex] then
                    ent:SetSubMaterial(k-1,passtexture.textures[tex])
                end
                if texture and texture.textures and texture.textures[tex] then
                    ent:SetSubMaterial(k-1,texture.textures[tex])
                end
            end
        end
    end
end

function ENT:Draw()
    self:DrawModel() 
end

function ENT:Think()
    if self.RenderBlock then
        if RealTime()-self.RenderBlock < 5 then
        self.ClientPropsInitialized = false
            return
        else
            self.RenderBlock = false
        end
    end

    if not self.FirstTick then
        self.FirstTick = true
        self.RenderClientEnts = true
        self.CreatingCSEnts = false
        return
    end
    if not self.ClientPropsInitialized then
        self.ClientPropsInitialized = true
        self:RemoveCSEnts()
        self.RenderClientEnts = false
        self.StopSounds = false
    end

    if self.RenderClientEnts ~= self:ShouldRenderClientEnts() then
        self.RenderClientEnts = self:ShouldRenderClientEnts()
        if self.RenderClientEnts then
            self.CreatingCSEnts = true
            --self:CreateCSEnts()
            --if self.UpdateTextures then self:UpdateTextures() end
            --local _,ent = next(self.ClientEnts)
            --if not IsValid(ent) then self.RenderClientEnts = false end
        else
            self:OnRemove(true)
            return
        end
    end
    if self.RenderClientEnts and self.CreatingCSEnts then
        self.CreatingCSEnts = not self:CreateCSEnts()
        if not self.CreatingCSEnts then
            self:UpdateTextures()
        end
    end
    if not self.RenderClientEnts or self.CreatingCSEnts then return end

    if self.Texture ~= self:GetNW2String("Texture") then self:UpdateTextures() end
    if self.PassTexture ~= self:GetNW2String("PassTexture") then self:UpdateTextures() end
    if self.CabinTexture ~= self:GetNW2String("CabTexture") then self:UpdateTextures() end

    
    if (not self.LastCheck or RealTime()-self.LastCheck > 0.5) then
        self.LastCheck = RealTime()
        local screenshotMode = C_ScreenshotMode:GetBool()
        for k,v in pairs(self.ClientProps) do
            if not v.pos then goto cont end
            local cent = self.ClientEnts[k]

            if (v.nohide or screenshotMode) then
                if not IsValid(cent) then
                    self:SpawnCSEnt(k,true)
                end
                goto cont
            end
            local hidden = not self:ShouldDrawClientEnt(v)
            if IsValid(cent) and hidden then
                cent:Remove()
                self.ClientEnts[k] = nil
            elseif not IsValid(cent) and not hidden then
                self:SpawnCSEnt(k)
            end

            ::cont::
        end
    end
end



function ENT:OnRemove(nfinal)
    if not nfinal then
        self.RenderBlock = RealTime()
    end

    self:RemoveCSEnts()
    self.RenderClientEnts = false
end

-- Reload props in trains
for k, v in pairs(cachedTrains or {}) do
    v:RemoveCSEnts()
end
