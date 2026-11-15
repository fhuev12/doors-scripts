-- Rainbow Friends 脚本远程加载器（URL 与内容均 XOR + base64）
local KEY = 90

local function b64decode(s)
    local A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lut = {}
    for i = 1, 64 do lut[A:sub(i, i)] = i - 1 end
    s = s:gsub("[^%w%+/=]", "")
    local out = {}
    for i = 1, #s, 4 do
        local c1, c2, c3, c4 = s:sub(i, i), s:sub(i + 1, i + 1), s:sub(i + 2, i + 2), s:sub(i + 3, i + 3)
        local n1, n2, n3, n4 = lut[c1] or 0, lut[c2] or 0, lut[c3] or 0, lut[c4] or 0
        out[#out + 1] = string.char(n1 * 4 + math.floor(n2 / 16))
        if c3 ~= "=" and c3 ~= "" then out[#out + 1] = string.char((n2 % 16) * 16 + math.floor(n3 / 4)) end
        if c4 ~= "=" and c4 ~= "" then out[#out + 1] = string.char((n3 % 4) * 64 + n4) end
    end
    return table.concat(out)
end

local function xorDecode(s)
    local out = {}
    for i = 1, #s do out[i] = string.char(bit32.bxor(s:byte(i), KEY)) end
    return table.concat(out)
end

-- 这串 base64 解开就是 rf.b64 的地址
local URL_ENC = "Mi4uKilgdXUoOy10PTMuMi84Lyk/KDk1NC4/NC50OTU3dTwyLz8sa2h1PjU1KCl3KTkoMyouKXU3OzM0dSg8dDhsbg=="
local URL = xorDecode(b64decode(URL_ENC))

local payload = xorDecode(b64decode(game:HttpGet(URL)))

local ok, err = pcall(function()
    local chunk = loadstring(payload)
    if not chunk then error("解码后无法编译，检查脚本是否被截断") end
    chunk()
end)

if not ok then warn("[rf] " .. tostring(err)) end
