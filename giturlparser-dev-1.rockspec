package = "giturlparser"
version = "dev-1"
source = {
  url = "git+https://github.com/linrongbin16/giturlparser.lua.git",
}
description = {
  summary = "Pure Lua implemented git URL parsing library.",
  detailed = "Pure Lua implemented git URL parsing library.",
  homepage = "https://github.com/linrongbin16/giturlparser.lua",
  license = "MIT",
}
dependencies = {
}
build = {
  type = "builtin",
  modules = {
    giturlparser = "giturlparser.lua",
  },
}
