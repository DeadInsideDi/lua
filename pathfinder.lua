return (function()
  local PathFinder = {}

  local CoreGui = game:GetService("CoreGui")
  local PathfindingService = game:GetService("PathfindingService")
  local Camera = workspace.CurrentCamera

  local PathFinderFolder = CoreGui:FindFirstChild("PathFinder_Folder")
  if PathFinderFolder then PathFinderFolder:Destroy() end
  PathFinderFolder = Instance.new("Folder", CoreGui)
  PathFinderFolder.Name = "PathFinder_Folder"

  type Settings = {
    Color: Color3,
    ClosestColor: Color3,
    Length: number,
    MinDistance: number,
    UpdateTime: number,
    TransparencyFunction: (number) -> number
  }
  type ActiveTrack = {
    Settings: Settings,
    Lines: {LineHandleAdornment}
  }

  local PathToAgentParams = {}
  local ActiveTracks: {[Vector3]: ActiveTrack} = {}
  local ShortestTrackTargetPosition: Vector3

  local function GetShortestTrackTargetPosition(): Vector3
    local MinParts = math.huge
    local ShortestPosition = nil

    for Position, Track in ActiveTracks do
      local partCount = #Track.Lines
      if partCount < MinParts then
        MinParts = partCount
        ShortestPosition = Position
      end
    end

    return ShortestPosition
  end

  local function ComputePathWithFallback(path: Path, startPos: Vector3, baseTarget: Vector3): boolean
    local MaxAttempts, CurrentAttempt = 10, 0
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

  local function CreateTrack(path: Path, targetPosition: Vector3, config): ActiveTrack
    if config == nil then config = {} end
    local AgentParams = PathToAgentParams[path]

    local Settings = {
      Color = config and config.Color or Color3.fromRGB(255, 255, 255),
      ClosestColor = config and config.ClosestColor or Color3.fromRGB(0, 255, 0),
      Length = config and config.Length or AgentParams.WaypointSpacing,
      MinDistance = config and config.MinDistance or (AgentParams.AgentRadius + AgentParams.WaypointSpacing) * 4,
      UpdateTime = config and config.UpdateTime or 0.25,
      TransparencyFunction = config and config.TransparencyFunction or (function(x) return x/50 end)
    }

    local ActiveTrack = { Settings = Settings, Lines = {} }
    ActiveTracks[targetPosition] = ActiveTrack
    return ActiveTrack
  end

  local function RenderingPath(path: Path, targetPos: Vector3): boolean
    local ActiveTrack = ActiveTracks[targetPos]
    local Settings = ActiveTrack.Settings
    task.wait(Settings.UpdateTime)

    local CameraPos = Camera.Focus.Position

    if Settings.MinDistance > (CameraPos - targetPos).Magnitude then
      for _, Part in ActiveTrack.Lines do Part:Destroy() end
      ActiveTracks[targetPos] = nil
      return true
    end

    local HasPath = ComputePathWithFallback(path, CameraPos, targetPos)
    if not HasPath then return end

    local Waypoints = path:GetWaypoints()
    local LineColor = ShortestTrackTargetPosition == targetPos and Settings.ClosestColor or Settings.Color
    local NewLines = {}

    for Index, Waypoint in Waypoints do
      local PartDistance = (Waypoint.Position - CameraPos).Magnitude
      if PartDistance < Settings.MinDistance then return end

      local Line = Instance.new("LineHandleAdornment", PathFinderFolder)
      Line.Adornee = workspace
      Line.AlwaysOnTop = true
      Line.ZIndex = 1
      Line.Color3 = LineColor
      Line.Length = Settings.Length
      Line.Transparency = math.clamp(Settings.TransparencyFunction(PartDistance), 0, 1)

      local NextWaypoint = Waypoints[Index + 1]
      if NextWaypoint then
        Line.CFrame = CFrame.lookAt(Waypoint.Position, NextWaypoint.Position)
      end
      table.insert(NewLines, Line)
    end

    for _, Part in ActiveTrack.Lines do Part:Destroy() end
    ActiveTrack.Lines = NewLines
  end

  local function RenderingPathLoop(path: Path, targetPosition: Vector3): ()
    while ActiveTracks[targetPosition] ~= nil do
      local IsFinished = RenderingPath(path, targetPosition)
      if IsFinished then break end
    end
  end

  function PathFinder.CreatePath(agentParams): Path
    local FinalParams = {
      AgentRadius = 2,
      AgentHeight = 5,
      AgentCanJump = true,
      AgentCanClimb = false,
      WaypointSpacing = 1,
      Costs = {}
    }

    if agentParams then
      for k, v in agentParams do FinalParams[k] = v end
    end

    local Path = PathfindingService:CreatePath(FinalParams)
    PathToAgentParams[Path] = FinalParams
    return Path
  end

  function PathFinder.RenderPath(path: Path, targetPosition: Vector3, config): ()
    CreateTrack(path, targetPosition, config)
    RenderingPath(path, targetPosition)
    ActiveTracks[targetPosition] = nil
  end

  function PathFinder.RenderPathLoop(path: Path, targetPosition: Vector3, config): ()
    CreateTrack(path, targetPosition, config)
    task.spawn(function()
      RenderingPathLoop(path, targetPosition)
    end)
  end

  function PathFinder.Clear(): ()
    PathFinderFolder:ClearAllChildren()
    ActiveTracks = {}
  end

  task.spawn(function()
    while task.wait(0.1) do
      ShortestTrackTargetPosition = GetShortestTrackTargetPosition()
    end
  end)

  return PathFinder
end)()
-- PathFinder = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/pathfinder.lua"))()

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
