return (function()
  local SpeedHack = {}

  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Character = Client.Character or Client.CharacterAdded:Wait()
  local Humanoid = Character:WaitForChild("Humanoid")

  for _, Connection in ipairs(getgenv().SPEEDHACK_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().SPEEDHACK_RBX_CONNECTIONS = {}

  local function FindValueInstance(vtype: string, name: string, value: any)
    local Value = script:FindFirstChild(name)

    if Value == nil then
      Value = Instance.new(vtype.."Value", script)
      Value.Name = name
      Value.Value = value
    end

    return Value
  end

  local EnabledValue = FindValueInstance("Bool", "SpeedHack_Enabled", false)
  local BaseSpeedValue = FindValueInstance("Number", "SpeedHack_BaseSpeed", 0)
  local SpeedValue = FindValueInstance("Number", "SpeedHack_Speed", 20)

  local function UpdateSpeed()
    local TargetSpeed = EnabledValue.Value and SpeedValue.Value or BaseSpeedValue.Value

    RunService:UnbindFromRenderStep("Boost")
    RunService:BindToRenderStep("Boost", Enum.RenderPriority.Character.Value, function(dt)
      if Humanoid == nil then return end
      local Dir = Humanoid.MoveDirection
      if Dir.Magnitude > 0 then Character:TranslateBy(TargetSpeed * dt * Dir) end
    end)
  end

  EnabledValue.Changed:Connect(UpdateSpeed)
  BaseSpeedValue.Changed:Connect(UpdateSpeed)
  SpeedValue.Changed:Connect(UpdateSpeed)

  function SpeedHack.SetEnabled(value: boolean): ()
    EnabledValue.Value = value or false
  end

  function SpeedHack.Enable(): ()
    SpeedHack.SetEnabled(true)
  end

  function SpeedHack.Disable(): ()
    SpeedHack.SetEnabled(false)
  end

  function SpeedHack.ChangeBaseSpeed(numberOrFunc: number | (number) -> number): ()
    if type(numberOrFunc) == "function" then
      BaseSpeedValue.Value = numberOrFunc(BaseSpeedValue.Value) or BaseSpeedValue.Value
    else
      BaseSpeedValue.Value = numberOrFunc or BaseSpeedValue.Value
    end
  end

  function SpeedHack.ChangeSpeed(numberOrFunc: number | (number) -> number): ()
    if type(numberOrFunc) == "function" then
      SpeedValue.Value = numberOrFunc(SpeedValue.Value) or SpeedValue.Value
    else
      SpeedValue.Value = numberOrFunc or SpeedValue.Value
    end
  end

  local function setup(newCharacter: Model)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    UpdateSpeed()
  end

  setup(Character)
  getgenv().SPEEDHACK_RBX_CONNECTION = Client.CharacterAdded:Connect(setup)

  return SpeedHack
end)()
-- SpeedHack = loadstring(game:HttpGet("https://pastebin.com/raw/38W0vdTM"))()

-- SetEnabled(bool) / Enable / Disable
-- SetBaseSpeed(number) / ChangeSpeed(number | func)