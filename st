--==========================================
-- SERVICES
--==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--==========================================
-- UI SETUP
--==========================================
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 220)
Main.Position = UDim2.new(0.5, -160, 0.5, -110) -- กึ่งกลางหน้าจอ
Main.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Text = "🔥 Brainrot Menu"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
Title.BackgroundTransparency = 1
Title.Parent = Main

-- Close button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "✖"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.TextColor3 = Color3.fromRGB(255, 80, 80)
Close.BackgroundTransparency = 1
Close.Parent = Main
Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Holder for buttons
local Holder = Instance.new("Frame")
Holder.Size = UDim2.new(1, 0, 1, -45)
Holder.Position = UDim2.new(0, 0, 0, 45)
Holder.BackgroundTransparency = 1
Holder.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 10)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Holder

--==========================================
-- BUTTON GENERATOR
--==========================================
local function createButton(txt)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(50, 40, 85)
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(230, 210, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = Holder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 40, 85)
    end)

    return btn
end

--==========================================
-- ANTI-RAGDOLL
--==========================================
local antiRagdoll = false
local ARConnections = {}
local AROriginalMotors = {}

local function antiRagdollFunc(character)
    if not antiRagdoll then return end
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- เก็บ Motor6D เดิม
    AROriginalMotors[character] = {}
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("Motor6D") then
            AROriginalMotors[character][part] = part.C0
        end
    end

    -- PlatformStand
    local pconn = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
    end)
    table.insert(ARConnections, pconn)

    -- RenderStepped
    local rconn
    rconn = RunService.RenderStepped:Connect(function()
        if not antiRagdoll then
            rconn:Disconnect()
            return
        end
        for motor,c0 in pairs(AROriginalMotors[character]) do
            if motor.Parent and motor.Part0 and motor.Part1 then
                motor.C0 = c0
            end
        end
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude > 50 then
                hrp.AssemblyLinearVelocity = vel.Unit * 50
            end
        end
    end)
    table.insert(ARConnections, rconn)
end

-- สร้างปุ่ม Anti-Ragdoll
local ARButton = createButton("🛡 Anti-Ragdoll: OFF")
ARButton.MouseButton1Click:Connect(function()
    antiRagdoll = not antiRagdoll
    ARButton.Text = antiRagdoll and "🛡 Anti-Ragdoll: ON" or "🛡 Anti-Ragdoll: OFF"

    local char = LocalPlayer.Character
    if antiRagdoll and char then
        antiRagdollFunc(char)
    else
        for _, conn in pairs(ARConnections) do
            if conn.Connected then conn:Disconnect() end
        end
        ARConnections = {}

        if char and AROriginalMotors[char] then
            for motor,c0 in pairs(AROriginalMotors[char]) do
                if motor.Parent then motor.C0 = c0 end
            end
        end
    end
end)

-- Character Added
LocalPlayer.CharacterAdded:Connect(function(char)
    if antiRagdoll then
        antiRagdollFunc(char)
    end
end)
if LocalPlayer.Character then
    antiRagdollFunc(LocalPlayer.Character)
end

--==========================================
-- ESP BEST BRAINROT
--==========================================
local ESP_FOLDER = Instance.new("Folder")
ESP_FOLDER.Name = "ESP"
ESP_FOLDER.Parent = playerGui

local LINE_FOLDER = Instance.new("Folder")
LINE_FOLDER.Name = "ESP_Lines"
LINE_FOLDER.Parent = Workspace

local currentESP
local currentBeam
local currentPetInfo
local a0,a1

local function parseMoneyPerSec(text)
    text = text:match("^%s*(.-)%s*$")
    local number,suffix = text:match("%$([%d%.]+)%s*([kKmMbB]?)%s*/?s?")
    number = tonumber(number) or 0
    if suffix then
        suffix = suffix:lower()
        if suffix=="k" then number=number*1000
        elseif suffix=="m" then number=number*1e6
        elseif suffix=="b" then number=number*1e9
        end
    end
    return number
end

local function createESP(petName, infoText, mutationText, targetPart)
    if currentESP then currentESP:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0,150,0,50)
    billboard.AlwaysOnTop = true
    billboard.Adornee = targetPart
    billboard.Parent = ESP_FOLDER
    billboard.StudsOffset = Vector3.new(0,3,0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size=UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency=1
    textLabel.TextColor3=Color3.fromRGB(255,255,255)
    textLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
    textLabel.TextStrokeTransparency=0
    textLabel.TextScaled=false
    textLabel.TextSize=10
    textLabel.RichText=true
    textLabel.Text=string.format(
        '<font color="rgb(255,0,0)">%s</font>\n<font color="rgb(0,255,0)">%s</font>\n<font color="rgb(255,255,0)">%s</font>',
        petName,infoText,mutationText or ""
    )
    textLabel.Parent=billboard
    currentESP=billboard
end

local function createBeam(targetPart)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not targetPart then return end

    if currentBeam then
        currentBeam:Destroy()
        if a0 then a0:Destroy() end
        if a1 then a1:Destroy() end
    end

    a0=Instance.new("Attachment")
    a0.Parent=char.HumanoidRootPart
    a1=Instance.new("Attachment")
    a1.Parent=targetPart

    local beam=Instance.new("Beam")
    beam.Attachment0=a0
    beam.Attachment1=a1
    beam.Width0=0.35
    beam.Width1=0.35
    beam.FaceCamera=true
    beam.LightInfluence=0
    beam.Parent=LINE_FOLDER
    currentBeam=beam

    task.spawn(function()
        while beam.Parent do
            local color = Color3.fromHSV((tick()%5)/5,1,1)
            beam.Color = ColorSequence.new(color)
            task.wait(0.05)
        end
    end)
end

local function findBestPet()
    local PlotsFolder = Workspace:FindFirstChild("Plots")
    if not PlotsFolder then return end
    local bestValue=-1
    local bestPet=nil
    for _,plot in ipairs(PlotsFolder:GetChildren()) do
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            for _,podium in ipairs(podiums:GetChildren()) do
                local spawnPart = podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")
                if spawnPart then
                    local attachment = spawnPart:FindFirstChild("Attachment")
                    local overhead = attachment and attachment:FindFirstChild("AnimalOverhead")
                    if overhead then
                        local nameLabel=overhead:FindFirstChild("DisplayName")
                        local genLabel=overhead:FindFirstChild("Generation")
                        local mutationLabel=overhead:FindFirstChild("Mutation")
                        if genLabel then
                            local petName = nameLabel and nameLabel.Text or "Unknown"
                            local genText = genLabel.Text
                            local mutationText = mutationLabel and mutationLabel.Text or ""
                            local mps=parseMoneyPerSec(genText)
                            local genNumber = tonumber(genText:match("%d+")) or 0
                            local value = mps>0 and mps or genNumber
                            if value>bestValue then
                                bestValue=value
                                bestPet={name=petName,info=genText,mutation=mutationText,part=spawnPart,value=value}
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPet
end

local espOn = false
local ESPButton = createButton("👁 ESP: OFF")
ESPButton.MouseButton1Click:Connect(function()
    espOn = not espOn
    ESPButton.Text = espOn and "👁 ESP: ON" or "👁 ESP: OFF"

    if not espOn then
        if currentESP then currentESP:Destroy() currentESP=nil currentPetInfo=nil end
        if currentBeam then currentBeam:Destroy() currentBeam=nil end
    end
end)

-- Update loop
task.spawn(function()
    while task.wait(0.3) do
        if espOn then
            local pet = findBestPet()
            if pet then
                local needUpdate=false
                if not currentESP then needUpdate=true
                elseif currentPetInfo then
                    if pet.value>currentPetInfo.value or pet.mutation~=currentPetInfo.mutation then
                        needUpdate=true
                    end
                end
                if needUpdate then
                    currentPetInfo=pet
                    createESP(pet.name,pet.info,pet.mutation,pet.part)
                    createBeam(pet.part)
                end
            else
                if currentESP then currentESP:Destroy() currentESP=nil currentPetInfo=nil end
                if currentBeam then currentBeam:Destroy() currentBeam=nil end
            end
        end
    end
end)
