if not pcall(require, "gwsockets") then
    ErrorNoHalt("Metrostroi Sync - Модуль gwsockets не установлен\n")
    ErrorNoHalt("Для его установки перейдите по этой ссылке\n")
    MsgC(Color(255,0,0), "https://github.com/FredyH/GWSockets")

    return
else
    MsgC(Color(0,255,0), "Metrostroi Sync - Модуль gwsockets успешно включен\n")
end

function Metrostroi.SyncSystem.RecreateWebsocket(port)

    local url = Metrostroi.SyncSystem.WebSocketURL .. ":" .. tostring(port) .. "/"

    if Metrostroi.SyncSystem.Socket then
        Metrostroi.SyncSystem.Socket:clearQueue()
        Metrostroi.SyncSystem.Socket:closeNow()

        Metrostroi.SyncSystem.Socket = nil
    end

    Metrostroi.SyncSystem.Socket = GWSockets.createWebSocket(url)

    Metrostroi.SyncSystem.Socket_ID = Metrostroi.SyncSystem.Socket_ID or 0
    Metrostroi.SyncSystem.OwnTrains = Metrostroi.SyncSystem.OwnTrains or {}
    Metrostroi.SyncSystem.SyncedTrains = Metrostroi.SyncSystem.SyncedTrains or {}

    local socket = Metrostroi.SyncSystem.Socket

    socket._events = socket._events or {}

    function socket:onConnected()
        MsgC(Color(0, 255, 0), "Metrostroi Sync - Подключено к серверу\n")
        socket:emit("@connect")
    end

    function socket:onDisconnected()
        MsgC(Color(255, 0, 0), "Metrostroi Sync - Отключен от сервера\n")
        socket:emit("@disconnect")
    end

    function socket:writeJSON(typ, data)
        self:write(util.TableToJSON({type = typ, data = data}))
    end

    function socket:on(typ, callback)
        self._events[typ] = callback
    end

    function socket:emit(typ, ...)
        if socket._events[typ] then
            socket._events[typ](...)
        end
    end

    function socket:onMessage(json)
        local msg = util.JSONToTable(json)

        socket:emit(msg.type, msg.data)
    end

end

Metrostroi.SyncSystem.RecreateWebsocket(800)