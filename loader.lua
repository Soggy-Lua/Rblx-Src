-- loader.lua

local baseUrl = "https://raw.githubusercontent.com/Soggy-Lua/Rblx-Src/refs/heads/main/"

loadstring(game:HttpGet(baseUrl .. "init.lua", true))()

loadstring(game:HttpGet(baseUrl .. "main.lua", true))()
