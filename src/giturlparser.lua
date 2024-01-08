local M = {}

-- utils {

--- @param s string
--- @param t string
--- @param opts {ignorecase:boolean?}?
--- @return boolean
M._startswith = function(s, t, opts)
  assert(type(s) == "string")
  assert(type(t) == "string")

  opts = opts or { ignorecase = false }
  opts.ignorecase = type(opts.ignorecase) == "boolean" and opts.ignorecase
    or false

  if opts.ignorecase then
    return string.len(s) >= string.len(t) and s:sub(1, #t):lower() == t:lower()
  else
    return string.len(s) >= string.len(t) and s:sub(1, #t) == t
  end
end

--- @param s string
--- @param t string
--- @param opts {ignorecase:boolean?}?
--- @return boolean
M._endswith = function(s, t, opts)
  assert(type(s) == "string")
  assert(type(t) == "string")

  opts = opts or { ignorecase = false }
  opts.ignorecase = type(opts.ignorecase) == "boolean" and opts.ignorecase
    or false

  if opts.ignorecase then
    return string.len(s) >= string.len(t)
      and s:sub(#s - #t + 1):lower() == t:lower()
  else
    return string.len(s) >= string.len(t) and s:sub(#s - #t + 1) == t
  end
end

--- @param s string
--- @param t string
--- @param start integer?  by default start=1
--- @return integer?
M._find = function(s, t, start)
  assert(type(s) == "string")
  assert(type(t) == "string")

  start = start or 1
  for i = start, #s do
    local match = true
    for j = 1, #t do
      if i + j - 1 > #s then
        match = false
        break
      end
      local a = string.byte(s, i + j - 1)
      local b = string.byte(t, j)
      if a ~= b then
        match = false
        break
      end
    end
    if match then
      return i
    end
  end
  return nil
end

--- @param s string
--- @param t string
--- @param rstart integer?  by default rstart=#s
--- @return integer?
M._rfind = function(s, t, rstart)
  assert(type(s) == "string")
  assert(type(t) == "string")

  rstart = rstart or #s
  for i = rstart, 1, -1 do
    local match = true
    for j = 1, #t do
      if i + j - 1 > #s then
        match = false
        break
      end
      local a = string.byte(s, i + j - 1)
      local b = string.byte(t, j)
      if a ~= b then
        match = false
        break
      end
    end
    if match then
      return i
    end
  end
  return nil
end

-- utils }

-- 'path' is all payload after 'host', e.g. 'org/repo'.
--
--- @alias giturlparser.GitUrlPos {start_pos:integer?,end_pos:integer?}
--- @alias giturlparser.GitUrlInfo {protocol:string?,protocol_pos:giturlparser.GitUrlPos?,user:string?,user_pos:giturlparser.GitUrlPos?,password:string?,password_pos:giturlparser.GitUrlPos?,host:string?,host_pos:giturlparser.GitUrlPos?,port:string?,port_pos:giturlparser.GitUrlPos?,org:string?,org_pos:giturlparser.GitUrlPos?,repo:string?,repo_pos:giturlparser.GitUrlPos?,path:string?,path_pos:giturlparser.GitUrlPos?}
--
--- @param url string
--- @param start_pos integer
--- @param end_pos integer
--- @return string, giturlparser.GitUrlPos
M._make = function(url, start_pos, end_pos)
  --- @type giturlparser.GitUrlPos
  local pos = {
    start_pos = start_pos,
    end_pos = end_pos,
  }
  local component = string.sub(url, start_pos, end_pos)
  return component, pos
end

--- @alias giturlparser._GitUrlPath {org:string?,org_pos:giturlparser.GitUrlPos?,repo:string?,repo_pos:giturlparser.GitUrlPos?,path:string?,path_pos:giturlparser.GitUrlPos?}
--
--- @param p string
--- @param start integer
--- @return giturlparser._GitUrlPath
M._make_path = function(p, start)
  assert(type(start) == "number")

  local endswith_slash = M._endswith(p, "/")

  local org = nil
  local org_pos = nil
  local repo = nil
  local repo_pos = nil
  local path = nil
  local path_pos = nil
  local plen = string.len(p)

  local last_slash_pos = M._rfind(p, "/", endswith_slash and plen - 1 or plen)
  if
    type(last_slash_pos) == "number"
    and last_slash_pos > start
    and last_slash_pos < plen
  then
    org, org_pos = M._make(p, start, last_slash_pos - 1)
    repo, repo_pos =
      M._make(p, last_slash_pos, endswith_slash and plen - 1 or plen)
  else
    -- no slash found, only 1 path component
    repo, repo_pos = M._make(p, start, endswith_slash and plen - 1 or plen)
  end
  path, path_pos = M._make(p, start, plen)

  return {
    org = org,
    org_pos = org_pos,
    repo = repo,
    repo_pos = repo_pos,
    path = path,
    path_pos = path_pos,
  }
end

--- @alias giturlparser._GitUrlHost {host:string?,host_pos:giturlparser.GitUrlPos?,port:string?,port_pos:giturlparser.GitUrlPos?,path_obj:giturlparser._GitUrlPath}
--
--- @param p string
--- @param start integer
--- @return giturlparser._GitUrlHost
M._make_host = function(p, start)
  assert(type(start) == "number")
  assert(not M._startswith(p, "/"))
  assert(not M._endswith(p, "/"))

  local host = nil
  local host_pos = nil
  local port = nil
  local port_pos = nil
  --- @type giturlparser._GitUrlPath
  local path_obj = {}

  local plen = string.len(p)

  -- find ':', the end position of host, start position of port
  local first_colon_pos = M._find(p, ":", start)
  if type(first_colon_pos) == "number" and first_colon_pos > start then
    -- host end with ':', port start with ':'
    host, host_pos = M._make(p, 1, first_colon_pos - 1)

    -- find first slash '/' (after second ':'), the end position of port, start position of path
    local first_slash_pos = M._find(p, "/", first_colon_pos + 1)
    if
      type(first_slash_pos) == "number"
      and first_slash_pos > first_colon_pos + 1
    then
      -- port end with '/'
      port, port_pos = M._make(p, first_colon_pos + 1, first_slash_pos - 1)
      path_obj = M._make_path(p, first_slash_pos)
    else
      -- path not found, port end until url end
      port, port_pos = M._make(p, first_colon_pos + 1, plen)
    end
  else
    -- port not found, host (highly possibly) end with '/'

    -- find first slash '/', the end position of host, start position of path
    local first_slash_pos = M._find(p, "/", start)
    if type(first_slash_pos) == "number" and first_slash_pos > start then
      -- host end with '/'
      host, host_pos = M._make(p, start, first_slash_pos - 1)
      path_obj = M._make_path(p, first_slash_pos)
    else
      -- first slash not found, host end until url end
      host, host_pos = M._make(p, start, plen)
    end
  end

  return {
    host = host,
    host_pos = host_pos,
    port = port,
    port_pos = port_pos,
    path_obj = path_obj,
  }
end

--- @alias giturlparser._GitUrlUser {user:string?,user_pos:giturlparser.GitUrlPos?,password:string?,password_pos:giturlparser.GitUrlPos?,host_obj:giturlparser._GitUrlHost}
--
--- @param p string
--- @param start integer
--- @return giturlparser._GitUrlUser
M._make_user = function(p, start)
  assert(type(start) == "number")
  assert(not M._startswith(p, "/"))
  assert(not M._endswith(p, "/"))

  local user = nil
  local user_pos = nil
  local password = nil
  local password_pos = nil
  --- @type giturlparser._GitUrlHost
  local host_obj = {}

  local plen = string.len(p)

  local host_start_pos = 1

  -- find first '@', the end position of user and password
  local first_at_pos = M._find(p, "@", start)
  if type(first_at_pos) == "number" and first_at_pos > start then
    -- user (and password) end with '@'

    -- find first ':' (before '@'), the end position of password
    local first_colon_pos = M._find(p, ":", start)
    if
      type(first_colon_pos) == "number"
      and first_colon_pos > start
      and first_colon_pos < first_at_pos
    then
      -- password end with ':'
      user, user_pos = M._make(p, start, first_colon_pos - 1)
      password, password_pos = M._make(p, first_colon_pos + 1, first_at_pos - 1)
    else
      -- password not found, user end with '@'
      user, user_pos = M._make(p, start, first_at_pos - 1)
    end

    -- host start from '@', user (and password) end position
    host_start_pos = first_at_pos + 1
  else
    -- user (and password) not found
    -- host start from beginning
  end

  host_obj = M._make_host(p, host_start_pos)

  return {
    user = user,
    user_pos = user_pos,
    password = password,
    password_pos = password_pos,
    host_obj = host_obj,
  }
end

--- @param url string
--- @return giturlparser.GitUrlInfo?, string?
M.parse = function(url)
  if type(url) ~= "string" or string.len(url) == 0 then
    return nil, "empty string"
  end

  if M._endswith(url, "/") then
    url = string.sub(url, 1, #url - 1)
  end

  -- find first '://', the end position of protocol
  local protocol_delimiter_pos = M._find(url, "://")
  if
    type(protocol_delimiter_pos) == "number" and protocol_delimiter_pos > 1
  then
    -- protocol end with '://'
    local protocol, protocol_pos = M._make(url, 1, protocol_delimiter_pos - 1)

    local user_obj = M._make_user(url, protocol_delimiter_pos + 3)
    local host_obj = user_obj.host_obj
    local path_obj = host_obj.path_obj

    return {
      protocol = protocol,
      protocol_pos = protocol_pos,

      -- user
      user = user_obj.user,
      user_pos = user_obj.user_pos,
      password = user_obj.password,
      password_pos = user_obj.password_pos,

      -- host
      host = host_obj.host,
      host_pos = host_obj.host_pos,
      port = host_obj.port,
      port_pos = host_obj.port_pos,

      -- path
      org = path_obj.org,
      org_pos = path_obj.org_pos,
      repo = path_obj.repo,
      repo_pos = path_obj.repo_pos,
      path = path_obj.path,
      path_pos = path_obj.path_pos,
    }
  else
    -- protocol not found, either ssh/local file path

    -- find first '@', user (and password) end position
    local first_at_pos = M._find(url, "@")
    if type(first_at_pos) == "number" and first_at_pos > 1 then
      local user_obj = M._make_user(url, 1)
      local host_obj = user_obj.host_obj
      local path_obj = host_obj.path_obj

      return {
        -- no protocol

        -- user
        user = user_obj.user,
        user_pos = user_obj.user_pos,
        password = user_obj.password,
        password_pos = user_obj.password_pos,

        -- host
        host = host_obj.host,
        host_pos = host_obj.host_pos,
        port = host_obj.port,
        port_pos = host_obj.port_pos,

        -- path
        org = path_obj.org,
        org_pos = path_obj.org_pos,
        repo = path_obj.repo,
        repo_pos = path_obj.repo_pos,
        path = path_obj.path,
        path_pos = path_obj.path_pos,
      }
    else
      -- user not found

      -- find first ':', host end position, port start position
      local first_colon_pos = M._find(url, ":")
      if type(first_colon_pos) == "number" and first_colon_pos > 1 then
        -- host end with ':', port start with ':'

        local host_obj = M._make_host(url, 1)
        local path_obj = host_obj.path_obj
        return {
          -- no protocol
          -- no user

          -- host
          host = host_obj.host,
          host_pos = host_obj.host_pos,
          port = host_obj.port,
          port_pos = host_obj.port_pos,

          -- path
          org = path_obj.org,
          org_pos = path_obj.org_pos,
          repo = path_obj.repo,
          repo_pos = path_obj.repo_pos,
          path = path_obj.path,
          path_pos = path_obj.path_pos,
        }
      else
        -- port not found, treat as path, either absolute/relative

        local path_obj = M._make_path(url, 1)
        return {
          -- no protocol
          -- no user
          -- no host

          -- path
          org = path_obj.org,
          org_pos = path_obj.org_pos,
          repo = path_obj.repo,
          repo_pos = path_obj.repo_pos,
          path = path_obj.path,
          path_pos = path_obj.path_pos,
        }
      end
    end
  end
end

return M
