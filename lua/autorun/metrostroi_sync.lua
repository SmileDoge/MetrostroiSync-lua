Metrostroi = Metrostroi or {}
Metrostroi.SyncSystem = Metrostroi.SyncSystem or {}

Metrostroi.SyncSystem.MainIP = "49.12.229.2"

Metrostroi.SyncSystem.WebAPI = "http://" .. Metrostroi.SyncSystem.MainIP .. "/api"
Metrostroi.SyncSystem.WebSocketURL = "ws://" .. Metrostroi.SyncSystem.MainIP

Metrostroi.SyncSystem.ProtocolVersion = 1

if SERVER then
    include("metrostroi_sync/buffer.lua")
    include("metrostroi_sync/packets.lua")
    include("metrostroi_sync/socket.lua")
    include("metrostroi_sync/server.lua")
    AddCSLuaFile("metrostroi_sync/client.lua")
else
    include("metrostroi_sync/client.lua")
end