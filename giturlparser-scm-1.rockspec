package = "giturlparser"
version = "scm-1"
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
test_dependencies = {
  "inspect",
}
build = {
  type = "builtin",
  modules = {
    giturlparser = "src/giturlparser.lua",
  },
}
