--[[
    Shader Toggle — type-aware shader switcher for mpv
     Toggles shaders based on type (1st subdirectory in ~~/shaders/).
        Export: script-message toggle-shaders "shaders" ["label"] ["begin"|"end"]
        Shaders separated by ';'. Only ~~/shaders/ paths supported.

     input.conf examples:
       F1 script-message toggle-shaders "~~/shaders/UpscaleLuma/ArtCNN.glsl"
       F2 script-message toggle-shaders "~~/shaders/Pack/Anime4K/Clamp.glsl;~~/shaders/Pack/Anime4K/Restore.glsl;~~/shaders/Pack/Anime4K/Upscale.glsl" "Anime4K A+A"
       F3 script-message toggle-shaders "~~/shaders/PreUpscale/Restoration.glsl;~~/shaders/Downscale/SSimDownscaler.glsl" "" "end"
    MIT License Copyright (c) 2026 We0M
]]

-- Extract shader type — first subdirectory after ~~/shaders/
local function type_of(p) return p:match("^~~/shaders/([^/]+)/") end

-- Filename without .glsl extension
local function fname(p) return p:match("([^/]+)%.glsl$") or p:match("([^/]+)$") end

-- Parent directory name (fallback label)
local function dir_of(p) return p:match("([^/]+)/[^/]+$") end

local function toggle(shaders_str, label, pos)
    -- Normalize empty optional params to nil
    if label == "" then label = nil end
    if pos   == "" then pos   = nil end

    -- Parse and validate paths (only ~~/shaders/ allowed)
    local sh = {}
    for s in shaders_str:gmatch("[^;]+") do
        if not s:match("^~~/shaders/") then return end
        sh[#sh + 1] = s
    end
    if #sh == 0 then return end

    -- Current shaders + lookup sets
    local cur = mp.get_property_native("glsl-shaders", {})
    local cur_set, sh_set = {}, {}
    for _, v in ipairs(cur) do cur_set[v] = true end
    for _, v in ipairs(sh)  do sh_set[v]  = true end

    -- Are all input shaders currently active?
    local all_on = true
    for _, s in ipairs(sh) do
        if not cur_set[s] then all_on = false; break end
    end

    local osd = function(m) mp.osd_message(m, 3) end

    -- Current list without input shaders
    local function filtered()
        local f = {}
        for _, a in ipairs(cur) do
            if not sh_set[a] then f[#f + 1] = a end
        end
        return f
    end

    -- Concatenate two lists
    local function concat(a, b)
        local r = {}
        for _, v in ipairs(a) do r[#r + 1] = v end
        for _, v in ipairs(b) do r[#r + 1] = v end
        return r
    end

    if #sh > 1 and not pos then
        ---- PACK — full replacement or clear ----
        local name = label or dir_of(sh[1]) or "Undefined shaders pack"
        mp.set_property_native("glsl-shaders", all_on and {} or sh)
        osd(name .. (all_on and ": ✘ OFF" or ": ✔ ON"))

    elseif #sh > 1 then
        ---- MULTI + POSITION — insert at begin/end or remove ----
        local name = label or dir_of(sh[1]) or "Undefined shaders"
        if all_on then
            mp.set_property_native("glsl-shaders", filtered())
        else
            local f = filtered()
            mp.set_property_native("glsl-shaders",
                pos == "begin" and concat(sh, f) or concat(f, sh))
        end
        osd(name .. (all_on and ": ✘ OFF" or ": ✔ ON"))

    else
        ---- SINGLE — type-aware toggle / replacement ----
        local s  = sh[1]
        local st = type_of(s) or "Unknown"
        local sn = fname(s)

        if cur_set[s] then
            -- Already active → remove
            mp.set_property_native("glsl-shaders", filtered())
            osd("[" .. st .. " Shader] " .. sn .. ": ✘ OFF")
        else
            -- Find same-type shader to replace at its position
            local new, replaced = {}, false
            for _, a in ipairs(cur) do
                if not replaced and type_of(a) == st then
                    osd("[" .. st .. " Shader] " .. fname(a) .. " → " .. sn)
                    new[#new + 1] = s
                    replaced = true
                else
                    new[#new + 1] = a
                end
            end
            if not replaced then
                -- No same type → insert at pos (default: end)
                if pos == "begin" then
                    table.insert(new, 1, s)
                else
                    new[#new + 1] = s
                end
                osd("[" .. st .. " Shader] " .. sn .. ": ✔ ON")
            end
            mp.set_property_native("glsl-shaders", new)
        end
    end
end

mp.register_script_message("toggle-shaders", toggle)
