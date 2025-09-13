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

local MainTab = MainWindow:CreateTab("Player🙍‍♂️", nil)
local MainSection = MainTab:CreateSection("Main")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- helper clamp
local function clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi else return v end end

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

-- Shooter tab (ESP + Aimbot)
local ShooterTab = MainWindow:CreateTab("Shooter 🔫", nil)
local ShooterSection = ShooterTab:CreateSection("OP but a bit broken")

-- ESP (surround hitbox approx + blue name). removed red square.
local espEnabled = false
local espTable = {}

local function createESPForPlayer(plr)
    if not plr.Character or not plr.Character:FindFirstChild("Head") or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    if espTable[plr] then return end

    local bill = Instance.new("BillboardGui")
    bill.Name = "MSH_ESP"
    bill.Adornee = plr.Character.Head
    bill.Size = UDim2.new(0,120,0,30) -- initial, will be updated every frame
    bill.StudsOffset = Vector3.new(0, 2.2, 0)
    bill.AlwaysOnTop = true
    bill.ResetOnSpawn = false

    local container = Instance.new("Frame", bill)
    container.Name = "Container"
    container.Size = UDim2.new(1,0,1,0)
    container.BackgroundTransparency = 1

    local outlineFrame = Instance.new("Frame", container)
    outlineFrame.Name = "Outline"
    outlineFrame.AnchorPoint = Vector2.new(0,0)
    outlineFrame.Position = UDim2.new(0,0,0,0)
    outlineFrame.Size = UDim2.new(1,0,1,0)
    outlineFrame.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", outlineFrame)
    stroke.Color = Color3.fromRGB(255,0,0)
    stroke.Thickness = 3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local nameLabel = Instance.new("TextLabel", container)
    nameLabel.Name = "Name"
    nameLabel.AnchorPoint = Vector2.new(0.5, 0)
    nameLabel.Position = UDim2.new(0.5,0,0, -6)
    nameLabel.Size = UDim2.new(1,0,0,18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.fromRGB(0,170,255) -- blue name
    nameLabel.TextScaled = false
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0.7
    nameLabel.ZIndex = 2

    bill.Parent = game.CoreGui
    espTable[plr] = {
        gui = bill,
        outline = outlineFrame,
        nameLabel = nameLabel
    }
end

local function removeESPForPlayer(plr)
    if espTable[plr] and espTable[plr].gui and espTable[plr].gui.Parent then
        espTable[plr].gui:Destroy()
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
   end,
})

RunService.RenderStepped:Connect(function()
   if espEnabled then
      for _, plr in pairs(Players:GetPlayers()) do
         if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            if not espTable[plr] then
               createESPForPlayer(plr)
            end
            local data = espTable[plr]
            if data and data.gui and data.gui.Adornee and plr.Character and plr.Character:FindFirstChild("Head") then
               -- compute 2D screen positions for head and root to approximate box size
               local headPos = plr.Character.Head.Position
               local hrp = plr.Character.HumanoidRootPart.Position
               local screenHead, onHead = Camera:WorldToViewportPoint(headPos)
               local screenRoot, onRoot = Camera:WorldToViewportPoint(hrp)
               if onHead and onRoot then
                  local heightPx = math.abs(screenHead.Y - screenRoot.Y)
                  -- add a bit of padding
                  local paddedHeight = clamp(heightPx * 1.6, 24, 400)
                  local paddedWidth = clamp(paddedHeight * 0.6, 16, 300)
                  data.gui.Size = UDim2.new(0, paddedWidth, 0, paddedHeight)
                  -- adjust StudsOffset so the box visually centers on the body
                  data.gui.StudsOffset = Vector3.new(0, (paddedHeight/100) + 1.8, 0)
                  -- position name label above box (keep centered)
                  data.nameLabel.Position = UDim2.new(0.5, 0, 0, - (paddedHeight * 0.25))
                  data.nameLabel.Text = plr.Name
                  if not data.gui.Parent then data.gui.Parent = game.CoreGui end
               else
                  -- keep gui parent but it's off-screen
                  data.gui.Parent = game.CoreGui
               end
            end
         else
            removeESPForPlayer(plr)
         end
      end
   end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESPForPlayer(plr)
end)

-- >>> Aimbot with adjustable FOV circle (RAINBOW) <<<
local aimbotEnabled = false
local aimHold = false
local aimFOV = 150            -- pixels
local showFOV = true
local aimSmooth = 0.55        -- 0 = snap, 0.1-0.8 smooth
local aimMaxDistance = 1000   -- studs

-- Drawing circle (if available) + hue for rainbow
local haveDrawing, drawNew = pcall(function() return Drawing.new end)
local aimCircle = nil
local hue = 0 -- 0..1
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
        aimCircle.Color = Color3.fromHSV(hue, 1, 1)
    else
        aimCircle = nil
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
    end,
})

ShooterTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Flag = "ShowFOVToggle",
    Callback = function(v)
        showFOV = v
        if aimCircle then aimCircle.Visible = (v and aimbotEnabled and aimHold) end
    end,
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
    end,
})

ShooterTab:CreateSlider({
    Name = "Smooth",
    Range = {0,100}, -- 0..100 -> 0..1
    Increment = 1,
    Suffix = "%",
    CurrentValue = math.floor(aimSmooth * 100),
    Flag = "AimSmoothSlider",
    Callback = function(v)
        aimSmooth = clamp(v / 100, 0, 1)
    end,
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
    end,
})

local function getClosestInRange()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local localPos = LocalPlayer.Character.HumanoidRootPart.Position
    local closest, cd = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            if not plr.Team or plr.Team ~= LocalPlayer.Team then
                local dist = (localPos - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist <= aimMaxDistance then
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
    return closest
end

-- Input handling (hold right mouse to aim)
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

-- Render loop: update circle + aim smoothly + animate hue
RunService.RenderStepped:Connect(function(dt)
    -- animate rainbow hue
    if aimCircle then
        hue = (hue + dt * 0.18) % 1 -- 0.18 -> vitesse raisonnable ; augmente pour plus rapide
        aimCircle.Color = Color3.fromHSV(hue, 1, 1)
    end

    -- update circle position & radius
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

-- -----------------------------
-- Fly contrôlé par la caméra
-- -----------------------------
local flyEnabled = false
local flySpeed = 100 -- default fly speed (you can change)
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

-- Fly toggle in Player tab
MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(v)
        flyEnabled = v
        -- set PlatformStand when enabling/disabling to stabilize movement
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = v
        end
        -- clear keys when disabling
        if not v then
            for k,_ in pairs(flyKeys) do flyKeys[k] = false end
        end
    end,
})

-- Optional slider for fly speed
MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10,500},
    Increment = 1,
    Suffix = "SPD",
    CurrentValue = flySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(v)
        flySpeed = v
    end
})

-- Input handling for fly keys
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false end
end)

-- Fly movement: follow camera directions
RunService.RenderStepped:Connect(function()
    if flyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local camCf = cam.CFrame
        local moveDir = Vector3.new(0,0,0)

        if flyKeys.W then moveDir = moveDir + camCf.LookVector end
        if flyKeys.S then moveDir = moveDir - camCf.LookVector end
        if flyKeys.A then moveDir = moveDir - camCf.RightVector end
        if flyKeys.D then moveDir = moveDir + camCf.RightVector end
        if flyKeys.Space then moveDir = moveDir + Vector3.new(0,1,0) end
        if flyKeys.Shift then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            hrp.Velocity = moveDir.Unit * flySpeed
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- Clean up on disable / leaving: destroy remaining ESP guis and drawing
local function cleanup()
    for p,_ in pairs(espTable) do
        removeESPForPlayer(p)
    end
    if aimCircle then
        pcall(function() aimCircle.Visible = false end)
    end
end

game:BindToClose(function()
    cleanup()
end)
