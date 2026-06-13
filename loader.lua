local fullBypassScript = [[
local function runBypass()
    local bypassAttempts = {
        function()
            local lp = game:GetService("Players").LocalPlayer
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "Kick" and self == lp then return nil end
                return old(self, ...)
            end)
            setreadonly(mt, true)
            return true
        end,
        function()
            local lp = game:GetService("Players").LocalPlayer
            if lp.Kick then
                local old
                old = hookfunction(lp.Kick, newcclosure(function() return nil end))
            end
            return true
        end,
        function()
            local old = hookfunction(getrenv().setmetatable, newcclosure(function(t, mt)
                if mt and mt.__mode then
                    local trace = debug.traceback()
                    if trace:find("Replicated") or trace:find("CoreGui") then
                        return old({1,2,3}, {})
                    end
                end
                return old(t, mt)
            end))
            return true
        end,
        function()
            for _, conn in pairs(getconnections(game:GetService("LogService").MessageOut)) do
                if conn and conn.Function then
                    pcall(function() hookfunction(conn.Function, newcclosure(function() end)) end)
                end
            end
            return true
        end,
        function()
            local sc = game:GetService("ScriptContext")
            for _, conn in ipairs(getconnections(sc.Error)) do
                pcall(function() conn:Disable() end)
            end
            pcall(function() hookfunction(sc.Error.Connect, newcclosure(function() return nil end)) end)
            return true
        end,
        function()
            local lp = game:GetService("Players").LocalPlayer
            local fake = Instance.new("RemoteEvent")
            fake.Name = "ClientAlert"
            fake.Parent = lp
            local mt = getrawmetatable(lp)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "WaitForChild" and select(1, ...) == "ClientAlert" then
                    return fake
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
            return true
        end,
        function()
            local gc = getgc(true)
            for _, v in pairs(gc) do
                if typeof(v) == "function" then
                    local ok, src = pcall(debug.info, v, "s")
                    if ok and type(src) == "string" then
                        if src:lower():find("anticheat") or src:lower():find("ban") or src:lower():find("analytics") then
                            pcall(function() hookfunction(v, newcclosure(function() return task.wait(9e9) end)) end)
                        end
                    end
                end
            end
            return true
        end
    }

    local anySuccess = false
    for _, attempt in ipairs(bypassAttempts) do
        local ok, result = pcall(attempt)
        if ok and result then
            anySuccess = true
        end
    end

    pcall(function()
        local TweenService = game:GetService("TweenService")
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BypassNotification"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 999
        screenGui.Parent = game:GetService("CoreGui")

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = anySuccess and "Bypassed" or "Bypass Failed"
        textLabel.TextColor3 = anySuccess and Color3.new(1, 1, 1) or Color3.new(1, 0.3, 0.3)
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

if queue_on_teleport then
    queue_on_teleport([[
        local fullBypassScript = ]] .. string.dump(fullBypassScript) .. [[
        loadstring(fullBypassScript)()
    ]])
end
]]

if queue_on_teleport then
    queue_on_teleport(fullBypassScript)
end

local function runBypass()
    local bypassAttempts = {
        function()
            local lp = game:GetService("Players").LocalPlayer
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "Kick" and self == lp then return nil end
                return old(self, ...)
            end)
            setreadonly(mt, true)
            return true
        end,
        function()
            local lp = game:GetService("Players").LocalPlayer
            if lp.Kick then
                local old
                old = hookfunction(lp.Kick, newcclosure(function() return nil end))
            end
            return true
        end,
        function()
            local old = hookfunction(getrenv().setmetatable, newcclosure(function(t, mt)
                if mt and mt.__mode then
                    local trace = debug.traceback()
                    if trace:find("Replicated") or trace:find("CoreGui") then
                        return old({1,2,3}, {})
                    end
                end
                return old(t, mt)
            end))
            return true
        end,
        function()
            for _, conn in pairs(getconnections(game:GetService("LogService").MessageOut)) do
                if conn and conn.Function then
                    pcall(function() hookfunction(conn.Function, newcclosure(function() end)) end)
                end
            end
            return true
        end,
        function()
            local sc = game:GetService("ScriptContext")
            for _, conn in ipairs(getconnections(sc.Error)) do
                pcall(function() conn:Disable() end)
            end
            pcall(function() hookfunction(sc.Error.Connect, newcclosure(function() return nil end)) end)
            return true
        end,
        function()
            local lp = game:GetService("Players").LocalPlayer
            local fake = Instance.new("RemoteEvent")
            fake.Name = "ClientAlert"
            fake.Parent = lp
            local mt = getrawmetatable(lp)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "WaitForChild" and select(1, ...) == "ClientAlert" then
                    return fake
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
            return true
        end,
        function()
            local gc = getgc(true)
            for _, v in pairs(gc) do
                if typeof(v) == "function" then
                    local ok, src = pcall(debug.info, v, "s")
                    if ok and type(src) == "string" then
                        if src:lower():find("anticheat") or src:lower():find("ban") or src:lower():find("analytics") then
                            pcall(function() hookfunction(v, newcclosure(function() return task.wait(9e9) end)) end)
                        end
                    end
                end
            end
            return true
        end
    }

    local anySuccess = false
    for _, attempt in ipairs(bypassAttempts) do
        local ok, result = pcall(attempt)
        if ok and result then
            anySuccess = true
        end
    end

    pcall(function()
        local TweenService = game:GetService("TweenService")
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BypassNotification"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 999
        screenGui.Parent = game:GetService("CoreGui")

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = anySuccess and "Bypassed" or "Bypass Failed"
        textLabel.TextColor3 = anySuccess and Color3.new(1, 1, 1) or Color3.new(1, 0.3, 0.3)
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

if queue_on_teleport then
    queue_on_teleport(fullBypassScript)
end
