return (function()
  local FreeCam = {}

  local CoreGui = game:GetService("CoreGui")

  for _, Connection in getgenv().FREE_CAM_RBX_CONNECTIONS or {} do
    Connection:Disconnect()
  end
  getgenv().FREE_CAM_RBX_CONNECTIONS = {}

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  local FreeCamFolder = CoreGui:FindFirstChild("FreeCam_Folder")
  if FreeCamFolder then FreeCamFolder:Destroy() end
  FreeCamFolder = Instance.new("Folder", CoreGui)
  FreeCamFolder.Name = "FreeCam_Folder"

  local currentCamPart = nil
  local heartbeatConnection = nil
  local inputConnections = {}
  local camera = workspace.CurrentCamera
  local client = game.Players.LocalPlayer
  local uis = game:GetService("UserInputService")
  local runService = game:GetService("RunService")

  local mouseDelta = Vector2.new()
  local keysDown = {}

  local function stopFreeCam()
    if heartbeatConnection then
      heartbeatConnection:Disconnect()
      heartbeatConnection = nil
    end
    for _, conn in ipairs(inputConnections) do
      conn:Disconnect()
    end
    table.clear(inputConnections)

    if currentCamPart then
      currentCamPart:Destroy()
      currentCamPart = nil
    end

    local char = client.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
      camera.CameraSubject = char.Humanoid
    end
    uis.MouseIconEnabled = true
  end

  -- Heartbeat update
  local function onHeartbeat(deltaTime)
    if not currentCamPart then
      stopFreeCam()
      return
    end

    local speed = FreeCam.Speed.Value

    local move = Vector3.new()
    if keysDown[Enum.KeyCode.W] then move += Vector3.new(0, 0, -1) end
    if keysDown[Enum.KeyCode.S] then move += Vector3.new(0, 0, 1) end
    if keysDown[Enum.KeyCode.A] then move += Vector3.new(-1, 0, 0) end
    if keysDown[Enum.KeyCode.D] then move += Vector3.new(1, 0, 0) end
    if keysDown[Enum.KeyCode.E] then move += Vector3.new(0, 1, 0) end
    if keysDown[Enum.KeyCode.Q] then move += Vector3.new(0, -1, 0) end

    if move.Magnitude > 0 then
      move = move.Unit * speed * deltaTime
      currentCamPart.CFrame += currentCamPart.CFrame:VectorToWorldSpace(move)
    end

    if mouseDelta.X ~= 0 or mouseDelta.Y ~= 0 then
      local sensitivity = 0.01
      local yaw = -mouseDelta.X * sensitivity
      local pitch = -mouseDelta.Y * sensitivity
      currentCamPart.CFrame = currentCamPart.CFrame * CFrame.Angles(pitch, yaw, 0)
      mouseDelta = Vector2.new()
    end

    camera.CFrame = currentCamPart.CFrame
  end

  local function onInputBegan(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
      keysDown[input.KeyCode] = true
    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
      mouseDelta += input.Delta
    end
  end

  local function onInputEnded(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
      keysDown[input.KeyCode] = nil
    end
  end

  local function startFreeCam()
    stopFreeCam()

    local part = Instance.new("Part")
    part.Name = "FreeCamAnchor"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = FreeCamFolder

    local char = client.Character
    if char and char:FindFirstChild("Head") then
      part.CFrame = char.Head.CFrame
    else
      part.CFrame = camera.CFrame
    end
    currentCamPart = part
    camera.CameraSubject = part

    table.insert(inputConnections, uis.InputBegan:Connect(onInputBegan))
    table.insert(inputConnections, uis.InputEnded:Connect(onInputEnded))
    heartbeatConnection = runService.Heartbeat:Connect(onHeartbeat)

    uis.MouseIconEnabled = false
  end

  FreeCam.Speed = CreateValue(16)
  FreeCam.Enabled = CreateValue(false, function(newValue)
    if newValue then
      startFreeCam()
    else
      stopFreeCam()
    end
  end)

  function FreeCam.Destroy()
    stopFreeCam()
    FreeCam.Enabled.Value = false
    FreeCamFolder:Destroy()
  end

  return FreeCam
end)()
-- FreeCam = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/freecam.lua"))()

-- Enabled: bool / Speed: number
