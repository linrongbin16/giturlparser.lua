describe("giturlparser", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function() end)

  local giturlparser = require("giturlparser")
  describe("[http(s)]", function()
    it("http://host.xz/path/to/repo.git/", function()
      local actual = giturlparser.parse("http://host.xz/path/to/repo.git/")
      assert_eq(type(actual), "table")
      assert_eq(actual.protocol, "http")
      assert_eq(actual.protocol_pos.start_pos, 1)
      assert_eq(actual.protocol_pos.end_pos, 4)
    end)
    it("https://host.xz/path/to/repo.git/", function()
      local actual = giturlparser.parse("https://host.xz/path/to/repo.git/")
      assert_eq(type(actual), "table")
      assert_eq(actual.protocol, "https")
      assert_eq(actual.protocol_pos.start_pos, 1)
      assert_eq(actual.protocol_pos.end_pos, 5)
    end)
  end)
end)
