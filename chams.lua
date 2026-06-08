return (function()
  local Chams = {}
  local Profiles = {}

  local CoreGui = game:GetService("CoreGui")

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  function Chams.CreateCham()
    local PName = "Profile_"..tostring(#Profiles)
    local Profile = {}
    local ManagedTargets: {[Instance]: Highlight} = {}
    table.insert(Profiles, Profile)

    local function ApplyStyle(highlight: Highlight)
      highlight.Enabled = Profile.Enabled.Value
      highlight.FillColor = Profile.FillColor.Value
      highlight.FillTransparency = Profile.FillTransparency.Value
      highlight.OutlineColor = Profile.OutlineColor.Value
      highlight.OutlineTransparency = Profile.OutlineTrans.Value
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

    Profile.Enabled = CreateValue(false, UpdateAllStyles)
    Profile.FillColor = CreateValue(Color3.fromRGB(255, 0, 0), UpdateAllStyles)
    Profile.FillTransparency = CreateValue(0.75, UpdateAllStyles)
    Profile.OutlineColor = CreateValue(Color3.fromRGB(255, 255, 255), UpdateAllStyles)
    Profile.OutlineTrans = CreateValue(0.25, UpdateAllStyles)

    function Profile.AddInstance(partOrModel: Instance): ()
      if not (partOrModel:IsA("Model") or partOrModel:IsA("BasePart")) then return end
      if ManagedTargets[partOrModel] then return end

      local Highlight = Instance.new("Highlight", CoreGui)
      Highlight.Name = "ChamsHighlight_"..PName
      Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
      Highlight.Adornee = partOrModel

      ApplyStyle(Highlight)
      ManagedTargets[partOrModel] = Highlight
    end

    function Profile.AddPlayer(player: Player): ()
      if player.Character then
        Profile.AddInstance(player.Character)
      end

      player.CharacterAdded:Connect(function(character)
        Profile.AddInstance(character)
      end)
      player.CharacterRemoving:Connect(function(character)
        Profile.Remove(character)
      end)
    end

    function Profile.Remove(partOrModel: Instance): ()
      local Highlight = ManagedTargets[partOrModel]
      if Highlight then Highlight:Destroy() end
      ManagedTargets[partOrModel] = nil
    end

    function Profile.Clear(): ()
      for _, Highlight in pairs(ManagedTargets) do
        if Highlight.Parent then Highlight:Destroy() end
      end
      table.clear(ManagedTargets)
    end

    return Profile
  end

  function Chams.EnableAll(): ()
    for _, Profile in pairs(Profiles) do
      Profile.Enabled.Value = true
    end
  end

  function Chams.DisableAll(): ()
    for _, Profile in pairs(Profiles) do
      Profile.Enabled.Value = false
    end
  end

  return Chams
end)()
-- Chams = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/chams.lua"))()

-- EnableAll / DisableAll / CreateCham -V-
-- AddInstance(Instance) / Remove(Instance) / Clear / AddPlayer(Player)

-- Enabled: bool / FillColor: Color3 / FillTransparency: number
-- OutlineColor: Color3 / OutlineTransparency: number
