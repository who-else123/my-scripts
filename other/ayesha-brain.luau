seed = (os.time() * Random.new():NextNumber(0, 0.00000001)) / Random.new():NextNumber(0,math.pi) seed /= (1 + math.abs(seed)) seed *= Random.new():NextNumber(0, 500)

--[[

┏┓╋┏━━━┓╋╋╋╋╋╋╋╋┏┓┏┓╋╋╋╋╋╋┏━━━┳┓╋┏┓┏━━━┓
┃┃╋┃┏━┓┃╋╋╋╋╋╋╋┏┛┗┫┃╋╋╋╋╋╋┃┏━┓┃┃╋┃┃┃┏━┓┃
┃┗━┫┃┃┃┣━┓┏━━┳━┻┓┏┫┃┏┓╋┏┳━┫┃┃┃┃┗━┫┃┃┃┃┃┣┓┏┓
┃┏┓┃┃┃┃┃┏┓┫┃━┫━━┫┃┃┃┃┃╋┃┃┏┫┃┃┃┃┏┓┃┃┃┃┃┃┣╋╋┛
┃┃┃┃┗━┛┃┃┃┃┃━╋━━┃┗┫┗┫┗━┛┃┃┃┗━┛┃┗┛┃┗┫┗━┛┣╋╋┓
┗┛┗┻━━━┻┛┗┻━━┻━━┻━┻━┻━┓┏┻┛┗━━━┻━━┻━┻━━━┻┛┗┛
╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋┏━┛┃
╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋┗━━┛


this script is designed to be modular, so i expect u to have a good knowledge of luau
if something breaks.

written by h0nestlyr0bl0x

]]

local magnitude, unit = vector.magnitude, vector.normalize

local CONFIG = {
	Max_Distance = 400,
	Attention_Span = 6,
	Minimum_Movement = 0.25,
	
	CanChangeAISpeed = true,
	
	SPEEDS = {
		Idle = script.SpeedIdle.Value,
		Chase = script.SpeedChase.Value
	},

	STATE = {
		Chase = false,
		Lost_Sight = false,
		Last_Sight_Tick = 0,
		Last_Waypoints = {nil, nil}
	}
}

local SERVICES = {
	Players = game:GetService("Players"),
	RepStorage = game:GetService("ReplicatedStorage"),
	Debris = game:GetService("Debris"),
}

local AI_COMPONENTS = {
	AI = script.Parent,
	Primary = script.Parent.PrimaryPart,
	Humanoid = script.Parent.Humanoid,
	Active_Flag = script.Active
}

local NAVIGATION = {
	Pathfinder = require(script:WaitForChild("SPath")),
	Waypoint_Folder = workspace:FindFirstChild("WaypointFolder", true),
	Safezones = workspace:FindFirstChild("Safezones", true),

	PATH_PARAMS = {
		AgentRadius = 10,
		AgentHeight = 12,
		AgentCanJump = false,
		AgentCanClimb = false
	},
	
}

local EVENTS = {
	Chasing = SERVICES.RepStorage.Events:WaitForChild("Chasing"),
	Jumpscare = SERVICES.RepStorage.Events:WaitForChild("Jumpscare")
}

local STUCK_DETECTION = {
	Last_Position = vector.zero,
	Timer = 0,
	Threshold = 2,
	Thread = nil
}

local Path = NAVIGATION.Pathfinder.new(AI_COMPONENTS.AI, NAVIGATION.PATH_PARAMS)
Path.Visualize = false

if not AI_COMPONENTS.Primary then
	error("Could not find AI's primary part!")
else
	AI_COMPONENTS.Primary:SetNetworkOwner(nil)
end

if not NAVIGATION.Waypoint_Folder then
	error("No Waypoint folder found! Please create a folder with necessary looping points.")
end

if not NAVIGATION.Safezones then
	error("No Safezone folder found! Please create a folder with necessary safe zones.")
end

-- START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN!
-- START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN!
-- START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN! START OF MAIN!


local function ChangeAISpeed(arg)
	if not CONFIG.CanChangeAISpeed then return("Can't change speed, boolean set to false!") end
	if arg == "chase icon" then
		AI_COMPONENTS.Humanoid.WalkSpeed = CONFIG.SPEEDS.Chase
	else
		AI_COMPONENTS.Humanoid.WalkSpeed = CONFIG.SPEEDS.Idle
	end
end

local function updateChasingState(client, isChasing)
	EVENTS.Chasing:FireClient(client, isChasing)
	print("Updated chasing state to "..tostring(isChasing))
end

local function randomPart()
	local waypoints = NAVIGATION.Waypoint_Folder:GetChildren()
	local LastWPT = CONFIG.STATE.Last_Waypoints
	local random = waypoints[math.random(#waypoints)]
	
	task.wait()
	
	if random:IsA("BasePart") then 
		if random ~= LastWPT[1] and random ~= LastWPT[2] then
			LastWPT[2] = LastWPT[1]
			LastWPT[1] = random
			
			return random
		else
			return randomPart()
		end
	end 
end

local function findPlayerInDistance()
	local nearestCharacter = NAVIGATION.Pathfinder.GetNearestCharacter(AI_COMPONENTS.Primary.Position)
	if not nearestCharacter then return nil end

	local humanoidRootPart = nearestCharacter:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		local distance = magnitude(AI_COMPONENTS.Primary.Position - humanoidRootPart.Position)
		if distance < CONFIG.Max_Distance and nearestCharacter.Humanoid.Health > 0 then
			return nearestCharacter
		end
	end

	return
end

local function handleStuckAI()
	if magnitude(AI_COMPONENTS.Primary.Position - STUCK_DETECTION.Last_Position) < CONFIG.Minimum_Movement then
		STUCK_DETECTION.Timer += task.wait()

		if STUCK_DETECTION.Timer >= STUCK_DETECTION.Threshold then
			warn("AI is stuck - teleporting to new waypoint")

			local newWaypoint = randomPart()
			AI_COMPONENTS.Primary.CFrame = CFrame.new(newWaypoint.Position + vector.create(0, 1, 0))

			STUCK_DETECTION.Timer = 0
			STUCK_DETECTION.Last_Position = AI_COMPONENTS.Primary.Position
			return true
		end
	else
		-- AI is moving normally, reset stuck detection
		STUCK_DETECTION.Timer = 0
		STUCK_DETECTION.Last_Position = AI_COMPONENTS.Primary.Position
		return false
	end
end

local function runPath(goal)
	Path:Run(goal)
	print("running path")
	STUCK_DETECTION.Last_Position = AI_COMPONENTS.Primary.Position
	
	if not STUCK_DETECTION.Thread then
		STUCK_DETECTION.Thread = task.spawn(function()
			while task.wait() do
				handleStuckAI()
			end
		end)
	end
end

local function isInSafeZone(part)
	if NAVIGATION.Safezones then
		for _, safeZone in pairs(NAVIGATION.Safezones:GetChildren()) do
			if safeZone:IsA("BasePart") then
				if table.find(workspace:GetPartsInPart(safeZone), part) then
					return true
				end
			end
		end
	end
	return false
end

local function canSeeTarget(target)
	local directionToTarget = unit(target.HumanoidRootPart.Position - AI_COMPONENTS.Primary.Position)
	local aiForward = AI_COMPONENTS.Primary.CFrame.LookVector -- AI's forward-facing direction

	local dotProduct = directionToTarget:Dot(aiForward)

	if dotProduct >= 0.2 then
		return true
	end
end

local function Obstructed(target)
	local origin = AI_COMPONENTS.Primary.Position
	local direction = unit(target.HumanoidRootPart.Position - origin) * CONFIG.Max_Distance

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {AI_COMPONENTS.AI}
	
	local hit = workspace:Raycast(origin, direction, params).Instance

	if hit and hit:IsDescendantOf(target) then
		return false 
	end
	return true
end

function CreateWP(pos: Vector3, permanent: boolean)
	for _, WP in NAVIGATION.Waypoint_Folder:GetChildren() do
		if magnitude(WP.Position - pos) <= 30 then
			return
		end
	end

	local part = Instance.new("Part")
	part.Name = "dynamic_Part"
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Material = Enum.Material.Neon
	part.Transparency = 1
	part.Position = pos
	part.Parent = NAVIGATION.Waypoint_Folder

	if not permanent then
		SERVICES.Debris:AddItem(part, 60)
	end
end

local function attack(target)
	local distance = magnitude(AI_COMPONENTS.Primary.Position - target.HumanoidRootPart.Position)
	local plrz = SERVICES.Players:GetPlayerFromCharacter(target)
	
	if distance <= 10 then
		EVENTS.Jumpscare:FireClient(plrz)
		target.Humanoid.Health = 0
		CONFIG.STATE.Chase = false
		
		updateChasingState(plrz,false)
		
	elseif distance < CONFIG.Max_Distance then
		runPath(target.HumanoidRootPart.Position)
		
	else
		CONFIG.STATE.Chase = false
		updateChasingState(plrz,false)
	end
	return
end

local function Patrol()
	if not CONFIG.STATE.Chase then
		local goal = randomPart()
		runPath(goal.Position)

		while Path._status ~= Path.StatusType.Idle do
			task.wait()

			if CONFIG.STATE.Chase then
				break
			end

			local target = findPlayerInDistance()
			if target and canSeeTarget(target) and not Obstructed(target) then
				CONFIG.STATE.Chase = true
				CONFIG.STATE.Last_Sight_Tick = tick()
				updateChasingState(SERVICES.Players:GetPlayerFromCharacter(target), true)
				CreateWP(target.HumanoidRootPart.Position, false)
				break
			end

		end
	end
end

local function Chase()
	local target = findPlayerInDistance()
	if target and target.Humanoid.Health > 0 then
-------------------------------------------------------------------------------------
		if isInSafeZone(target.HumanoidRootPart) then
			CONFIG.STATE.Chase = false
			EVENTS.Chasing:FireAllClients(false)
			updateChasingState(SERVICES.Players:GetPlayerFromCharacter(target),false)
			return
		end
------------------------------------------------------------------------------------
		if canSeeTarget(target) and not Obstructed(target) then
			if CONFIG.STATE.Lost_Sight then
				CONFIG.STATE.Last_Sight_Tick = tick()
				CONFIG.STATE.Lost_Sight = false
			end
		else
			CONFIG.STATE.Lost_Sight = true
		end
------------------------------------------------------------------------------------
		if (tick() - CONFIG.STATE.Last_Sight_Tick) >= CONFIG.Attention_Span and CONFIG.STATE.Lost_Sight then
			warn("Exceeded attention span while chasing")
			CONFIG.STATE.Chase = false
			EVENTS.Chasing:FireAllClients(false)
		
			return
		end

		attack(target)
	else
		CONFIG.STATE.Chase = false
		EVENTS.Chasing:FireAllClients(false)
		return
	end
	task.wait()
end


while task.wait() do
	if AI_COMPONENTS.Active_Flag.Value then
		if CONFIG.STATE.Chase then
			ChangeAISpeed("chase icon")
			Chase()
		else
			ChangeAISpeed("not chase icon aka idle")
			Patrol()
		end
	else
		repeat task.wait(1) until AI_COMPONENTS.Active_Flag.Value
	end
end
