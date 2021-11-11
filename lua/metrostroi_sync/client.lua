print("Metrostroi Sync - Client started")

net.Receive("MetrostroiSync-chat", function()
    local text = net.ReadString()
    local sender = net.ReadString()
    local rank = net.ReadString()
    local color = net.ReadColor()
    chat.AddText(
        Color(255, 255, 255), "(Synced) ", 
        Color(0, 0, 0), "[", 
        color, rank, 
        Color(0, 0, 0),"] ", 
        color, sender,
        Color(255, 255, 255), ": " .. text)
end)

local trainClasses = {
    ["gmod_subway_sync_81-714_lvz"] = true,
    ["gmod_subway_sync_81-714_msk"] = true,
    ["gmod_subway_sync_81-717_lvz"] = true,
    ["gmod_subway_sync_81-717_msk"] = true,
}

surface.CreateFont( "MetrostroiSync-train-info", {
	font = "Arial",
	extended = true,
	size = 100,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

hook.Add("PostDrawTranslucentRenderables", "MetrostroiSync-draw-info", function(_,isDD)
    for class in pairs(trainClasses) do 
        for k, train in pairs(ents.FindByClass(class)) do
            

            local info = train.TrainInfo

            local dist = 1024

            if LocalPlayer():GetPos():DistToSqr(train:GetPos()) > dist*dist then goto cont end

            cam.Start3D2D(train:LocalToWorld(Vector(0, 0, 100)), train:LocalToWorldAngles(Angle(0, 90, 90)), 0.1)
                draw.SimpleText("Владелец: " .. train:GetNW2String("OwnerNick"), "MetrostroiSync-train-info", 0, 0, Color(0,255,0), TEXT_ALIGN_CENTER)
                if info.haveroute then
                draw.SimpleText("Маршрут: " .. train:GetNW2String("RouteNumber"):sub(1, info.max), "MetrostroiSync-train-info", 0, 100, Color(0,255,0), TEXT_ALIGN_CENTER)
                end
            cam.End3D2D()

            cam.Start3D2D(train:LocalToWorld(Vector(0, 0, 100)), train:LocalToWorldAngles(Angle(0, -90, 90)), 0.1)
                draw.SimpleText("Владелец: " .. train:GetNW2String("OwnerNick"), "MetrostroiSync-train-info", 0, 0, Color(0,255,0), TEXT_ALIGN_CENTER)
                if info.haveroute then
                draw.SimpleText("Маршрут: " .. train:GetNW2String("RouteNumber"):sub(1, info.max), "MetrostroiSync-train-info", 0, 100, Color(0,255,0), TEXT_ALIGN_CENTER)
                end
            cam.End3D2D()

            ::cont::
        end
    end
end)

local function GetInfo(Append)
    http.Fetch(Metrostroi.SyncSystem.WebAPI .. "/get-servers", function(body)
        local json = util.JSONToTable(body)
        if not json then
            Append("Ошибка получений данных")
            return
        end

        for _, session in pairs(json) do
            local line = Append(
                session.name,
                session.map,
                session.havePassword and "Есть" or "Нету",
                session.createdBy
            )

            line.full_info = session
        end
    end, function(err) Append("Ошибка получений данных: " .. err) end)
end



local function ConnectServer(id, port, password)
    net.Start("MetrostroiSync-connect-server")
        net.WriteString(id)
        net.WriteString(tostring(port))
        net.WriteString(password)
    net.SendToServer()
end

local function DisconnectServer()
    net.Start("MetrostroiSync-disconnect-server")
    net.SendToServer()
end


local function CreateInfoPanel(options)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Информация о сессии")
    frame:SetSize(300, 200)
    frame:Center()
    frame:MakePopup()

    local panel = vgui.Create("DScrollPanel", frame)
    panel:Dock(FILL)
    panel:DockMargin(10, 10, 0, 0)

    local function CreateLabel(text)
        local label = panel:Add( "DLabel" )
        label:SetText(text)
        label:Dock(TOP)
    end

    CreateLabel("Имя сессии: " .. options.name)
    CreateLabel("Карта: " .. options.map)
    CreateLabel("Пароль: " .. (options.havePassword and "Есть" or "Нету") )
    CreateLabel("Создано кем: " .. options.createdBy)
    CreateLabel("TPS: " .. options.tps)
    CreateLabel("Количество вагонов: " .. options.trainCount)
    CreateLabel("Количество подключеных серверов: " .. options.serverCount)
end

local function CreateConnectPanel(options)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Подключение к сессии")
    frame:SetSize(300, 55)
    frame:Center()
    frame:MakePopup()

    local password = vgui.Create("DTextEntry", frame)
    password:RequestFocus()
    password:Dock(TOP)
    password:SetPlaceholderText("Введите пароль")
    password.OnEnter = function( self )
        http.Post(Metrostroi.SyncSystem.WebAPI .. "/check-password", { id = options.id, password = self:GetValue()},
        function(body)
            print(body, '"'..self:GetValue()..'"')
            if body == "200" then
                ConnectServer(options.id, options.port, self:GetValue())
                frame:Close()
            else
                self:SetValue("")
                self:SetPlaceholderText("Неверный пароль")
                timer.Simple(2, function() self:SetPlaceholderText("Введите пароль") end)
            end
        end,
        function(msg)
            self:SetValue("")
            self:SetPlaceholderText("HTTP CreateConnectPanel ERROR: " .. msg)
            timer.Simple(2, function() self:SetPlaceholderText("Введите пароль") end)
        end
        )
    end
end

local function CreateSession()
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle("Создание сессии")
    frame:SetSize( 300, 200 )
    frame:Center()
    frame:MakePopup()

end

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    self.Browser = self:Add("DListView")
    self.Browser:Dock( FILL )
    self.Browser:DockMargin( 10, 0, 10, 240 )
    self.Browser:SetMultiSelect( false )
    self.Browser:AddColumn("Имя сессии"):SetWidth(200)
    self.Browser:AddColumn("Карта сессии")
    self.Browser:AddColumn("Пароль"):SetWidth(10)
    self.Browser:AddColumn("Создано кем"):SetWidth(10)

    self:BrowserSetInfo()

    self.Browser.OnRowRightClick = function( lst, index, pnl )
        if not pnl.full_info then return end

        local menu = DermaMenu()
        menu:AddOption("Посмотреть информацию", function() CreateInfoPanel(pnl.full_info) end)
        menu:Open()
    end
    self.Browser.OnRowSelected = function( lst, index, pnl )
        if not pnl.full_info then return end
        if GetGlobalBool("MetrostroiSync-connected") then return end

        self.ConnectButton:SetEnabled(true)
    end

    self.ConnectButton = self:Add("DButton")
    self.ConnectButton:SetSize(200, 30)
    self.ConnectButton:SetPos(800-800/2-100, 350)
    self.ConnectButton:SetText("Подключиться к сессии")
    self.ConnectButton:SetEnabled(false)
    self.ConnectButton.DoClick = function()
        local _, pnl = self.Browser:GetSelectedLine()
        if pnl.full_info.havePassword then
            CreateConnectPanel(pnl.full_info)
        else
            ConnectServer(pnl.full_info.id, pnl.full_info.port, "")
        end
    end

    
    self.DisconnectButton = self:Add("DButton")
    self.DisconnectButton:SetSize(200, 30)
    self.DisconnectButton:SetPos(800-800/2-100, 350+40)
    self.DisconnectButton:SetText("Отключиться от сессии")
    self.DisconnectButton:SetEnabled(GetGlobalBool("MetrostroiSync-connected"))
    self.DisconnectButton.DoClick = function()
        DisconnectServer()
    end

    self.CreateButton = self:Add("DButton")
    self.CreateButton:SetSize(200, 30)
    self.CreateButton:SetPos(800-800/2-100, 350+40*2)
    self.CreateButton:SetText("Создать сессию")
    self.CreateButton:SetEnabled(not GetGlobalBool("MetrostroiSync-connected"))
    self.CreateButton.DoClick = function()
        CreateSession()
    end

    
    self.LogsLabel = self:Add("DLabel")
    self.LogsLabel:SetPos(128, 307)
    self.LogsLabel:SetText("События")
    self.LogsLabel:SizeToContents()

    self.Logs = self:Add("DListView")
    self.Logs:SetPos(10, 330)
    self.Logs:SetSize(280, 160)

    local logs_type = self.Logs:AddColumn("Тип")
    logs_type:SetMinWidth(1)
    logs_type:SetWidth(10)

    self.Logs:AddColumn("Текст"):SetWidth(170)

    self.ProtoVersion = self:Add("DLabel")
    self.ProtoVersion:SetPos(15, 510)
    self.ProtoVersion:SetText("Версия протокола: " .. Metrostroi.SyncSystem.ProtocolVersion)
    self.ProtoVersion:SizeToContents()
    self.ProtoVersion:SetTextColor(Color(0, 0, 0))
end

function PANEL:BrowserSetInfo()
    self.Browser:Clear()
    GetInfo(function(...)
        return self.Browser:AddLine(...)
    end)
end

function PANEL:LogInfo(text)
    self.Logs:AddLine("Обычный", text)
end

function PANEL:LogError(text)
    self.Logs:AddLine("Ошибка", text)
end

vgui.Register( "MSMainMenu", PANEL, "Panel")


net.Receive("MetrostroiSync-open-menu", function()
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle("Меню синхронизации")
    frame:SetSize( 800, 600 )
    frame:Center()
    frame:MakePopup()

    local sheet = vgui.Create( "DPropertySheet", frame )
    sheet:Dock(FILL)

    local menu = vgui.Create( "MSMainMenu", sheet)
    sheet:AddSheet("Список сессий", menu)
    
    net.Receive("MetrostroiSync-error-code-connect", function()
        if not IsValid(menu) then return end

        local code = net.ReadUInt(8)

        local err_str = "Ошибка"
        if code == 102 then err_str = "Неверный пароль" end
        if code == 103 then err_str = "Карта сессии не совпадает с текущей" end
        if code == 104 then err_str = "Ошибка подключения" end
        if code == 105 then err_str = "Несоотв. протокола сессии с сервером" end
        if code == 106 then err_str = "Сессия переполнена" end

        menu:LogError(err_str)
    end)
    
    net.Receive("MetrostroiSync-connect-server", function()
        notification.AddLegacy("Подключено к сессии", 0, 5)

        if not IsValid(menu) then return end
        menu:LogInfo("Подключено к сессии")
        menu.ConnectButton:SetEnabled(false)
        menu.CreateButton:SetEnabled(false)
        menu.DisconnectButton:SetEnabled(true)
        menu:BrowserSetInfo()
    end)
    
    net.Receive("MetrostroiSync-disconnect-server", function()
        notification.AddLegacy("Отключен от сессии", 0, 5)

        if not IsValid(menu) then return end
        menu:LogInfo("Отключен от сессии")
        menu.Browser:ClearSelection()
        menu.ConnectButton:SetEnabled(false)
        menu.CreateButton:SetEnabled(true)
        menu.DisconnectButton:SetEnabled(false)
        menu:BrowserSetInfo()
    end)
end)