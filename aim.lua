return (function()
  local Aim = {}

  local VirtualInputManager = game:GetService("VirtualInputManager")
  local UserGameSettings = UserSettings():GetService("UserGameSettings")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Camera = workspace.CurrentCamera

  for _, Connection in ipairs(getgenv().AIM_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().AIM_RBX_CONNECTIONS = {}

  local function FindValueInstance(vtype: string, name: string, value: any)
    local Value = script:FindFirstChild(name)

    if Value == nil then
      Value = Instance.new(vtype.."Value", script)
      Value.Name = name
      Value.Value = value
    end

    return Value
  end

  local UseVirtualMouseValue = FindValueInstance("Bool", "Aim_UseVirtualMouse", true)
  local Speed = 0.5
  local AimPart = "HumanoidRootPart"
  local TeamCheck = false
  local MaxDistance = 5000
  local MaxAngle = 180
  local DistanceWeight = 0.1
  local AngleWeight = 1
  local HealthWeight = 0

  local function GetAngleOffset(targetPos: Vector3): number
    local Dir = (targetPos - Camera.Focus.Position).Unit
    local Dot = Camera.CFrame.LookVector:Dot(Dir)
    return math.deg(math.acos(math.clamp(Dot, -1, 1)))
  end

  local function GetDistance(fromPos: Vector3, toPos: Vector3)
    return (fromPos - toPos).Magnitude
  end

  local function GetHealthOfPlayer(player): number
    local Humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    return Humanoid and Humanoid.Health or 100
  end

  local function IsSameTeam(player): boolean
    return player.Team == Client.Team
  end

  local function GetPartOfModel(model: Model): Instance
    return model:FindFirstChild(AimPart) or model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
  end

  local function AimToPositionCFrame(position: Vector3): ()
    local CameraCFrame = Camera.CFrame
    local DesiredCFrame = CFrame.lookAt(CameraCFrame.Position, position)
    Camera.CFrame = CameraCFrame:Lerp(DesiredCFrame, math.min(1, Speed))
  end

  local function AimToPositionVirtualMouse(targetPos: Vector3): ()
    local Look = Camera.CFrame.LookVector
    local Dir = (targetPos - Camera.Focus.Position).Unit

    local YawDiff = (math.atan2(Look.X, Look.Z) - math.atan2(Dir.X, Dir.Z) + math.pi) % (2 * math.pi) - math.pi
    local pitchDiff = math.asin(Look.Y) - math.asin(Dir.Y)
    local Sensitivity = math.rad(UserGameSettings.MouseSensitivity) / Speed

    local DeltaX = YawDiff / Sensitivity / 0.5
    local DeltaY = pitchDiff / Sensitivity / 0.385
    VirtualInputManager:SendMouseMoveDeltaEvent(DeltaX, DeltaY, game)
  end

  Aim.AimToPosition = UseVirtualMouseValue.Value and AimToPositionVirtualMouse or AimToPositionCFrame
  UseVirtualMouseValue.Changed:Connect(function(value)
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
    local CameraCFrame = Camera.CFrame
    local BestTarget = nil
    local SmallestScore = math.huge

    for _, Player in ipairs(PlayersList) do
      if Player == Client then continue end
      if TeamCheck and IsSameTeam(Player) then continue end

      local PlayerChar = Player.Character
      if not PlayerChar then continue end

      local Part = GetPartOfModel(PlayerChar)
      if not Part then continue end

      local TargetPos = Part.Position
      local Dist = GetDistance(CameraCFrame.Position, TargetPos)
      if Dist > MaxDistance then continue end

      local AngleOffset = GetAngleOffset(CameraCFrame, TargetPos)
      if AngleOffset > MaxAngle then continue end

      local Score = Dist * DistanceWeight + AngleOffset * AngleWeight
      if HealthWeight ~= 0 then
        Score += GetHealthOfPlayer(Player) * HealthWeight
      end

      if Score < SmallestScore then
        SmallestScore = Score
        BestTarget = Player
      end
    end
    return BestTarget
  end

  function Aim.SetUseVirtualMouse(value: boolean): ()
    UseVirtualMouseValue.Value = value or false
  end

  function Aim.SetSpeed(value: number): ()
    Speed = math.clamp(type(value) == "number" and value or Speed, 0.01, 1)
  end

  function Aim.SetAimPart(value: string): ()
    AimPart = type(value) == "string" and value or AimPart
  end

  function Aim.SetTeamCheck(value: boolean): ()
    TeamCheck = value or false
  end

  function Aim.SetMaxDistance(value: number): ()
    MaxDistance = type(value) == "number" and value or MaxDistance
  end

  function Aim.SetMaxAngle(value: number): ()
    MaxAngle = type(value) == "number" and value or MaxAngle
  end

  function Aim.SetDistanceWeight(value: number): ()
    DistanceWeight = type(value) == "number" and value or DistanceWeight
  end

  function Aim.SetAngleWeight(value: number): ()
    AngleWeight = type(value) == "number" and value or AngleWeight
  end

  function Aim.SetHealthWeight(value: number): ()
    HealthWeight = type(value) == "number" and value or HealthWeight
  end

  return Aim
end)()
-- Aim = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/aim.lua"))()

-- AimToInstance(Instance) / AimToPosition(Vector3)
-- AimToPlayer(Player) / ChoosePlayerToAim({Player}?)
-- SetUseVirtualMouse(bool)
-- SetSpeed(number) / SetAimPart(string) / SetTeamCheck(bool)
-- SetMaxDistance(number) / SetMaxAngle(number)
-- SetDistanceWeight(number) / SetAngleWeight(number) / SetHealthWeight(number)
