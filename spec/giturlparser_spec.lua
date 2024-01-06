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
      assert_eq(actual.user, nil)
      assert_eq(actual.user_pos, nil)
      assert_eq(actual.password, nil)
      assert_eq(actual.password_pos, nil)
      assert_eq(actual.host, "host.xz")
      assert_eq(actual.host_pos.start_pos, 8)
      assert_eq(actual.host_pos.end_pos, 14)
      assert_eq(actual.org, "path/to")
      assert_eq(actual.org_pos.start_pos, 16)
      assert_eq(actual.org_pos.end_pos, 22)
      assert_eq(actual.repo, "repo.git")
      assert_eq(actual.repo_pos.start_pos, 24)
      assert_eq(actual.repo_pos.end_pos, 31)
    end)
    it("http://host.xz/path/to/repo.git", function()
      local actual = giturlparser.parse("http://host.xz/path/to/repo.git")
      assert_eq(type(actual), "table")
      assert_eq(actual.protocol, "http")
      assert_eq(actual.protocol_pos.start_pos, 1)
      assert_eq(actual.protocol_pos.end_pos, 4)
      assert_eq(actual.user, nil)
      assert_eq(actual.user_pos, nil)
      assert_eq(actual.password, nil)
      assert_eq(actual.password_pos, nil)
      assert_eq(actual.host, "host.xz")
      assert_eq(actual.host_pos.start_pos, 8)
      assert_eq(actual.host_pos.end_pos, 14)
      assert_eq(actual.org, "path/to")
      assert_eq(actual.org_pos.start_pos, 16)
      assert_eq(actual.org_pos.end_pos, 22)
      assert_eq(actual.repo, "repo.git")
      assert_eq(actual.repo_pos.start_pos, 24)
      assert_eq(actual.repo_pos.end_pos, 31)
    end)
    it("https://host.xz/path/to/repo.git/", function()
      local actual = giturlparser.parse("https://host.xz/path/to/repo.git/")
      assert_eq(type(actual), "table")
      assert_eq(actual.protocol, "https")
      assert_eq(actual.protocol_pos.start_pos, 1)
      assert_eq(actual.protocol_pos.end_pos, 5)
      assert_eq(actual.user, nil)
      assert_eq(actual.user_pos, nil)
      assert_eq(actual.password, nil)
      assert_eq(actual.password_pos, nil)
      assert_eq(actual.host, "host.xz")
      assert_eq(actual.host_pos.start_pos, 9)
      assert_eq(actual.host_pos.end_pos, 15)
      assert_eq(actual.org, "path/to")
      assert_eq(actual.org_pos.start_pos, 17)
      assert_eq(actual.org_pos.end_pos, 23)
      assert_eq(actual.repo, "repo.git")
      assert_eq(actual.repo_pos.start_pos, 25)
      assert_eq(actual.repo_pos.end_pos, 32)
    end)
    it("https://host.xz/path/to/repo.git", function()
      local actual = giturlparser.parse("https://host.xz/path/to/repo.git")
      assert_eq(type(actual), "table")
      assert_eq(actual.protocol, "https")
      assert_eq(actual.protocol_pos.start_pos, 1)
      assert_eq(actual.protocol_pos.end_pos, 5)
      assert_eq(actual.user, nil)
      assert_eq(actual.user_pos, nil)
      assert_eq(actual.password, nil)
      assert_eq(actual.password_pos, nil)
      assert_eq(actual.host, "host.xz")
      assert_eq(actual.host_pos.start_pos, 9)
      assert_eq(actual.host_pos.end_pos, 15)
      assert_eq(actual.org, "path/to")
      assert_eq(actual.org_pos.start_pos, 17)
      assert_eq(actual.org_pos.end_pos, 23)
      assert_eq(actual.repo, "repo.git")
      assert_eq(actual.repo_pos.start_pos, 25)
      assert_eq(actual.repo_pos.end_pos, 32)
    end)
    it("https://git.samba.com/samba.git", function()
      local actual = giturlparser.parse("https://git.samba.com/samba.git")
      assert_eq(type(actual), "table")
      assert_eq(actual.protocol, "https")
      assert_eq(actual.protocol_pos.start_pos, 1)
      assert_eq(actual.protocol_pos.end_pos, 5)
      assert_eq(actual.user, nil)
      assert_eq(actual.user_pos, nil)
      assert_eq(actual.password, nil)
      assert_eq(actual.password_pos, nil)
      assert_eq(actual.host, "git.samba.com")
      assert_eq(actual.host_pos.start_pos, 9)
      assert_eq(actual.host_pos.end_pos, 21)
      assert_eq(actual.org, nil)
      assert_eq(actual.org_pos, nil)
      assert_eq(actual.repo, "samba.git")
      assert_eq(actual.repo_pos.start_pos, 23)
      assert_eq(actual.repo_pos.end_pos, 31)
    end)
    it("https://git.samba.com/samba.git/", function()
      local actual = giturlparser.parse("https://git.samba.com/samba.git/")
      assert_eq(type(actual), "table")
      assert_eq(actual.protocol, "https")
      assert_eq(actual.protocol_pos.start_pos, 1)
      assert_eq(actual.protocol_pos.end_pos, 5)
      assert_eq(actual.user, nil)
      assert_eq(actual.user_pos, nil)
      assert_eq(actual.password, nil)
      assert_eq(actual.password_pos, nil)
      assert_eq(actual.host, "git.samba.com")
      assert_eq(actual.host_pos.start_pos, 9)
      assert_eq(actual.host_pos.end_pos, 21)
      assert_eq(actual.org, nil)
      assert_eq(actual.org_pos, nil)
      assert_eq(actual.repo, "samba.git")
      assert_eq(actual.repo_pos.start_pos, 23)
      assert_eq(actual.repo_pos.end_pos, 31)
    end)
  end)
end)
