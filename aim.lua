return (function()
  local Aim = {}

  local ROTATION_SPEED_MOUSE = Vector2.new(1, 0.77)*math.rad(0.5)
  local VirtualInputManager = game:GetService("VirtualInputManager")
  local UserGameSettings = UserSettings():GetService("UserGameSettings")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Camera = workspace.CurrentCamera

  for _, Connection in getgenv().AIM_RBX_CONNECTIONS or {} do
    Connection:Disconnect()
  end
  getgenv().AIM_RBX_CONNECTIONS = {}

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  Aim.UseVirtualMouse = CreateValue(true)
  Aim.Speed = CreateValue(0.5)
  Aim.AimPart = CreateValue("HumanoidRootPart")
  Aim.TeamCheck = CreateValue(false)
  Aim.MaxDistance = CreateValue(5000)
  Aim.MaxAngle = CreateValue(180)
  Aim.DistanceWeight = CreateValue(0.1)
  Aim.AngleWeight = CreateValue(1)
  Aim.HealthWeight = CreateValue(0)

  local function GetAngleOffset(targetPos: Vector3): number
    local Dir = (targetPos - Camera.Focus.Position).Unit
    local Dot = Camera.CFrame.LookVector:Dot(Dir)
    return math.deg(math.acos(math.clamp(Dot, -1, 1)))
  end

  local function GetHealthOfPlayer(player): number
    local Humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    return Humanoid and Humanoid.Health or 100
  end

  local function IsSameTeam(player): boolean
    return player.Team == Client.Team
  end

  local function GetPartOfModel(model: Model): Instance
    return model:FindFirstChild(Aim.AimPart.Value) or model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
  end

  local function CountScore(dist: number, angle: number, health: number): number
    return dist * Aim.DistanceWeight.Value + angle * Aim.AngleWeight.Value + health * Aim.HealthWeight.Value
  end

  local function AimToPositionCFrame(position: Vector3): ()
    local CameraCFrame = Camera.CFrame
    local DesiredCFrame = CFrame.lookAt(CameraCFrame.Position, position)
    Camera.CFrame = CameraCFrame:Lerp(DesiredCFrame, math.min(1, Aim.Speed.Value))
  end
  local function AimToPositionVirtualMouse(targetPos: Vector3): ()
    local Look = Camera.CFrame.LookVector
    local Dir = (targetPos - Camera.Focus.Position).Unit

    local YawDiff = (math.atan2(Look.X, Look.Z) - math.atan2(Dir.X, Dir.Z) + math.pi) % (2 * math.pi) - math.pi
    local pitchDiff = math.asin(Look.Y) - math.asin(Dir.Y)
    local Sensitivity = UserGameSettings.MouseSensitivity / Aim.Speed.Value

    local DeltaX = YawDiff / (Sensitivity * ROTATION_SPEED_MOUSE.X)
    local DeltaY = pitchDiff / (Sensitivity * ROTATION_SPEED_MOUSE.Y)
    VirtualInputManager:SendMouseMoveDeltaEvent(DeltaX, DeltaY, game)
  end

  Aim.AimToPosition = Aim.UseVirtualMouse.Value and AimToPositionVirtualMouse or AimToPositionCFrame
  Aim.UseVirtualMouse:Changed(function(value)
    Aim.AimToPosition = value and AimToPositionVirtualMouse or AimToPositionCFrame
  end)

  function Aim.AimToInstance(target: Model | Part): ()
    local Position
    if target:IsA("Model") then
      Position = GetPartOfModel(target).Position
    elseif target:IsA("BasePart") then
      Position = target.Position
    end

    if Position then Aim.AimToPosition(Position) end
  end

  function Aim.AimToPlayer(player: Player): ()
    if player and player.Character then
      local Part = GetPartOfModel(player.Character)
      if Part then Aim.AimToPosition(Part.Position) end
    end
  end

  function Aim.ChoosePlayerToAim(playerList: {Player}?): Player | nil
    local PlayersList = playerList or Players:GetPlayers()
    local BestTarget = nil
    local SmallestScore = math.huge

    for _, Player in PlayersList do
      if Player == Client then continue end
      if Aim.TeamCheck.Value and IsSameTeam(Player) then continue end

      local PlayerChar = Player.Character
      if not PlayerChar then continue end

      local Part = GetPartOfModel(PlayerChar)
      if not Part then continue end

      local TargetPos = Part.Position
      local Dist = (Camera.Focus.Position - TargetPos).Magnitude
      if Dist > Aim.MaxDistance.Value then continue end

      local AngleOffset = GetAngleOffset(TargetPos)
      if AngleOffset > Aim.MaxAngle.Value then continue end

      local Score = CountScore(Dist, AngleOffset, GetHealthOfPlayer(Player))
      if Score < SmallestScore then
        SmallestScore = Score
        BestTarget = Player
      end
    end
    return BestTarget
  end

  function Aim.ChooseModelToAim(modelList: {Instance}): Instance | nil
    local BestTarget = nil
    local SmallestScore = math.huge

    for _, model in modelList do
      if not (model:IsA("Model") or model:IsA("BasePart")) then continue end

      local Part
      if model:IsA("Model") then
        Part = GetPartOfModel(model)
      else
        Part = model
      end
      if not Part then continue end

      local TargetPos = Part.Position
      local Dist = (Camera.Focus.Position - TargetPos).Magnitude
      if Dist > Aim.MaxDistance.Value then continue end

      local AngleOffset = GetAngleOffset(TargetPos)
      if AngleOffset > Aim.MaxAngle.Value then continue end

      local Score = CountScore(Dist, AngleOffset, 0)
      if Score < SmallestScore then
        SmallestScore = Score
        BestTarget = model
      end
    end
    return BestTarget
  end

  return Aim
end)()
-- Aim = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/aim.lua"))()

-- AimToInstance(Instance) / AimToPosition(Vector3)
-- AimToPlayer(Player) / ChoosePlayerToAim({Player}?) / ChooseModelToAim({Model})

-- UseVirtualMouse: bool / Speed: number / AimPart: string / TeamCheck: bool
-- MaxDistance: number / MaxAngle: number
-- DistanceWeight: number / AngleWeight: number / HealthWeight: number
