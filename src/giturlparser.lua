local giturlparser = {}

-- utils {

--- @param s string
--- @param t string
--- @param start integer?  by default start=1
--- @return integer?
giturlparser._find = function(s, t, start)
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

-- utils }

-- 'path' is all payload after 'host', e.g. 'org/repo'.
--
--- @alias giturlparser.GitUrlInfo {protocol:string?,user:string?,password:string?,host:string?,port:integer?,org:string?,repo:string,path:string}
local GitUrlInfo = {}

--- @param url string
--- @return giturlparser.GitUrlInfo?, string?
giturlparser.parse = function(url)
  if type(url) ~= "string" or string.len(url) == 0 then
    return nil, "empty string"
  end

  local protocol = nil
  local user = nil
  local password = nil
  local host = nil
  local port = nil
  local org = nil
  local repo = nil
  local path = nil

  local protocol_delimiter_end_pos = giturlparser._find(url, "://")
  if
    type(protocol_delimiter_end_pos) == "number"
    and protocol_delimiter_end_pos > 1
  then
    protocol = string.sub(url, 1, protocol_delimiter_end_pos - 1)
  end
end

return giturlparser
