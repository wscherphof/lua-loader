# lua-loader

Make require() in lua to load lua [npm](http://npmjs.org) packages as lua modules

## Usage

### 0. npm
Download and install [Node.js](http://nodejs.org/download/). Then you have `npm`

### 1. Install
In the root of your project, `npm install lua-loader`

### 2. Initialise
In the main lua file in your project:
```lua
require("node_modules.lua-loader.init")
```

### 3. Have fun

#### Require modules
Install the lua npm package you want to use in your project, eg. `npm install lua-events`.
This will install the package as expected in `./node_modules/lua-events`.
You can now just:
```lua
local EventEmitter = require("lua-events").EventEmitter
```
And then just use the module for what it's useful for, eg:
```lua
local myObj = EventEmitter:new({text = "Hello, world!"})
function myObj:talk ()
  self:emit("spoken", self.text)
end
myObj:on("spoken", function (text)
  print("myObj said", text)
end)
myObj:talk()
```

#### Require source files
Suppuse the following directory structue:
```
project-root
├── init.lua
├─┬ lib
│ └── foo.lua
└─┬ tests
  ├── init.lua
  └── test-1.lua
```
- From `init.lua` you can load `lib/foo.lua` with:
```lua
require("./lib/foo")
```
- From `tests/init.lua` you can load `tests/test-1.lua` with:
```lua
require("./test-1")
```
- From `tests/init.lua` you can load `lib/foo.lua` with:
```lua
require("../lib/foo")
```

## Limitations
- Doesn't read the `package.json`. So won't respect the `main` entry in there. Tries to load `./init.lua` or else `./<package name>.lua` and that's it.

## License
[LGPL+](https://github.com/wscherphof/lua-loader/blob/master/LICENSE.md)
