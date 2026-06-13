return (function()
  local Fly = {}

  local InputService = game:GetService("UserInputService")
  local RunService = game:GetService("RunService")
  local Camera = workspace.CurrentCamera
  local MoveDirection = Vector3.zero

  for _, Connection in getgenv().FLY_RBX_CONNECTIONS or {} do
    Connection:Disconnect()
  end
  getgenv().FLY_RBX_CONNECTIONS = {}

  if not getgenv().CharacterFinderRunned then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/characterfinder.lua"))()
  end
  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  local function GetPartOfModel(model: Model | nil): BasePart | nil
    if not model then return nil end
    if model.PrimaryPart then return model.PrimaryPart end
    return model:FindFirstChildOfClass("BasePart")
  end

  local function UpdateFly()
    local Part = GetPartOfModel(getgenv().Character)
    print(Fly.Enabled.Value, getgenv().Character, Part)
    if not Part then return end
    Part.Anchored = false
    Part.AssemblyLinearVelocity = Vector3.zero

    RunService:UnbindFromRenderStep("UpdateFly")
    if not Fly.Enabled.Value then return end
    local Speed = Fly.Speed.Value
    if Part then Part.Anchored = true end
    print(Fly.Enabled.Value, Part)
    RunService:BindToRenderStep("UpdateFly", Enum.RenderPriority.Character.Value * 2, function(dt)
      local Char = getgenv().Character
      if Char and MoveDirection.Magnitude > 0 then
        local Fwd, Right = Camera.CFrame.LookVector, Camera.CFrame.RightVector
        local direction = (Fwd * MoveDirection.X) + (Right * MoveDirection.Z)
        Char:PivotTo(CFrame.new(Char:GetPivot().Position + direction.Unit * Speed * dt) * Camera.CFrame.Rotation)
        print('PIVOTED TO', Char)
      end
    end)
  end

  Fly.Enabled = CreateValue(false, UpdateFly)
  Fly.Speed = CreateValue(50, UpdateFly)

  local Keys = {
    [Enum.KeyCode.W] = 0, [Enum.KeyCode.Up] = 0,
    [Enum.KeyCode.S] = 0, [Enum.KeyCode.Down] = 0,
    [Enum.KeyCode.A] = 0, [Enum.KeyCode.Left] = 0,
    [Enum.KeyCode.D] = 0, [Enum.KeyCode.Right] = 0
  }

  local function UpdateMoveDirection()
    local x = math.max(Keys[Enum.KeyCode.W], Keys[Enum.KeyCode.Up]) - math.max(Keys[Enum.KeyCode.S], Keys[Enum.KeyCode.Down])
    local z = math.max(Keys[Enum.KeyCode.D], Keys[Enum.KeyCode.Right]) - math.max(Keys[Enum.KeyCode.A], Keys[Enum.KeyCode.Left])
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
