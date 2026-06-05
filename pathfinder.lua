return (function()
  local PathFinder = {}

  local PathfindingService = game:GetService("PathfindingService")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Character = Client.Character or Client.CharacterAdded:Wait()
  local Root = Character:WaitForChild("HumanoidRootPart")

  local RouteFolder = workspace:FindFirstChild("ActiveRoutes")
  if RouteFolder ~= nil then RouteFolder:Destroy() end

  RouteFolder = Instance.new("Folder", workspace)
  RouteFolder.Name = "ActiveRoutes"

  type Settings = {
    Material: Enum.Material,
    Color: Color3,
    ClosestColor: Color3,
    Width: number,
    Height: number,
    Length: number,
    MinDistance: number,
    UpdateTime: number,
    TransparencyFunction: (number) -> number
  }
  type ActiveTrack = {
    Settings: Settings,
    Parts: {Part}
  }

  local PathToAgentParams = {}
  local ActiveTracks: {[Vector3]: ActiveTrack} = {}
  local ShortestTrackTargetPosition: Vector3

  local function GetShortestTrackTargetPosition()
    local MinParts = math.huge
    local ShortestPosition = nil

    for Position, Track in pairs(ActiveTracks) do
      local partCount = #Track.Parts
      if partCount < MinParts then
        MinParts = partCount
        ShortestPosition = Position
      end
    end

    return ShortestPosition
  end

  local function ComputePathWithFallback(path: Path, startPos: Vector3, baseTarget: Vector3)
    local MaxAttempts, CurrentAttempt = 25, 0
    local StepSize, HeightStep = 4, 3

    local x, z, dx, dz = 0, 0, 0, -1
    while CurrentAttempt < MaxAttempts do
      local Offset = Vector3.new(x * StepSize, (CurrentAttempt % 3 - 1) * HeightStep, z * StepSize)
      local TestTarget = baseTarget + Offset

      local ok, _ = pcall(path.ComputeAsync, path, startPos, TestTarget)
      if ok and path.Status == Enum.PathStatus.Success then return true end

      if x == z or (x < 0 and x == -z) or (x > 0 and x == 1 - z) then dx, dz = -dz, dx end
      x, z = x + dx, z + dz
      CurrentAttempt = CurrentAttempt + 1
    end

    return false
  end

  local function CreateTrack(path: Path, targetPosition: Vector3, config)
    if config == nil then config = {} end
    local AgentParams = PathToAgentParams[path]

    local Settings = {
      Material = config and config.Material or Enum.Material.Neon,
      Color = config and config.Color or Color3.fromRGB(255, 255, 255),
      ClosestColor = config and config.ClosestColor or Color3.fromRGB(0, 255, 0),
      Width = config and config.Width or AgentParams.WaypointSpacing / 4,
      Height = config and config.Height or AgentParams.WaypointSpacing / 10,
      Length = config and config.Length or AgentParams.WaypointSpacing,
      MinDistance = config and config.MinDistance or (AgentParams.AgentRadius + AgentParams.WaypointSpacing) * 4,
      UpdateTime = config and config.UpdateTime or 0.25,
      TransparencyFunction = config and config.TransparencyFunction or (function(x) return x/50 end)
    }

    local ActiveTrack = { Settings = Settings, Parts = {} }
    ActiveTracks[targetPosition] = ActiveTrack
    return ActiveTrack
  end

  local function RenderingPath(path: Path, targetPos: Vector3)
    local ActiveTrack = ActiveTracks[targetPos]
    local Settings = ActiveTrack.Settings
    task.wait(Settings.UpdateTime)

    if not Root or not Root.Parent then return true end
    local PlayerPos = Root.Position

    if Settings.MinDistance > (PlayerPos - targetPos).Magnitude then
      for _, Part in ipairs(ActiveTrack.Parts) do Part:Destroy() end
      ActiveTracks[targetPos] = nil
      return true
    end

    local HasPath = ComputePathWithFallback(path, PlayerPos, targetPos)
    if not HasPath then return end

    local Waypoints = path:GetWaypoints()
    local PartSize = Vector3.new(Settings.Width, Settings.Height, Settings.Length)
    local PartColor = ShortestTrackTargetPosition == targetPos and Settings.ClosestColor or Settings.Color
    local NewParts = {}

    for Index, Waypoint in ipairs(Waypoints) do
      local PartDistance = (Waypoint.Position - PlayerPos).Magnitude
      if PartDistance < Settings.MinDistance then return end

      local Part = Instance.new("Part", RouteFolder)
      Part.Size = PartSize
      Part.Anchored = true
      Part.CanCollide = false
      Part.CanTouch = false
      Part.CanQuery = false
      Part.Material = Settings.Material
      Part.Color = PartColor
      Part.Transparency = math.clamp(Settings.TransparencyFunction(PartDistance), 0, 1)

      local NextWaypoint = Waypoints[Index + 1]
      if NextWaypoint then
        Part.CFrame = CFrame.lookAt(Waypoint.Position + Vector3.new(0, Settings.Height, 0), NextWaypoint.Position + Vector3.new(0, Settings.Height, 0))
      end
      table.insert(NewParts, Part)
    end

    for _, Part in ipairs(ActiveTrack.Parts) do Part:Destroy() end
    ActiveTrack.Parts = NewParts
  end

  local function RenderingPathLoop(path: Path, targetPosition: Vector3)
    while ActiveTracks[targetPosition] ~= nil do
      local IsFinished = RenderingPath(path, targetPosition)
      if IsFinished then break end
    end
  end

  function PathFinder.CreatePath(agentParams)
    local FinalParams = {
      AgentRadius = 2,
      AgentHeight = 5,
      AgentCanJump = true,
      AgentCanClimb = false,
      WaypointSpacing = 1,
      Costs = {}
    }

    if agentParams then
      for k, v in pairs(agentParams) do FinalParams[k] = v end
    end

    local Path = PathfindingService:CreatePath(FinalParams)
    PathToAgentParams[Path] = FinalParams
    return Path
  end

  function PathFinder.RenderPath(path: Path, targetPosition: Vector3, config)
    CreateTrack(path, targetPosition, config)
    RenderingPath(path, targetPosition)
    ActiveTracks[targetPosition] = nil
  end

  function PathFinder.RenderPathLoop(path: Path, targetPosition: Vector3, config)
    CreateTrack(path, targetPosition, config)
    task.spawn(function()
      RenderingPathLoop(path, targetPosition)
    end)
  end

  function PathFinder.Clear()
    RouteFolder:ClearAllChildren()
    ActiveTracks = {}
  end

  task.spawn(function()
    while task.wait(0.1) do
      ShortestTrackTargetPosition = GetShortestTrackTargetPosition()
    end
  end)

  return PathFinder
end)()
-- CreatePath({
--   AgentRadius = 2, AgentHeight = 5, AgentCanJump = true,
--   AgentCanClimb = false, WaypointSpacing = 1, Costs = {}
-- })
-- (RenderPath | RenderPathLoop)(path, Vector3, {
--   Material: Enum.Material, Color: Color3, ClosestColor: Color3,
--   Width: number, Height: number, Length: number, MinDistance: number,
--   UpdateTime: number, TransparencyFunction: (number) -> number
-- }
-- Clear