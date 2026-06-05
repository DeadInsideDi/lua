return (function()
  local Fly = {}

  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Character = Client.Character or Client.CharacterAdded:Wait()
  local Root = Character:WaitForChild("HumanoidRootPart")
  local Humanoid = Character:WaitForChild("Humanoid")
  local Camera = workspace.CurrentCamera
  local RenderStepName = "Fly_Update"
  local BodyGyro = Root:FindFirstChildOfClass("BodyGyro")
  local BodyVelocity = Root:FindFirstChildOfClass("BodyVelocity")

  for _, Connection in ipairs(getgenv().FLY_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().FLY_RBX_CONNECTIONS = {}

  local function FindValueInstance(vtype: string, name: string, value: any)
    local Value = script:FindFirstChild(name)

    if Value == nil then
      Value = Instance.new(vtype.."Value", script)
      Value.Name = name
      Value.Value = value
    end

    return Value
  end

  local EnabledValue = FindValueInstance("Bool", "Fly_Enabled", false)
  local SpeedValue = FindValueInstance("Number", "Fly_Speed", 50)
  local ForceValue = FindValueInstance("Number", "Fly_Force", 10000000)

  local function CleanupPhysics()
    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end
    BodyGyro = nil
    BodyVelocity = nil
  end

  local function SetupPhysics()
    CleanupPhysics()
    if not Root then return end

    BodyGyro = Instance.new("BodyGyro", Root)
    BodyGyro.D = 500
    BodyGyro.MaxTorque = Vector3.new(1, 1, 1) * ForceValue.Value
    BodyGyro.P = 3000

    BodyVelocity = Instance.new("BodyVelocity", Root)
    BodyVelocity.MaxForce = Vector3.new(1, 1, 1) * ForceValue.Value
    BodyVelocity.P = 20000
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
  end

  local function UpdateFly()
    if not EnabledValue.Value then
      CleanupPhysics()
      Humanoid.PlatformStand = false
      RunService:UnbindFromRenderStep(RenderStepName)
      return
    end

    if not BodyGyro or not BodyVelocity then
      SetupPhysics()
    end

    Humanoid.PlatformStand = true
    local Speed = SpeedValue.Value

    RunService:UnbindFromRenderStep(RenderStepName)
    RunService:BindToRenderStep(RenderStepName, Enum.RenderPriority.Input.Value, function()
      if not Root or not Root.Parent then
        RunService:UnbindFromRenderStep(RenderStepName)
        CleanupPhysics()
        return
      end

      if BodyGyro and BodyVelocity then
        BodyGyro.CFrame = Camera.CFrame
        local Dir = Humanoid.MoveDirection
        if Dir.Magnitude > 0 then
          local Fwd, Right = Camera.CFrame.LookVector, Camera.CFrame.RightVector
          BodyVelocity.Velocity = (Fwd * Dir:Dot(Fwd) + Right * Dir:Dot(Right)).Unit * Speed
        else
          BodyVelocity.Velocity = Vector3.new(0,0,0)
        end
      end
    end)
  end

  EnabledValue.Changed:Connect(UpdateFly)
  SpeedValue.Changed:Connect(UpdateFly)
  ForceValue.Changed:Connect(UpdateFly)

  local function setup(newCharacter: Model)
    Character = newCharacter
    Root = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    Camera = workspace.CurrentCamera
    CleanupPhysics()
    UpdateFly()
  end

  setup(Character)
  table.insert(getgenv().FLY_RBX_CONNECTIONS, Client.CharacterAdded:Connect(setup))

  function Fly.SetEnabled(value: boolean): ()
    EnabledValue.Value = value or false
  end

  function Fly.Enable(): ()
    Fly.SetEnabled(true)
  end

  function Fly.Disable(): ()
    Fly.SetEnabled(false)
  end

  function Fly.ChangeSpeed(numberOrFunc: number | (number) -> number): ()
    if type(numberOrFunc) == "function" then
      SpeedValue.Value = numberOrFunc(SpeedValue.Value) or SpeedValue.Value
    else
      SpeedValue.Value = numberOrFunc or SpeedValue.Value
    end
  end

  function Fly.SetForce(value: number): ()
    ForceValue.Value = value == nil and ForceValue.Value or value
  end

  return Fly
end)()
-- Fly = loadstring(game:HttpGet("https://pastebin.com/raw/26dUawd3"))()

-- SetEnabled(bool) / Enable / Disable
-- ChangeSpeed(number | (number) -> number) / SetForce(number)