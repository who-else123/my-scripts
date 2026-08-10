local supportedGames = {
  [18687417158] = "https://raw.githubusercontent.com/who-else123/my-scripts/refs/heads/main/Syncsaken/main.lua"
}

local currentGame = supportedGames[game.PlaceId]
if currentGame then
  loadstring(game:HttpGet(currentGame))()
else
  warn("Your game isn't supported! Loading the universal aimbot instead...")
  loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/5b3ef80eb614b965fe0effe6f04e322f.lua"))()
end
