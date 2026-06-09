return (function()
  local Chams = {}
  local Profiles = {}

  local CoreGui = game:GetService("CoreGui")

  for _, Connection in getgenv().CHAMS_RBX_CONNECTIONS or {} do
    Connection:Disconnect()
  end
  getgenv().CHAMS_RBX_CONNECTIONS = {}
  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  local ChamsFolder = CoreGui:FindFirstChild("Chams_Folder")
  if ChamsFolder then ChamsFolder:Destroy() end
  ChamsFolder = Instance.new("Folder", CoreGui)
  ChamsFolder.Name = "Chams_Folder"

  function Chams.CreateCham()
    local Profile = {}
    table.insert(Profiles, Profile)

    local function ApplyStyle(highlight: Highlight)
      highlight.Enabled = Profile.Enabled.Value
      highlight.FillColor = Profile.FillColor.Value
      highlight.FillTransparency = Profile.FillTransparency.Value
      highlight.OutlineColor = Profile.OutlineColor.Value
      highlight.OutlineTransparency = Profile.OutlineTrans.Value
    end

    local function UpdateAllStyles()
      for Target, Highlight in Profile.ManagedTargets do
        if Target.Parent and Highlight.Parent then
          ApplyStyle(Highlight)
        else
          Profile.ManagedTargets[Target] = nil
        end
      end
    end

    Profile.ManagedTargets = {}
    Profile.Enabled = CreateValue(false, UpdateAllStyles)
    Profile.FillColor = CreateValue(Color3.fromRGB(255, 0, 0), UpdateAllStyles)
    Profile.FillTransparency = CreateValue(0.75, UpdateAllStyles)
    Profile.OutlineColor = CreateValue(Color3.fromRGB(255, 255, 255), UpdateAllStyles)
    Profile.OutlineTrans = CreateValue(0.25, UpdateAllStyles)

    function Profile.AddInstance(instance: Instance): ()
      if not (instance:IsA("Model") or instance:IsA("BasePart")) then return end
      if Profile.ManagedTargets[instance] then return end

      local Highlight = Instance.new("Highlight", ChamsFolder)
      Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
      Highlight.Adornee = instance

      ApplyStyle(Highlight)
      Profile.ManagedTargets[instance] = Highlight
    end

    function Profile.AddPlayer(player: Player): ()
      if player.Character then
        Profile.AddInstance(player.Character)
      end

      table.insert(getgenv().CHAMS_RBX_CONNECTIONS, player.CharacterAdded:Connect(Profile.AddInstance))
      table.insert(getgenv().CHAMS_RBX_CONNECTIONS, player.CharacterRemoving:Connect(Profile.RemoveInstance))
    end

    function Profile.RemoveInstance(instance: Instance): ()
      local Highlight = Profile.ManagedTargets[instance]
      if Highlight then Highlight:Destroy() end
      Profile.ManagedTargets[instance] = nil
    end

    function Profile.Clear(): ()
      for _, Highlight in Profile.ManagedTargets do
        if Highlight then Highlight:Destroy() end
      end
      table.clear(Profile.ManagedTargets)
    end

    return Profile
  end

  function Chams.EnableAll(): ()
    for _, Profile in Profiles do
      Profile.Enabled.Value = true
    end
  end

  function Chams.DisableAll(): ()
    for _, Profile in Profiles do
      Profile.Enabled.Value = false
    end
  end

  return Chams
end)()
-- Chams = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/chams.lua"))()

-- EnableAll / DisableAll / CreateCham -V-
-- AddInstance(Instance) / AddPlayer(Player)
-- RemoveInstance(Instance) / Clear

-- Enabled: bool / FillColor: Color3 / FillTransparency: number
-- OutlineColor: Color3 / OutlineTransparency: number
