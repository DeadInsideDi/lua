return (function()
  local Tracers = {}
  local Profiles = {}

  local CoreGui = game:GetService("CoreGui")
  local RunService = game:GetService("RunService")
  local Camera = workspace.CurrentCamera

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  local function GetPositionAndCFrameOfModelOrPart(instance: Instance): Vector3
    local TargetPosition, TargetCFrame = nil, nil

    if instance:IsA("BasePart") then
      TargetPosition = instance.Position
      TargetCFrame = instance.CFrame
    elseif instance:IsA("Model") then
      TargetCFrame = Instance.new("Model"):GetPivot()
      TargetPosition = TargetCFrame.Position
    end

    return TargetPosition, TargetCFrame
  end

  RunService:UnbindFromRenderStep("TracersUpdatePosition")
  RunService:BindToRenderStep("TracersUpdatePosition", Enum.RenderPriority.Character.Value * 2, function()
    local FocusPos = Camera.Focus.Position
    for _, Profile in Profiles do
      for Target, Line in Profile.ManagedTargets do
        if not Target then continue end
        local TargetPos, TargetCFrame = GetPositionAndCFrameOfModelOrPart(Target)
        local Direction = FocusPos - TargetPos
        local Distance = Direction.Magnitude
        if Distance == 0 then continue end

        local worldCF = CFrame.lookAt(TargetPos, FocusPos)
        Line.CFrame = TargetCFrame:Inverse() * worldCF
        Line.Length = Distance
      end
    end
  end)

  for _, Connection in getgenv().TRACERS_RBX_CONNECTIONS or {} do
    Connection:Disconnect()
  end
  getgenv().TRACERS_RBX_CONNECTIONS = {}

  local TracerFolders = CoreGui:FindFirstChild("Tracers_Folder")
  if TracerFolders then TracerFolders:Destroy() end
  TracerFolders = Instance.new("Folder", CoreGui)
  TracerFolders.Name = "Tracers_Folder"

  function Tracers.CreateTracer()
    local Profile = {}
    table.insert(Profiles, Profile)

    Profile.ManagedTargets = {}
    Profile.Enabled = CreateValue(false, Profile.UpdateAllStyles)
    Profile.Color = CreateValue(Color3.fromRGB(255, 0, 0), Profile.UpdateAllStyles)
    Profile.Transparency = CreateValue(0, Profile.UpdateAllStyles)
    Profile.AlwaysOnTop = CreateValue(true, Profile.UpdateAllStyles)
    Profile.Thickness = CreateValue(5, Profile.UpdateAllStyles)

    local function ApplyStyle(line: LineHandleAdornment)
      line.Visible = Profile.Enabled.Value
      line.Color3 = Profile.Color.Value
      line.Transparency = Profile.Transparency.Value
      line.AlwaysOnTop = Profile.AlwaysOnTop.Value
      line.Thickness = Profile.Thickness.Value
    end

    function Profile.UpdateAllStyles()
      for Target, Line in Profile.ManagedTargets do
        if Target.Parent and Line.Parent then
          ApplyStyle(Line)
        else
          Profile.ManagedTargets[Target] = nil
        end
      end
    end

    function Profile.AddInstance(instance: Instance)
      if not instance:IsA("BasePart") and not instance:IsA("Model") then return end
      if Profile.ManagedTargets[instance] then return end

      local Line = Instance.new("LineHandleAdornment", TracerFolders)
      Line.ZIndex = 1
      Line.Adornee = instance

      ApplyStyle(Line)
      Profile.ManagedTargets[instance] = Line
    end

    function Profile.AddPosition(pos: Vector3)
      local Part = Instance.new("Part", TracerFolders)
      Part.Position = pos
      Part.Transparency = 1
      Part.Anchored = true
      Part.CanCollide = false
      Part.CanQuery = false
      return Profile.AddInstance(Part)
    end

    function Profile.AddPlayer(player: Player)
      if player.Character then
        Profile.AddInstance(player.Character)
      end

      table.insert(getgenv().TRACERS_RBX_CONNECTIONS, player.CharacterAdded:Connect(Profile.AddInstance))
      table.insert(getgenv().TRACERS_RBX_CONNECTIONS, player.CharacterRemoving:Connect(Profile.RemoveInstance))
    end

    function Profile.RemoveInstance(instance: Instance): ()
      local Line = Profile.ManagedTargets[instance]
      if Line then Line:Destroy() end
      Profile.ManagedTargets[instance] = nil
    end

    function Profile.Clear(): ()
      for _, Data in Profile.ManagedTargets do
        if Data.Line then Data.Line:Destroy() end
      end
      table.clear(Profile.ManagedTargets)
    end

    return Profile
  end

  function Tracers.EnableAll(): ()
    for _, Profile in Profiles do
      Profile.Enabled.Value = true
    end
  end

  function Tracers.DisableAll(): ()
    for _, Profile in Profiles do
      Profile.Enabled.Value = false
    end
  end

  return Tracers
end)()
-- Tracers = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/tracers.lua"))()

-- EnableAll / DisableAll / CreateTracer -V-
-- AddInstance(Instance) / AddPosition(Vector3) / AddPlayer(Player)
-- RemoveInstance(Instance) / Clear

-- Enabled: bool / AlwaysOnTop: bool / Color: Color3
-- Transparency: number / Thickness: number
