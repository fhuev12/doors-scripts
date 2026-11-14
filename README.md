# doors-scripts

Doors 脚本集合，远程加载用。本地脚本只保留 `loader.lua` 的十几行，脚本体从这里拉取。

## 文件

| 文件 | 作用 |
| --- | --- |
| `loader.lua` | 远程加载器，粘到自己脚本里用 |
| `payload.b64` | 编码后的脚本体（base64 + XOR，KEY=90） |

## 用法

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/fhuev12/doors-scripts/main/loader.lua"))()
```

`loader.lua` 内部会先拉 `payload.b64`，做 base64 解码、XOR 还原，再 `loadstring` 执行。

## 说明

- 脚本体已压缩：去注释、去缩进、去多余空白，86,604 字节 / 2040 行 → 49,875 字节 / 1 行（字符数 47,970，约为原稿 57%）；压缩前 token 流 11,145 个，压缩后完全一致，Luau 语法解析通过。
- XOR 只是让直接打开仓库的人看不到明文，**不是真正的加密**：拿到 key 就能还原，任何客户端 Lua 也能被 dump。要真混淆得上付费服务。
- 想换 key：把明文脚本 XOR 新 key 后 base64，替换 `payload.b64`，同步改 `loader.lua` 里的 `KEY`。
