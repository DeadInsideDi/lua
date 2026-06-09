return (function()
  local Fly = {}

  local InputService = game:GetService("UserInputService")
  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Camera = workspace.CurrentCamera
  local Character = nil
  local MoveDirection = Vector3.zero

  for _, Connection in getgenv().FLY_RBX_CONNECTIONS or {} do
    Connection:Disconnect()
  end
  getgenv().FLY_RBX_CONNECTIONS = {}

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  local function GetPartOfModel(model: Model): BasePart | nil
    if model.PrimaryPart then return model.PrimaryPart end
    return model:FindFirstChildOfClass("BasePart")
  end

  local function UpdateFly()
    if not Character then return end
    local Part = GetPartOfModel(Character)
    if Part then Part.Anchored = false end

    RunService:UnbindFromRenderStep("UpdateFly")
    if not Fly.Enabled.Value then return end

    local Speed = Fly.Speed.Value
    if Part then Part.Anchored = true end
    RunService:BindToRenderStep("UpdateFly", Enum.RenderPriority.Last.Value * 2, function()
      if Character then
        local Fwd, Right = Camera.CFrame.LookVector, Camera.CFrame.RightVector
        local d = (Fwd * MoveDirection:Dot(Fwd) + Right * MoveDirection:Dot(Right)).Unit * Speed
        -- Character:TranslateBy(Vector3.new(0,0,1) )
        print(MoveDirection, Speed)
        print(Character, d)
      end
    end)
  end

  Fly.Enabled = CreateValue(false, UpdateFly)
  Fly.Speed = CreateValue(10, UpdateFly)

  RunService:UnbindFromRenderStep("FindCharacter")
  RunService:BindToRenderStep("FindCharacter", Enum.RenderPriority.Last.Value * 2, function()
    local Counts, MaxCount, PossibleCharacter = {}, 0, nil
    local Parts = workspace:GetPartBoundsInRadius(Camera.Focus.Position, 1)
    for _, Part in Parts do
      local Model = Part:FindFirstAncestorOfClass("Model")
      if Model then Counts[Model] = (Counts[Model] or 0) + 1 end
    end

    for Model, Count in Counts do
      if Count > MaxCount then
        MaxCount = Count
        PossibleCharacter = Model
      end
    end
    Character = PossibleCharacter
  end)

  local Keys = {
    [Enum.KeyCode.W] = 0, [Enum.KeyCode.Up] = 0,
    [Enum.KeyCode.S] = 0, [Enum.KeyCode.Down] = 0,
    [Enum.KeyCode.A] = 0, [Enum.KeyCode.Left] = 0,
    [Enum.KeyCode.D] = 0, [Enum.KeyCode.Right] = 0
  }

  local function UpdateMoveDirection()
    local x = math.max(Keys[Enum.KeyCode.D], Keys[Enum.KeyCode.Right]) - math.max(Keys[Enum.KeyCode.A], Keys[Enum.KeyCode.Left])
    local z = math.max(Keys[Enum.KeyCode.S], Keys[Enum.KeyCode.Down]) - math.max(Keys[Enum.KeyCode.W], Keys[Enum.KeyCode.Up])
    MoveDirection = Vector3.new(x, 0, z)
  end

  table.insert(getgenv().FLY_RBX_CONNECTIONS, InputService.InputBegan:Connect(function(input, processed)
    if processed or not Keys[input.KeyCode] then return end
    Keys[input.KeyCode] = 1
    UpdateMoveDirection()
  end))

  table.insert(getgenv().FLY_RBX_CONNECTIONS, InputService.InputEnded:Connect(function(input)
    if not Keys[input.KeyCode] then return end
    Keys[input.KeyCode] = 0
    UpdateMoveDirection()
  end))

  return Fly
end)()
-- Fly = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/fly.lua"))()

-- Enabled: bool / Speed: number
