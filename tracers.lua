return (function()
  local Tracers = {}
  local Profiles = {}

  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local Camera = workspace.CurrentCamera

  local CameraPart = Camera:FindFirstChild("Tracers_CameraPart") or Instance.new("Part", Camera)
  CameraPart.Name = "Tracers_CameraPart"
  CameraPart.Anchored = true
  CameraPart.CanCollide = false
  CameraPart.Transparency = 1
  CameraPart.Size = Vector3.new(0.01, 0.01, 0.01)
  local CameraAttachment = CameraPart:FindFirstChild("Tracers_Attachment") or Instance.new("Attachment", CameraPart)
  CameraAttachment.Name = "Tracers_Attachment"

  RunService:UnbindFromRenderStep("ChangeCameraPartPos")
  RunService:BindToRenderStep("ChangeCameraPartPos", Enum.RenderPriority.Character.Value, function()
    CameraPart.Position = Camera.Focus.Position
  end)


  for _, Connection in ipairs(getgenv().TRACERS_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().TRACERS_RBX_CONNECTIONS = {}

  local function FindValueInstance(vtype: string, name: string, value: any)
    local Value = script:FindFirstChild(name)
    if Value == nil then
      Value = Instance.new(vtype.."Value", script)
      Value.Name = name
      Value.Value = value
    end
    return Value
  end

  local TracerFolder = workspace:FindFirstChild("Tracers_Folder")
  if TracerFolder then TracerFolder:Destroy() end
  TracerFolder = Instance.new("Folder", workspace)
  TracerFolder.Name = "Tracers_Folder"

  function Tracers.CreateTracer()
    local PName = "Profile_"..tostring(#Profiles)
    local Profile = {}
    local ManagedTargets: {[Instance]: Beam} = {}
    table.insert(Profiles, Profile)

    local EnabledValue = FindValueInstance("Bool", "Tracers_"..PName.."_Enabled", false)
    local BrightnessValue = FindValueInstance("Number", "Tracers_"..PName.."_Brightness", 2)
    local ColorFromValue = FindValueInstance("Color3", "Tracers_"..PName.."_ColorFrom", Color3.fromRGB(255, 0, 0))
    local ColorToValue = FindValueInstance("Color3", "Tracers_"..PName.."_ColorTo", Color3.fromRGB(255, 0, 0))
    local TransparencyFromValue = FindValueInstance("Number", "Tracers_"..PName.."_TransparencyFrom", 0.5)
    local TransparencyToValue = FindValueInstance("Number", "Tracers_"..PName.."_TransparencyTo", 0)
    local WidthFromValue = FindValueInstance("Number", "Tracers_"..PName.."_WidthFrom", 0.1)
    local WidthToValue = FindValueInstance("Number", "Tracers_"..PName.."_WidthTo", 0.3)
    local TextureValue = FindValueInstance("String", "Tracers_"..PName.."_Texture", "rbxassetid://111579957804177")
    local TextureLengthValue = FindValueInstance("Number", "Tracers_"..PName.."_TextureLength", 8)

    local function ApplyStyle(beam: Beam)
      beam.Enabled = EnabledValue.Value
      beam.Brightness = BrightnessValue.Value
      beam.Color = ColorSequence.new(ColorFromValue.Value, ColorToValue.Value)
      beam.Transparency = NumberSequence.new(TransparencyFromValue.Value, TransparencyToValue.Value)
      beam.Width0 = WidthFromValue.Value
      beam.Width1 = WidthToValue.Value
      beam.Texture = TextureValue.Value
      beam.TextureLength = TextureLengthValue.Value
    end

    function Profile.UpdateAllStyles()
      for Target, Beam in pairs(ManagedTargets) do
        if Target.Parent and Beam.Parent then
          ApplyStyle(Beam)
        else
          ManagedTargets[Target] = nil
        end
      end
    end

    EnabledValue.Changed:Connect(Profile.UpdateAllStyles)
    BrightnessValue.Changed:Connect(Profile.UpdateAllStyles)
    ColorFromValue.Changed:Connect(Profile.UpdateAllStyles)
    ColorToValue.Changed:Connect(Profile.UpdateAllStyles)
    TransparencyFromValue.Changed:Connect(Profile.UpdateAllStyles)
    TransparencyToValue.Changed:Connect(Profile.UpdateAllStyles)
    WidthFromValue.Changed:Connect(Profile.UpdateAllStyles)
    WidthToValue.Changed:Connect(Profile.UpdateAllStyles)
    TextureValue.Changed:Connect(Profile.UpdateAllStyles)
    TextureLengthValue.Changed:Connect(Profile.UpdateAllStyles)

    function Profile.AddInstance(instance: Instance)
      if not instance:IsA("BasePart") and not instance:IsA("Model") then
        return print("BasePart or Model expected!")
      end
      if ManagedTargets[instance] then return end

      local TargetPart = instance:IsA("Model") and (instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart")) or instance
      if not TargetPart then return end

      local Beam = Instance.new("Beam", TracerFolder)
      Beam.Attachment0 = CameraAttachment
      Beam.Attachment1 = Instance.new("Attachment", TargetPart)
      Beam.FaceCamera = true

      ApplyStyle(Beam)
      ManagedTargets[instance] = Beam
      return ManagedTargets[instance]
    end

    function Profile.AddPosition(pos: Vector3)
      local Part = Instance.new("Part", TracerFolder)
      Part.Position = pos
      Part.Transparency = 1
      Part.Anchored = true
      Part.CanCollide = false
      Part.CanQuery = false
      return Profile.AddInstance(Part)
    end

    function Profile.AddPlayer(targetPlayer: Player)
      if targetPlayer == nil then return end
      local function OnCharacter(character: Model)
        if not character then return end
        return Profile.AddInstance(character)
      end
      if OnCharacter(targetPlayer.Character or targetPlayer.CharacterAdded:Wait()) ~= nil then
        table.insert(getgenv().TRACERS_RBX_CONNECTIONS, targetPlayer.CharacterAdded:Connect(OnCharacter))
      end
    end

    function Profile.Remove(instance: Instance): ()
      local Data = ManagedTargets[instance]
      if Data then
        if Data.Beam.Parent then Data.Beam:Destroy() end
        if Data.Attachment1.Parent then Data.Attachment1:Destroy() end
      end
      ManagedTargets[instance] = nil
    end

    function Profile.Clear(): ()
      for _, Data in pairs(ManagedTargets) do
        if Data.Beam.Parent then Data.Beam:Destroy() end
        if Data.Attachment1.Parent then Data.Attachment1:Destroy() end
      end
      table.clear(ManagedTargets)
    end

    function Profile.SetEnabled(value: boolean): ()
      EnabledValue.Value = value or false
    end

    function Profile.Enable(): ()
      Profile.SetEnabled(true)
    end

    function Profile.Disable(): ()
      Profile.SetEnabled(false)
    end

    function Profile.SetBrightness(value: number): ()
      BrightnessValue.Value = value == nil and BrightnessValue.Value or value
    end

    function Profile.SetColorFrom(color3: Color3): ()
      ColorFromValue.Value = color3 == nil and ColorFromValue.Value or color3
    end

    function Profile.SetColorTo(color3: Color3): ()
      ColorToValue.Value = color3 == nil and ColorToValue.Value or color3
    end

    function Profile.SetTransparencyFrom(value: number): ()
      TransparencyFromValue.Value = value == nil and TransparencyFromValue.Value or value
    end

    function Profile.SetTransparencyTo(value: number): ()
      TransparencyToValue.Value = value == nil and TransparencyToValue.Value or value
    end

    function Profile.SetWidthFrom(value: number): ()
      WidthFromValue.Value = value == nil and WidthFromValue.Value or value
    end

    function Profile.SetWidthTo(value: number): ()
      WidthToValue.Value = value == nil and WidthToValue.Value or value
    end

    function Profile.SetTexture(value: string): ()
      TextureValue.Value = value == nil and TextureValue.Value or value
    end

    function Profile.SetTextureLength(value: number): ()
      TextureLengthValue.Value = value == nil and TextureLengthValue.Value or value
    end

    return Profile
  end

  function Tracers.EnableAll(): ()
    for _, Profile in pairs(Profiles) do
      Profile.SetEnabled(true)
    end
  end

  function Tracers.DisableAll(): ()
    for _, Profile in pairs(Profiles) do
      Profile.SetEnabled(false)
    end
  end

  return Tracers
end)()
-- Tracers = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/tracers.lua"))()

-- EnableAll / DisableAll / CreateTracer -V-
-- AddInstance(Instance) / AddPosition(Vector3) / AddPlayer(Player)
-- Remove(Instance) / Clear
-- SetEnabled(bool) / Enable / Disable
-- SetBrightness(string)
-- SetColorFrom(Color3) / SetColorTo(Color3)
-- SetTransparencyFrom(number) / SetTransparencyTo(number)
-- SetWidthFrom(number) / SetWidthTo(number)
-- SetTexture(string) / SetTextureLength(number)
