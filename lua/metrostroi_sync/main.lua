local allowedTrains = {
    ["gmod_subway_81-717_mvm"] = true,
    ["gmod_subway_81-714_mvm"] = true,
    ["gmod_subway_81-717_lvz"] = true,
    ["gmod_subway_81-714_lvz"] = true,
}

local trainTypes = {
    ["gmod_subway_81-717_mvm"] = 1,
    ["gmod_subway_81-714_mvm"] = 2,
    ["gmod_subway_81-717_lvz"] = 3,
    ["gmod_subway_81-714_lvz"] = 4,
}

local bogeyTypes = {
    ["717"] = 1,
}

local coupleTypes = {
    ["717"] = 1,
}

function Metrostroi.SyncSystem.Connect(port, password)
    if Metrostroi.SyncSystem.Socket:isConnected() then return end
    Metrostroi.SyncSystem.RecreateWebsocket(port)
    Metrostroi.SyncSystem.Refresh()
    local socket = Metrostroi.SyncSystem.Socket
    password = password or ""

    socket:setHeader( "map", game.GetMap() )
    socket:setHeader( "prid", tostring(Metrostroi.SyncSystem.ProtocolVersion))
    socket:setHeader( "port", string.Split(game.GetIPAddress(), ":")[2])
    if password ~= "" then 
    socket:setHeader( "password", password)
    end

    
    socket:open()
end

function Metrostroi.SyncSystem.Disconnect()
    if not Metrostroi.SyncSystem.Socket:isConnected() then return end
    local socket = Metrostroi.SyncSystem.Socket
    socket:closeNow()
end

local table_insert = table.insert

local updatetime = Metrostroi.SyncSystem.UpdateTime or 10

function Metrostroi.SyncSystem.Refresh()

    local socket = Metrostroi.SyncSystem.Socket
    
    if not socket then return end
    
    SetGlobalBool("MetrostroiSync-connected", socket:isConnected())

    local function getTrainID(ent)
        return tostring(ent:EntIndex() + Metrostroi.SyncSystem.Socket_ID*1000000)
    end

    MetrostroiSyncConnected = MetrostroiSyncConnected or false
    
    local function createTrain717(ent, obj)
        obj.mask = ent:GetNW2Bool("Mask")
        obj.mask22 = ent:GetNW2Bool("Mask22")
        obj.lvz = ent:GetNW2Bool("LVZ")
        obj.dot5 = ent:GetNW2Bool("Dot5")
    end
    
    local function createTrain714(ent, obj)
        obj.lvz = ent:GetNW2Bool("LVZ")
        obj.dot5 = ent:GetNW2Bool("Dot5")
    end
    
    local function createTrain717_lvz(ent, obj)
        obj.masktype = ent:GetNW2Int("MaskType")
    
        obj.kvr = ent:GetNW2Bool("KVR")
    end
    
    local function createTrain714_lvz(ent, obj)
        obj.kvr = ent:GetNW2Bool("KVR")
    end
    
    
    local function spawnTrain717(ent, msg)
        ent:SetNW2Bool("Mask", msg.mask)
        ent:SetNW2Bool("Mask22", msg.mask22)
        ent:SetNW2Bool("LVZ", msg.lvz)
        ent:SetNW2Bool("Dot5", msg.dot5)
    end
    
    local function spawnTrain714(ent, msg)
        ent:SetNW2Bool("Dot5", msg.dot5)
        ent:SetNW2Bool("LVZ", msg.lvz)
    end
    
    local function spawnTrain717_lvz(ent, msg)
        ent:SetNW2Int("MaskType", msg.masktype)
        ent:SetNW2Bool("KVR", msg.kvr)
    end
    
    local function spawnTrain714_lvz(ent, msg)
        ent:SetNW2Bool("KVR", msg.kvr)
    end
    
    local function createTrain(ent)
    
        local obj = {
            id = getTrainID(ent),
    
            owner_steamid = ent:CPPIGetOwner():SteamID(),
            owner_nickname = ent:CPPIGetOwner():Nick(),
    
            type_train = trainTypes[ent:GetClass()],
            type_bogey = ent.FrontBogey.BogeyType,
            type_couple = ent.FrontCouple.CoupleType,
    
            texture = ent:GetNW2String("Texture"),
            passtexture = ent:GetNW2String("PassTexture"),
            cabtexture = ent:GetNW2String("CabTexture"),
    
            newseats = ent:GetNW2Bool("NewSeats"),
            route_number = ent:GetNW2String("RouteNumber") or "000",
    
            pos = ent:GetPos(),
            ang = ent:GetAngles(),
        }
    
        if trainTypes[ent:GetClass()] == 1 then createTrain717(ent, obj) end
        if trainTypes[ent:GetClass()] == 2 then createTrain714(ent, obj) end
        if trainTypes[ent:GetClass()] == 3 then createTrain717_lvz(ent, obj) end
        if trainTypes[ent:GetClass()] == 4 then createTrain714_lvz(ent, obj) end
    
        
        socket:writeJSON(Metrostroi.SyncSystem.Packets.SPAWN_TRAIN, obj)
    end
    local function updateTrain(ent)
        if not IsValid(ent.FrontBogey) then return end
        if not IsValid(ent.RearBogey) then return end
    
        local obj = {
            id = getTrainID(ent),
    
            pos = ent:GetPos(),
            ang = ent:GetAngles(),
    
            door_left_1 = ent:GetPackedRatio("DoorL1"),
            door_left_2 = ent:GetPackedRatio("DoorL2"),
            door_left_3 = ent:GetPackedRatio("DoorL3"),
            door_left_4 = ent:GetPackedRatio("DoorL4"),
    
            door_right_1 = ent:GetPackedRatio("DoorR1"),
            door_right_2 = ent:GetPackedRatio("DoorR2"),
            door_right_3 = ent:GetPackedRatio("DoorR3"),
            door_right_4 = ent:GetPackedRatio("DoorR4"),
    
            bogey_front_ang = ent.FrontBogey:GetAngles(),
            bogey_rear_ang  = ent.RearBogey:GetAngles(),
    
            route_number = ent:GetNW2String("RouteNumber") or "000",
        }

        return obj
    end
    local function deleteTrain(ent)
        local obj = {
            id = getTrainID(ent)
        }
        
        socket:writeJSON(Metrostroi.SyncSystem.Packets.DELETE_TRAIN, obj)
    end
    
    hook.Add("MetrostroiChangedSwitch", "MetrostroiSync", function(ent, alt)
        local obj = {
            name = ent.Name,
            alt = alt,
        }
    
        socket:writeJSON(Metrostroi.SyncSystem.Packets.SWITCH, obj)
    end)
    
    hook.Add("PlayerSay","MetrostroiSync-Chat-Routes", function(ply, comm) 
    
        local chat_obj = {
            text = comm,
            sender = ply:Nick(),
            rank = team.GetName(ply:Team()),
            color = {
                r = team.GetColor(ply:Team()).r,
                g = team.GetColor(ply:Team()).g,
                b = team.GetColor(ply:Team()).b,
            }
        }
        socket:writeJSON(Metrostroi.SyncSystem.Packets.CHAT, chat_obj)
    
        if 
            comm:sub(1,8) == "!sactiv " or
            comm:sub(1,10) == "!sdeactiv " or
            comm:sub(1,8) == "!sclose " or
            comm:sub(1,7) == "!sopen " or
            comm:sub(1,7) == "!sopps " or
            comm:sub(1,7) == "!sclps "
        then
            local route_obj = {
                text = comm,
            }
    
            socket:writeJSON(Metrostroi.SyncSystem.Packets.ROUTE, route_obj)
        end
    
        if ply:IsAdmin() then
            if comm == "!sync_menu" then
                net.Start("MetrostroiSync-open-menu")
                net.Send(ply)
            end
        end
    end)
    
    cachedSwitchs = cachedSwitchs or {}
    cachedTrains = cachedTrains or {}
    
    socket:on("@connect", function()

    end)
    
    socket:on("@disconnect", function()
        for id, train in pairs(cachedTrains) do
            Metrostroi.SyncSystem.SyncedTrains[train] = nil
            SafeRemoveEntity(train)
            cachedTrains[id] = nil
        end
    
        MetrostroiSyncConnected = false

        SetGlobalBool("MetrostroiSync-connected", false)

        cachedTrains = {}
        cachedSwitchs = {}

        net.Start("MetrostroiSync-disconnect-server")
        net.Broadcast()
    end)
    
    --[[
    WRONG_PASSWORD  = 102,
    MAP_NOT_MATCH   = 103,
    ERROR_WHEN_CONN = 104,
    ]]

    local function SendErrorCode(msg)
        net.Start("MetrostroiSync-error-code-connect")
            net.WriteUInt(msg.type, 8)
        net.Broadcast()
    end

    socket:on(Metrostroi.SyncSystem.Packets.WRONG_PASSWORD, SendErrorCode)
    socket:on(Metrostroi.SyncSystem.Packets.MAP_NOT_MATCH, SendErrorCode)
    socket:on(Metrostroi.SyncSystem.Packets.ERROR_WHEN_CONN, SendErrorCode)
    socket:on(Metrostroi.SyncSystem.Packets.PROTOCOL_MISMATCH, SendErrorCode)
    socket:on(Metrostroi.SyncSystem.Packets.SERVER_FULL, SendErrorCode)

    socket:on(Metrostroi.SyncSystem.Packets.SYNC_SWITCHES, function(msg)
        for swt, state in pairs(msg) do
            local eswt = Metrostroi.GetSwitchByName(swt)
            if eswt.AlternateTrack and state == true then
                eswt:SendSignal("alt", nil, true)
            elseif not eswt.AlternateTrack and state == false then
                eswt:SendSignal("main", nil, true)
            end
    
            cachedSwitchs[swt] = state
        end
    end)
    
    socket:on(Metrostroi.SyncSystem.Packets.CHANGE_TPS, function(msg)
        Metrostroi.SyncSystem.UpdateTime = msg.tps
        updatetime = msg.tps
    end)
    
    
    socket:on(Metrostroi.SyncSystem.Packets.CHAT, function(msg)
        net.Start("MetrostroiSync-chat")
            net.WriteString(msg.text)
            net.WriteString(msg.sender)
            net.WriteString(msg.rank)
            net.WriteColor(Color(msg.color.r,msg.color.g,msg.color.b))
        net.Broadcast()
    end)
    
    socket:on(Metrostroi.SyncSystem.Packets.ROUTE, function(msg)
        local name = msg.text
    
        if MSignalSayHook then
            MSignalSayHook(nil, name, true)
            return
        end
        local tbl = hook.GetTable()
        for hookName, hook in pairs(tbl) do
            if hookName ~= "PlayerSay" then goto cont end
    
            for hookID, hookFunc in pairs(hook) do
                if hookID:sub(1, 21) == "metrostroi-signal-say" then
                    hookFunc(nil, name)
                end
            end

            ::cont::
        end
    end)
    
    
    socket:on(Metrostroi.SyncSystem.Packets.SWITCH, function(msg)
        local state = msg.alt
        local name = msg.name
    
        if cachedSwitchs[name] ~= state then
            Metrostroi.GetSwitchByName(name):SendSignal(state and "alt" or "main", nil, true)
            cachedSwitchs[name] = state
        end
    end)
    
    socket:on(Metrostroi.SyncSystem.Packets.CONNECT, function(msg)
        Metrostroi.SyncSystem.Socket_ID = msg.id

        
        SetGlobalBool("MetrostroiSync-connected", true)
        
        local trains = Metrostroi.SyncSystem.OwnTrains
    
        if table.Count(trains) > 0 then 
            for train in pairs(trains) do
                if IsValid(train) then
                    createTrain(train)
                end
            end
        end
    
        local switches = {}
    
        for k, v in pairs(ents.FindByClass("gmod_track_switch")) do
            
            --Metrostroi.GetSwitchByName(name):SendSignal(state and "alt" or "main", nil, true)
            cachedSwitchs[v.Name] = v.AlternateTrack
            switches[v.Name] = v.AlternateTrack
        end
    
        socket:writeJSON(Metrostroi.SyncSystem.Packets.SYNC_SWITCHES, switches)

        net.Start("MetrostroiSync-connect-server")
        net.Broadcast()

        MetrostroiSyncConnected = true
    end)
    
    socket:on(Metrostroi.SyncSystem.Packets.DISCONNECT, function(msg)
        local server_id = msg.id
    
        if server_id == Metrostroi.SyncSystem.Socket_ID then 
            socket:clearQueue()
            socket:closeNow()
        end
    
        for id, train in pairs(cachedTrains) do
            if train.ServerId == server_id then
                Metrostroi.SyncSystem.SyncedTrains[train] = nil
                SafeRemoveEntity(train)
                cachedTrains[id] = nil
            end
        end
    end)
    
    socket:on(Metrostroi.SyncSystem.Packets.SPAWN_TRAIN, function(msg)
        local typ = msg.type_train
    
        local types = {
            [1] = "gmod_subway_sync_81-717_msk",
            [2] = "gmod_subway_sync_81-714_msk",
            [3] = "gmod_subway_sync_81-717_lvz",
            [4] = "gmod_subway_sync_81-714_lvz",
        }
    
        local sync_train = ents.Create(types[typ])
        sync_train.SyncId = msg.id
        sync_train.ServerId = msg.server_id
        sync_train.Type = typ
        sync_train:SetPos(msg.pos)
        sync_train:SetAngles(msg.ang)
        sync_train:Spawn()
    
    
        timer.Simple(1, function()
            if not IsValid(sync_train) then return end

            sync_train:SetNW2String("Texture", msg.texture)
            sync_train:SetNW2String("PassTexture", msg.passtexture)
            sync_train:SetNW2String("CabTexture", msg.cabintexture)
            sync_train:SetNW2String("OwnerID", msg.owner_steamid)
            sync_train:SetNW2String("OwnerNick", msg.owner_nickname)
            sync_train:SetNW2String("RouteNumber", msg.route_number)
    
            sync_train:SetNW2Bool("NewSeats", msg.newseats)
    
            
            if typ == 1 then spawnTrain717(sync_train, msg) end
            if typ == 2 then spawnTrain714(sync_train, msg) end
            if typ == 3 then spawnTrain717_lvz(sync_train, msg) end
            if typ == 4 then spawnTrain714_lvz(sync_train, msg) end
    
            sync_train:UpdateTextures()
        end)
    
        Metrostroi.SyncSystem.SyncedTrains[sync_train] = true
        cachedTrains[msg.id] = sync_train
    end)
    
    local last_time = 0
    
    socket:on(Metrostroi.SyncSystem.Packets.UPDATE_TRAIN, function(msg)
        local update_time = msg.update_time
    
        if (update_time < last_time) then return end
    
        for k, v in pairs(msg.trains) do
            local id = v.id
    
            local train = cachedTrains[id]
            if train then
                train.FrontBogey:SetAngles(v.bogey_front_ang or Angles(0, 0, 0))
                train.RearBogey:SetAngles(v.bogey_rear_ang or Angles(0, 0, 0))
    
    
                train:SetPackedRatio("DoorL1", v.door_left_1 or 0)
                train:SetPackedRatio("DoorL2", v.door_left_2 or 0)
                train:SetPackedRatio("DoorL3", v.door_left_3 or 0)
                train:SetPackedRatio("DoorL4", v.door_left_4 or 0)
    
                train:SetPackedRatio("DoorR1", v.door_right_1 or 0)
                train:SetPackedRatio("DoorR2", v.door_right_2 or 0)
                train:SetPackedRatio("DoorR3", v.door_right_3 or 0)
                train:SetPackedRatio("DoorR4", v.door_right_4 or 0)
    
                
                train:SetNW2String("RouteNumber", v.route_number)
                
                train:SetPos(v.pos)
                train:SetAngles(v.ang)
            end
        end

        last_time = update_time
    end)
    
    local function getTrainById(id)
        if cachedTrains[id] then return cachedTrains[id] end
    
        for train in pairs(Metrostroi.SyncSystem.SyncedTrains) do
            if train.SyncId == id then return train end
        end
        return false
    end
    
    socket:on(Metrostroi.SyncSystem.Packets.DELETE_TRAIN, function(msg)
        local id = tostring(msg.id)
        local train = getTrainById(id)
        if train then
            Metrostroi.SyncSystem.SyncedTrains[train] = nil
            SafeRemoveEntity(train)
            cachedTrains[id] = nil
        end
    end)
    
    local lastupdate = CurTime()
    local table_Count = table.Count
    
    hook.Add("Think", "MetrostroiTrains-sync", function()
        if lastupdate + (1/updatetime) > CurTime() then return end
    
        if MetrostroiSyncConnected then 
            local trains = Metrostroi.SyncSystem.OwnTrains

            if table_Count(trains) > 0 then 
                local updateTrains = {
                    update_time = SysTime()*1000,
                    trains = {}
                }
        
                for train in pairs(trains) do
                    if IsValid(train) then 
                        table_insert(updateTrains.trains, updateTrain(train))
                    end
                end
        
                socket:writeJSON(Metrostroi.SyncSystem.Packets.UPDATE_TRAIN, updateTrains)
            end
        end
    
        lastupdate = CurTime()
    end)
    
    hook.Add("OnEntityCreated", "MetrostroiTrains-sync", function(ent)
        if ent:GetClass() == "gmod_subway_sync_train" or ent.Base == "gmod_subway_sync_train" then
            Metrostroi.SpawnedTrains[ent] = true
        end
        
        if allowedTrains[ent:GetClass()] then
            MsgC(Color(0,255,0), "Metrostroi Sync - Поезд " .. getTrainID(ent) .. " заспавлен и синхронизирован \n")
            Metrostroi.SyncSystem.OwnTrains[ent] = true 
            timer.Simple(0.1, function()
                if not socket:isConnected() then return end
                createTrain(ent)
            end)
        end
    end)
    
    hook.Add("EntityRemoved","MetrostroiTrains-sync",function(ent)
        if Metrostroi.SpawnedTrains[ent] then
            Metrostroi.SpawnedTrains[ent] = nil
        end
    
        if Metrostroi.SyncSystem.OwnTrains[ent] then
            Metrostroi.SyncSystem.OwnTrains[ent] = nil
            MsgC(Color(0,255,0), "Metrostroi Sync - Поезд " .. getTrainID(ent) .. " удален и рассинхронизирован \n")
            if not socket:isConnected() then return end
            deleteTrain(ent)
        end
    end)
    
end
    
Metrostroi.SyncSystem.Refresh()