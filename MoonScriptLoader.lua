local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local MainWindow = Rayfield:CreateWindow({
    Name = "💫MoonScriptHub✨",
    Icon = 0,
    LoadingTitle = "💫MoonScriptHub✨",
    LoadingSubtitle = "by DarkFadow & Narixx",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = { Enabled = false }
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Helper clamp
local function clamp(v, lo, hi) 
    if v < lo then return lo elseif v > hi then return hi else return v end 
end

-- =====================
-- PLAYER TAB
-- =====================
local MainTab = MainWindow:CreateTab("Player🙍‍♂️", nil)
local MainSection = MainTab:CreateSection("Main")

-- Infinite Jump
local InfiniteJumpEnabled = false
MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end,
})
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- WalkSpeed
local speedValue = 16
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {0,300},
    Increment = 1,
    Suffix = "WS",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(v)
        speedValue = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speedValue
        end
    end
})

-- JumpPower
local jumpValue = 50
MainTab:CreateSlider({
    Name = "JumpPower",
    Range = {0,300},
    Increment = 1,
    Suffix = "JP",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(v)
        jumpValue = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = jumpValue
        end
    end
})

-- Noclip
local noclipEnabled = false
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(v) noclipEnabled = v end,
})
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Speed Boost
MainTab:CreateButton({
    Name = "Speed Boost (3s)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local old = hum.WalkSpeed
            hum.WalkSpeed = math.max(100, old + 80)
            task.delay(3, function()
                if hum and hum.Parent then
                    hum.WalkSpeed = old
                end
            end)
        end
    end
})

-- Kill All
MainTab:CreateButton({
    Name = "Kill All",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                plr.Character:FindFirstChildOfClass("Humanoid").Health = 0
            end
        end
    end
})

-- Kill Aura
local killAuraEnabled = false
local killDistance = 20
MainTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAuraToggle",
    Callback = function(v)
        killAuraEnabled = v
    end,
})
RunService.RenderStepped:Connect(function()
    if killAuraEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local localHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - localHrp.Position).Magnitude <= killDistance then
                    plr.Character:FindFirstChildOfClass("Humanoid").Health = 0
                end
            end
        end
    end
end)

-- =====================
-- SHOOTER TAB
-- =====================
local ShooterTab = MainWindow:CreateTab("Shooter 🔫", nil)
local ShooterSection = ShooterTab:CreateSection("OP but a bit broken")

-- Infinite HP & Ammo
local infiniteHPEnabled = false
local infiniteAmmoEnabled = false
ShooterTab:CreateToggle({
    Name = "Infinite HP",
    CurrentValue = false,
    Flag = "InfiniteHPToggle",
    Callback = function(v)
        infiniteHPEnabled = v
    end
})
ShooterTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Flag = "InfiniteAmmoToggle",
    Callback = function(v)
        infiniteAmmoEnabled = v
    end
})

RunService.RenderStepped:Connect(function()
    if infiniteHPEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MaxHealth
    end
    -- Infinite ammo: dépend du jeu, ici juste exemple générique
    if infiniteAmmoEnabled and LocalPlayer.Backpack then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                tool.Ammo.Value = tool.Ammo.MaxValue
            end
        end
    end
end)

-- ESP Table
local espEnabled = false
local espTable = {}

-- Aim Through Walls toggle
local aimThroughWalls = true
ShooterTab:CreateToggle({
    Name = "Aim Through Walls",
    CurrentValue = true,
    Flag = "AimThroughWallsToggle",
    Callback = function(v)
        aimThroughWalls = v
    end
})

-- Dropdown Aimbot: All / Enemies
local aimbotTargetMode = "Enemies"
ShooterTab:CreateDropdown({
    Name = "Aimbot Target",
    Options = {"All","Enemies"},
    CurrentOption = "Enemies",
    Flag = "AimbotDropdown",
    Callback = function(v)
        aimbotTargetMode = v
    end
})

-- ESP Hitbox
local function createESPForPlayer(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    if espTable[plr] then return end
    local hrp = plr.Character.HumanoidRootPart
    local bill = Instance.new("BillboardGui")
    bill.Name = "MSH_ESP"
    bill.Adornee = hrp
    bill.Size = UDim2.new(0, hrp.Size.X*30, 0, hrp.Size.Y*30)
    bill.StudsOffset = Vector3.new(0, hrp.Size.Y/2, 0)
    bill.AlwaysOnTop = true
    bill.ResetOnSpawn = false

    local nameLabel = Instance.new("TextLabel", bill)
    nameLabel.Size = UDim2.new(1,0,1,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    if plr.Team == LocalPlayer.Team then
        nameLabel.TextColor3 = Color3.fromRGB(0,170,255)
    else
        nameLabel.TextColor3 = Color3.fromRGB(255,0,0)
    end
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0.7
    nameLabel.ZIndex = 2

    bill.Parent = game.CoreGui
    espTable[plr] = bill
end

local function removeESPForPlayer(plr)
    if espTable[plr] and espTable[plr].Parent then
        espTable[plr]:Destroy()
    end
    espTable[plr] = nil
end

ShooterTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ShooterESPToggle",
    Callback = function(v)
        espEnabled = v
        if not v then
            for p,_ in pairs(espTable) do removeESPForPlayer(p) end
        end
    end
})

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not espTable[plr] then createESPForPlayer(plr) end
            else
                removeESPForPlayer(plr)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(removeESPForPlayer)

-- >>> Aimbot with adjustable FOV circle <<<
local aimbotEnabled = false
local aimHold = false
local aimFOV = 150
local showFOV = true
local aimSmooth = 0.55
local aimMaxDistance = 1000

-- Drawing circle
local haveDrawing, drawNew = pcall(function() return Drawing.new end)
local aimCircle = nil
if haveDrawing then
    local ok, c = pcall(function()
        return Drawing.new("Circle")
    end)
    if ok and c then
        aimCircle = c
        aimCircle.Thickness = 2
        aimCircle.NumSides = 100
        aimCircle.Filled = false
        aimCircle.Visible = false
        aimCircle.Radius = aimFOV
        aimCircle.Color = Color3.fromRGB(255,0,0)
    end
end

ShooterTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(v)
        aimbotEnabled = v
        if not v then aimHold = false end
        if aimCircle then aimCircle.Visible = false end
    end
})

ShooterTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Flag = "ShowFOVToggle",
    Callback = function(v)
        showFOV = v
        if aimCircle then aimCircle.Visible = (v and aimbotEnabled and aimHold) end
    end
})

ShooterTab:CreateSlider({
    Name = "Aim FOV",
    Range = {50, 500},
    Increment = 1,
    Suffix = "px",
    CurrentValue = aimFOV,
    Flag = "AimFOVSlider",
    Callback = function(v)
        aimFOV = v
        if aimCircle then aimCircle.Radius = v end
    end
})

ShooterTab:CreateSlider({
    Name = "Smooth",
    Range = {0,100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = math.floor(aimSmooth * 100),
    Flag = "AimSmoothSlider",
    Callback = function(v)
        aimSmooth = clamp(v / 100, 0, 1)
    end
})

ShooterTab:CreateSlider({
    Name = "Max Distance",
    Range = {50,2000},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = aimMaxDistance,
    Flag = "AimMaxDistSlider",
    Callback = function(v)
        aimMaxDistance = v
    end
})

-- Get closest target considering Dropdown and Aim Through Walls
local function getClosestInRange()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local localPos = LocalPlayer.Character.HumanoidRootPart.Position
    local closest, cd = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            local sameTeam = (plr.Team == LocalPlayer.Team)
            if aimbotTargetMode == "All" or (aimbotTargetMode == "Enemies" and not sameTeam) then
                local dist = (localPos - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist <= aimMaxDistance then
                    local canSee = true
                    if not aimThroughWalls then
                        local ray = Ray.new(Camera.CFrame.Position, (plr.Character.Head.Position - Camera.CFrame.Position).Unit * dist)
                        local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character}, false, true)
                        if hitPart and not hitPart:IsDescendantOf(plr.Character) then
                            canSee = false
                        end
                    end
                    if canSee then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                        if onScreen then
                            local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if mag < cd and mag <= aimFOV then
                                cd = mag
                                closest = plr
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Input
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then
        aimHold = true
        if aimCircle then aimCircle.Visible = showFOV and true end
    end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimHold = false
        if aimCircle then aimCircle.Visible = false end
    end
end)

-- Render loop
RunService.RenderStepped:Connect(function(dt)
    if aimCircle then
        aimCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        aimCircle.Radius = aimFOV
        aimCircle.Visible = (showFOV and aimbotEnabled and aimHold)
    end

    if aimbotEnabled and aimHold then
        local target = getClosestInRange()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local cam = workspace.CurrentCamera
            local targetCf = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
            if aimSmooth and aimSmooth > 0 then
                local alpha = clamp(1 - math.exp(-aimSmooth * 60 * dt), 0, 1)
                cam.CFrame = cam.CFrame:Lerp(targetCf, alpha)
            else
                cam.CFrame = targetCf
            end
        end
    end
end)

-- Cleanup
local function cleanup()
    for p,_ in pairs(espTable) do removeESPForPlayer(p) end
    if aimCircle then pcall(function() aimCircle.Visible = false end) end
end
game:BindToClose(cleanup)


