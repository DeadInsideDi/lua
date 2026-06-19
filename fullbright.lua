return (function()
  local FullBright = {}

  local Lighting = game:GetService("Lighting")

  for _, Connection in getgenv().FULLBRIGHT_RBX_CONNECTIONS or {} do
    Connection:Disconnect()
  end
  getgenv().FULLBRIGHT_RBX_CONNECTIONS = {}

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  local BaseAmbient = Lighting.Ambient
  local BaseBrightness = Lighting.Brightness
  local BaseGlobalShadows = Lighting.GlobalShadows

  local function UpdateLighting(): ()
    local IsEnabled = FullBright.Enabled.Value or false

    if IsEnabled then
      Lighting.Ambient = FullBright.Ambient.Value
      Lighting.GlobalShadows = FullBright.GlobalShadows.Value
      Lighting.Brightness = FullBright.Brightness.Value
    else
      Lighting.Ambient = BaseAmbient
      Lighting.Brightness = BaseBrightness
      Lighting.GlobalShadows = BaseGlobalShadows
    end
  end

  FullBright.Enabled = CreateValue(false, UpdateLighting)
  FullBright.Ambient = CreateValue(Color3.new(1, 1, 1), UpdateLighting)
  FullBright.Brightness = CreateValue(10, UpdateLighting)
  FullBright.GlobalShadows = CreateValue(false, UpdateLighting)

  table.insert(getgenv().FULLBRIGHT_RBX_CONNECTIONS, Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if not FullBright.Enabled.Value and Lighting.Ambient ~= BaseAmbient then BaseAmbient = Lighting.Ambient end
    if FullBright.Enabled.Value and Lighting.Ambient ~= FullBright.Ambient.Value then Lighting.Ambient = FullBright.Ambient.Value end
  end))

  table.insert(getgenv().FULLBRIGHT_RBX_CONNECTIONS, Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
    if not FullBright.Enabled.Value and Lighting.GlobalShadows ~= BaseGlobalShadows then BaseGlobalShadows = Lighting.GlobalShadows end
    if FullBright.Enabled.Value and Lighting.GlobalShadows ~= FullBright.GlobalShadows.Value then Lighting.GlobalShadows = FullBright.GlobalShadows.Value end
  end))

  table.insert(getgenv().FULLBRIGHT_RBX_CONNECTIONS, Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if not FullBright.Enabled.Value and Lighting.Brightness ~= BaseBrightness then BaseBrightness = Lighting.Brightness end
    if FullBright.Enabled.Value and Lighting.Brightness ~= FullBright.Brightness.Value then Lighting.Brightness = FullBright.Brightness.Value end
  end))

  UpdateLighting()
  return FullBright
end)()
-- FullBright = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/fullbright.lua"))()

-- Enabled: bool / Ambient: Color3 / GlobalShadows: bool  / Brightness: number
