print("Metrostroi Sync - Server started")

util.AddNetworkString("MetrostroiSync-chat")
util.AddNetworkString("MetrostroiSync-open-menu")
util.AddNetworkString("MetrostroiSync-connect-server")
util.AddNetworkString("MetrostroiSync-disconnect-server")

util.AddNetworkString("MetrostroiSync-error-code-connect")
util.AddNetworkString("MetrostroiSync-error-create")

Metrostroi.SyncSystem.UpdateTime = Metrostroi.SyncSystem.UpdateTime or 10

include("metrostroi_sync/main.lua")

net.Receive("MetrostroiSync-connect-server", function(_, ply)
    if not ply:IsAdmin() then return end

    local id = net.ReadString()
    local port = net.ReadString()
    local password = net.ReadString()

    http.Post(Metrostroi.SyncSystem.WebAPI .. "/check-password", { id = id, password = password},
    function(body)
        if body == "200" then
            Metrostroi.SyncSystem.Connect(port, password)
        else
            net.Start("MetrostroiSync-error-code-connect")
                net.WriteUInt(Metrostroi.SyncSystem.Packets.WRONG_PASSWORD)
            net.Broadcast()
        end
    end,
    function(msg)
        ErrorNoHalt("HTTP MetrostroiSync-connect-server ERROR: " .. msg .. "\n")
        net.Start("MetrostroiSync-error-code-connect")
            net.WriteUInt(Metrostroi.SyncSystem.Packets.ERROR_WHEN_CONN)
        net.Broadcast()
    end
    )

end)

net.Receive("MetrostroiSync-disconnect-server", function(_, ply)
    if not ply:IsAdmin() then return end

    Metrostroi.SyncSystem.Disconnect()
end)