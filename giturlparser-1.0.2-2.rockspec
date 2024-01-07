package = "giturlparser"
version = "1.0.2-2"
source = {
  url = "git+https://github.com/linrongbin16/giturlparser.lua.git",
}
description = {
  summary = "Pure Lua implemented git URL parsing library.",
  homepage = "https://github.com/linrongbin16/giturlparser.lua",
  license = "MIT",
}
dependencies = {
  "lua >= 5.1, luajit >= 2.0.0",
}
build = {
  type = "builtin",
  modules = {
    giturlparser = "src/giturlparser.lua",
  },
}
