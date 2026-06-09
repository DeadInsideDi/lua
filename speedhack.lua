return (function()
  local SpeedHack = {}

  local InputService = game:GetService("UserInputService")
  local RunService = game:GetService("RunService")
  local MoveDirection = Vector3.zero

  for _, Connection in ipairs(getgenv().SPEEDHACK_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().SPEEDHACK_RBX_CONNECTIONS = {}

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

  local function ImpulseRun(speed: number): ()
    local Char = getgenv().Character
    local Part = GetPartOfModel(Char)
    if Part and MoveDirection.Magnitude > 0  then
      Part:ApplyImpulse(MoveDirection * speed)
    end
  end
  local function TranslateRun(speed: number): ()
    local Char = getgenv().Character
    if Char and MoveDirection.Magnitude > 0  then
      Char:TranslateBy(MoveDirection * speed)
    end
  end

  local function UpdateSpeed()
    RunService:UnbindFromRenderStep("SpeedHackBoost")
    if not SpeedHack.Enabled.Value then return end

    local Speed = SpeedHack.Speed.Value
    local RunFunction = SpeedHack.UseTranslate.Value and TranslateRun or ImpulseRun
    RunService:BindToRenderStep("SpeedHackBoost", Enum.RenderPriority.Character.Value, function(dt)
      RunFunction(Speed * dt)
    end)
  end

  SpeedHack.Enabled = CreateValue(false, UpdateSpeed)
  SpeedHack.Speed = CreateValue(20, UpdateSpeed)
  SpeedHack.UseTranslate = CreateValue(true, UpdateSpeed)

  local Keys = {
    [Enum.KeyCode.W] = 0, [Enum.KeyCode.Up] = 0,
    [Enum.KeyCode.S] = 0, [Enum.KeyCode.Down] = 0,
    [Enum.KeyCode.A] = 0, [Enum.KeyCode.Left] = 0,
    [Enum.KeyCode.D] = 0, [Enum.KeyCode.Right] = 0
  }

  local function UpdateMoveDirection(): ()
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

  return SpeedHack
end)()
-- SpeedHack = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/speedhack.lua"))()

-- Enabled: bool / Speed: number / UseTranslate: bool
