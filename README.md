# giturlparser.lua

<a href="https://luarocks.org/modules/linrongbin16/giturlparser"><img alt="luarocks" src="https://custom-icon-badges.demolab.com/luarocks/v/linrongbin16/giturlparser?label=LuaRocks&labelColor=2C2D72&logo=tag&logoColor=fff&color=blue" /></a>
<a href="https://github.com/linrongbin16/giturlparser.lua/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/giturlparser.lua/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>

Pure Lua implemented git URL parsing library, e.g. the output of `git remote get-url origin`.

## Features

- [ ] Single file & zero dependency.
- [ ] Support lua >= 5.1, luajit >= 2.0.0.
- [ ] Compatible with RFC 3689.

## Install

`luarocks install giturlparser`

## API

### `giturlparser.GitUrlPos`

The string index of a component.

```lua
--- @alias giturlparser.GitUrlPos {start_pos:integer?,end_pos:integer?}
```

It contains below fields:

- `start_pos`: Start string index.
- `end_pos`: End string index.

### `giturlparser.GitUrlInfo`

Parsed information.

```lua
--- @alias giturlparser.GitUrlInfo {protocol:string?,protocol_pos:giturlparser.GitUrlPos?,user:string?,user_pos:giturlparser.GitUrlPos?,password:string?,password_pos:giturlparser.GitUrlPos?,host:string?,host_pos:giturlparser.GitUrlPos?,org:string?,org_pos:giturlparser.GitUrlPos?,repo:string,repo_pos:giturlparser.GitUrlPos,path:string,path_pos:giturlparser.GitUrlPos}
```

It contains below fields:

- `protocol`: Protocol, e.g. `http` (`http://`), `https` (`https://`), `ssh` (`ssh://`), `file` (`file://`).
- `protocol_pos`: Protocol position.
- `user`: User name, e.g. `username` in `ssh://username@githost.com`.
- `user_pos`: User name position.
- `password`: Password, e.g. `password` in `ssh://username:password@githost.com`.
- `password_pos`: Password position.
- `host`: Host name, e.g. `githost.com` in `ssh://githost.com`.
- `host_pos`: Host name position.
- `path`: All the left parts after `host/`, e.g. `linrongbin16/giturlparser.lua.git` in `https://github.com/linrongbin16/giturlparser.lua.git`.
- `path_pos`: Path position.
- `repo`: Repository (the left parts after the last slash `/`, if exists), e.g. `giturlparser.lua.git` in `https://github.com/linrongbin16/giturlparser.lua.git`.
- `repo_pos`: Repository position.
- `org`: , Organization (the parts after `host/` and before the last slash `/`, if exists), e.g. `linrongbin16` in `https://github.com/linrongbin16/giturlparser.lua.git`.
- `org_pos`: Organization position.

> [!NOTE]
>
> The `{path}` component is equivalent to `{org}/{repo}`.

> [!IMPORTANT]
>
> If there's only 1 slash, the `org` component is missing.

### `parse`

Parse `url` and returns the parsed info (lua table).

```lua
--- @param url string
--- @return giturlparser.GitUrlInfo?, string?
M.parse = function(url)
```

Parameters:

- `url`: Git url, e.g. the output of `git remote get-url origin`.

Returns:

- Returns `giturlparser.GitUrlInfo` and `nil` if success.
- Returns `nil` and error message `string` if failed.

## References

1. [What are the supported git url formats?](https://stackoverflow.com/questions/31801271/what-are-the-supported-git-url-formats)
2. [4.1 Git on the Server - The Protocols](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols)

## Development

## Contribute
