local imgui = require 'imgui' -- регистрация ImGUI
local vkeys = require 'vkeys' -- регистрация ID клавиш и функций, позволяющих с ними стандартно работать
local style = imgui.GetStyle() -- стиль для ImGUI
local colors = style.Colors -- использование колоров
local clr = imgui.Col -- регистрация кол-ов
local ImVec4 = imgui.ImVec4 -- настройка значений ImGUI в ImVec4
local encoding = require 'encoding' -- регистрация кодирования 
u8 = encoding.UTF8 -- определение стандартной кодировки
encoding.default = 'CP1251' -- изменение кодировки на Cyrillic

local functions = {} -- блок экспортируемых функций

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}  -- список русских символов

local ru_en_map = {
    -- Маленькие
    ["й"]="q", ["ц"]="w", ["у"]="e", ["к"]="r", ["е"]="t", ["н"]="y", ["г"]="u", ["ш"]="i", ["щ"]="o", ["з"]="p", ["х"]="[", ["ъ"]="]",
    ["ф"]="a", ["ы"]="s", ["в"]="d", ["а"]="f", ["п"]="g", ["р"]="h", ["о"]="j", ["л"]="k", ["д"]="l", ["ж"]=";", ["э"]="'",
    ["я"]="z", ["ч"]="x", ["с"]="c", ["м"]="v", ["и"]="b", ["т"]="n", ["ь"]="m", ["б"]=",", ["ю"]=".", ["ё"]="`",

    -- Заглавные
    ["Й"]="Q", ["Ц"]="W", ["У"]="E", ["К"]="R", ["Е"]="T", ["Н"]="Y", ["Г"]="U", ["Ш"]="I", ["Щ"]="O", ["З"]="P", ["Х"]="{", ["Ъ"]="}",
    ["Ф"]="A", ["Ы"]="S", ["В"]="D", ["А"]="F", ["П"]="G", ["Р"]="H", ["О"]="J", ["Л"]="K", ["Д"]="L", ["Ж"]=":", ["Э"]='"',
    ["Я"]="Z", ["Ч"]="X", ["С"]="C", ["М"]="V", ["И"]="B", ["Т"]="N", ["Ь"]="M", ["Б"]="<", ["Ю"]=">", ["Ё"]="`",

    -- Дополнительные символы (важно не конфликтовать с основными)
    [";"]=":",  ["'"]='"',
}

local en_ru_map = {
    -- Маленькие
    ["q"]="й", ["w"]="ц", ["e"]="у", ["r"]="к", ["t"]="е", ["y"]="н", ["u"]="г", ["i"]="ш", ["o"]="щ", ["p"]="з", ["["]="х", ["]"]="ъ",
    ["a"]="ф", ["s"]="ы", ["d"]="в", ["f"]="а", ["g"]="п", ["h"]="р", ["j"]="о", ["k"]="л", ["l"]="д", [";"]="ж", ["'"]="э",
    ["z"]="я", ["x"]="ч", ["c"]="с", ["v"]="м", ["b"]="и", ["n"]="т", ["m"]="ь", [","]="б", ["."]="ю", ["`"]="ё",

    -- Заглавные
    ["Q"]="Й", ["W"]="Ц", ["E"]="У", ["R"]="К", ["T"]="Е", ["Y"]="Н", ["U"]="Г", ["I"]="Ш", ["O"]="Щ", ["P"]="З", ["{"]="Х", ["}"]="Ъ",
    ["A"]="Ф", ["S"]="Ы", ["D"]="В", ["F"]="А", ["G"]="П", ["H"]="Р", ["J"]="О", ["K"]="Л", ["L"]="Д", [":"]="Ж", ['"']="Э",
    ["Z"]="Я", ["X"]="Ч", ["C"]="С", ["V"]="М", ["B"]="И", ["N"]="Т", ["M"]="Ь", ["<"]="Б", [">"]="Ю", ["~"]="Ё",

    -- Обратные дополнительные символы
    ["?"]=",",  ["/"]=".",  [":"]=";",  ['"']="'",
}


function main()
	while true do
		wait(0)
	end
end

function functions.change_layout(text)
    if not text or text == "" then return "" end
    
    local result = ""
    for i = 1, #text do
        local char = text:sub(i, i)
        -- Если символ есть в русской раскладке — меняем на английскую
        if ru_en_map[char] then
            result = result .. ru_en_map[char]
        -- Если символ есть в английской — меняем на русскую
        elseif en_ru_map[char] then
            result = result .. en_ru_map[char]
        else
            result = result .. char  -- оставляем как есть (цифры, пробелы, знаки и т.д.)
        end
    end
    return result
end

function functions.imgui_TextColoredRGB(text, isCenter, isCenterText) -- RGB текст для ImGUI, с автоматической кодировкой
	local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
				local i = 0
        for w in text_:gmatch('[^\r\n]+') do
						i = i + 1
						local textsize = w:gsub('{.-}', '')
						local text_width = imgui.CalcTextSize(u8(textsize))

						if i == 1 then
							if isCenter == 2 then
								imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
							elseif isCenter == 3 then
								imgui.SetCursorPosX(width - text_width .x - 10)
							end
						else
							if isCenterText == 2 then
		            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
							elseif isCenterText == 3 then
								imgui.SetCursorPosX(width - text_width .x - 10)
							end
						end

            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

function functions.string_split(inputstr, sep) -- сплит текста
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function functions.getMyNick() -- взятие ника текущего игрока, то-есть Вас
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        local nick = sampGetPlayerNickname(id)
        return nick
    end
end

function functions.getMyId() -- взятие ID текущего игрока, то-есть Вас
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        return id
    end
end

function functions.textSplit(str, delim, plain) -- аналог string.split, но работает с объемным текстом
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function functions.playernickname(nick) -- функция для поиска всех никнеймов
    nick = tostring(nick)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nick == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1003 do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
            return i
        end
    end
end

function functions.string_rlower(s) -- делаем текст большми
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function functions.string_rupper(s) -- рупперим текст
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function getDownKeys() -- получаем список продавленных нахер клавиш
    local curkeys = ""
    local bool = false
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function functions.getDownKeysText() -- получаем текст продавленных клавиш, не знаю как, но так и есть
	tKeys = functions.string_split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end

function functions.strToIdKeys(str) -- получаем ID клавиш из обусловенного текста, поиска как раз по VKeys
    tKeys = functions.string_split(str, "+")
    if #tKeys ~= 0 then
        for i = 1, #tKeys do
            if i == 1 then
                str = vkeys.name_to_id(tKeys[i], false)
            else
                str = str .. " " .. vkeys.name_to_id(tKeys[i], false)
            end
        end
        return tostring(str)
    else
        return "(("
    end
end

function functions.join_argb(a, r, g, b) -- вводим ARGB через BIT таблицу
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function functions.explode_argb(argb) -- выкладываем разделенные A R G B также через BIT таблицу
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function functions.isKeysDown(keylist, pressed) -- если какие-то клавиши были зажаты вместе, или нет
    local tKeys = functions.string_split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end

function functions.isKeysJustPressed(keylist, pressed) -- если какие-то клавиши были нажаты вместе, или нет
    local tKeys = functions.string_split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyJustPressed(VK_RMENU) and not isKeyJustPressed(VK_LMENU) and not isKeyJustPressed(VK_LSHIFT) and not isKeyJustPressed(VK_RSHIFT) and not isKeyJustPressed(VK_LCONTROL) and not isKeyJustPressed(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyJustPressed(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyJustPressed(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyJustPressed(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end

function functions.black() 

	local style = imgui.GetStyle() 
	local colors = style.Colors 
	local clr = imgui.Col 
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	style.WindowPadding       = ImVec2(4, 6)
	style.WindowRounding      = 0
	style.ChildWindowRounding = 3
	style.FramePadding        = ImVec2(5, 4)
	style.FrameRounding       = 2
	style.ItemSpacing         = ImVec2(3, 3)
	style.TouchExtraPadding   = ImVec2(0, 0)
	style.IndentSpacing       = 21
	style.ScrollbarSize       = 14
	style.ScrollbarRounding   = 16
	style.GrabMinSize         = 10
	style.GrabRounding        = 5
	style.WindowTitleAlign    = ImVec2(0.50, 0.50)
	style.ButtonTextAlign     = ImVec2(0, 0)

	colors[clr.Text]                = ImVec4(1, 1, 1, 1)
	colors[clr.TextDisabled]        = ImVec4(0.50, 0.50, 0.50, 1)
	colors[clr.WindowBg]            = ImVec4(0.059, 0.051, 0.035, 1)
	colors[clr.ChildWindowBg]       = ImVec4(0.059, 0.051, 0.035, 1)
	colors[clr.PopupBg]             = ImVec4(0.059, 0.051, 0.035, 1)
	colors[clr.Border]              = ImVec4(0.22, 0.22, 0.22, 1)
	colors[clr.BorderShadow]        = ImVec4(0.22, 0.22, 0.22, 1)
	
	-- Поля ввода (Frame) — чуть светлее кнопки
	colors[clr.FrameBg]             = ImVec4(0.20, 0.20, 0.20, 1)
	colors[clr.FrameBgHovered]      = ImVec4(0.28, 0.28, 0.28, 1)
	colors[clr.FrameBgActive]       = ImVec4(0.36, 0.36, 0.36, 1)
	
	-- Заголовки окон
	colors[clr.TitleBg]             = ImVec4(0.078, 0.067, 0.051, 1)
	colors[clr.TitleBgActive]       = ImVec4(0.078, 0.067, 0.051, 1)
	colors[clr.TitleBgCollapsed]    = ImVec4(0.078, 0.067, 0.051, 1)
	colors[clr.MenuBarBg]           = ImVec4(0.078, 0.067, 0.051, 1)
	
	-- Скроллбар — та же шкала что кнопки/слайдеры
	colors[clr.ScrollbarBg]         = ImVec4(0.06, 0.06, 0.06, 1)
	colors[clr.ScrollbarGrab]       = ImVec4(0.20, 0.20, 0.20, 1)
	colors[clr.ScrollbarGrabHovered]= ImVec4(0.28, 0.28, 0.28, 1)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.36, 0.36, 0.36, 1)
	
	colors[clr.ComboBg]             = ImVec4(0.10, 0.10, 0.10, 0.99)
	
	-- Чекбокс и слайдер — одна шкала с кнопками
	colors[clr.CheckMark]           = ImVec4(1, 1, 1, 1)
	colors[clr.SliderGrab]          = ImVec4(0.20, 0.20, 0.20, 1)
	colors[clr.SliderGrabActive]    = ImVec4(0.36, 0.36, 0.36, 1)
	
	-- Кнопки
	colors[clr.Button]              = ImVec4(0.14, 0.14, 0.14, 1)
	colors[clr.ButtonHovered]       = ImVec4(0.22, 0.22, 0.22, 1)
	colors[clr.ButtonActive]        = ImVec4(0.4, 0.4, 0.4, 1)
	
	-- Header — та же шкала что кнопки
	colors[clr.Header]              = ImVec4(0.14, 0.14, 0.14, 1)
	colors[clr.HeaderHovered]       = ImVec4(0.22, 0.22, 0.22, 1)
	colors[clr.HeaderActive]        = ImVec4(0.4, 0.4, 0.4, 1)
	
	-- Разделители
	colors[clr.Separator]           = ImVec4(0.22, 0.22, 0.22, 1)
	colors[clr.SeparatorHovered]    = ImVec4(0.36, 0.36, 0.36, 1)
	colors[clr.SeparatorActive]     = ImVec4(0.50, 0.50, 0.50, 1)
	
	-- Ресайз — акцентный синий (единственный цветной элемент)
	colors[clr.ResizeGrip]          = ImVec4(0.067, 0.149, 0.259, 1)
	colors[clr.ResizeGripHovered]   = ImVec4(0.173, 0.396, 0.663, 1)
	colors[clr.ResizeGripActive]    = ImVec4(0.247, 0.557, 0.933, 1)
	
	-- Кнопка закрытия
	colors[clr.CloseButton]         = ImVec4(0.20, 0.20, 0.20, 1)
	colors[clr.CloseButtonHovered]  = ImVec4(0.98, 0.39, 0.36, 1)
	colors[clr.CloseButtonActive]   = ImVec4(0.98, 0.39, 0.36, 1)
	
	-- Графики
	colors[clr.PlotLines]           = ImVec4(1, 1, 1, 1)
	colors[clr.PlotLinesHovered]    = ImVec4(0.90, 0.70, 0, 1)
	colors[clr.PlotHistogram]       = ImVec4(0.90, 0.70, 0, 1)
	colors[clr.PlotHistogramHovered]= ImVec4(1, 0.60, 0, 1)
	
	colors[clr.TextSelectedBg]      = ImVec4(0.153, 0.267, 0.396, 1)
	colors[clr.ModalWindowDarkening]= ImVec4(0.20, 0.20, 0.20, 0.35)
end 

return functions, functions