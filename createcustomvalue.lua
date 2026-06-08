return (function()
    local ValueMetaTable = {}

    ValueMetaTable.__index = function(self, key)
        if key == "Value" then return rawget(self, "_value")
        elseif key == "Changed" then return ValueMetaTable.Changed
        else return rawget(self, key) end
    end
    ValueMetaTable.__newindex = function(self, key, new)
        if rawget(self, key) == new then return end
        rawset(self, key, new) if key ~= "Value" then return end
        for _, cb in ipairs(rawget(self, "_listeners")) do cb(new) end
    end
    function ValueMetaTable:Changed(cb)
        local ls = rawget(self, "_listeners")
        table.insert(ls, cb)
        return function()
            local i = table.find(ls, cb)
            if i then table.remove(ls, i) end
        end
    end

    local CreateCustomValue = function(initial, cb)
        return setmetatable({_value = initial, _listeners = {cb}}, ValueMetaTable)
    end

    getgenv().CreateCustomValue = CreateCustomValue

  return CreateCustomValue
end)()
-- CreateCustomValue = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()

-- CreateCustomValue(any, (any) -> ()) -> T
-- T.Value / T:Changed((any) -> ()) -> ()
