return (function()
  local IMAGE_URL_TO_KEY = {
    ["rbxassetid://153287108"] = Enum.KeyCode.W,
    ["rbxassetid://153287191"] = Enum.KeyCode.A,
    ["rbxassetid://13360801719"] = Enum.KeyCode.S,
    ["rbxassetid://153287088"] = Enum.KeyCode.D
  }

  local Solver = {}

  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")

  local Client = Players.LocalPlayer
  local Character = Client.Character or Client.CharacterAdded:Wait()
  local Root = Character:WaitForChild("HumanoidRootPart")
  local PlayerGui = Client:WaitForChild("PlayerGui")

  local TasksFrame = PlayerGui.UI_MAIN.Tasks
  local WirePanel = TasksFrame.WirePanel
  local Sequence = TasksFrame.Sequence
  local Memory = TasksFrame.Memory
  local HoldPressure = TasksFrame.HoldPressure
  local SendData = TasksFrame.SendData

  function Solver.SolveWirePanel(Controller): ()
    if not WirePanel.Visible then return end
    local LeftButtons = {}
    local RightButtons = {}

    for _, Frame in ipairs(WirePanel.Left:GetChildren()) do
      if Frame:IsA("TextButton") then
        LeftButtons[tostring(Frame.BackgroundColor3)] = Frame
      end
    end

    for _, Frame in ipairs(WirePanel.Right:GetChildren()) do
      if Frame:IsA("TextButton") then
        RightButtons[tostring(Frame.BackgroundColor3)] = Frame
      end
    end

    for ColorStr, LeftBtn in pairs(LeftButtons) do
      local RightBtn = RightButtons[ColorStr]
      if RightBtn then
        Controller.ClickGui(LeftBtn)
        Controller.ClickGui(RightBtn)
      end
    end
  end

  function Solver.SolveSequence(Controller): ()
    if not Sequence.Visible then return end
    Root.Anchored = true
    for _, Frame in ipairs(Sequence.SequenceFrame:GetChildren()) do
      if Frame:IsA("ImageLabel") then
        Controller.Tap(IMAGE_URL_TO_KEY[Frame.Image])
      end
    end
    Root.Anchored = false
  end

  function Solver.SolveMemory(Controller): ()
    if not Memory.Visible then return end
    print(Memory.NumberSequence.Text)
    -- for _, v in ipairs(Sequence.SequenceFrame:GetChildren()) do
    --   if v:IsA("ImageLabel") then
    --     Controller.Tap(IMAGE_URL_TO_KEY[v.Image])
    --   end
    -- end

    for _, Button in ipairs(Memory['Buttons']:GetChildren()) do
      print(Button, Button.ClassName)
    end
  end

  function Solver.SolveHoldPressure(Controller): ()
    if not HoldPressure.Visible then return end

    local Bar = HoldPressure.Bar
    local Current, Objetive = Bar.Current, Bar.Objetive
    local BindName = "Solver_SolveHoldPressure"

    RunService:UnbindFromRenderStep(BindName)
    RunService:BindToRenderStep(BindName, Enum.RenderPriority.Camera.Value, function()
      if not HoldPressure.Visible then
        RunService:UnbindFromRenderStep(BindName)
        return
      end

      if Current.AbsolutePosition.Y > Objetive.AbsolutePosition.Y then
        Controller.Tap(Enum.KeyCode.Space)
      end
    end)

  end

  function Solver.SolveSendData(Controller): ()
    if not HoldPressure.Visible then return end
    -- SendData.LogIn.Code
    -- SendData.LogIn.Send

    local targetFolder = workspace:WaitForChild("Map").Rooms.Security.SendDataComputer.Main
  
    -- for _, v in ipairs(targetFolder:GetDescendants()) do
    --   if (v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton")) and v.Text == text then
    --     print("[FOUND TEXT]:", v:GetFullName())
    --     return v
    --   elseif v:IsA("StringValue") and v.Value == text then
    --     print("[FOUND VALUE]:", v:GetFullName())
    --     return v
    --   end
    -- end
    
    print("Target text not found inside Main computer descendants.")
    return nil

  end

  function Solver.Solve(Controller): ()
    Solver.SolveWirePanel(Controller)
    Solver.SolveSequence(Controller)
    Solver.SolveMemory(Controller)
    Solver.SolveHoldPressure(Controller)
    Solver.SolveSendData(Controller)
  end

  return Solver
end)()
-- Solver = loadstring(game:HttpGet("https://github.com/DeadInsideDi/lua/raw/refs/heads/main/game-spec/controlsolver.lua"))()

-- SolveSequence(Controller) / SolveWirePanel(Controller)
-- SolveMemory(Controller) / SolveHoldPressure(Controller)
-- SolveSendData(Controller) / Solve(Controller) <- Universal
