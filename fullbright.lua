return (function()
  local FullBright = {}

  local Lighting = game:GetService("Lighting")
  local Camera = workspace.CurrentCamera

  for _, Connection in ipairs(getgenv().FULLBRIGHT_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().FULLBRIGHT_RBX_CONNECTIONS = {}

  local function FindValueInstance(vtype: string, name: string, value: any)
    local Value = script:FindFirstChild(name)

    if Value == nil then
      Value = Instance.new(vtype.."Value", script)
      Value.Name = name
      Value.Value = value
    end

    return Value
  end

  local EnabledValue = FindValueInstance("Bool", "FullBright_Enabled", false)
  local AmbientValue = FindValueInstance("Color3", "FullBright_Ambient", Color3.new(1, 1, 1))
  local OutdoorValue = FindValueInstance("Color3", "FullBright_OutdoorAmbient", Color3.new(1, 1, 1))
  local ShadowsValue = FindValueInstance("Bool", "FullBright_GlobalShadows", false)
  local BrightValue = FindValueInstance("Number", "FullBright_Brightness", 2)

  local RangeValue = FindValueInstance("Number", "FullBright_Range", 1000)
  local LightBrightValue = FindValueInstance("Number", "FullBright_LightBrightness", 5)
  local LightShadowsValue = FindValueInstance("Bool", "FullBright_LightShadows", false)
  local FaceValue = FindValueInstance("String", "FullBright_Face", "Front")
  local AngleValue = FindValueInstance("Number", "FullBright_Angle", 180)

  local BaseAmbient = Lighting.Ambient
  local BaseOutdoor = Lighting.OutdoorAmbient
  local BaseShadows = Lighting.GlobalShadows
  local BaseBrightness = Lighting.Brightness

  local Attachment = Camera:FindFirstChild("FullBrightAttachment")
  if not Attachment then
    Attachment = Instance.new("Attachment")
    Attachment.Name = "FullBrightAttachment"
    Attachment.Parent = Camera
  end

  local ExistingLight = Attachment:FindFirstChild("FullBrightLight")
  if ExistingLight and not ExistingLight:IsA("SurfaceLight") then
    ExistingLight:Destroy()
    ExistingLight = nil
  end

  local SurfaceLight = ExistingLight
  if not SurfaceLight then
    SurfaceLight = Instance.new("SurfaceLight")
    SurfaceLight.Name = "FullBrightLight"
    SurfaceLight.Parent = Attachment
  end

  local function UpdateLighting()
    local IsEnabled = EnabledValue.Value or false

    if not SurfaceLight or not SurfaceLight:IsA("SurfaceLight") then
      local CheckLight = Attachment:FindFirstChild("FullBrightLight")
      if CheckLight and not CheckLight:IsA("SurfaceLight") then
        CheckLight:Destroy()
      end
      SurfaceLight = Instance.new("SurfaceLight")
      SurfaceLight.Name = "FullBrightLight"
      SurfaceLight.Parent = Attachment
    end

    SurfaceLight.Enabled = IsEnabled
    SurfaceLight.Range = RangeValue.Value
    SurfaceLight.Brightness = LightBrightValue.Value
    SurfaceLight.Shadows = LightShadowsValue.Value

    local ParsedFace = Enum.NormalId.Front
    pcall(function() ParsedFace = Enum.NormalId[FaceValue.Value] end)
    SurfaceLight.Face = ParsedFace
    SurfaceLight.Angle = AngleValue.Value or 90

    if IsEnabled then
      Lighting.Ambient = AmbientValue.Value
      Lighting.OutdoorAmbient = OutdoorValue.Value
      Lighting.GlobalShadows = ShadowsValue.Value
      Lighting.Brightness = BrightValue.Value
    else
      if Lighting.Ambient ~= BaseAmbient then Lighting.Ambient = BaseAmbient end
      if Lighting.OutdoorAmbient ~= BaseOutdoor then Lighting.OutdoorAmbient = BaseOutdoor end
      if Lighting.GlobalShadows ~= BaseShadows then Lighting.GlobalShadows = BaseShadows end
      if Lighting.Brightness ~= BaseBrightness then Lighting.Brightness = BaseBrightness end
    end
  end

  EnabledValue.Changed:Connect(UpdateLighting)
  AmbientValue.Changed:Connect(UpdateLighting)
  OutdoorValue.Changed:Connect(UpdateLighting)
  ShadowsValue.Changed:Connect(UpdateLighting)
  BrightValue.Changed:Connect(UpdateLighting)
  RangeValue.Changed:Connect(UpdateLighting)
  LightBrightValue.Changed:Connect(UpdateLighting)
  LightShadowsValue.Changed:Connect(UpdateLighting)
  FaceValue.Changed:Connect(UpdateLighting)
  AngleValue.Changed:Connect(UpdateLighting)

  table.insert(getgenv().FULLBRIGHT_RBX_CONNECTIONS, Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if not EnabledValue.Value and Lighting.Ambient ~= BaseAmbient then BaseAmbient = Lighting.Ambient end
  end))

  table.insert(getgenv().FULLBRIGHT_RBX_CONNECTIONS, Lighting:GetPropertyChangedSignal("OutdoorAmbient"):Connect(function()
    if not EnabledValue.Value and Lighting.OutdoorAmbient ~= BaseOutdoor then BaseOutdoor = Lighting.OutdoorAmbient end
  end))

  table.insert(getgenv().FULLBRIGHT_RBX_CONNECTIONS, Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
    if not EnabledValue.Value and Lighting.GlobalShadows ~= BaseShadows then BaseShadows = Lighting.GlobalShadows end
  end))

  table.insert(getgenv().FULLBRIGHT_RBX_CONNECTIONS, Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if not EnabledValue.Value and Lighting.Brightness ~= BaseBrightness then BaseBrightness = Lighting.Brightness end
  end))

  function FullBright.SetEnabled(value: boolean): ()
    EnabledValue.Value = value or false
  end

  function FullBright.Enable(): ()
    FullBright.SetEnabled(true)
  end

  function FullBright.Disable(): ()
    FullBright.SetEnabled(false)
  end

  function FullBright.SetAmbient(color3: Color3): ()
    AmbientValue.Value = color3 == nil and AmbientValue.Value or color3
  end

  function FullBright.SetOutdoorAmbient(color3: Color3): ()
    OutdoorValue.Value = color3 == nil and OutdoorValue.Value or color3
  end

  function FullBright.SetGlobalShadows(value: boolean): ()
    ShadowsValue.Value = value == nil and false or value
  end

  function FullBright.SetBrightness(value: number): ()
    BrightValue.Value = value == nil and BrightValue.Value or value
  end

  function FullBright.SetRange(value: number): ()
    RangeValue.Value = value == nil and RangeValue.Value or value
  end

  function FullBright.SetLightBrightness(value: number): ()
    LightBrightValue.Value = value == nil and LightBrightValue.Value or value
  end

  function FullBright.SetShadows(value: boolean): ()
    LightShadowsValue.Value = value == nil and false or value
  end

  function FullBright.SetFace(faceName: string): ()
    FaceValue.Value = faceName == nil and FaceValue.Value or faceName
  end

  function FullBright.SetAngle(value: number): ()
    AngleValue.Value = value == nil and AngleValue.Value or value
  end

  UpdateLighting()
  return FullBright
end)()
-- FullBright = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/refs/heads/main/fullbright.lua"))()

-- SetEnabled(bool) / Enable / Disable
-- SetAmbient(Color3) / SetOutdoorAmbient(Color3)
-- SetGlobalShadows(bool)/ SetShadows(bool)
-- SetLightBrightness(number) / SetBrightness(number)
-- SetRange(number) / SetFace(string) / SetAngle(number)
