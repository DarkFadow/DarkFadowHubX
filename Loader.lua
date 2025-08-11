--// Chargement Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Steal a Brainrot Pro Hub",
    LoadingTitle = "Chargement en cours...",
    LoadingSubtitle = "par ChatGPT",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Tabs
local MainTab = Window:CreateTab("Main")
local CheatsTab = Window:CreateTab("Cheats")
local AutoTab = Window:CreateTab("Auto")
local MovementTab = Window:CreateTab("Movement")
local UtilsTab = Window:CreateTab("Utilities")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables et RemoteEvents (remplacer par les remotes exacts trouvés dans le jeu)
local RemoteEvents = {
    BuyBrainrot = ReplicatedStorage:WaitForChild("BuyBrainrotEvent"),
    StealBrainrot = ReplicatedStorage:WaitForChild("StealBrainrotEvent"),
    LockBase = ReplicatedStorage:WaitForChild("LockBaseEvent"),
    SellBrainrot = ReplicatedStorage:WaitForChild("SellBrainrotEvent"),
    Rebirth = ReplicatedStorage:WaitForChild("RebirthEvent"),
}

local function getBaseCFrame()
    -- Retourner la position de ta base (à modifier si nécessaire)
    return CFrame.new(0, 10, 0) -- Exemple
end

-- Téléportation à la base
MainTab:CreateButton({
    Name = "Téléporter à la base",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = getBaseCFrame()
        end
    end
})

-- Fly (fonctionnel avec BodyVelocity)
local fly = false
local flying = false
local bodyVelocity, bodyGyro

MovementTab:CreateToggle({
    Name = "Fly (Bypass)",
    CurrentValue = false,
    Callback = function(v)
        fly = v
        if fly then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVelocity.Parent = hrp

                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bodyGyro.P = 1e4
                bodyGyro.CFrame = hrp.CFrame
                bodyGyro.Parent = hrp

                flying = true
            end
        else
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            flying = false
        end
    end
})

RunService.RenderStepped:Connect(function(delta)
    if fly and flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        moveDir = moveDir.Unit * 50
        if moveDir.Magnitude == 0 then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        else
            bodyVelocity.Velocity = moveDir
        end

        bodyGyro.CFrame = cam.CFrame
    end
end)

-- ESP Joueurs + Brainrots
local function createESP(parent, name, color)
    if parent:FindFirstChild("ESP_" .. name) then return end
    local bill = Instance.new("BillboardGui", parent)
    bill.Name = "ESP_" .. name
    bill.Size = UDim2.new(0, 100, 0, 40)
    bill.Adornee = parent
    bill.AlwaysOnTop = true

    local label = Instance.new("TextLabel", bill)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = name
    label.TextColor3 = color
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
end

CheatsTab:CreateToggle({
    Name = "ESP Joueurs",
    CurrentValue = false,
    Callback = function(v)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                createESP(plr.Character.HumanoidRootPart, plr.Name, Color3.fromRGB(255, 0, 0))
            end
        end
    end
})

-- Auto Steal
local autoSteal = false
AutoTab:CreateToggle({
    Name = "Auto Steal",
    CurrentValue = false,
    Callback = function(v)
        autoSteal = v
    end
})

spawn(function()
    while wait(0.5) do
        if autoSteal and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for _, br in pairs(Workspace:FindFirstChild("Brainrots") and Workspace.Brainrots:GetChildren() or {}) do
                if br:FindFirstChild("HumanoidRootPart") and (hrp.Position - br.HumanoidRootPart.Position).Magnitude < 50 then
                    -- Interagir avec le Brainrot
                    firetouchinterest(hrp, br.HumanoidRootPart, 0)
                    firetouchinterest(hrp, br.HumanoidRootPart, 1)
                    RemoteEvents.StealBrainrot:FireServer(br) -- Exemple pour voler
                end
            end
        end
    end
end)

-- Auto Buy Brainrot
local autoBuy = false
AutoTab:CreateToggle({
    Name = "Auto Buy Brainrot",
    CurrentValue = false,
    Callback = function(v)
        autoBuy = v
    end
})

AutoTab:CreateDropdown({
    Name = "Choisir rareté à acheter",
    Options = {"Common", "Rare", "Legendary", "Mythic"},
    CurrentOption = "Common",
    Callback = function(option)
        -- Gérer les options d'achat ici
        if autoBuy then
            RemoteEvents.BuyBrainrot:FireServer(option)
        end
    end
})

-- Auto Rebirth
local autoRebirth = false
AutoTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(v)
        autoRebirth = v
    end
})

spawn(function()
    while wait(60) do
        if autoRebirth then
            RemoteEvents.Rebirth:FireServer() -- Exemple de rebirth
        end
    end
end)

-- Anti AFK
local antiAFK = false
UtilsTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(v)
        antiAFK = v
    end
})

local VirtualUser = game:GetService("VirtualUser")
spawn(function()
    while wait(60) do
        if antiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- Fin du script
print("Steal a Brainrot Pro Hub chargé avec succès !")
