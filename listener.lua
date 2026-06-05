return (function()
  local Listener = {}
  local Binds: { [Enum.KeyCode]: { Toggle } } = {}

  local InputService = game:GetService("UserInputService")

  type ToggleFunction = (locals: { [string]: any }) -> boolean?
  type Toggle = {
    Type: string,
    State: boolean,
    Cases: { [boolean]: ToggleFunction },
    Locals: { [string]: any },
    Turn: (self: Toggle, newState: boolean?) -> ()
  }

  for _, Connection in ipairs(getgenv().LISTENER_RBX_CONNECTIONS or {}) do
    Connection:Disconnect()
  end
  getgenv().LISTENER_RBX_CONNECTIONS = {}

  function Listener.CreateHoldToggle(
    enabledFunc: ToggleFunction,
    disabledFunc: ToggleFunction?,
    initFunc: ToggleFunction?,
    initState: boolean?
  ): Toggle
    local ToggleInstance: Toggle = {
      Type = "Hold",
      State = initState or false,
      Cases = {
        [true] = enabledFunc,
        [false] = disabledFunc
      },
      Locals = {}
    }

    function ToggleInstance:Turn(newState: boolean?)
      if newState == nil then return end
      self.State = newState

      local CurrentCallback = self.Cases[self.State]
      if CurrentCallback then
        local SetterState = CurrentCallback(self.Locals)
        if SetterState ~= nil then
          self.State = SetterState
        end
      end
    end

    if initFunc and initFunc(ToggleInstance.Locals) then
      ToggleInstance:Turn(true)
    end

    return ToggleInstance
  end

  function Listener.CreateToggle(
    onFunc: ToggleFunction,
    offFunc: ToggleFunction,
    initFunc: ToggleFunction?,
    initState: boolean?
  ): Toggle
    local ToggleInstance: Toggle = {
      Type = "Switch",
      State = initState or false,
      Cases = {
        [true] = onFunc,
        [false] = offFunc
      },
      Locals = {}
    }

    function ToggleInstance:Turn(newState: boolean?)
      self.State = newState or not self.State
      local SetterState = self.Cases[self.State](self.Locals)
      if SetterState ~= nil then
        self.State = SetterState
      end
    end

    if initFunc and initFunc(ToggleInstance.Locals) then
      ToggleInstance.State = true
      local SetterState = ToggleInstance.Cases[true](ToggleInstance.Locals)
      if SetterState ~= nil then
        ToggleInstance.State = SetterState
      end
    end

    return ToggleInstance
  end

  function Listener.BindKey(key: Enum.KeyCode, toggle: ToggleFunction): ()
    if not Binds[key] then Binds[key] = {} end
    table.insert(Binds[key], toggle)
  end

  function Listener.UnbindKey(key: Enum.KeyCode, toggle: ToggleFunction): ()
    local KeyList = Binds[key]
    if not KeyList then return end

    local index = table.find(KeyList, toggle)
    if index then
      table.remove(KeyList, index)
    end

    if #KeyList == 0 then
      Binds[key] = nil
    end
  end

  function Listener.UnbindAll(): ()
    table.clear(Binds)
  end

  local function handleInput(input: InputObject, processed: boolean, isBegan: boolean): ()
    if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local KeyList = Binds[input.KeyCode]
    if not KeyList then return end

    for i = 1, #KeyList do
      local Toggle = KeyList[i]

      if Toggle.Type == "Switch" then
        if isBegan then Toggle:Turn() end
      elseif Toggle.Type == "Hold" then
        Toggle:Turn(isBegan)
      end
    end
  end

  table.insert(getgenv().LISTENER_RBX_CONNECTIONS, InputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
    handleInput(input, processed, true)
  end))

  table.insert(getgenv().LISTENER_RBX_CONNECTIONS, InputService.InputEnded:Connect(function(input: InputObject, processed: boolean)
    handleInput(input, processed, false)
  end))

  return Listener
end)()
-- Flex = loadstring(game:HttpGet("https://github.com/DeadInsideDi/lua/raw/refs/heads/main/listener.lua"))()

-- CreateHoldToggle / CreateToggle
-- BindKey / UnbindKey / UnbindAll
