return (function()
  local Controller = {}

  local VirtualInputManager = game:GetService("VirtualInputManager")
  local GuiService = game:GetService("GuiService")

  local MoveTimeInterval = 0.01
  local ClickTimeInterval = 0.04
  local TapTimeInterval = 0.03
  local ScrollTimeInterval = 0.02
  local TypeTimeInterval = 0.01

  function Controller.Move(dx: number, dy: number): ()
    VirtualInputManager:SendMouseMoveDeltaEvent(dx, dy, game)
    task.wait(MoveTimeInterval)
  end


  function Controller.Click(x: number, y: number): ()
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(ClickTimeInterval)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    task.wait(ClickTimeInterval)
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
    task.wait(TapTimeInterval)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    task.wait(TapTimeInterval)
  end

  function Controller.Scroll(scrollDelta: number, x: number?, y: number?): ()
    VirtualInputManager:SendMouseWheelEvent(x or 0, y or 0, scrollDelta, game)
    task.wait(ScrollTimeInterval)
  end

  function Controller.Type(character: string): ()
    VirtualInputManager:SendTextInputCharacterEvent(character, game)
    task.wait(TypeTimeInterval)
  end

  function Controller.SetMoveTimeInterval(value: number): ()
    MoveTimeInterval = type(value) == "number" and value or MoveTimeInterval
  end

  function Controller.SetClickTimeInterval(value: number): ()
    ClickTimeInterval = type(value) == "number" and value or ClickTimeInterval
  end

  function Controller.SetTapTimeInterval(value: number): ()
    TapTimeInterval = type(value) == "number" and value or TapTimeInterval
  end

  function Controller.SetScrollTimeInterval(value: number): ()
    ScrollTimeInterval = type(value) == "number" and value or ScrollTimeInterval
  end

  function Controller.SetTypeTimeInterval(value: number): ()
    TypeTimeInterval = type(value) == "number" and value or TypeTimeInterval
  end


  return Controller
end)()
-- Controller = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/controller.lua"))()

-- Move(number, number) / Click(number, number) / ClickGui(GuiObject)
-- Tap(Enum.KeyCode) / Scroll(number, number?, number?) / Type(string)
-- SetMoveTimeInterval(number) / SetClickTimeInterval(number) / SetTapTimeInterval(number)
-- SetScrollTimeInterval(number) / SetTypeTimeInterval(number)
