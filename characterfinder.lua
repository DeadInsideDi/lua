return (function ()
  local RunService = game:GetService("RunService")
  local Camera = workspace.CurrentCamera
  getgenv().CharacterFinderRunned = true

  RunService:UnbindFromRenderStep("CharacterFinder")
  RunService:BindToRenderStep("CharacterFinder", Enum.RenderPriority.Last.Value, function()
    local Counts, MaxCount, PossibleCharacter = {}, 0, nil
    local Parts = workspace:GetPartBoundsInRadius(Camera.CFrame.Position, 0.1)
    local FocusParts = workspace:GetPartBoundsInRadius(Camera.Focus.Position, 0.1)
    table.move(FocusParts, 1, #FocusParts, #Parts + 1, Parts)

    for _, Part in Parts do
      local Model = Part:FindFirstAncestorOfClass("Model")
      if Model then Counts[Model] = (Counts[Model] or 0) + 1 end
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
