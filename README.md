<!-- markdownlint-disable MD001 MD013 MD034 MD033 MD051 -->

# giturlparser.lua

<p align="center">
<a href="https://luarocks.org/modules/linrongbin16/giturlparser"><img alt="luarocks" src="https://custom-icon-badges.demolab.com/luarocks/v/linrongbin16/giturlparser?label=LuaRocks&labelColor=2C2D72&logo=tag&logoColor=fff&color=blue" /></a>
<a href="https://github.com/linrongbin16/giturlparser.lua/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/giturlparser.lua/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>
<a href="https://app.codecov.io/github/linrongbin16/giturlparser.lua"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/giturlparser.lua?logo=codecov&logoColor=F01F7A&label=Codecov" /></a>
</p>

<p align="center">
Git url parsing library for Lua, i.e. the output of <code>git remote get-url origin</code>.
</p>

Parse any git remote url into a flat Lua table of components — protocol, user, password, host, port, path, `org` and `repo` — along with the byte range of each component in the original string.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Install](#install)
- [Quick Start](#quick-start)
- [Supported URL Formats](#supported-url-formats)
- [API](#api)
  - [Types](#types)
    - [`giturlparser.GitUrlPos`](#giturlparsergiturlpos)
    - [`giturlparser.GitUrlInfo`](#giturlparsergiturlinfo)
  - [Functions](#functions)
    - [`parse`](#parse)
- [Examples](#examples)
- [Notes & Limitations](#notes--limitations)
- [References](#references)
- [Development](#development)
- [Contribute](#contribute)
- [License](#license)

## Features

- **Zero dependency, single file.** Copy `src/giturlparser.lua` into your project, or install it from LuaRocks.
- **Positions included.** Every component comes with a `{start_pos, end_pos}` pair, which is handy for highlighting or rewriting parts of a url in place.
- **Covers what git actually emits.** Full protocols (`https://`, `ssh://`, `git://`, `file://`), scp-like `user@host:path`, and local paths (absolute, relative, `~`, Windows drive letters) are all handled.

## Requirements

- Lua >= 5.1, LuaJIT >= 2.0.0.

## Install

```bash
luarocks install giturlparser
```

Or vendor the single source file:

```bash
cp src/giturlparser.lua /your/project/lua/giturlparser.lua
```

## Quick Start

```lua
local giturlparser = require("giturlparser")

local info, err = giturlparser.parse("git@github.com:linrongbin16/giturlparser.lua.git")
if not info then
  error(err)
end

print(info.host) -- github.com
print(info.org)  -- linrongbin16
print(info.repo) -- giturlparser.lua.git

-- Every component carries its byte range in the original url.
print(info.repo_pos.start_pos, info.repo_pos.end_pos) -- 29  48
```

## Supported URL Formats

There are (mainly) three families of git url. Below they are described with a regex-like syntax purely for readability:

1. `{}` marks a component returned in [`giturlparser.GitUrlInfo`](#giturlparsergiturlinfo).
2. `[]` is optional (0 or 1 occurrence), `[]*` is 0 or more, `[]+` is 1 or more.
3. `|` inside `[]` is the **_or_** operator.

### Full Protocols

`{protocol}://[[{user}[:{password}]@]{host}[:{port}]]/[{org}/]*{repo}`

- `http://host.xyz/repo.git`
- `https://git@127.0.0.1:12345/repo.git`
- `ssh://username:password@host.xyz:2222/path/to/the/repo.git`
- `ssh://host.xyz:2222/path/to/the/repo.git`
- `ssh://[::1]:2222/repo.git` (IPv6 host, without the enclosing brackets in `host`)
- `file:///repo.git`
- `file://host.xyz/path/to/the/repo.git`
- `file://~/home/to/the/repo.git`

### SSH Omitted Protocols (scp-like)

`[{user}[:{password}]@]{host}:[{org}/]*{repo}`

- `git@host.xyz:repo.git`
- `user:passwd@host.xyz:path/to/the/repo.git`
- `git@[::1]:repo.git`

> [!NOTE]
>
> A url is treated as scp-like only when there is no `/` before the first `:`. So `./foo:bar` and `/abs/path:with:colons` stay local paths, while `foo:bar` is read as host `foo` + path `bar`.

### Local File System

`[.|..|~|/][{org}/]*{repo}` (no protocol, no host)

- `repo.git`
- `./repo.git`
- `../path/to/the/repo.git`
- `~/home/to/the/repo.git`
- `/usr/home/to/the/repo.git`
- `/tmp/repo.git`
- `C:/path/to/repo.git` (Windows drive letter is read as `host`)

## API

### Types

#### `giturlparser.GitUrlPos`

The string position of a component.

```lua
--- @alias giturlparser.GitUrlPos {start_pos:integer?,end_pos:integer?}
```

- `start_pos`: Start string index (1-based, inclusive).
- `end_pos`: End string index (1-based, inclusive).

> [!NOTE]
>
> Indexes are Lua string indexes, so `url:sub(pos.start_pos, pos.end_pos)` returns exactly the component.

#### `giturlparser.GitUrlInfo`

Parsed information.

```lua
--- @alias giturlparser.GitUrlInfo {protocol:string?,protocol_pos:giturlparser.GitUrlPos?,user:string?,user_pos:giturlparser.GitUrlPos?,password:string?,password_pos:giturlparser.GitUrlPos?,host:string?,host_pos:giturlparser.GitUrlPos?,port:string?,port_pos:giturlparser.GitUrlPos?,org:string?,org_pos:giturlparser.GitUrlPos?,repo:string?,repo_pos:giturlparser.GitUrlPos?,path:string?,path_pos:giturlparser.GitUrlPos?}
```

| Field      | Description                                       | Example (`https://user:pass@host.xyz:8080/org/repo.git`) |
| ---------- | ------------------------------------------------- | -------------------------------------------------------- |
| `protocol` | Protocol before `://`                             | `https`                                                  |
| `user`     | User name before `@`                              | `user`                                                   |
| `password` | Password between `:` and `@`                      | `pass`                                                   |
| `host`     | Host name (IPv6 without brackets)                 | `host.xyz`                                               |
| `port`     | Port after `:`                                    | `8080`                                                   |
| `path`     | Everything after host (and port)                  | `/org/repo.git`                                          |
| `org`      | `path` without leading `/` and the last component | `org`                                                    |
| `repo`     | Last component of `path`                          | `repo.git`                                               |

Every field above has a matching `<field>_pos` field with its [`giturlparser.GitUrlPos`](#giturlparsergiturlpos), or `nil` when the component is absent.

Notes on the sugar fields:

- `path` is (almost) equivalent to `/{org}/{repo}`; it keeps its leading `/`.
- `org` and `repo` are trimmed of surrounding slashes.
- `org` may contain slashes: for `https://github.com/a/b/c.git` it is `a/b`, and `repo` is `c.git`.
- `org` is `nil` when there is only one path component.

### Functions

#### `parse`

Parse `url` and return the parsed info (a Lua table).

```lua
--- @param url string
--- @return giturlparser.GitUrlInfo?, string?
M.parse = function(url)
```

Parameters:

- `url`: Git url, e.g. the output of `git remote get-url origin`.

Returns:

- `giturlparser.GitUrlInfo, nil` on success.
- `nil, error_message` on failure. Today the only failure is a non-string or empty input, which returns `nil, "empty string"`.

> [!NOTE]
>
> An unparsable-looking url is not an error: `parse` always returns a table as long as the input is a non-empty string, filling in whatever components it could find and leaving the rest `nil`.

## Examples

| URL                                                    | `protocol` | `user` | `host`       | `port` | `org`          | `repo`                 |
| ------------------------------------------------------ | ---------- | ------ | ------------ | ------ | -------------- | ---------------------- |
| `https://github.com/linrongbin16/giturlparser.lua.git` | `https`    | —      | `github.com` | —      | `linrongbin16` | `giturlparser.lua.git` |
| `ssh://git@127.0.0.1:2222/repo.git`                    | `ssh`      | `git`  | `127.0.0.1`  | `2222` | —              | `repo.git`             |
| `git@github.com:linrongbin16/giturlparser.lua.git`     | —          | `git`  | `github.com` | —      | `linrongbin16` | `giturlparser.lua.git` |
| `ssh://[::1]:2222/repo.git`                            | `ssh`      | —      | `::1`        | `2222` | —              | `repo.git`             |
| `file:///path/to/repo.git`                             | `file`     | —      | —            | —      | `path/to`      | `repo.git`             |
| `/tmp/repo.git`                                        | —          | —      | —            | —      | `tmp`          | `repo.git`             |
| `./repo.git`                                           | —          | —      | —            | —      | `.`            | `repo.git`             |
| `@host:repo.git`                                       | —          | —      | `host`       | —      | —              | `repo.git`             |
| `user:passwd@host.xyz:path/to/the/repo.git`            | —          | `user` | `host.xyz`   | —      | `path/to/the`  | `repo.git`             |

Extracting the repository slug from whichever url git hands you:

```lua
local giturlparser = require("giturlparser")

--- @param remote_url string
--- @return string? slug e.g. "linrongbin16/giturlparser.lua"
local function repo_slug(remote_url)
  local info = giturlparser.parse(remote_url)
  if not info or not info.repo then
    return nil
  end
  if not info.org then
    return info.repo
  end
  return info.org .. "/" .. info.repo
end

print(repo_slug("git@github.com:linrongbin16/giturlparser.lua.git")) -- linrongbin16/giturlparser.lua.git
print(repo_slug("https://gitlab.com/group/sub/repo.git")) -- group/sub/repo.git
print(repo_slug("https://github.com/rust-lang/rust.git")) -- rust-lang/rust.git
```

## Notes & Limitations

- `host` for an IPv6 url (`ssh://[::1]:2222/repo.git`) is `::1`, i.e. without the `[` and `]`; `host_pos` points at `::1` inside the brackets.
- `port` is returned as a string, not a number.
- `file://~/home/to/the/repo.git` is treated like any other url: `~` ends up in `host` (`host = "~"`), not expanded.
- An empty authority such as `ssh://:2222/repo.git` yields `host = nil` and `port = "2222"`, like a bare local path such as `/tmp/repo.git`. The parsed fields alone do not tell the two apart.
- The host of a `file://` url is reported in `host` even though git ignores it: `file://host.xyz/tmp/repo.git` gives `host = "host.xyz"`. Use `path` if you need the pure path.
- This library only parses: it does not check that a url or a local path exists, nor does it talk to git. A remote url that parses fine can still be unusable.
- `C:/path/to/repo.git` is ambiguous by nature; it is parsed as scp-like (host `C`), not as a Windows path.
- Trailing slashes are trimmed from `org` and `repo`, but kept in `path`.
- For a local path, `org` keeps its `.`/`..`/`~` segments verbatim: `./repo.git` gives `org = "."`, `~/a/repo.git` gives `org = "~/a"`. Strip them yourself if you need a host-independent slug.

## References

1. [What are the supported git url formats?](https://stackoverflow.com/questions/31801271/what-are-the-supported-git-url-formats)
2. [Git on the Server - The Protocols](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols)
3. Used by [gitlinker.nvim](https://github.com/linrongbin16/gitlinker.nvim) to generate permalinks.

## Development

To develop the project and make a PR, please set up with:

- [lua-language-server](https://github.com/LuaLS/lua-language-server).
- [stylua](https://github.com/JohnnyMorganz/StyLua).
- [luarocks](https://luarocks.org/).
- [luacheck](https://github.com/mpeterv/luacheck).
- [busted](https://github.com/lunarmodules/busted).

Run the unit tests:

```bash
luarocks install busted
busted .
```

Format and lint (same as CI):

```bash
stylua --config-path .stylua.toml ./src ./spec
luacheck src --config .luacheckrc
```

Run the tests against a specific interpreter:

```bash
lua5.1 --version && busted .
luajit --version && busted .
```

Build the rock locally:

```bash
luarocks make giturlparser-scm-1.rockspec
```

## Contribute

Please open [issue](https://github.com/linrongbin16/giturlparser.lua/issues)/[PR](https://github.com/linrongbin16/giturlparser.lua/pulls) for anything about giturlparser.lua.

## License

[MIT](./LICENSE) © linrongbin16
