local function lua_loader (main, luarequire)

  local dirsep = string.match(package.config, "(.)")
  local maininfo = debug.getinfo(main, "S")
  local maindir = string.match(maininfo.source, "@(.*)" .. dirsep)
  main, maininfo = nil, nil

  local function newrequire (module)
    local _M -- set by callrequire()

    local function try (path)

      local function callrequire (loadstring)
        local success = false
        success, _M = pcall(luarequire, loadstring)
        return success
      end

      local prefix = ""
      if path then prefix = path .. "." end
      -- try to load it as a local module in this path
      for _,loadstring in ipairs({
        prefix .. module,
        prefix .. module .. ".init"
      }) do
        if callrequire(loadstring) then return true end
      end
      -- otherwise, try to load it as an npm module in this path, using the default starting points
      for _,loadstring in ipairs({
        prefix .. "node_modules." .. module .. "." .. "init",
        prefix .. "node_modules." .. module .. "." .. module
      }) do
        if callrequire(loadstring) then return true end
      end
      -- alas, just couldn't find it here
      return false
    end -- function try

    -- firstly, try to load it from just here in the source tree
    if try() then return _M end

    -- else, walk up the source tree and try to find it somewhere up there
    local paths, callinfo, calldir, loaddir = {}, debug.getinfo(2, "S")
    if callinfo then calldir = string.match(callinfo.source, "@(.*)" .. dirsep) end
    if calldir then loaddir = string.match(calldir, maindir .. dirsep .. "(.*)")
                           or string.match(calldir, "%."    .. dirsep .. "(.*)") end
    if loaddir then
      loaddir = string.gsub(loaddir, dirsep, ".")
      local path
      for dir in string.gmatch(loaddir, "[^%.]+") do
        if path then path = path .. "." .. dir
        else path = dir end
        if dir ~= "node_modules" then
          table.insert(paths, 1, path)
        end
      end
    end
    for _,path in ipairs(paths) do
      if try(path) then return _M end
    end
  end -- function newrequire

  return newrequire
end -- function lua_loader

-- initialise with some function that is in the project's main lua file,
-- so that we know what the top of the source tree is,
-- which is the point that the real require is looking at
local function init (main)
  -- prevent messing up the maindir once set
  if _LUA_LOADER then return end
  _LUA_LOADER = true
  -- replace the original require, but pass it in so that we can call it
  require = lua_loader(main, require)
  -- new require function all set up now; nothing to return 
end

return init
