return (function()
  local Chams = {}
  local Profiles = {}

  local function FindValueInstance(vtype: string, name: string, value: any)
    local Value = script:FindFirstChild(name)

    if Value == nil then
      Value = Instance.new(vtype.."Value", script)
      Value.Name = name
      Value.Value = value
    end

    return Value
  end

  function Chams.CreateChamProfile()
    local PName = "Profile_"..tostring(#Profiles)
    local Profile = {}
    local ManagedTargets: {[Instance]: Highlight} = {}
    table.insert(Profiles, Profile)

    local EnabledValue = FindValueInstance("Bool", "Chams_"..PName.."_Enabled", false)
    local FillColorValue = FindValueInstance("Color3", "Chams_"..PName.."_FillColor", Color3.fromRGB(255, 0, 0))
    local FillTransValue = FindValueInstance("Number", "Chams_"..PName.."_FillTransparency", 0.75)
    local OutlineColorValue = FindValueInstance("Color3", "Chams_"..PName.."_OutlineColor", Color3.fromRGB(255, 255, 255))
    local OutlineTransValue = FindValueInstance("Number", "Chams_"..PName.."_OutlineTransparency", 0.25)

    local function ApplyStyle(highlight: Highlight)
      highlight.Enabled = EnabledValue.Value
      highlight.FillColor = FillColorValue.Value
      highlight.FillTransparency = FillTransValue.Value
      highlight.OutlineColor = OutlineColorValue.Value
      highlight.OutlineTransparency = OutlineTransValue.Value
    end

    local function UpdateAllStyles()
      for Target, Highlight in pairs(ManagedTargets) do
        if Target.Parent and Highlight.Parent then
          ApplyStyle(Highlight)
        else
          ManagedTargets[Target] = nil
        end
      end
    end

    EnabledValue.Changed:Connect(UpdateAllStyles)
    FillColorValue.Changed:Connect(UpdateAllStyles)
    FillTransValue.Changed:Connect(UpdateAllStyles)
    OutlineColorValue.Changed:Connect(UpdateAllStyles)
    OutlineTransValue.Changed:Connect(UpdateAllStyles)

    function Profile.Add(partOrModel: Instance): ()
      if not partOrModel:IsA("Model") and not partOrModel:IsA("BasePart") then return end
      if ManagedTargets[partOrModel] then return end

      local HName = "ChamsHighlight_"..PName
      local Highlight = partOrModel:FindFirstChild(HName)
      if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = HName
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Parent = partOrModel
      end

      ApplyStyle(Highlight)
      ManagedTargets[partOrModel] = Highlight
    end

    function Profile.Remove(partOrModel: Instance): ()
      local HName = "ChamsHighlight_"..PName
      local Highlight = ManagedTargets[partOrModel] or partOrModel:FindFirstChild(HName)
      if Highlight then Highlight:Destroy() end
      ManagedTargets[partOrModel] = nil
    end

    function Profile.Clear(): ()
      for _, Highlight in pairs(ManagedTargets) do
        if Highlight.Parent then Highlight:Destroy() end
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

    function Profile.SetFillColor(color3: Color3): ()
      FillColorValue.Value = color3 == nil and FillColorValue.Value or color3
    end

    function Profile.SetFillTransparency(value: number): ()
      FillTransValue.Value = value == nil and FillTransValue.Value or value
    end

    function Profile.SetOutlineColor(color3: Color3): ()
      OutlineColorValue.Value = color3 == nil and OutlineColorValue.Value or color3
    end

    function Profile.SetOutlineTransparency(value: number): ()
      OutlineTransValue.Value = value == nil and OutlineTransValue.Value or value
    end

    return Profile
  end

  function Chams.EnableAllProfiles(): ()
    for _, Profile in pairs(Profiles) do
      Profile.SetEnabled(true)
    end
  end

  function Chams.DisableAllProfiles(): ()
    for _, Profile in pairs(Profiles) do
      Profile.SetEnabled(false)
    end
  end

  return Chams
end)()
-- Chams = loadstring(game:HttpGet("https://pastebin.com/raw/S4aLJz38"))()

-- EnableAllProfiles / DisableAllProfiles / CreateChamProfile -V-
-- Add(Instance) / Remove(Instance) / Clear
-- SetEnabled(bool) / Enable / Disable
-- SetFillColor(Color3) / SetFillTransparency(number)
-- SetOutlineColor(Color3) / SetOutlineTransparency(number)