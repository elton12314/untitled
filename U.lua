
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

getgenv().Settings = {
    AutoDrill = false,
    AutoSell = false,
    AutoCollectDrills = false,
    AutoRebirth = false,
    SellInterval = 10,
    AutoBuyDrill = false,
    AutoBuyHandDrill = false,
    BuyDelay = 1
}

local plrs = game.Players
local plr = game:GetService("Players").LocalPlayer
local sellPart = workspace:FindFirstChild("Scripted"):FindFirstChild("Sell")
local plot = nil
local selectedDrill = nil
local selectedHandDrill = nil

if plr then
    for _, p in ipairs(workspace.Plots:GetChildren()) do
        if p:FindFirstChild("Owner") and p.Owner.Value == plr then
            plot = p
            break
        end
    end
end

local function getDrillsSortedByPrice()
    local drills = {}
    for _, frame in pairs(plr.PlayerGui.Menu.CanvasGroup.Buy.Background
                              .DrillList:GetChildren()) do
        if frame:IsA("Frame") then
            local priceLabel = frame:FindFirstChild("Buy") and
                                   frame.Buy:FindFirstChild("TextLabel")
            local titleLabel = frame:FindFirstChild("Title")
            if priceLabel and titleLabel then
                local priceText = priceLabel.Text
                local cleanPriceText = priceText:gsub("[%$,]", "")
                local price = tonumber(cleanPriceText)
                if price then
                    table.insert(drills, {
                        name = titleLabel.Text,
                        price = price,
                        frame = frame
                    })
                end
            end
        end
    end
    table.sort(drills, function(a, b) return a.price < b.price end)
    return drills
end

local function getHandDrillsSortedByPrice()
    local drills = {}
    for _, frame in pairs(plr.PlayerGui.Menu.CanvasGroup.HandDrills.Background
                              .HandDrillList:GetChildren()) do
        if frame:IsA("Frame") then
            local priceLabel = frame:FindFirstChild("Buy") and
                                   frame.Buy:FindFirstChild("TextLabel")
            local titleLabel = frame:FindFirstChild("Title")
            if priceLabel and titleLabel then
                local priceText = priceLabel.Text
                local cleanPriceText = priceText:gsub("[%$,]", "")
                local price = tonumber(cleanPriceText)
                if price then
                    table.insert(drills, {
                        name = titleLabel.Text,
                        price = price,
                        frame = frame
                    })
                end
            end
        end
    end
    table.sort(drills, function(a, b) return a.price < b.price end)
    return drills
end

local function getDrillPrice()
    if not selectedDrill then return end
    for _, v in pairs(
                    plr.PlayerGui.Menu.CanvasGroup.Buy.Background.DrillList:GetDescendants()) do
        if v:IsA("TextLabel") and v.Name == "Title" and v.Text == selectedDrill then
            return v.Parent:FindFirstChild("Buy").TextLabel.Text
        end
    end
end

local function getHandDrillPrice()
    if not selectedHandDrill then return end
    for _, v in pairs(plr.PlayerGui.Menu.CanvasGroup.HandDrills.Background
                          .HandDrillList:GetDescendants()) do
        if v:IsA("TextLabel") and v.Name == "Title" and v.Text ==
            selectedHandDrill then
            return v.Parent:FindFirstChild("Buy").TextLabel.Text
        end
    end
end

local function buyDrill()
    if selectedDrill then
        game:GetService("ReplicatedStorage").Packages.Knit.Services.OreService
            .RE.BuyDrill:FireServer(selectedDrill)
    end
end

local function buyHandDrill()
    if selectedHandDrill then
        game:GetService("ReplicatedStorage").Packages.Knit.Services.OreService
            .RE.BuyHandDrill:FireServer(selectedHandDrill)
    end
end

local sortedDrills = getDrillsSortedByPrice()
local drillNames = {}
for _, drill in ipairs(sortedDrills) do table.insert(drillNames, drill.name) end

local sortedHandDrills = getHandDrillsSortedByPrice()
local handDrillNames = {}
for _, drill in ipairs(sortedHandDrills) do
    table.insert(handDrillNames, drill.name)
end

local function rebirth()
    pcall(function()
        local reb = plr.PlayerGui.Menu.CanvasGroup.Rebirth.Background
        local progress = reb.Progress.Checkmark.Image ==
                             "rbxassetid://131015443699741"
        local ores = reb.RequiredOres:GetChildren()

        if #ores >= 2 then
            local ore1 = ores[1]:FindFirstChild("Checkmark")
            local ore2 = ores[2]:FindFirstChild("Checkmark")

            if progress and ore1 and ore1.Image ==
                "rbxassetid://131015443699741" and ore2 and ore2.Image ==
                "rbxassetid://131015443699741" then
                game:GetService("ReplicatedStorage").Packages.Knit.Services
                    .RebirthService.RE.RebirthRequest:FireServer()
            end
        end
    end)
end

local function startAutoRebirth()
    task.spawn(function()
        while getgenv().Settings.AutoRebirth do
            rebirth()
            task.wait(1)
        end
    end)
end

local Window = Fluent:CreateWindow({
    Title = "untitled drill game",
    SubTitle = "by Elton",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({Title = "Main", Icon = "home"}),
    Buy = Window:AddTab({Title = "Shop", Icon = "shopping-cart"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "settings"}),
    Info = Window:AddTab({Title = "Information", Icon = "info"})
}

local MainGroup = Tabs.Main:AddSection("Automation")

local AutoDrillToggle = Tabs.Main:AddToggle("AutoDrill", {
    Title = "Auto Drill",
    Description = "Automatically mine resources",
    Default = false
})

local AutoSellToggle = Tabs.Main:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Description = "Automatically sell resources",
    Default = false
})

local AutoCollectToggle = Tabs.Main:AddToggle("AutoCollectDrills", {
    Title = "Auto Collect Drills",
    Description = "Automatically collect drills",
    Default = false
})

local ativo = false

local Toggle = Tabs.Main:AddToggle("MyToggle", {
    Title = "give a lot of ores LAGGED",
    Description = "Need Drill in hand",
    Default = false,
    Callback = function(v)
        ativo = v
        if ativo then
            task.spawn(function()
                while ativo do
                    local localPlayer = game:GetService("Players").LocalPlayer
                    local character = localPlayer.Character
                    local tool = character and
                                     character:FindFirstChildWhichIsA("Tool")
                    local handdrill = tool and
                                          (tool:GetAttribute("Type") ==
                                              "HandDrill" or
                                              string.find(tool.Name,
                                                          "Hand Drill")) and
                                          tool
                    if handdrill then
                        for i = 1, 100000 do
                            game:GetService("ReplicatedStorage").Packages.Knit
                                .Services.OreService.RE.RequestRandomOre:FireServer()
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

local AutoRebirthToggle = Tabs.Main:AddToggle("AutoRebirth", {
    Title = "Auto Rebirth",
    Description = "Automatically rebirth when requirements are met",
    Default = false
})

AutoRebirthToggle:OnChanged(function(Value)
    getgenv().Settings.AutoRebirth = Value
    if Value then
        startAutoRebirth()
        Fluent:Notify({
            Title = "Auto Rebirth",
            Content = "Auto Rebirth enabled!",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Auto Rebirth",
            Content = "Auto Rebirth disabled!",
            Duration = 3
        })
    end
end)

Tabs.Main:AddButton({
    Title = "Sell Manually",
    Description = "Sell all resources now",
    Callback = function()
        sell()
        Fluent:Notify({
            Title = "Manual Sell",
            Content = "Resources sold!",
            Duration = 3
        })
    end
})

do

    Tabs.Buy:AddSection("Regular Drills")

    local DrillPriceLabel = Tabs.Buy:AddParagraph({
        Title = "Selected Drill Price",
        Content = "No drill selected"
    })

    local DrillDropdown = Tabs.Buy:AddDropdown("DrillDropdown", {
        Title = "Select Drill",
        Values = drillNames,
        Multi = false,
        Default = 1
    })

    DrillDropdown:OnChanged(function(Value)
        selectedDrill = Value
        local price = getDrillPrice() or "N/A"
        DrillPriceLabel:SetDesc("Price: " .. price)
    end)

    Tabs.Buy:AddButton({
        Title = "Buy Drill",
        Description = "Purchase the selected drill",
        Callback = function()
            buyDrill()
            Fluent:Notify({
                Title = "Purchase",
                Content = "Drill purchase request sent!",
                Duration = 3
            })
        end
    })

    local AutoBuyDrillToggle = Tabs.Buy:AddToggle("AutoBuyDrill", {
        Title = "Auto Buy Drill",
        Default = false
    })

    AutoBuyDrillToggle:OnChanged(function(Value)
        getgenv().Settings.AutoBuyDrill = Value
        if Value then
            task.spawn(function()
                while getgenv().Settings.AutoBuyDrill do
                    buyDrill()
                    task.wait(getgenv().Settings.BuyDelay)
                end
            end)
        end
    end)

    Tabs.Buy:AddSection("Hand Drills")

    local HandDrillPriceLabel = Tabs.Buy:AddParagraph({
        Title = "Selected Hand Drill Price",
        Content = "No hand drill selected"
    })

    local HandDrillDropdown = Tabs.Buy:AddDropdown("HandDrillDropdown", {
        Title = "Select Hand Drill",
        Values = handDrillNames,
        Multi = false,
        Default = 1
    })

    HandDrillDropdown:OnChanged(function(Value)
        selectedHandDrill = Value
        local price = getHandDrillPrice() or "N/A"
        HandDrillPriceLabel:SetDesc("Price: " .. price)
    end)

    Tabs.Buy:AddButton({
        Title = "Buy Hand Drill",
        Description = "Purchase the selected hand drill",
        Callback = function()
            buyHandDrill()
            Fluent:Notify({
                Title = "Purchase",
                Content = "Hand drill purchase request sent!",
                Duration = 3
            })
        end
    })

    local AutoBuyHandDrillToggle = Tabs.Buy:AddToggle("AutoBuyHandDrill", {
        Title = "Auto Buy Hand Drill",
        Default = false
    })

    AutoBuyHandDrillToggle:OnChanged(function(Value)
        getgenv().Settings.AutoBuyHandDrill = Value
        if Value then
            task.spawn(function()
                while getgenv().Settings.AutoBuyHandDrill do
                    buyHandDrill()
                    task.wait(getgenv().Settings.BuyDelay)
                end
            end)
        end
    end)

    Tabs.Buy:AddButton({
        Title = "Refresh Drill Lists",
        Description = "Update the drill lists with current prices",
        Callback = function()
            sortedDrills = getDrillsSortedByPrice()
            sortedHandDrills = getHandDrillsSortedByPrice()

            drillNames = {}
            for _, drill in ipairs(sortedDrills) do
                table.insert(drillNames, drill.name)
            end

            handDrillNames = {}
            for _, drill in ipairs(sortedHandDrills) do
                table.insert(handDrillNames, drill.name)
            end

            DrillDropdown:SetValues(drillNames)
            HandDrillDropdown:SetValues(handDrillNames)

            Fluent:Notify({
                Title = "Success",
                Content = "Drill lists refreshed!",
                Duration = 3
            })
        end
    })
end

local SettingsGroup = Tabs.Settings:AddSection("Sell Settings")

local SellIntervalSlider = Tabs.Settings:AddSlider("SellInterval", {
    Title = "Sell Interval (seconds)",
    Description = "Time between automatic sells",
    Default = 10,
    Min = 1,
    Max = 60,
    Rounding = 1,
    Callback = function(Value) getgenv().Settings.SellInterval = Value end
})

Tabs.Settings:AddSection("Buy Settings")

local BuyDelaySlider = Tabs.Settings:AddSlider("BuyDelay", {
    Title = "Buy Delay (seconds)",
    Description = "Delay between automatic purchases",
    Default = 1,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value) getgenv().Settings.BuyDelay = Value end
})

-- Information Tab
local InfoGroup = Tabs.Info:AddSection("Player Status")

local PlayerInfo = Tabs.Info:AddParagraph({
    Title = "Information",
    Content = "Player: " .. plr.Name .. "\nPlot found: " ..
        (plot and "Yes" or "No")
})

local function startAutoDrill()
    task.spawn(function()
        while getgenv().Settings.AutoDrill do
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Packages")
                    :WaitForChild("Knit"):WaitForChild("Services"):WaitForChild(
                        "OreService"):WaitForChild("RE"):WaitForChild(
                        "RequestRandomOre"):FireServer()
            end)
            task.wait(0.01)
        end
    end)
end

local function sell()
    pcall(function()
        local lastPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
        plr.Character:FindFirstChild("HumanoidRootPart").CFrame =
            sellPart.CFrame
        task.wait(0.2)

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))
        local OreService = Knit.GetService("OreService")
        OreService.SellAll:Fire()

        task.wait(0.2)
        if lastPos then
            plr.Character:FindFirstChild("HumanoidRootPart").CFrame = lastPos
        end
    end)
end

local function startAutoSell()
    task.spawn(function()
        while getgenv().Settings.AutoSell do
            sell()
            task.wait(getgenv().Settings.SellInterval)
        end
    end)
end

local function startAutoCollectDrills()
    task.spawn(function()
        while getgenv().Settings.AutoCollectDrills do
            if plot and plot:FindFirstChild("Drills") then
                for _, drill in pairs(plot.Drills:GetChildren()) do
                    if not getgenv().Settings.AutoCollectDrills then
                        break
                    end
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild(
                            "Packages"):WaitForChild("Knit"):WaitForChild(
                            "Services"):WaitForChild("PlotService")
                            :WaitForChild("RE"):WaitForChild("CollectDrill")
                            :FireServer(drill)
                    end)
                end
            end
            task.wait(1)
        end
    end)
end

AutoDrillToggle:OnChanged(function(Value)
    getgenv().Settings.AutoDrill = Value
    if Value then
        startAutoDrill()
        Fluent:Notify({
            Title = "Auto Drill",
            Content = "Auto Drill enabled!",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Auto Drill",
            Content = "Auto Drill disabled!",
            Duration = 3
        })
    end
end)

AutoSellToggle:OnChanged(function(Value)
    getgenv().Settings.AutoSell = Value
    if Value then
        startAutoSell()
        Fluent:Notify({
            Title = "Auto Sell",
            Content = "Auto Sell enabled!",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Auto Sell",
            Content = "Auto Sell disabled!",
            Duration = 3
        })
    end
end)

AutoCollectToggle:OnChanged(function(Value)
    getgenv().Settings.AutoCollectDrills = Value
    if Value then
        startAutoCollectDrills()
        Fluent:Notify({
            Title = "Auto Collect Drills",
            Content = "Auto Collect Drills enabled!",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Auto Collect Drills",
            Content = "Auto Collect Drills disabled!",
            Duration = 3
        })
    end
end)

SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("EltonsHub/MiningSimulator")
SaveManager:BuildConfigSection(Tabs.Settings)

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentScriptHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Fluent:Notify({
    Title = "Mining Simulator",
    Content = "Script loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
