local r = require
require("../init")

assert(require == r, "requiring lua-loader again shouldn't replace the already loaded require function")
