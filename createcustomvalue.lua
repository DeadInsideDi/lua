return (function()
    local ValueMetaTable = {}

    ValueMetaTable.__index = function(self, key)
        if key == "Value" then return rawget(self, "_v")
        elseif key == "Changed" then return ValueMetaTable.Changed
        else return rawget(self, key) end
    end
    ValueMetaTable.__newindex = function(self, key, new)
        if rawget(self, key) == new then return end
        if key ~= "Value" then return rawset(self, key, new) else rawset(self, '_v', new) end
        for _, cb in ipairs(rawget(self, "_ls")) do cb(new) end
    end
    function ValueMetaTable:Changed(cb)
        local ls = rawget(self, "_ls")
        table.insert(ls, cb)
        return function()
            local i = table.find(ls, cb)
            if i then table.remove(ls, i) end
        end
    end

    local CreateCustomValue = function(initial, cb)
        return setmetatable({_v = initial, _ls = cb and {cb} or {}}, ValueMetaTable)
    end

    getgenv().CreateCustomValue = CreateCustomValue

  return CreateCustomValue
end)()
-- CreateCustomValue = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/createcustomvalue.lua"))()

-- CreateCustomValue(any, (any) -> ()) -> T
-- T.Value / T:Changed((any) -> ()) -> ()
