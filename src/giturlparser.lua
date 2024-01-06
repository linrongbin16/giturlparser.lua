local M = {}

-- utils {

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
--- @alias giturlparser.GitUrlInfo {protocol:string?,protocol_pos:giturlparser.GitUrlPos?,user:string?,user_pos:giturlparser.GitUrlPos?,password:string?,password_pos:giturlparser.GitUrlPos?,host:string?,host_pos:giturlparser.GitUrlPos?,org:string?,org_pos:giturlparser.GitUrlPos?,repo:string,repo_pos:giturlparser.GitUrlPos,path:string,path_pos:giturlparser.GitUrlPos}
local GitUrlInfo = {}

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

--- @param url string
--- @return giturlparser.GitUrlInfo?, string?
M.parse = function(url)
  if type(url) ~= "string" or string.len(url) == 0 then
    return nil, "empty string"
  end

  local protocol = nil
  local protocol_pos = nil
  local user = nil
  local user_pos = nil
  local password = nil
  local password_pos = nil
  local host = nil
  local host_pos = nil
  local org = nil
  local org_pos = nil
  local repo = nil
  local repo_pos = nil
  local path = nil
  local path_pos = nil

  local protocol_delimiter_pos = M._find(url, "://")
  if
    type(protocol_delimiter_pos) == "number" and protocol_delimiter_pos > 1
  then
    protocol = string.sub(url, 1, protocol_delimiter_pos - 1)
    -- https, ssh, file, sftp, etc
    local first_colon_pos = M._find(url, ":", protocol_delimiter_pos + 3)
    if
      type(first_colon_pos) == "number"
      and first_colon_pos > protocol_delimiter_pos + 3
    then
      -- ssh host end pos, or ssh user end pos
      local first_at_pos = M._find(url, "@", first_colon_pos + 1)
      if
        type(first_at_pos) == "number" and first_at_pos > first_colon_pos + 1
      then
        -- ssh password end pos
        local second_colon_pos = M._find(url, ":", first_at_pos + 1)
        if
          type(second_colon_pos) == "number"
          and second_colon_pos > first_at_pos + 1
        then
          -- host end with ':'
          host, host_pos = M._make(url, first_at_pos + 1, second_colon_pos - 1)
          password, password_pos =
            M._make(url, first_colon_pos + 1, first_at_pos - 1)
          user, user_pos =
            M._make(url, protocol_delimiter_pos + 3, first_colon_pos - 1)

          local last_slash_pos = M._rfind(url, "/")
          if
            type(last_slash_pos) == "number"
            and last_slash_pos > second_colon_pos + 1
          then
            repo, repo_pos = M._make(url, last_slash_pos + 1, string.len(url))
            org, org_pos =
              M._make(url, second_colon_pos + 1, last_slash_pos - 1)
            path, path_pos = M._make(url, second_colon_pos + 1, string.len(url))
          else
            repo, repo_pos = M._make(url, second_colon_pos + 1, string.len(url))
            path, path_pos = M._make(url, second_colon_pos + 1, string.len(url))
            -- missing org, org_pos
          end
        else
          local first_slash_pos = M._find(url, "/", first_at_pos + 1)
          if
            type(first_slash_pos) == "number"
            and first_slash_pos > first_at_pos + 1
          then
            -- host end with '/'
            host, host_pos = M._make(url, first_at_pos + 1, first_slash_pos - 1)
            password, password_pos =
              M._make(url, first_colon_pos + 1, first_at_pos - 1)
            user, user_pos =
              M._make(url, protocol_delimiter_pos + 3, first_colon_pos - 1)

            local last_slash_pos = M._rfind(url, "/")
            if
              type(last_slash_pos) == "number"
              and last_slash_pos > first_slash_pos + 1
            then
              repo, repo_pos = M._make(url, last_slash_pos + 1, string.len(url))
              org, org_pos =
                M._make(url, first_slash_pos + 1, last_slash_pos - 1)
              path, path_pos =
                M._make(url, first_slash_pos + 1, string.len(url))
            else
              repo, repo_pos =
                M._make(url, first_slash_pos + 1, string.len(url))
              path, path_pos =
                M._make(url, first_slash_pos + 1, string.len(url))
              -- missing org, org_pos
            end
          else
          end
        end
      else
        -- host end with ':'
        host, host_pos =
          M._make(url, protocol_delimiter_pos + 3, first_colon_pos - 1)
        -- missing user, password

        local last_slash_pos = M._rfind(url, "/")
        if
          type(last_slash_pos) == "number"
          and last_slash_pos > first_colon_pos + 1
        then
          repo, repo_pos = M._make(url, last_slash_pos + 1, string.len(url))
          org, org_pos = M._make(url, first_colon_pos + 1, last_slash_pos - 1)
          path, path_pos = M._make(url, first_colon_pos + 1, string.len(url))
        else
          repo, repo_pos = M._make(url, first_colon_pos + 1, string.len(url))
          path, path_pos = M._make(url, first_colon_pos + 1, string.len(url))
          -- missing org, org_pos
        end
      end
    else
    end
  else
    -- protocol is ommited, it's either ssh or local file path
  end
end

return M
