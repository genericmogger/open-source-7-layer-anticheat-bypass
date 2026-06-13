local function runBypass()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LogService = game:GetService("LogService")
    local ScriptContext = game:GetService("ScriptContext")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")

    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        LocalPlayer = Players.LocalPlayer
    end

    local function containsKickFunction(scriptObj)
        if not scriptObj or not scriptObj:IsA("LuaSourceContainer") then return false end
        local source = scriptObj.Source or ""
        local lower = source:lower()
        if lower:find("function%s+kick") or lower:find(":%s*kick") or lower:find("local%s+function%s+kick") then
            return true
        end
        return false
    end

    local function deleteKickScripts(parent)
        if not parent then return end
        for _, desc in ipairs(parent:GetDescendants()) do
            if containsKickFunction(desc) then
                pcall(function() desc:Destroy() end)
            end
        end
    end

    pcall(function() deleteKickScripts(LocalPlayer:WaitForChild("PlayerScripts")) end)
    pcall(function() deleteKickScripts(LocalPlayer:WaitForChild("CoreGui")) end)

    game.DescendantAdded:Connect(function(desc)
        if containsKickFunction(desc) then
            task.wait(0.05)
            if desc and desc.Parent then
                pcall(function() desc:Destroy() end)
            end
        end
    end)

    local fakeRemote = Instance.new("RemoteEvent")
    fakeRemote.Name = "ClientAlert"
    fakeRemote.Parent = LocalPlayer

    local pmt = getrawmetatable(LocalPlayer)
    local old_nc = pmt.__namecall
    setreadonly(pmt, false)
    pmt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "WaitForChild" and select(1, ...) == "ClientAlert" then
            return fakeRemote
        end
        return old_nc(self, ...)
    end)
    setreadonly(pmt, true)

    local gameMT = getrawmetatable(game)
    local old_game_nc = gameMT.__namecall
    setreadonly(gameMT, false)
    gameMT.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self == LocalPlayer and (method == "Kick" or method == "kick") then return nil end
        if method == "Shutdown" or method:lower() == "kick" then return nil end
        if method == "FireServer" and self == fakeRemote then return nil end
        return old_game_nc(self, ...)
    end)
    setreadonly(gameMT, true)

    local old_setmetatable = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
        if mt and type(mt) == "table" and rawget(mt, "__mode") then
            local mode = rawget(mt, "__mode")
            if mode == "kv" or mode == "v" or mode == "k" then
                local trace = debug.traceback()
                if trace:find("Replicated") or trace:find("CoreGui") or trace:find("ServerScript") or trace:find("StarterPlayer") then
                    return old_setmetatable({1, 2, 3}, {})
                end
            end
        end
        return old_setmetatable(tbl, mt)
    end))

    local originalKick = LocalPlayer.Kick
    if originalKick then
        hookfunction(originalKick, newcclosure(function(self, ...)
            if self == LocalPlayer then return nil end
            return originalKick(self, ...)
        end))
    end

    local antiCheatKeywords = {
        "analytics", "pipeline", "anticheat", "takethel", "ban", "kick", "shutdown",
        "report", "telemetry", "log", "tracking", "detect", "validate", "check", "verify"
    }

    local function shouldHookFunction(func)
        local ok, src = pcall(debug.info, func, "s")
        if ok and type(src) == "string" then
            local lowerSrc = src:lower()
            for _, kw in ipairs(antiCheatKeywords) do
                if lowerSrc:find(kw) then
                    return true
                end
            end
        end
        local ok2, constants = pcall(debug.getconstants, func)
        if ok2 then
            for _, c in pairs(constants) do
                if type(c) == "string" then
                    local lowerC = c:lower()
                    for _, kw in ipairs(antiCheatKeywords) do
                        if lowerC:find(kw) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    task.spawn(function()
        local gcTable = getgc(true)
        for _, v in pairs(gcTable) do
            if typeof(v) == "function" then
                if shouldHookFunction(v) then
                    pcall(function()
                        hookfunction(v, newcclosure(function(...) return task.wait(9e9) end))
                    end)
                end
            end
        end
    end)

    task.spawn(function()
        local function scanAndHookRemotes(container)
            if not container then return end
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    local nameLower = child.Name:lower()
                    for _, kw in ipairs(antiCheatKeywords) do
                        if nameLower:find(kw) then
                            if child.OnClientEvent then
                                for _, conn in pairs(getconnections(child.OnClientEvent)) do
                                    if conn and conn.Function then
                                        pcall(function() hookfunction(conn.Function, newcclosure(function(...) end)) end)
                                    end
                                end
                            end
                            break
                        end
                    end
                end
                scanAndHookRemotes(child)
            end
        end
        scanAndHookRemotes(ReplicatedStorage)
        scanAndHookRemotes(ReplicatedFirst)
        scanAndHookRemotes(LocalPlayer)
    end)

    task.spawn(function()
        for _, conn in pairs(getconnections(LogService.MessageOut)) do
            if conn and conn.Function then
                pcall(function() hookfunction(conn.Function, newcclosure(function(...) end)) end)
            end
        end
    end)

    task.spawn(function()
        for _, conn in ipairs(getconnections(ScriptContext.Error)) do
            pcall(function() conn:Disable() end)
        end
        pcall(function()
            local oldConnect = ScriptContext.Error.Connect
            hookfunction(oldConnect, newcclosure(function(...) return nil end))
        end)
    end)

    task.spawn(function()
        local function hookScripts(container)
            if not container then return end
            for _, scriptObj in ipairs(container:GetDescendants()) do
                if scriptObj:IsA("LocalScript") or scriptObj:IsA("ModuleScript") then
                    local nameLower = scriptObj.Name:lower()
                    if nameLower:find("loadingscreen") or nameLower:find("localscript3") or nameLower:find("anticheat") then
                        for _, func in pairs(getgc(false)) do
                            if typeof(func) == "function" then
                                local ok, env = pcall(getfenv, func)
                                if ok and env then
                                    local scr = rawget(env, "script")
                                    if scr == scriptObj then
                                        pcall(function() hookfunction(func, function() end) end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        hookScripts(ReplicatedFirst)
        hookScripts(LocalPlayer:FindFirstChild("PlayerScripts"))
    end)

    local anySuccess = true

    pcall(function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BypassNotification"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 999
        screenGui.Parent = game:GetService("CoreGui")

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = "Bypassed"
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextSize = 28
        textLabel.Font = Enum.Font.GothamBold
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(0, 0, 0, 50)
        textLabel.Position = UDim2.new(0.5, 0, 0.5, -25)
        textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        textLabel.Parent = screenGui

        local openTween = TweenService:Create(textLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.6, 0, 0, 50), Position = UDim2.new(0.5, 0, 0.5, -25)})
        local closeTween = TweenService:Create(textLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 50), Position = UDim2.new(0.5, 0, 0.5, -25)})

        textLabel.Size = UDim2.new(0, 0, 0, 50)
        textLabel.Position = UDim2.new(0.5, 0, 0.5, -25)

        openTween:Play()
        task.wait(1)
        closeTween:Play()
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

runBypass()
