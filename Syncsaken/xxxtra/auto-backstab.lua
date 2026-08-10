if getgenv().thereisnowhatifiampregnant then
    getgenv().thereisnowhatifiampregnant:Disconnect()
    getgenv().thereisnowhatifiampregnant = nil
end

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WPlayers = workspace:WaitForChild("Players")
local Killers = WPlayers:WaitForChild("Killers")
local Survivors = WPlayers:WaitForChild("Survivors")

local LocalPlayer: Player = Players.LocalPlayer
local LocalCharacter: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(char: Model)
    LocalCharacter = char
end)

local TRASHY: RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local args = {
	"UseActorAbility",
	{
		buffer.fromstring("\"Dagger\"")
	}
}


local function isTwoTime(): boolean
    return LocalCharacter and string.find(LocalCharacter.Name, "TwoTime") or false
end

local function getDistanceFrom(part: BasePart): number
    return vector.magnitude(LocalCharacter.HumanoidRootPart.Position - part.Position)
end

local function canBackstab(part: BasePart): boolean
    local partLook = part.CFrame.LookVector
    local selfLook = LocalCharacter.HumanoidRootPart.CFrame.LookVector
    local directionToSelf = vector.normalize(part.Position - LocalCharacter.HumanoidRootPart.Position)

    local facingAligned = selfLook:Dot(partLook)
    local isBehind = selfLook:Dot(directionToSelf)

    if facingAligned < 0.5 then -- tolerance magic num
        return false
    end
    if isBehind < 0.5 then
        return false
    end

    return true
end

getgenv().thereisnowhatifiampregnant = RunService.Heartbeat:Connect(function()
    if not isTwoTime() then return end
    if not Killers:GetChildren()[1] then return end

    local Killer = Killers:GetChildren()[1]
    local TRASHYPRIMARY = Killer and Killer:FindFirstChild("HumanoidRootPart")
    if not TRASHYPRIMARY or TRASHYPRIMARY.Anchored then return end

    if getDistanceFrom(TRASHYPRIMARY) > 4.5 then return end
    if not canBackstab(TRASHYPRIMARY) then return end

    TRASHY:FireServer(unpack(args))
end)
