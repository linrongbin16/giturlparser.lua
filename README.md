# giturlparser.lua

<p align="center">
<a href="https://luarocks.org/modules/linrongbin16/giturlparser"><img alt="luarocks" src="https://custom-icon-badges.demolab.com/luarocks/v/linrongbin16/giturlparser?label=LuaRocks&labelColor=2C2D72&logo=tag&logoColor=fff&color=blue" /></a>
<a href="https://github.com/linrongbin16/giturlparser.lua/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/giturlparser.lua/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>
<a href="https://app.codecov.io/github/linrongbin16/giturlparser.lua"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/giturlparser.lua?logo=codecov&logoColor=F01F7A&label=Codecov" /></a>
</p>

<p align="center">
Pure Lua implemented git URL parsing library, e.g. the output of <code>git remote get-url origin</code>.
</p>

## Table of Contents

- [Requirements](#requirements)
- [Features](#features)
- [Install](#install)
- [Documents](#documents)
  - [Types](#types)
    - [`giturlparser.GitUrlPos`](#giturlparsergiturlpos)
    - [`giturlparser.GitUrlInfo`](#giturlparsergiturlinfo)
  - [Functions](#functions)
    - [`parse`](#parse)
- [References](#references)
- [Development](#development)
- [Contribute](#contribute)

## Requirements

- Lua >= 5.1, luajit >= 2.0.0.

## Features

- Single file & zero dependency.
- Full [Git Protocols](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) support.

## Install

`luarocks install giturlparser`

## Documents

The git url syntax contains many use cases:

1. `{protocol}://[[{user}[:{password}]@]{host}[:{port}]]/[{org}/]*{repo}`
   - `http://host.xyz/repo.git`
   - `https://git@127.0.0.1:12345/repo.git`
   - `ssh://username:password@host.xyz:port/path/to/the/repo.git`
   - `ssh://host.xyz:port/path/to/the/repo.git`
   - `file:///repo.git`
   - `file://user:passwd@host.xyz:port/path/to/the/repo.git`
   - `file://~/home/to/the/repo.git`
2. `[{protocol}://][[{user}[:{password}]@]host[:{port}]]/[{org}/]*{repo}`
   - `git@host.xyz/repo.git`
   - `user:passwd@host.xyz:port/path/to/the/repo.git`
3. `[~][/{org}]*/{repo}`
   - `repo.git`
   - `./repo.git`
   - `../path/to/the/repo.git`
   - `~/home/to/the/repo.git`
   - `/usr/home/to/the/repo.git`

> [!NOTE]
>
> 1. The `{}` contains parsed components returned from [`giturlparser.GitUrlInfo`](#giturlparsergiturlinfo).
> 2. The `[]` contains optional (0 or 1) component.
> 3. The `[]*` contains zero or more (&ge; 0) component.
> 4. The `[]+` contains 1 or more (&ge; 1) component.
> 5. The `|` inside `[]` is **_or_** operator.

All of above can be written by:

1. `[{protocol}://][[{user}[:{password}]@]host[:{port}]]/[{org}/]*{repo}`
2. `[~][/{org}]*/{repo}`

### Types

#### `giturlparser.GitUrlPos`

The string position of a component.

```lua
--- @alias giturlparser.GitUrlPos {start_pos:integer?,end_pos:integer?}
```

It contains below fields:

- `start_pos`: Start string index.
- `end_pos`: End string index.

#### `giturlparser.GitUrlInfo`

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
> If there's only 1 slash, the `org` component is omitted.

### Functions

#### `parse`

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

## Development

To develop the project and make PR, please setup with:

- [lua-language-server](https://github.com/LuaLS/lua-language-server).
- [stylua](https://github.com/JohnnyMorganz/StyLua).
- [luarocks](https://luarocks.org/).
- [luacheck](https://github.com/mpeterv/luacheck).

To run unit tests, please install below dependencies:

- [busted](https://github.com/lunarmodules/busted).

## Contribute

Please open [issue](https://github.com/linrongbin16/giturlparser.lua/issues)/[PR](https://github.com/linrongbin16/giturlparser.lua/pulls) for anything about giturlparser.lua.

Like giturlparser.lua? Consider

[![Github Sponsor](https://img.shields.io/badge/-Sponsor%20Me%20on%20Github-magenta?logo=github&logoColor=white)](https://github.com/sponsors/linrongbin16)
[![Wechat Pay](https://img.shields.io/badge/-Tip%20Me%20on%20WeChat-brightgreen?logo=wechat&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
[![Alipay](https://img.shields.io/badge/-Tip%20Me%20on%20Alipay-blue?logo=alipay&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
