package = "giturlparser"
source = {
   url = "https://github.com/linrongbin16/giturlparser.lua"
}
description = {
   summary = "Git URL parsing library for Lua, e.g. the output of `git remote get-url origin`.",
   homepage = "https://github.com/linrongbin16/giturlparser.lua",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
}
test_dependencies = {
   "busted >= 2.1",
}
build = {
   type = "builtin",
   modules = {
      giturlparser = "src/giturlparser.lua",
}
copy_directories = { "spec" }
