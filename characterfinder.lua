return (function ()
  local RunService = game:GetService("RunService")
  local Camera = workspace.CurrentCamera
  local Players = game:GetService("Players")
  local Client = Players.LocalPlayer

  getgenv().CharacterFinderRunned = true

  RunService:UnbindFromRenderStep("CharacterFinder")
  RunService:BindToRenderStep("CharacterFinder", Enum.RenderPriority.Last.Value, function()
    if Client.Character then
      getgenv().Character = Client.Character
      return
    end
    local Counts, MaxCount, PossibleCharacter = {}, 0, nil
    local Parts = workspace:GetPartBoundsInRadius(Camera.CFrame.Position, 0.01)
    local FocusParts = workspace:GetPartBoundsInRadius(Camera.Focus.Position, 0.01)
    table.move(FocusParts, 1, #FocusParts, #Parts + 1, Parts)

    for _, Part in Parts do
      if Part.Size.Magnitude < 10 then
        local Model = Part:FindFirstAncestorOfClass("Model")
        if Model then Counts[Model] = (Counts[Model] or 0) + 1 end
      end
    end

    for Model, Count in Counts do
      if Count > MaxCount then
        MaxCount = Count
        PossibleCharacter = Model
      end
    end

    getgenv().Character = PossibleCharacter
  end)
end)()
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/DeadInsideDi/lua/main/characterfinder.lua"))()
