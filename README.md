# lua-loader

Make require() in lua to load lua npm packages as lua modules

## Usage

### 1. Install
In the root of your project, `npm install lua-loader`

### 2. Initialise
At the start of the main lua file in your project, load lpm once:
```lua
require("node_modules.lua-loader.init")(function() end)
```
(It's initialised a bit magically with a dummy function that will point it to where the root of the project is.
Don't worry, just type it as above, and aftwerwards everything will look just normal)

### 3. Require what you need
Install the lua npm package you want to use in your project, eg. `npm install lua-eventemitter`.
This will install the package as expected in `./node_modules/lua-eventemitter`.
You can now just:
```lua
local EventEmitter = require("lua-eventemitter")
```
And then just use the module for what it's useful for, eg:
```lua
local myObj = EventEmitter:new({text = "Hello, world!"})
function myObj:talk ()
  self:emit("spoken", self:text)
end
myObj:on("spoken", function (text)
  print("myObj said", text)
end)
myObj:talk()
```

## Limitations
- Doesn't read the `package.json`. So won't respect the `main` entry in there. Tries to load `./init.lua` or else `./<package name>.lua` and that's it.

