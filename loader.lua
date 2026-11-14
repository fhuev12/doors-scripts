-- 小黑子脚本 · 远程加载器
-- 本地只保留这十几行，脚本体在 GitHub 上（base64 + XOR 编码）
local URL = "https://raw.githubusercontent.com/fhuev12/doors-scripts/main/payload.b64"
local KEY = 90 -- 换个 1~255 的数字，再按同样规则重编一次 payload 即可

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

local raw = game:HttpGet(URL)
local decoded = b64decode(raw)

local bytes = table.create(#decoded)
for i = 1, #decoded do
    bytes[i] = string.char(bit32.bxor(string.byte(decoded, i), KEY))
end

local ok, err = pcall(function()
    local chunk = loadstring(table.concat(bytes))
    if not chunk then error("解码后无法编译，检查脚本是否被截断") end
    chunk()
end)

if not ok then
    Rayfield:Notify({
        Title = "加载失败",
        Content = tostring(err):sub(1, 120),
        Duration = 6.5,
        Image = 4483362458,
    })
    warn("[xiaoheizi] " .. tostring(err))
end
