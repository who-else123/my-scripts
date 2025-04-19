-- made by who_else123
local AnimationLoad = Instance.new("ScreenGui")
local UI = Instance.new("Frame")
local Input = Instance.new("TextBox")
local Load = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local Close = Instance.new("TextButton")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local UIDragDetector = Instance.new("UIDragDetector")
local UICorner_2 = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
AnimationLoad.Name = "AnimationLoad"
AnimationLoad.Parent = game.CoreGui
AnimationLoad.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.Name = "UI"
UI.Parent = AnimationLoad
UI.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
UI.BackgroundTransparency = 0.100
UI.BorderColor3 = Color3.fromRGB(0, 0, 0)
UI.BorderSizePixel = 0
UI.Position = UDim2.new(0.225814402, 0, 0.150000006, 0)
UI.Size = UDim2.new(0.325657904, 0, 0.295549363, 0)
UIDragDetector.Parent = UI
Input.Name = "Input"
Input.Parent = UI
Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Input.BackgroundTransparency = 0.800
Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
Input.BorderSizePixel = 0
Input.Position = UDim2.new(0.0336700343, 0, 0.0588235296, 0)
Input.Size = UDim2.new(0.932659924, 0, 0.423529416, 0)
Input.Font = Enum.Font.SourceSans
Input.PlaceholderText = "Enter rbxassetid..."
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(0, 0, 0)
Input.TextScaled = true
Input.TextSize = 14.000
Input.TextWrapped = true
Load.Name = "Load"
Load.Parent = UI
Load.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Load.BorderColor3 = Color3.fromRGB(0, 0, 0)
Load.BorderSizePixel = 0
Load.Position = UDim2.new(0.0942760929, 0, 0.576470613, 0)
Load.Size = UDim2.new(0.811447799, 0, 0.294117659, 0)
Load.Font = Enum.Font.SourceSans
Load.Text = "Load!"
Load.TextColor3 = Color3.fromRGB(0, 0, 0)
Load.TextScaled = true
Load.TextSize = 14.000
Load.TextWrapped = true
UICorner.Parent = UI
Close.Name = "Close"
Close.Parent = UI
Close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.468013465, 0, -0.176470593, 0)
Close.Size = UDim2.new(0, 50, 0, 18)
Close.Font = Enum.Font.SourceSans
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(0, 0, 0)
Close.TextScaled = true
Close.TextSize = 14.000
Close.TextWrapped = true
TextLabel.Parent = UI
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.0299999993, 0, 0.920000017, 0)
TextLabel.Size = UDim2.new(0, 200, 0, 11)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "made by who_else123"
TextLabel.TextColor3 = Color3.fromRGB(85, 85, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextTransparency = 0.400
TextLabel.TextWrapped = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
UIAspectRatioConstraint.Parent = Close
UICorner_2.CornerRadius = UDim.new(1, 0)
UICorner_2.Parent = Close
local Player = game.Players.LocalPlayer
local AnimInstance = Instance.new("Animation")
local CurrentText

local function LoadAndPlayAnimation()
	if not CurrentText then
		return -- no input
	end

	local Character = Player.Character 
	if not Character then 
		return -- no character
	end

	AnimInstance.AnimationId = CurrentText
	local loaded = Character:FindFirstChild("Humanoid"):FindFirstChild("Animator"):LoadAnimation(AnimInstance)

	for i = 1, 5 do
		if loaded.Length > 0 then break end -- animation loaded
		if i == 5 then
			return -- animation is invalid
		end
		task.wait(0.5)
	end

	loaded:Play()
end

Input.Changed:Connect(function(property)
	if property == "Text" then
		local text = Input.Text
		
		if text ~= "" then
			if tonumber(text) then
				CurrentText = "rbxassetid://" .. text
			else
				CurrentText = text
			end
		end
	end
end)

Load.MouseButton1Click:Connect(function()
	LoadAndPlayAnimation()
end)

Close.MouseButton1Click:Connect(function()
	AnimationLoad:Destroy()
end)

