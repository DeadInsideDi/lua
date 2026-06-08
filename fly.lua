return (function()
  local Fly = {}

  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Camera = workspace.CurrentCamera
  local RenderStepName = "Fly_Update"
  local Root = nil
  local Humanoid = nil
  local BodyGyro = nil
  local BodyVelocity = nil

  for _, Connection in ipairs(getgenv().FLY_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().FLY_RBX_CONNECTIONS = {}

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  local function GetCharacterFromPart(currentPart: Instance): Model | nil
    while currentPart and currentPart ~= workspace do
      if currentPart:FindFirstChildOfClass("Humanoid") then
        return currentPart
      end
      currentPart = currentPart.Parent
    end
    return nil
  end

  local function FindCharacterModel(): Model | nil
    local Parts = workspace:GetPartBoundsInRadius(Camera.Focus.Position, 3)
    for _, Part in ipairs(Parts) do
      local Model = GetCharacterFromPart(Part)
      if Model then return Model end
    end
  end

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
    BodyGyro.MaxTorque = Vector3.one * Fly.Force.Value
    BodyGyro.P = 3000

    BodyVelocity = Instance.new("BodyVelocity", Root)
    BodyVelocity.MaxForce = Vector3.one * Fly.Force.Value
    BodyVelocity.P = 20000
    BodyVelocity.Velocity = Vector3.zero
  end

  local function UpdateFly()
    if not Fly.Enabled.Value then
      CleanupPhysics()
      if Humanoid then Humanoid.PlatformStand = false end
      RunService:UnbindFromRenderStep(RenderStepName)
      return
    end

    if not BodyGyro or not BodyVelocity then
      SetupPhysics()
    end

    if Humanoid then Humanoid.PlatformStand = true end
    local Speed = Fly.Speed.Value

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
          BodyVelocity.Velocity = Vector3.zero
        end
      end
    end)
  end

  RunService:UnbindFromRenderStep("FindCharacterRootAndHumaniod")
  RunService:BindToRenderStep("FindCharacterRootAndHumaniod", Enum.RenderPriority.Last.Value * 2, function()
    if Fly.Enabled.Value then
      Root = FindCharacterModel()
      Humanoid = Root:FindFirstChildOfClass("Humanoid")
    end
  end)

  Fly.Enabled = CreateValue(false, UpdateFly)
  Fly.Speed = CreateValue(50, UpdateFly)
  Fly.Force = CreateValue(10000000, UpdateFly)

  return Fly
end)()
-- Fly = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/fly.lua"))()

-- Enabled: bool / Speed: number / Force: number
