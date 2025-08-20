<!-- markdownlint-disable MD001 MD013 MD034 MD033 MD051 -->

# giturlparser.lua

<p align="center">
<a href="https://luarocks.org/modules/linrongbin16/giturlparser"><img alt="luarocks" src="https://custom-icon-badges.demolab.com/luarocks/v/linrongbin16/giturlparser?label=LuaRocks&labelColor=2C2D72&logo=tag&logoColor=fff&color=blue" /></a>
<a href="https://github.com/linrongbin16/giturlparser.lua/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/giturlparser.lua/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>
<a href="https://app.codecov.io/github/linrongbin16/giturlparser.lua"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/giturlparser.lua?logo=codecov&logoColor=F01F7A&label=Codecov" /></a>
</p>

<p align="center">
Git url parsing library for lua, e.g. the output of <code>git remote get-url origin</code>.
</p>

## Table of Contents

- [Requirements](#requirements)
- [Features](#features)
- [Install](#install)
- [Patterns](#patterns)
  - [Full Protocols](#full-protocols)
  - [SSH Omitted Protocols](#ssh-omitted-protocols)
  - [Local File System](#local-file-system)
- [API](#api)
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

* Single file & zero dependency.
* Full [Git Protocols](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols) support (see [Patterns](#patterns)).

## Install

```bash
luarocks install giturlparser
```

## Patterns

There are (mainly) three types of git url pattern:

> [!NOTE]
>
> They are (just help to explain) written with a regex-like syntax:
>
> 1. The `{}` contains parsed components returned from [`giturlparser.GitUrlInfo`](#giturlparsergiturlinfo).
> 2. The `[]` contains optional (0 or 1) component.
> 3. The `[]*` contains 0 or more component.
> 4. The `[]+` contains 1 or more component.
> 5. The `|` inside `[]` is **_or_** operator.

### Full Protocols

`{protocol}://[[{user}[:{password}]@]{host}[:{port}]]/[{org}/]*{repo}`

For example:

- `http://host.xyz/repo.git`
- `https://git@127.0.0.1:12345/repo.git`
- `ssh://username:password@host.xyz:port/path/to/the/repo.git`
- `ssh://host.xyz:port/path/to/the/repo.git`
- `file:///repo.git`
- `file://user:passwd@host.xyz:port/path/to/the/repo.git`
- `file://~/home/to/the/repo.git`

### SSH Omitted Protocols

`[{user}[:{password}]@]{host}:[{org}/]*{repo}`

For example:

- `git@host.xyz:repo.git`
- `user:passwd@host.xyz:path/to/the/repo.git`

### Local File System

`[[.|..|~]/][{org}/]*{repo}`

For example:

- `repo.git`
- `./repo.git`
- `../path/to/the/repo.git`
- `~/home/to/the/repo.git`
- `/usr/home/to/the/repo.git`

## API

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

- `protocol`/`protocol_pos`: Protocol, e.g. `http` in `http://github.com`, and its position.
- `user`/`user_pos`: User name, e.g. `username` in `ssh://username@githost.com`, and its position.
- `password`/`password_pos`: Password, e.g. `password` in `ssh://username:password@githost.com`, and its position.
- `host`/`host_pos`: Host name, e.g. `githost.com` in `ssh://githost.com`, and its position.
- `port`/`port_pos`: Port, e.g. `12345` in `ssh://127.0.0.1:12345/org/repo.git`, and its position.
- `path`/`path_pos`: All the left parts after host name (and optional port), e.g. `/linrongbin16/giturlparser.lua.git` in `https://github.com/linrongbin16/giturlparser.lua.git`, and its position.

There're 2 more sugar fields:

- `repo`/`repo_pos`: Repository (the last part after the last slash `/`), e.g. `giturlparser.lua.git` in `https://github.com/linrongbin16/giturlparser.lua.git`, and its position.
- `org`/`org_pos`: , Organization (the parts after host name (and optional port), before the last slash `/`), e.g. `linrongbin16` in `https://github.com/linrongbin16/giturlparser.lua.git`, and its position.

> [!NOTE]
>
> - The `{path}` component is (almost) equivalent to `/{org}/{repo}`.
> - The `{org}` and `{repo}` component are trimmed from around slashes if there's any.
> - If there's only 1 slash, the `org` component is omitted.

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
