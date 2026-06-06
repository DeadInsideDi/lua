
return (function()
  local Debugger = {}

  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer
  local PlayerGui = Client:WaitForChild("PlayerGui")
  local Character = Client.Character or Client.CharacterAdded:Wait()
  local Root = Character:WaitForChild("HumanoidRootPart")
  local Camera = workspace.CurrentCamera

  local BillboardedInstances: {[string]: Instance} = {}
  local ScreenLabel: TextLabel
  local LifeTime = 10

  function Debugger.SetLifeTime(lifeTime: number): ()
    LifeTime = lifeTime ~= nil and lifeTime or LifeTime
  end

  local function IsCharacterPart(currentPart: Instance): boolean
    while currentPart and currentPart ~= workspace do
      if currentPart:FindFirstChildOfClass("Humanoid") then
        return true
      end
      currentPart = currentPart.Parent
    end

    return false
  end

  local function GetOrCreateScreenLabel(): TextLabel
    if ScreenLabel then return ScreenLabel end

    local GuiName = "Debugger_LookOverlay"
    local ScreenGui = PlayerGui:FindFirstChild(GuiName)

    if not ScreenGui then
      ScreenGui = Instance.new("ScreenGui", PlayerGui)
      ScreenGui.Name = GuiName
      ScreenGui.ResetOnSpawn = false
    end

    local Label = ScreenGui:FindFirstChild("LookedAtPartLabel")

    if not Label then
      Label = Instance.new("TextLabel", ScreenGui)
      Label.Name = "LookedAtPartLabel"
      Label.Size = UDim2.new(0.6, 0, 0.05, 0)
      Label.Position = UDim2.new(0.2, 0, 0.05, 0)
      Label.TextColor3 = Color3.fromRGB(255, 0, 0)
      Label.BorderColor3 = Color3.fromRGB(255, 255, 255)
      Label.TextScaled = true
      Label.Font = Enum.Font.SciFi
      Label.Text = "Nothing"
    end

    task.delay(LifeTime, function()
      if Label and Label.Parent then Label:Destroy() end
    end)

    ScreenLabel = Label
    return ScreenLabel
  end

  local function GetPositionOfModelOrPart(modelOrPart: Instance)
    local TargetPosition = nil

    if modelOrPart:IsA("BasePart") then
      TargetPosition = modelOrPart.Position
    elseif modelOrPart:IsA("Model") then
      TargetPosition = modelOrPart:GetPivot().Position
    end

    return TargetPosition
  end

  function Debugger.FindCloseInstances(distance: number, parent: Instance): {Instance}
    if parent == nil then parent = workspace end
    local Instances = {}

    for _, Ins in ipairs(parent:GetDescendants()) do
      if IsCharacterPart(Ins) or not (Ins:IsA("BasePart") or Ins:IsA("Model")) then continue end
      if (GetPositionOfModelOrPart(Ins) - Root.Position).magnitude < distance then
        table.insert(Instances, Ins)
      end
    end

    return Instances
  end

  function Debugger.PrintCloseParts(distance: number, parent: Instance)
    local Instances = Debugger.FindCloseInstances(distance, parent)
    local Models, Parts = {}, {}

    for _, Ins in pairs(Instances) do
      if Ins:IsA("Model") then
        table.insert(Models, Ins)
      else
        table.insert(Parts, Ins)
      end
    end

    print("=== Models:", #Models, "===========")
    for _, model in pairs(Models) do print(model.Name, model:GetFullName()) end
    print("=== Parts:", #Parts, "===========")
    for _, part in pairs(Parts) do print(part.Name, part:GetFullName()) end
  end

  local function GetRandomStudsOffset()
    return Vector3.new(math.random(0, 50)/100,math.random(0, 200)/100,math.random(0, 100)/1000)
  end

  local function GetRandomColor()
    return Color3.fromHSV(math.random(0, 359)/360, 1, 1)
  end

  local function CreateBillboard(parent: Instance, text: string, color: Color3, size: number)
    local Billboard = Instance.new("BillboardGui", parent)
    Billboard.Name = "Debug"
    Billboard.Size = UDim2.new(size or 1.4, 0, size or 1.4, 0)
    Billboard.StudsOffset = GetRandomStudsOffset()
    Billboard.AlwaysOnTop = true
    Billboard.MaxDistance = 120
    local TextLabel = Instance.new("TextLabel", Billboard)
    TextLabel.Text = text
    TextLabel.Font = Enum.Font.SciFi
    TextLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
    TextLabel.Position = UDim2.new(-0.125, 0, -0.25, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextScaled = true
    TextLabel.TextColor3 = if color ~= nil then color else GetRandomColor()

    task.delay(LifeTime, function()
      if Billboard and Billboard.Parent then Billboard:Destroy() end
    end)

    return Billboard
  end

  function Debugger.MarkPrintCloseParts(distance: number, parent: Instance, color: Color3)
    local Instances = Debugger.FindCloseInstances(distance, parent)

    for _, Ins in pairs(Instances) do
      if not BillboardedInstances[Ins:GetFullName()] then
        CreateBillboard(Ins, Ins.Name, color)
        BillboardedInstances[Ins:GetFullName()] = Ins
      end
    end
  end

  function Debugger.ShowNameOfLookedAtPart()
    local Label = GetOrCreateScreenLabel()
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude

    if Character then RayParams.FilterDescendantsInstances = {Character} end

    local CameraCFrame = Camera.CFrame
    local Origin = CameraCFrame.Position
    local Direction = CameraCFrame.LookVector * 500

    local Result = workspace:Raycast(Origin, Direction, RayParams)
    local Name = Result and Result.Instance and Result.Instance:GetFullName() or nil
    if Name then Label.Text = Result.Instance:GetFullName() end
    return Name
  end


  function Debugger.PrintRootPosition(leaveMark: boolean?): Vector3
    local Position = Root.Position
    print(Root.Name, 'at position:', Position)
    if leaveMark then
      local Part = Instance.new("Part", workspace)
      Part.Position = Position
      Part.Color = GetRandomColor()
      Part.Size = Vector3(1, 1, 1)
      Part.CanCollide = false
      Part.CanQuery = false
      Part.Anchored = true
      Part.Transparency = 0.5
      task.delay(LifeTime, function()
        if Part and Part.Parent then Part:Destroy() end
      end)
    end
    return Position
  end

  function Debugger.PrintTable(
    tableToPrint: table,
    indent: string?,
    sortKeys: boolean,
    sep: string?,
    keyValueFormat: string?
  ): string
    sep = sep ~= nil and sep or ","
    keyValueFormat = keyValueFormat ~= nil and keyValueFormat or "%*: %*"
    sortKeys = sortKeys or false
    indent = indent ~= nil and indent or "    "

    local function Serialize(value: any, lvl: number)
      if type(value) ~= "table" then return tostring(value) end

      local Keys={} for K in pairs(value) do Keys[#Keys+1] = K end
      if sortKeys then table.sort(Keys, function(A,B) return tostring(A)<tostring(B) end) end

      local P, Nxt = {}, lvl+1
      local Pre = indent and string.rep(indent, Nxt) or ""

      for _, Key in ipairs(Keys) do
        P[#P+1] = Pre..string.format(keyValueFormat, Key, Serialize(value[Key],Nxt))
      end

      local Inr = table.concat(P, sep)
      if indent == "" then return "{"..Inr.."}"  end
      local BPre = string.rep(indent, lvl)
      return "{\n"..Inr.."\n"..BPre.."}"
    end

    local serialized_table = Serialize(tableToPrint, 0)
    print(serialized_table)
    return serialized_table
  end


  return Debugger
end)()
-- Debugger = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/debugger.lua"))()

-- SetLifeTime(number) / FindCloseInstances(number, Instance)
-- PrintCloseParts(number, Instance) / MarkPrintCloseParts(number, Instance, Color3)
-- ShowNameOfLookedAtPart / PrintRootPosition
-- PrintTable(table, string, bool, string, string)
