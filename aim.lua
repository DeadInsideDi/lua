return (function()
  local Aim = {}

  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Camera = workspace.CurrentCamera
  local Character = Client.Character or Client.CharacterAdded:Wait()

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

  local SmoothnessValue = FindValueInstance("Number", "Aim_Smoothness", 0.1)
  local AimPartValue = FindValueInstance("String", "Aim_AimPart", "HumanoidRootPart")
  local TeamCheckValue = FindValueInstance("Bool", "Aim_TeamCheck", false)
  local MaxDistanceValue = FindValueInstance("Number", "Aim_MaxDistance", 5000)
  local MaxAngleValue = FindValueInstance("Number", "Aim_MaxAngle", 180)
  local DistanceWeightValue = FindValueInstance("Number", "Aim_DistanceWeight", 1.25)
  local AngleWeightValue = FindValueInstance("Number", "Aim_AngleWeightValue", 1)
  local HealthWeightValue = FindValueInstance("Number", "Aim_HealthWeight", 0)

  local function GetAngleOffset(cameraCFrame: CFrame, targetPos: Vector3): number
    local Dir = (targetPos - cameraCFrame.Position).Unit
    local Dot = cameraCFrame.LookVector:Dot(Dir)
    return math.deg(math.acos(math.clamp(Dot, -1, 1)))
  end

  local function GetDistance(fromPos: Vector3, toPos: Vector3)
    return (fromPos - toPos).Magnitude
  end

  local function GetHealthOfPlayer(player): number
    local Humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    return Humanoid and Humanoid.Health or 100
  end

  local function IsSameTeam(player)
    return player.Team == Client.Team
  end

  local function GetPartOfModel(model: Model): Instance
    return model:FindFirstChild(AimPartValue.Value) or model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
  end

  function Aim.AimToPosition(position: Vector3): ()
    local CameraCFrame = Camera.CFrame
    print('3')
    local DesiredCFrame = CFrame.lookAt(CameraCFrame.Position, position)
    -- local Alpha = math.min(1, SmoothnessValue.Value)
    -- Camera.CFrame = CameraCFrame:Lerp(DesiredCFrame, Alpha)
  end

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
    print('1')
    if player and player.Character then
      local Part = GetPartOfModel(player.Character)
      print('2')
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
      if TeamCheckValue.Value and IsSameTeam(Player) then continue end

      local PlayerChar = Player.Character
      if not PlayerChar then continue end

      local Part = GetPartOfModel(PlayerChar)
      if not Part then continue end

      local TargetPos = Part.Position
      local Dist = GetDistance(CameraCFrame.Position, TargetPos)
      if Dist > MaxDistanceValue.Value then continue end

      local AngleOffset = GetAngleOffset(CameraCFrame, TargetPos)
      if AngleOffset > MaxAngleValue.Value then continue end

      local Score = Dist * DistanceWeightValue.Value + AngleOffset * AngleWeightValue.Value
      if HealthWeightValue.Value ~= 0 then
        Score += GetHealthOfPlayer(Player) * HealthWeightValue.Value
      end

      if Score < SmallestScore then
        SmallestScore = Score
        BestTarget = Player
      end
    end
    return BestTarget
  end

  function Aim.SetSmoothness(value: number): ()
    SmoothnessValue.Value = value == nil and SmoothnessValue.Value or value
  end

  function Aim.SetAimPart(value: string): ()
    AimPartValue.Value = value == nil and AimPartValue.Value or value
  end

  function Aim.SetTeamCheck(value: boolean): ()
    TeamCheckValue.Value = value == nil and TeamCheckValue.Value or value
  end

  function Aim.SetMaxDistance(value: number): ()
    MaxDistanceValue.Value = value == nil and MaxDistanceValue.Value or value
  end

  function Aim.SetMaxAngle(value: number): ()
    MaxAngleValue.Value = value == nil and MaxAngleValue.Value or value
  end

  function Aim.SetDistanceWeight(value: number): ()
    DistanceWeightValue.Value = value == nil and DistanceWeightValue.Value or value
  end

  function Aim.SetAngleWeight(value: number): ()
    AngleWeightValue.Value = value == nil and AngleWeightValue.Value or value
  end

  function Aim.SetHealthWeight(value: number): ()
    HealthWeightValue.Value = value == nil and HealthWeightValue.Value or value
  end

  table.insert(getgenv().AIM_RBX_CONNECTIONS, Client.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
  end))

  return Aim
end)()
-- Aim = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/aim.lua"))()

-- AimToInstance(Instance) / AimToPosition(Vector3)
-- AimToPlayer(Player) / ChoosePlayerToAim({Player}?)
-- SetSmoothness(number) / SetAimPart(string) / SetTeamCheck(bool)
-- SetMaxDistance(number) / SetMaxAngle(number)
-- SetDistanceWeight(number) / SetAngleWeight(number) / SetHealthWeight(number)
