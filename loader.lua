-- 小黑子脚本 · 远程加载器
-- URL 与脚本体都做了编码：直接看仓库看不到明文地址，也看不到脚本内容
local KEY = 90 -- 1~255，换 key 时 URL 编码和 payload 要一起重编

-- base64 解码：把仓库里的 base64 文本还原成字节串
local function b64decode(s)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lut = {}
    for i = 1, 64 do
        lut[string.sub(alphabet, i, i)] = i - 1
    end

    s = string.gsub(s, "[^%w%+/=]", "") -- 剔除换行、空格等
    local out = {}
    for i = 1, #s, 4 do
        local c1 = string.sub(s, i, i)
        local c2 = string.sub(s, i + 1, i + 1)
        local c3 = string.sub(s, i + 2, i + 2)
        local c4 = string.sub(s, i + 3, i + 3)
        local n1 = lut[c1] or 0
        local n2 = lut[c2] or 0
        local n3 = lut[c3] or 0
        local n4 = lut[c4] or 0

        local b1 = n1 * 4 + math.floor(n2 / 16)
        local b2 = (n2 % 16) * 16 + math.floor(n3 / 4)
        local b3 = (n3 % 4) * 64 + n4

        out[#out + 1] = string.char(b1)
        if c3 ~= "=" and c3 ~= "" then out[#out + 1] = string.char(b2) end
        if c4 ~= "=" and c4 ~= "" then out[#out + 1] = string.char(b3) end
    end
    return table.concat(out)
end

-- XOR 解码：每个字节和 KEY 异或一次，还原原文
local function xorDecode(s)
    local out = {}
    for i = 1, #s do
        out[i] = string.char(bit32.bxor(string.byte(s, i), KEY))
    end
    return table.concat(out)
end

-- 这串 base64 解开就是 payload.b64 的地址（同样 XOR + base64）
local URL_ENC = "Mi4uKilgdXUoOy10PTMuMi84Lyk/KDk1NC4/NC50OTU3dTwyLz8sa2h1PjU1KCl3KTkoMyouKXU3OzM0dSo7IzY1Oz50OGxu"
local URL = xorDecode(b64decode(URL_ENC))

-- 拉取编码后的脚本体，再两层还原
local payload = xorDecode(b64decode(game:HttpGet(URL)))

local ok, err = pcall(function()
    local chunk = loadstring(payload)
    if not chunk then error("解码后无法编译，检查脚本是否被截断") end
    chunk()
end)

if not ok then
    if Rayfield and Rayfield.Notify then
        Rayfield:Notify({
            Title = "加载失败",
            Content = tostring(err):sub(1, 120),
            Duration = 6.5,
            Image = 4483362458,
        })
    end
    warn("[xiaoheizi] " .. tostring(err))
end
