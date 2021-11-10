Metrostroi = Metrostroi or {}
Metrostroi.SyncSystem = Metrostroi.SyncSystem or {}

Metrostroi.SyncSystem.MainIP = "49.12.229.2"

Metrostroi.SyncSystem.WebAPI = "http://" .. Metrostroi.SyncSystem.MainIP .. "/api"
Metrostroi.SyncSystem.WebSocketURL = "ws://" .. Metrostroi.SyncSystem.MainIP

Metrostroi.SyncSystem.ProtocolVersion = 1

local function load()
    if SERVER then
        include("metrostroi_sync/buffer.lua")
        include("metrostroi_sync/packets.lua")
        include("metrostroi_sync/socket.lua")
        include("metrostroi_sync/server.lua")
        AddCSLuaFile("metrostroi_sync/client.lua")
    else
        include("metrostroi_sync/client.lua")
    end
end

timer.Simple(0, function()
    load()
end)

load()

if SERVER then
    concommand.Add("metrostroi_sync_reload", function(ply)
        if IsValid(ply) then
            if ply:IsAdmin() then
                load()
            end
        else
            load()
        end
    end)
end