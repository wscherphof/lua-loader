local luarequire
local mname = "node_modules"
local sep = string.match(package.config, "(.)")
local lastpath

local function fileExists(path)
  local file, exists = io.open(path), false
  if file then
    exists = true
    file:close()
  end
  return exists
end

local function loadModule (request, path)
  local prv = ""
  local dirs = {}
  for dir in path:gmatch("[^" .. sep .. "]+") do
    local nxt = dir
    if "" ~= prv then
      nxt = prv .. "." .. dir
    end
    local new
    if mname == dir then
      new = nxt
    else
      new = nxt .. "." .. mname
    end
    table.insert(dirs, 1, new .. "." .. request)
    prv = nxt
  end
  local files = {"init", request}
  for i, dir in ipairs(dirs) do
    for _, file in ipairs(files) do
      local path = dir:gsub("%.", sep)
      if fileExists(path .. sep .. file .. ".lua") then
        lastpath = path
        return luarequire(dir .. "." .. file)
      end
    end
  end
  return luarequire(request)
end

local function loadFile (request, path)
  while request:sub(1, 1) == "." do
    if request:sub(1, 3) == "../" then
      path = path:match("(.*)" .. sep)
      request = request:sub(4)
    else
      request = request:sub(3)
    end
  end
  local filepath = ""
  if path then
    filepath = path .. sep
  end
  filepath = filepath .. request:gsub("/", sep)
  if fileExists(filepath .. ".lua") then
    lastpath = path
    return luarequire(filepath:gsub(sep, "."))
  end
  return luarequire(request)
end

local function newrequire (request)
  local source = debug.getinfo(2, "S").source
  local path = source:match("@%." .. sep .. "(.*)" .. sep) or mname
  if source == "=[C]" then
    path = lastpath
  end
  if request:sub(1, 1) == "." then
    return loadFile(request, path)
  else
    return loadModule(request, path)
  end
end

if not package.loaded["lua-loader"] then
  package.loaded["lua-loader"] = true
  luarequire = require
  require = newrequire
end
