return (function()
  local Controller = {}

  local VirtualInputManager = game:GetService("VirtualInputManager")
  local GuiService = game:GetService("GuiService")

  if not getgenv().CreateCustomValue then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()
  end
  local CreateValue = getgenv().CreateCustomValue

  Controller.MoveTimeInterval = CreateValue(0.01)
  Controller.ClickTimeInterval = CreateValue(0.04)
  Controller.TapTimeInterval = CreateValue(0.03)
  Controller.ScrollTimeInterval = CreateValue(0.02)
  Controller.TypeTimeInterval = CreateValue(0.01)

  function Controller.Move(dx: number, dy: number): ()
    VirtualInputManager:SendMouseMoveDeltaEvent(dx, dy, game)
    task.wait(Controller.MoveTimeInterval.Value)
  end

  function Controller.Click(x: number, y: number): ()
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(Controller.ClickTimeInterval.Value)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    task.wait(Controller.ClickTimeInterval.Value)
  end

  function Controller.ClickGui(guiElement: GuiObject): ()
    local TargetX = guiElement.AbsolutePosition.X + (guiElement.AbsoluteSize.X / 2)
    local TargetY = guiElement.AbsolutePosition.Y + (guiElement.AbsoluteSize.Y / 2)
    TargetX += GuiService:GetGuiInset().X
    TargetY += GuiService:GetGuiInset().Y

    Controller.Click(TargetX, TargetY)
  end

  function Controller.Tap(keyCode: Enum.KeyCode): ()
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(Controller.TapTimeInterval.Value)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    task.wait(Controller.TapTimeInterval.Value)
  end

  function Controller.Scroll(scrollDelta: number, x: number?, y: number?): ()
    VirtualInputManager:SendMouseWheelEvent(x or 0, y or 0, scrollDelta, game)
    task.wait(Controller.ScrollTimeInterval.Value)
  end

  function Controller.Type(character: string): ()
    VirtualInputManager:SendTextInputCharacterEvent(character, game)
    task.wait(Controller.TypeTimeInterval.Value)
  end

  return Controller
end)()
-- Controller = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/controller.lua"))()

-- Move(number, number) / Click(number, number) / ClickGui(GuiObject)
-- Tap(Enum.KeyCode) / Scroll(number, number?, number?) / Type(string)
-- MoveTimeInterval: number / ClickTimeInterval: number / TapTimeInterval: number
-- ScrollTimeInterval: number / TypeTimeInterval: number
