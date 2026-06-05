return (function()
  local Controller = {}

  local VirtualInputManager = game:GetService("VirtualInputManager")
  local GuiService = game:GetService("GuiService")

  local GuiInset = GuiService:GetGuiInset()
  local GuiInsetX = GuiInset.X
  local GuiInsetY = GuiInset.Y
  local InputTimeInterval = 0.04

  function Controller.Click(x: number, y: number, withInset: boolean?): ()
    if withInset == nil then withInset = true end
    local TargetX = x + (if withInset then GuiInsetX else 0)
    local TargetY = y + (if withInset then GuiInsetY else 0)

    VirtualInputManager:SendMouseMoveEvent(TargetX, TargetY, game)
    task.wait(InputTimeInterval)
    VirtualInputManager:SendMouseButtonEvent(TargetX, TargetY, 0, true, game, 1)
    task.wait(InputTimeInterval)
    VirtualInputManager:SendMouseButtonEvent(TargetX, TargetY, 0, false, game, 1)
    task.wait(InputTimeInterval)
  end

  function Controller.ClickGui(guiElement: GuiObject): ()
    local TargetX = guiElement.AbsolutePosition.X + (guiElement.AbsoluteSize.X / 2)
    local TargetY = guiElement.AbsolutePosition.Y + (guiElement.AbsoluteSize.Y / 2)
    Controller.Click(TargetX, TargetY)
  end

  function Controller.Tap(keyCode: Enum.KeyCode): ()
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(InputTimeInterval)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    task.wait(InputTimeInterval)
  end

  return Controller
end)()
-- Controller = loadstring(game:HttpGet("https://pastebin.com/raw/tbQaB0X0"))()

-- click(number, number, withInset=True) / clickGui(GuiObject)
-- tap(Enum.KeyCode)