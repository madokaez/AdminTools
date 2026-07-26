script_name("AdminTool")
script_author("madokaez")
script_version("1.0.1")
local SCRIPT_VERSION = "1.0.1"

require "lib.moonloader"
require 'resource.commands'
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local imgui = require 'imgui'
local memory = require 'memory'
local atlibs = require 'libsfor'
local sampfuncs = require 'sampfuncs'
local ffi = require 'ffi'
local fai = require "fAwesome5"
local fa = require 'faicons'
local tag = "{7d00ff} [AdminTools] {FFFFFF}"
local bitex = require 'bitex'
local lfs = require 'lfs'
local requests = require 'requests'
imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.BufferingBar = require('imgui_addons').BufferingBar
imgui.Tooltip = require('imgui_addons').Tooltip
imgui.ToClipboard = require('imgui_addons').ToClipboard
imgui.CenterText = require('imgui_addons').CenterText
encoding.default = 'CP1251'
u8 = encoding.UTF8
local requests = require 'requests'
local FULL_ACCESS_URL = "https://raw.githubusercontent.com/madokaez/FullAccessAT/refs/heads/main/admins.txt"
local FullAccessList = {}
local FullAccessList_loaded = false

local function toLowerNickCmp(nick)
    return tostring(nick or ""):lower()
end

function LoadFullAccessList()
    lua_thread.create(function()
        local url = FULL_ACCESS_URL .. "?t=" .. os.time()
        local ok, response = pcall(requests.get, url)
        if ok and response and response.status_code == 200 and response.text and response.text ~= "" then
            local newList = {}
            for line in tostring(response.text):gmatch("[^\r\n]+") do
                local nick = line:match("^%s*(.-)%s*$")
                if nick ~= "" then
                    newList[toLowerNickCmp(nick)] = true
                end
            end
            FullAccessList = newList
            FullAccessList_loaded = true
        else
            FullAccessList_loaded = false
        end
    end)
end

function IsFullAccessAdmin(nick)
    if not FullAccessList_loaded then return false end
    return FullAccessList[toLowerNickCmp(nick or "")] == true
end

-- ================================================================
-- ## ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ##
-- ================================================================
local reasons = {"/jail", "/jailakk", "/ban", "/iban", "/sban", "/siban", "/offban", "/ioffban", "/iunban"}
local sw, sh = getScreenResolution()
local ATMenu = imgui.ImBool(false)
local menuSelect = "HOME"
local key_helper = imgui.ImBool(false)
local multiply_punish_frame = {}
-- ================================================================
-- ## ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ##
-- ================================================================


-- ================================================================
-- ## ПЕРЕМЕННЫЕ КАСТОМНОГО РЕКОНА ##
-- ================================================================
local ids_recon = {}
local text_recon = {'STATS', 'MUTE', 'KICK', 'BAN', 'JAIL', 'CLOSE'}
for i = 190, 236 do
	ids_recon[i] = true 
end
local refresh_button_textdraw = 0
local info_textdraw_recon = 0
local info_to_player = {}
local recon_info = { "Здоровье: ", "Броня: ", "ХП машины: ", "Скорость: ", "Пинг: ", "Патроны: ", "Выстрел: ", "Тайминг выстрела: ", "AФК: ", "P.Loss: ", "VIP: ", "Пассивный режим: ", "Турбо-режим: ", "Коллизия: ", 'Дрифт-мод: '}
local show_stats = { [1]  = true, [2]  = true, [3]  = true, [4]  = true, [5]  = true, [6]  = true, [7]  = false, [8]  = false, [9]  = true, [10] = false, [11] = true, [12] = true, [13] = true, [14] = true, [15] = true,}
local control_to_player = false
local select_recon = 0
local recon_id = -1
local ATRecon = imgui.ImBool(false)
local reconCursor = false
-- ================================================================
-- ## ПЕРЕМЕННЫЕ КАСТОМНОГО РЕКОНА ##
-- ================================================================



-- ================================================================
-- ## CHAT-LOGGER ##
-- ================================================================
local chat_logger_text = { }
local text_ru = { }
local chat_find = imgui.ImBuffer(65536)

local chatlogDirectory = getWorkingDirectory() .. "\\config\\AdminTools\\logs\\chatlog"

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

local logs_file = { }
local name_log_select = ""
local read_file = false
local update_files = false
local combo_select = imgui.ImInt(0)

function scan_logs_file()
    logs_file = {}
    
    local logsRoot = getWorkingDirectory() .. "\\config\\AdminTools\\logs"
    if not doesDirectoryExist(logsRoot) then
        createDirectory(logsRoot)
    end
    if not doesDirectoryExist(chatlogDirectory) then
        createDirectory(chatlogDirectory)
        return
    end
    
    local dir = chatlogDirectory .. "\\"
    
    for file in lfs.dir(dir) do
        if file:match("^%d+%-%d+%-%d+%.txt$") then
            table.insert(logs_file, file:match("(.+)%.txt"))
        end
    end

    table.sort(logs_file, function(a, b)
        local d1, m1, y1 = a:match("(%d+)-(%d+)-(%d+)")
        local d2, m2, y2 = b:match("(%d+)-(%d+)-(%d+)")
        
        if not d1 or not d2 then return a > b end
        
        y1, m1, d1 = tonumber(y1), tonumber(m1), tonumber(d1)
        y2, m2, d2 = tonumber(y2), tonumber(m2), tonumber(d2)
        
        if y1 ~= y2 then return y1 > y2 end
        if m1 ~= m2 then return m1 > m2 end
        return d1 > d2
    end)
end  

function readRussian()
    text_ru = {}
    for key,v in pairs(chat_logger_text) do 
        local text = u8:encode(dec(v))
        table.insert(text_ru, text)
    end 
end        

function readChatlog_select()
    local file_check = io.open(chatlogDirectory .. "\\" .. name_log_select, "r")
    if not file_check then
        sampAddChatMessage(tag .. " Файл не найден.", -1)
        return {}
    end
    local t = file_check:read("*all")
    sampAddChatMessage(tag .. " Чтение выбранного файла.", -1)
    file_check:close() 
    t = t:gsub("{......}", "")
    local final_text = string.split(t, "\n")
    sampAddChatMessage(tag .. " Файл прочитан.", -1)
    return final_text
end

function getFileName()
    local filePath = chatlogDirectory .. "\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt"
    if not doesFileExist(filePath) then
        local f = io.open(filePath, "w")
        f:close()
        return filePath
    else
        return filePath  
    end
end

function string.split(inputstr, sep)
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
-- ================================================================
-- ## /CHAT-LOGGER ##
-- ================================================================

-- ================================================================
-- ## БИНДЕР ##
-- ================================================================
local directBinderIni = "AdminTools\\binder.ini"
local configB = inicfg.load({
    bind_name = {},
    bind_keys = {},
    bind_int = {},
    bind_delay = {},
    bind_argument = {},
    bind_my_id_arguments = {},
}, directBinderIni)
inicfg.save(configB, directBinderIni)

local elements = {
    buff = {
        name       = imgui.ImBuffer(256),
        int        = imgui.ImBuffer(65536),
        keys       = imgui.ImBuffer(256),
        delay      = imgui.ImBuffer(2500),
        argument   = imgui.ImBool(false),
        my_id_arg  = imgui.ImBool(false),
    },
    boolean = {
        CreateOrEditCommand = false,
    },
}

function UpdateBinderConfig()
    if inicfg.save(configB, directBinderIni) then return true end
    return false
end

function InjectWaitFunction(cmd, key_cmd, arg)
    for _, input in pairs(cmd) do
        input = tostring(input)
        if arg ~= nil and input:find("arg") then
            input = input:gsub("arg", arg)
        end
        sampSendChat(u8:decode(input))
        wait(tonumber(configB.bind_delay[key_cmd]))
    end
end
local function executeBind(key, arg)
    if not configB.bind_int[key] or #configB.bind_int[key] == 0 then return end
    local cmds  = atlibs.string_split(configB.bind_int[key], "~")
    local delay = tonumber(configB.bind_delay[key]) or 0
    local useArg   = configB.bind_argument[key]
    local useMyId  = configB.bind_my_id_arguments[key]
    if delay > 0 then
        if useArg then
            waiting_function:run(cmds, key, arg)
        else
            waiting_function:run(cmds, key)
        end
        return
    end
    for _, input in pairs(cmds) do
        input = tostring(input)
        if useArg then
            if arg == nil then return end
            if useMyId then
                local my_id = atlibs.getMyId()
                if input:find("my_id") and my_id then
                    input = input:gsub("my_id", tostring(my_id))
                else
                    sampAddChatMessage(tag .. "Ошибка: my_id не найден.", -1)
                    return
                end
            end
            input = input:gsub("arg", tostring(arg))
        end
        sampSendChat(u8:decode(input))
    end
end
local function getBindCommandName(rawName)
    if rawName:find("^/") then
        return rawName:match("^/(.+)")
    end
    return rawName
end

-- ================================================================
-- ## БИНДЕР ##
-- ================================================================


local view_cache = { filter = nil, source_len = 0, lines = {} }

local function rebuild_view(source, filter_lower)
    if view_cache.filter == filter_lower and view_cache.source_len == #source then
        return view_cache.lines
    end
    local out = {}
    if filter_lower == "" then
        for i = 1, #source do out[#out+1] = source[i] end
    else
        for i = 1, #source do
            local line = source[i]
            if line:lower():find(filter_lower, 1, true) then
                out[#out+1] = line
            end
        end
    end
    view_cache.filter = filter_lower
    view_cache.source_len = #source
    view_cache.lines = out
    return out
end


-- ================================================================
-- ## НАСТРOOЙКА РЕПОРТА ##
-- ================================================================

local ATReportShow = imgui.ImBool(false)
local is_layout_changed = false
local report_select_menu = 0


local questions = {
    ["HelpCmd"] = {
        { name = u8"Команды VIP`а",        desc = "/help -> 7 пункт" },
        { name = u8"Привелегия Premuim",    desc = "Привелегия Premuim VIP (/help -> 7)" },
        { name = u8"Джетпак",              desc = "/jp" },
        { name = u8"Привелегия Diamond",    desc = "Привелегия Diamond VIP (/help -> 7) " },
        { name = u8"Привелегия Platinum",   desc = "Привелегия Platinum VIP (/help -> 7)" },
        { name = u8"Привелегия Личный",     desc = "Привелегия Premium VIP (/help -> 7)" },
        { name = u8"Команды для свадьбы",   desc = "/help -> 8 пункт" },
        { name = u8"Турбопакет",           desc = "/help -> 11 пункт" },
    },
    ["HelpTP"] = {
        { name = u8"Тп",                   desc = "/tp" },
        { name = u8"Тп развлечения",        desc = "/tp -> Drift, Drag трассы" },
        { name = u8"Арена",                desc = "/arena" },
        { name = u8"Тп мини игры",          desc = "/tp -> Разное" },
        { name = u8"Тп Автосалон",          desc = "/tp -> Разное -> Автосалоны" },
        { name = u8"Тп тюн лич кара",       desc = "/tp -> Разное -> Автосалоны -> Автомастерская" },
        { name = u8"Тп объекты лич кара",   desc = "/tp -> Разное -> Бизнесы -> Магазин автозапчестей" },
        { name = u8"Трейд",                desc = "/trade" },
        { name = u8"Развлекательное место", desc = "/place" },
    },
    ["HelpSettings"] = {
        { name = u8"Настройки",                    desc = "/settings" },
        { name = u8"Входы/Выходы игроков",          desc = "/settings -> 1 пункт." },
        { name = u8"On/Off вызывать на дуель",      desc = "/settings -> 2 пункт." },
        { name = u8"On/Off Личные сообщения",       desc = "/settings -> 3 пункт." },
        { name = u8"On/Off телепорт",               desc = "/settings -> 4 пункт." },
        { name = u8"Разрешение показывать DM Stats", desc = "/settings -> 5 пункт." },
        { name = u8"On/Off эффект тп",              desc = "/settings -> 6 пункт." },
        { name = u8"On/Off спидометр",              desc = "/settings -> 7 пункт." },
        { name = u8"On/Off Drift Lvl",              desc = "/settings -> 8 пункт." },
        { name = u8"Спавн в доме/доме семьи",       desc = "/settings -> 9 пункт." },
        { name = u8"Вызов главного меню",           desc = "/settings -> 10 пункт." },
        { name = u8"On/Off приглашение в банду",    desc = "/settings -> 11 пункт." },
        { name = u8"On/Off TextDraw ТС",            desc = "/settings -> 12 пункт." },
        { name = u8"On/Off кейс",                  desc = "/settings -> 13 пункт." },
        { name = u8"On/Off Радио чат",              desc = "/settings -> 14 пункт." },
        { name = u8"On/Off FPS показатель",         desc = "/settings -> 15 пункт." },
        { name = u8"On/Off Уведы",                 desc = "/settings -> 16 пункт." },
        { name = u8"On/Off Уведы.акции",            desc = "/settings -> 17 пункт." },
        { name = u8"On/Off Автологин",              desc = "/settings -> 18 пункт." },
        { name = u8"On/Off Фон.музыка при входе",   desc = "/settings -> 19 пункт." },
        { name = u8"On/Off гс.чата",               desc = "/settings -> 20 пункт." },
        { name = u8"Ближ/общ чат",                 desc = "/settings -> 21 пункт." },
        { name = u8"On/Off семьи над головой",      desc = "/settings -> 22 пункт." },
        { name = u8"On/Off ур.Drift над головой",   desc = "/settings -> 23 пункт." },
        { name = u8"On/Off камеры перехода на перса.", desc = "/settings -> 24 пункт." },
        { name = u8"On/Off прорисовка объектов",    desc = "/settings -> 25 пункт." },
        { name = u8"On/Off метки домов на мапе",    desc = "/settings -> 26 пункт." },
        { name = u8"On/Off TextDraw /inv",          desc = "/settings -> 27 пункт." },
        { name = u8"Отображение статы",             desc = "/settings -> 28 пункт." },
        { name = u8"Отображение счетчика-Drift",    desc = "/settings -> 29 пункт." },
    },
    ["HelpSkins"] = {
        { name = u8"Копы",            desc = "280-286, 287-288, 300-307, 309-311" },
        { name = u8"Балласы",         desc = "102-104" },
        { name = u8"Грув",            desc = "105-107" },
        { name = u8"Триад",           desc = "117-118, 120" },
        { name = u8"Вагосы",          desc = "108-110" },
        { name = u8"Ру.Мафия",        desc = "111-113" },
        { name = u8"Ацтеки",          desc = "114-116" },
        { name = u8"Мафия",           desc = "124-127" },
        { name = u8"Биг Смоук",       desc = "269" },
        { name = u8"Свит",            desc = "270" },
        { name = u8"Райдер",          desc = "271" },
        { name = u8"Сиджей",          desc = "74" },
        { name = u8"Цезарь",          desc = "292" },
        { name = u8"OGloc",           desc = "293" },
    },
    ["HelpDefault"] = {
        { name = u8"Спросите у игроков",       desc = "Обратитесь к игрокам за информацией" },
        { name = u8"Как поставить цвет",       desc = "Цвет в коде HTML {RRGGBB}. Зеленый - 008000. Берем {} и ставим цвет перед словом {008000}Зеленый" },
        { name = u8"Как начать капт",          desc = "/capture" },
        { name = u8"On/Off пассив",            desc = "/passive" },
        { name = u8"Восстановить хп",          desc = "/heal" },
        { name = u8"Как Фаст тюнить тачку",    desc = "/cartune" },
        { name = u8"Как попасть на join",      desc = "/join | Есть внутриигровые команды, следите за чатом" },
        { name = u8"Виртуальный мир",          desc = "/dt 0-990" },
        { name = u8"Прогресс миссий/квестов",  desc = "/quests | /dquest | /bquest" },
        { name = u8"Донат",                    desc = "/donate" },
        { name = u8"Связь с администрацией",   desc = "/report" },
        { name = u8"Режим GangWar",            desc = "/gw" },
        { name = u8"Телефон",                  desc = "/phone" },
        { name = u8"Инвентарь",               desc = "/inv" },
        { name = u8"Статистика",               desc = "/statpl" },
        { name = u8"Личный чат",              desc = "/pm" },
        { name = u8"Ближний чат",             desc = "/b" },
        { name = u8"Чат банды",               desc = "/gc" },
        { name = u8"Онлайн админы",           desc = "/admins - Доступно от 3 часов игры" },
        { name = u8"Привет в всем в чат",     desc = "/hh" },
        { name = u8"Пока всем чат",           desc = "/bb" },
        { name = u8"Счетчик и дм счетчик",    desc = "/count /dmcount" },
        { name = u8"Передать деньги",         desc = "/givemoney" },
        { name = u8"Передать очки",           desc = "/givescore" },
        { name = u8"Передать рубли",          desc = "/giverub | С Личного VIP (/help -> 7)" },
        { name = u8"Передать коины",          desc = "/givecoin | С Личного VIP (/help -> 7)" },
        { name = u8"REBORN",                  desc = "/reborn" },
    },
    ["HelpMenu"] = {
        { name = u8"Открыть меню",             desc = "ALT/Y" },
        { name = u8"Транспортное средство",    desc = "ALT/Y -> Транспортное средство" },
        { name = u8"Предметы",                desc = "ALT/Y -> Предметы" },
        { name = u8"Оружие",                  desc = "ALT/Y -> Оружия" },
        { name = u8"Действия",                desc = "ALT/Y -> Действия" },
        { name = u8"Радио",                   desc = "ALT/Y -> Радио" },
        { name = u8"Онлайн админы",           desc = "/admins - Доступно от 3 часов игры" },
        { name = u8"Система банд",            desc = "ALT/Y -> Система банд" },
        { name = u8"Счетчик отыгранных часов", desc = "ALT/Y -> Счетчик отыгранных часов" },
        { name = u8"Промокод",                desc = "ALT/Y -> Промокод" },
        { name = u8"Банды с автонабором",     desc = "ALT/Y -> Авто-набор в банду" },
        { name = u8"Ежедневные задания",      desc = "ALT/Y -> Ежедневные задания" },
        { name = u8"Список ТОПЕРОВ",          desc = "ALT/Y -> Список лидеров" },
        { name = u8"Реферал",                 desc = "ALT/Y -> Реферальная система" },
        { name = u8"Достижения",              desc = "ALT/Y -> Достижения" },
    },
}

local function toLowerCP1251(str)
    local out = {}
    for i = 1, #str do
        local b = str:byte(i)
        if b >= 0xC0 and b <= 0xDF then
            b = b + 32
        elseif b == 0xA8 then
            b = 0xB8
        elseif b >= 0x41 and b <= 0x5A then
            b = b + 32
        end
        out[i] = string.char(b)
    end
    return table.concat(out)
end
 
local all_answers = {}
for _, category in pairs(questions) do
    for _, item in ipairs(category) do
        table.insert(all_answers, {
            name        = item.name,
            desc        = item.desc,
            search_name = toLowerCP1251(u8:decode(item.name)),
            search_desc = toLowerCP1251(item.desc),
        })
    end
end
 
function SendReportAnswer(text, after_func)
    lua_thread.create(function()
        sampSendDialogResponse(2349, 1, 0)
        wait(50)
        sampSendDialogResponse(2350, 1, 0)
        wait(50)
        sampSendDialogResponse(2351, 1, 0, text)
        wait(50)
        sampCloseCurrentDialogWithButton(13)
        ATReportShow.v = false
        if after_func then after_func() end
    end)
end

-- ================================================================
-- ## НАСТРОЙКА РЕПОРТА ##
-- ================================================================



-- ================================================================
-- ## ОСНОВНЫЕ НАСТРОЙКИ (КОНФИГ) ##
-- ================================================================
local direct = "AdminTools\\settings.ini"
local config = inicfg.load({
    main = {
        notf_zloup = false,
        notf_flood = false,
        auto_login = false,
        custom_tab = true,
        password = "",
        recon_menu = true,
        checkweaponhack = false,
        key_helper = false,
        timescreen = false,
        adminforms = true,
        auto_adminforms = false,
        styleImGUI = 0,
        font = 10,
        automultiply = false,
        radar_recon = true,
        after_login_commands = "",
        auto_prefix = "",
        random_prefix = false,
        split_long_a = true,
        auto_online = false,
        timescreen_color = "FFFFFF",
        timescreen_scale = 10,
        timescreen_rgb = false,
        report_interface = true,
		chatlogger_enabled = true,
    },
    colours = {
        prefix_MA = "{FFFFFF}",
        prefix_ADM = "{FFFFFF}",
        prefix_STA = "{FFFFFF}",
        prefix_ZGA = "{FFFFFF}",
        prefix_GA = "{FFFFFF}",
    },
    random_enabled = {
        prefix_MA = true,
        prefix_ADM = true,
        prefix_STA = true,
        prefix_ZGA = true,
        prefix_GA = true,
    },
    keys = {
        GUI = "F3",
        OpenReport = "None",
        GiveOnline = "None",
        SendRecon = 'None',
    },
    position = {
        reX = 0,
        reY = 0,
        change_timescreen = false,
        timescreen_posX = 0,
        timescreen_posY = 1,
    },
    settings_start = {
        others = true,
        renders = true,
        iplogger = false,
        adminstate = true,
        ATEvents = false,
    },
    access = {
        ban  = false,
        mute = false,
        jail = false,
    },
    scoreboard = {
        type = 0,
        titlebar = 2,
        fontSize = 2,
        nickType = 0,
        clog = true,
    },
    report_bind_name = {},
    report_bind_text = {},
    flood_text = {},
    flood_name = {},
	cheking_list = {},
}, direct)
inicfg.save(config, direct)

local cheking = {}
new_check_nick = imgui.ImBuffer(32)

for _, originalNick in pairs(config.cheking_list) do
    if originalNick and originalNick ~= "" then
        cheking[originalNick:lower()] = originalNick
    end
end

function ConfigSave()
    inicfg.save(config, direct)
    return true
end

function saveCheking()
    config.cheking_list = {}
    for _, originalNick in pairs(cheking) do
        table.insert(config.cheking_list, originalNick)
    end
    ConfigSave()
end

local elm = {
    boolean = {
		notf_zloup = imgui.ImBool(config.main.notf_zloup),
		notf_flood = imgui.ImBool(config.main.notf_flood),
		adminforms = imgui.ImBool(config.main.adminforms),
        auto_adminforms = imgui.ImBool(config.main.auto_adminforms),
        auto_login = imgui.ImBool(config.main.auto_login),
        random_prefix = imgui.ImBool(config.main.random_prefix),
        custom_tab = imgui.ImBool(config.main.custom_tab),
        recon_menu = imgui.ImBool(config.main.recon_menu),
        checkweaponhack = imgui.ImBool(config.main.checkweaponhack),
        timescreen = imgui.ImBool(config.main.timescreen),
        key_helper = imgui.ImBool(config.main.key_helper),
		automultiply = imgui.ImBool(config.main.automultiply),
		radar_recon = imgui.ImBool(config.main.radar_recon),
		report_interface = imgui.ImBool(config.main.report_interface),
		split_long_a = imgui.ImBool(config.main.split_long_a),
        auto_online = imgui.ImBool(config.main.auto_online),
		timescreen_rgb = imgui.ImBool(config.main.timescreen_rgb),
		chatlogger_enabled = imgui.ImBool(config.main.chatlogger_enabled),
    },
    random_enabled = {
        prefix_MA = imgui.ImBool(config.random_enabled.prefix_MA),
        prefix_ADM = imgui.ImBool(config.random_enabled.prefix_ADM),
        prefix_STA = imgui.ImBool(config.random_enabled.prefix_STA),
        prefix_ZGA = imgui.ImBool(config.random_enabled.prefix_ZGA),
        prefix_GA = imgui.ImBool(config.random_enabled.prefix_GA),
    },
    int = {
        styleImGUI = imgui.ImInt(config.main.styleImGUI),
        font = imgui.ImInt(config.main.font),
		timescreen_scale = imgui.ImInt(config.main.timescreen_scale or 15),
    },
    input = {
		password = imgui.ImBuffer(tostring(config.main.password), 50),
		timescreen_color = imgui.ImBuffer(tostring(config.main.timescreen_color or "FFFFFF"), 10),
        after_login_commands  = imgui.ImBuffer(tostring(config.main.after_login_commands or ""), 512),
        auto_prefix = imgui.ImBuffer(tostring(config.main.auto_prefix or ""), 256),
        set_punish_in_recon = imgui.ImBuffer(100),
        set_time_punish_in_recon = imgui.ImBuffer(100),
		prefix_MA  = imgui.ImBuffer(tostring(config.colours.prefix_MA), 50),
		prefix_ADM = imgui.ImBuffer(tostring(config.colours.prefix_ADM), 50),
		prefix_STA = imgui.ImBuffer(tostring(config.colours.prefix_STA), 50),
		prefix_ZGA = imgui.ImBuffer(tostring(config.colours.prefix_ZGA), 50),
		prefix_GA = imgui.ImBuffer(tostring(config.colours.prefix_GA), 50),
    },
	binder = {
		reports = {
			prefix = imgui.ImBuffer(256),
			name = imgui.ImBuffer(256),
			text = imgui.ImBuffer(65536),
		},
		flood = {
			text = imgui.ImBuffer(65536),
			name = imgui.ImBuffer(256),
		},
	},
	report = {
		text = imgui.ImBuffer(4096),
		answers_search = imgui.ImBuffer(256),
	},
    position = {
        reX = config.position.reX,
        reY = config.position.reY,
        timescreen_posX = config.position.timescreen_posX or (sw - 290),
        timescreen_posY = config.position.timescreen_posY or 1,
        change_timescreen = false,
        change_recon = false,
    },
	settings_start = {
		others = imgui.ImBool(config.settings_start.others),
		renders = imgui.ImBool(config.settings_start.renders),
		iplogger = imgui.ImBool(config.settings_start.iplogger),
		ATEvents = imgui.ImBool(config.settings_start.ATEvents),
		adminstate = imgui.ImBool(config.settings_start.adminstate),
	},
}

config.access.ban  = config.access.ban  ~= false
config.access.mute = config.access.mute ~= false
config.access.jail = config.access.jail ~= false

elm.boolean.access_ban  = imgui.ImBool(not config.access.ban)
elm.boolean.access_mute = imgui.ImBool(not config.access.mute)
elm.boolean.access_jail = imgui.ImBool(not config.access.jail)
-- ================================================================
-- ## ОСНОВНЫЕ НАСТРОЙКИ (КОНФИГ) ##
-- ================================================================


-- ================================================================
-- ## ИНИЦИАЛИЗАЦИЯ ПОДСКРИПТОВ ##
-- ================================================================
local events_res,     events  = false, nil
local other_res,      pother  = false, nil
local adminstate_res, admst   = false, nil
local renders_res,    prender = false, nil
local iplogger_res,   iplp    = false, nil
local function TryLoadSubscript(key, path)
    local s = elm.settings_start[key]
    local enabled = s and s.v
    if not enabled then
        return false, nil
    end
    local ok, mod = pcall(import, path)
    if ok and mod then
        return true, mod
    end
    sampAddChatMessage(tag .. "{FF5555}Не удалось загрузить " .. path, -1)
    return false, nil
end

other_res,      pother  = TryLoadSubscript("others",     "resource/admcheat.lua")
-- other_res,      pother  = TryLoadSubscript("others",     "resource/admcheat.luac")
adminstate_res, admst   = TryLoadSubscript("adminstate", "resource/adminstate.lua")
renders_res,    prender = TryLoadSubscript("renders",    "resource/renders.lua")
events_res,     events  = TryLoadSubscript("ATEvents",   "resource/ATEvents.lua")

-- ================================================================
-- ## ИНИЦИАЛИЗАЦИЯ ПОДСКРИПТОВ ##
-- ================================================================

local function ResetReconState()
    ATRecon.v = false
    control_to_player = false
    reconCursor = false
    recon_id = -1
    select_recon = 0
    if other_res then pother.ActivateKeySync("off") end
end


-- ================================================================
-- ## СКОРБОРД (TAB) ##
-- ================================================================
local show_main_window = imgui.ImBool(false)
local show_set_window  = imgui.ImBool(false)
local searchBuf = imgui.ImBuffer(256)
local playerCount = 0
local cType = imgui.ImInt(config.scoreboard.type)
local bTitlebar = imgui.ImInt(config.scoreboard.titlebar)
local cNType = imgui.ImInt(config.scoreboard.nickType)
local bLog = imgui.ImBool(config.scoreboard.clog)
local logConFilter = imgui.ImBuffer(128)
local ScrollToButton = false
local logConnect = {}
local focusId = -1
local scrollToId = false
local gameInit = false



function toggleScoreboard(flag)
    if type(flag) == 'boolean' then
        show_main_window.v = flag
    else
        show_main_window.v = not show_main_window.v
    end
    if show_main_window.v and focusId > -1 then scrollToId = true end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        ConfigSave()
    end
end


-- ================================================================
-- ## СКОРБОРД (TAB) ##
-- ================================================================


-- ================================================================
-- ## ЗАГРУЗКА ШРИФТОВ IMGUI ##
-- ================================================================
local fa_glyph_ranges  = imgui.ImGlyphRanges({ fa.min_range,  fa.max_range  })
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })
local cyr_glyph_ranges = nil

function imgui.BeforeDrawFrame()
    if not fontChanged then
        fontChanged = true
        cyr_glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
        imgui.GetIO().Fonts:Clear()
        imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arialbd.ttf', 14, nil, cyr_glyph_ranges)

        local fai_font_config = imgui.ImFontConfig()
        fai_font_config.MergeMode = true
        fai_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, fai_font_config, fai_glyph_ranges)
        minimalfont = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 15.0, fai_font_config, fa_glyph_ranges)

        local fa_font_config = imgui.ImFontConfig()
        fa_font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, fa_font_config, fa_glyph_ranges)

        imgui.RebuildFonts()
    end
end
-- ================================================================
-- ## ЗАГРУЗКА ШРИФТОВ IMGUI ##
-- ================================================================




-- ================================================================
-- ## АНИМАЦИЯ TIMESCREEN (RGB) ##
-- ================================================================
local animation_progress_ts = 0
local direction_ts = 1
local last_time_ts = nil
local function getGradientColor_ts(progress)
    if progress < 0.33 then
        local p = progress / 0.33
        return 255, 0, math.floor(255 * p)
    elseif progress < 0.66 then
        local p = (progress - 0.33) / 0.33
        return math.floor(255 - 128 * p), 0, 255
    else
        local p = (progress - 0.66) / 0.34
        return math.floor(127 - 127 * p), 0, 255
    end
end
local function getTimeScreenColor()
    local current_time = os.clock()
    local delta = current_time - (last_time_ts or current_time)
    last_time_ts = current_time
    animation_progress_ts = animation_progress_ts + delta * 0.4 * direction_ts
    if animation_progress_ts >= 1.0 then animation_progress_ts = 1.0; direction_ts = -1
    elseif animation_progress_ts <= 0.0 then animation_progress_ts = 0.0; direction_ts = 1 end
    return getGradientColor_ts(animation_progress_ts)
end
-- ================================================================
-- ## АНИМАЦИЯ TIMESCREEN (RGB) ##
-- ================================================================



-- ================================================================
-- ## ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ##
-- ================================================================

local function SaveOrEditBind(isEdit, pos, entries, itemNameForLog, saveFn)
    if not isEdit then
        for _, e in ipairs(entries) do
            table.insert(e.list, e.value)
        end
    else
        for _, e in ipairs(entries) do
            table.insert(e.list, pos, e.value)
            table.remove(e.list, pos + 1)
        end
    end
    if (saveFn or ConfigSave)() then
        sampAddChatMessage(tag .. 'Бинд "' .. u8:decode(itemNameForLog) ..
            (isEdit and '" отредактирован!' or '" создан!'), -1)
        return true
    end
    return false
end

local function RemoveBind(lists, pos, itemNameForLog, saveFn)
    for _, list in ipairs(lists) do
        table.remove(list, pos)
    end
    sampAddChatMessage(tag .. 'Бинд "' .. u8:decode(itemNameForLog) .. '" удален!', -1)
    ;(saveFn or ConfigSave)()
end


math.randomseed(os.time())
local function getRandomColor()
    local brightHex = {"4","5","6","7","8","9","A","B","C","D","E","F"}
    local mcolor = ""
    for i = 1, 6 do mcolor = mcolor .. brightHex[math.random(1, #brightHex)] end
    return mcolor
end
function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local pid = atlibs.getMyId()
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(recon_id) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end
addEventHandler('onWindowMessage', function(msg, wparam, lparam)
    if msg ~= 0x100 and msg ~= 0x101 then return end
    if elm.boolean.custom_tab.v and wparam == VK_TAB then
        consumeWindowMessage(true, false)
        return
    end
end)

function sampev.onPlayerJoin(id, color, npc, nickname)
	local lowerNick = nickname:lower()
    if cheking[lowerNick] then
		sampAddChatMessage(tag .. 'Игрок ' .. nickname .. ' в игре! Его ID: ' .. id, -1)
    end
	if gameInit then
        logConnect[#logConnect+1] = string.format("[%s] %s[%d] подключился", os.date("%H:%M:%S"), nickname, id)
        ScrollToButton = true
    end
end

function sampev.onPlayerQuit(id, reason)
    if gameInit then
        local quit_reasons = {"вылет", "вышел", "кикнут"}
        logConnect[#logConnect+1] = string.format("[%s] %s[%d] %s", os.date("%H:%M:%S"), sampGetPlayerNickname(id), id, quit_reasons[reason+1] or "неизвестно")
        ScrollToButton = true
    end
end
function imgui.SettingsButton()
    imgui.SameLine()
    imgui.PushFont(minimalfont)
    imgui.TextDisabled(fa.ICON_FA_COG)
    imgui.PopFont()
    return imgui.IsItemClicked()
end

-- ================================================================
-- ## ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ##
-- ================================================================


-- ================================================================
-- ## FFI СТРУКТУРЫ (KILLCHAT) ##
-- ================================================================
ffi.cdef[[
struct stKillEntry
{
	char     szKiller[25];
	char     szVictim[25];
	uint32_t clKillerColor;
	uint32_t clVictimColor;
	uint8_t  byteType;
} __attribute__ ((packed));

struct stKillInfo
{
	int               iEnabled;
	struct stKillEntry killEntry[5];
	int               iLongestNickLength;
	int               iOffsetX;
	int               iOffsetY;
	void             *pD3DFont;
	void             *pWeaponFont1;
	void             *pWeaponFont2;
	void             *pSprite;
	void             *pD3DDevice;
	int               iAuxFontInited;
	void             *pAuxFont1;
	void             *pAuxFont2;
} __attribute__ ((packed));
]]

function sampev.onPlayerDeathNotification(killerId, killedId, reason)
	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local myid = atlibs.getMyId()
	local n_killer = (sampIsPlayerConnected(killerId) or killerId == myid) and sampGetPlayerNickname(killerId) or nil
	local n_killed = (sampIsPlayerConnected(killedId) or killedId == myid) and sampGetPlayerNickname(killedId) or nil
	lua_thread.create(function()
		wait(0)
		if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', (n_killer .. '[' .. killerId .. ']'):sub(1, 24)) end
		if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', (n_killed .. '[' .. killedId .. ']'):sub(1, 24)) end
	end)
end
-- ================================================================
-- ## FFI СТРУКТУРЫ (KILLCHAT) ##
-- ================================================================


-- ================================================================
-- ## ДЕТЕКТОР ФЛУДА ##
-- ================================================================
local string_number_max = 4
local msgs = {chat = {}}
local string_time = 30

function detectedFlood(name, id, msg, time, count, original_text)
	if not isGamePaused() and not isPauseMenuActive() then
		sampAddChatMessage(tag .. "--------------------------------------------------------------------------------", -1)
		sampAddChatMessage(tag .. "{FF0000}Обнаружен флуд! "..count.." сообщения, за "..time.." секунд из ".. string_time .. " разрешенных!", -1)
		sampAddChatMessage(tag .. "Сообщение: "..msg.." | Отправитель: "..sampGetPlayerNickname(tonumber(id)).." ("..id..")", -1)
		sampAddChatMessage(tag .. "--------------------------------------------------------------------------------", -1)
	end
end
-- ================================================================
-- ## ДЕТЕКТОР ФЛУДА ##
-- ================================================================


-- ================================================================
-- ## ДЕТЕКТОР ЗЛОУПОТРЕБЛЕНИЯ СИМВОЛАМИ ##
-- ================================================================
function getCharCount(str)
    local count = 0
    for _ in str:gmatch("[\128-\191]?.") do
        count = count + 1
    end
    return count
end

function findLongestWord(text)
    local longest = ""
    local longest_len = 0
    local current_word = ""
    for char in text:gmatch("[\128-\191]?.") do
        if char ~= " " then
            current_word = current_word .. char
        else
            local len = getCharCount(current_word)
            if len > longest_len then
                longest = current_word
                longest_len = len
            end
            current_word = ""
        end
    end
    local len = getCharCount(current_word)
    if len > longest_len then
        longest = current_word
        longest_len = len
    end
    return longest, longest_len
end

function getMaxSameChars(word)
    if word == "" then return 0 end
    local chars = {}
    for char in word:gmatch("[\128-\191]?.") do
        table.insert(chars, char)
    end
    local max_same = 1
    local current = 1
    for i = 2, #chars do
        if chars[i] == chars[i-1] then
            current = current + 1
            if current > max_same then max_same = current end
        else
            current = 1
        end
    end
    return max_same
end
-- ================================================================
-- ## ДЕТЕКТОР ЗЛОУПОТРЕБЛЕНИЯ СИМВОЛАМИ ##
-- ================================================================


-- ================================================================
-- ## АВТО /ONLINE ##
-- ================================================================
function drawOnline()
    if elm.boolean.auto_online.v then
        while true do
            if sampIsChatInputActive() == false then
                sampAddChatMessage(tag .. "Запуск переменной AutoOnline. Ожидайте выдачи.", -1)
                wait(62000)
                sampSendChat("/online")
                wait(100)
                local c = math.floor(sampGetPlayerCount(false) / 10)
                sampSendDialogResponse(1098, 1, c - 1)
                sampCloseCurrentDialogWithButton(0)
                wait(650)
            end
            wait(1)
        end
    end
end
-- ================================================================
-- ## АВТО /ONLINE ##
-- ================================================================


-- ================================================================
-- ## КОМАНДА /A (РАЗДЕЛЕНИЕ ДЛИННЫХ СООБЩЕНИЙ) ##
-- ================================================================
local function cmd_a(arg)
    if not arg or arg == "" then return end
    lua_thread.create(function()
        if elm.boolean.split_long_a.v and #arg > 76 then
            local len  = #arg
            local mid  = math.floor(len / 2)
            local part1 = arg:sub(1, mid)
            local part2 = arg:sub(mid + 1)
            sampSendChat("/a " .. part1)
            wait(2500)
            sampSendChat("/a " .. part2)
        else
            sampSendChat("/a " .. arg)
        end
    end)
end
-- ================================================================
-- ## КОМАНДА /A (РАЗДЕЛЕНИЕ ДЛИННЫХ СООБЩЕНИЙ) ##
-- ================================================================


-- ================================================================
-- ## ОБРАБОТКА АДМИН ФОРМ ##
-- ================================================================
function processAdminForm(form)
    local command   = form:match("^/(%S+)")
    local player_id = form:match("/%w+ (%d+)")
    if command and player_id then
        if command == "iban" or command == "ban" or command == "sban" or command == "siban" then
            sampSendChat('/getip ' .. player_id)
        end
    end
    if command then
        sampSendChat(form)
        form = ''
    end
end

function registerFormCommands()
    sampRegisterChatCommand('fac', function()
        if not form_active then return end
        sampSendChat("/a Принял <3")
        processAdminForm(form)
        ffi.cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
        form = ''
        form_active = false
    end)
    sampRegisterChatCommand('fn', function()
        if not form_active then return end
        sampSendChat('/a Отклонено((')
        form = ''
        form_active = false
    end)
end
-- ================================================================
-- ## ОБРАБОТКА АДМИН ФОРМ ##
-- ================================================================


-- ================================================================
-- ## ФУНКЦИИ РЕКОНА ##
-- ================================================================
function change_position_recon()
    if elm.position.change_recon then
        local X, Y = getCursorPos()
        config.position.reX, config.position.reY = X, Y
        if isKeyJustPressed(49) then
            elm.position.change_recon = false
            ConfigSave()
        end
    end
end

function change_position_timescreen()
    if elm.position.change_timescreen then
        local X, Y = getCursorPos()
        elm.position.timescreen_posX = X
        elm.position.timescreen_posY = Y
        config.position.timescreen_posX = X
        config.position.timescreen_posY = Y
        if isKeyJustPressed(49) then
            elm.position.change_timescreen = false
            ConfigSave()
        end
    end
end

function sampev.onShowTextDraw(id, data)
    if not elm.boolean.recon_menu.v then return end
    if data.text:find('~g~::Health:~n~') then return false end
    if data.text:find('REFRESH') then
        refresh_button_textdraw = id
        return false
    end
    if data.text:find('(%d+) : (%d+)') then
        info_textdraw_recon = id
        return false
    end
    for _, v in pairs(text_recon) do
        if data.text:find(v) and id ~= 244 then return false end
    end
    if ids_recon[id] then return false end
    if id == 2050 then
        local text = data.text
        local clean_text = text:gsub("~.-~", ""):gsub("%s+", " ")
        local player_id = clean_text:match("%((%d+)%)")
        if player_id then
            player_id = tonumber(player_id)
            if player_id ~= recon_id_num then
                recon_id_num = player_id
                recon_id = tostring(player_id)
                if sampIsPlayerConnected(player_id) then
                    recon_nick = sampGetPlayerNickname(player_id)
                else
                    recon_nick = clean_text:match("^(.-)%s*%(%d+%)$") or "-"
                    recon_nick = recon_nick:match("^%s*(.-)%s*$") or recon_nick
                end
				if elm.boolean.radar_recon.v then
					memory.write(sampGetBase() + 643864, 37008, 2, true)
				end
                if other_res then
					pother.ActivateKeySync(player_id)
                end
            end
            return false
        end
    end
end

function sampev.onTextDrawSetString(id, text)
    if id == info_textdraw_recon and elm.boolean.recon_menu.v then
        info_to_player = atlibs.textSplit(text, "~n~")
    end
end

function sampev.onSendCommand(command)
    local id = string.match(command, "/re (%d+)")
    if id ~= nil and elm.boolean.recon_menu.v and sampIsPlayerConnected(id) then
        control_to_player = true
        if control_to_player then
            ATRecon.v = true
            if other_res then
                pother.ResetPlayerDevice(id)
                pother.ActivateKeySync(tonumber(id))
            end
        end
        recon_id = id
    end
end
-- ================================================================
-- ## ФУНКЦИИ РЕКОНА ##
-- ================================================================


-- ================================================================
-- ## ИВЕНТ: СЕРВЕРНЫЕ СООБЩЕНИЯ ##
-- ================================================================
function sampev.onServerMessage(color, text)
	gameInit = true
	if elm.boolean.chatlogger_enabled.v then
		local chatlog = io.open(getFileName(), "r+")
		if chatlog then
			chatlog:seek("end", 0)
			local chatTime = "[" .. os.date("*t").hour .. ":" .. os.date("*t").min .. ":" .. os.date("*t").sec .. "] "
			chatlog:write(enc(chatTime .. text) .. "\n")
			chatlog:flush()
			chatlog:close()
		end
	end
	local _, _, _, lc_nick, _, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")
	if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then
		if elm.boolean.adminforms.v and lc_text ~= nil then
			for k, v in ipairs(reasons) do
				if lc_text:match(v) ~= nil then
					if lc_text:find("/(.+) (%d+) (%d+) (.+)") or lc_text:find('/(.+) (.+) (%d+) (.+)') or lc_text:find('/iunban (.+)') then
						if v == "/iunban" then
							form = lc_text
						else
							if lc_text:find(lc_nick) then form = lc_text
							else form = lc_text .. " // " .. lc_nick end
						end
					else
						form = ''
					end
					if #form > 1 then
						sampAddChatMessage(tag .. "Форма: " .. form, -1)
						if elm.boolean.auto_adminforms.v then
							sampSendChat("/a Автоматическое принятие формы")
							processAdminForm(form)
							ffi.cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
							form = ''
						else
							form_active = true
						end
						break
					end
				end
			end
		end
	end

	-- Сбор IP
	if checkip then
		local reg2 = text:match("IP%-REG:%s*(%d+%.%d+%.%d+%.%d+)")
		if reg2 then reg_ip2 = reg2 end
		local reg = text:match("IP:%s*(%d+%.%d+%.%d+%.%d+)")
		if reg then reg_ip = reg end
		local last = text:match("LAST%s*IP:%s*(%d+%.%d+%.%d+%.%d+)")
		if last then last_ip = last end
	end

	-- Проверка WeaponHack
	if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then
		if elm.boolean.checkweaponhack.v then
			if text:match('%<AC%-WARNING%> {ffffff}(.+)%[(%d+)%]{82b76b} подозревается в использовании чит%-программ: {ffffff}Weapon hack') then
				iwep_check_enabled = true
				if not sampIsDialogActive() then
					lua_thread.create(function()
						sampAddChatMessage("{82b76b}" .. text, 0x82b76b)
						sampSendChat('/iwep ' .. string.match(text, "%[(%d+)%]"))
						wait(300)
						iwep_check_enabled = false
					end)
				end
			end
		end
	end
	-- Проверка злоупотребления символами
	if elm.boolean.notf_zloup.v then
		local name, id, msg
		name, id, msg = text:match("%[VIP чат%] (.+)%[(%d+)%]: (.+)")
		if not name then
			local name_temp, id_temp, color, msg_temp = text:match("(.+)%((.+)%): {(.+)}(.+)")
			if name_temp and id_temp and msg_temp then
				name = name_temp; id = id_temp; msg = msg_temp
			end
		end
		if name and id and msg then
			local longest_word, word_length = findLongestWord(msg)
			local max_same = getMaxSameChars(longest_word)
			local is_flood = false
			local flood_count = 0
			local flood_type  = ""
			if word_length >= 30 then
				is_flood    = true
				flood_count = word_length
				flood_type  = "Символов без пробелов подряд"
			end
			if is_flood then
				sampAddChatMessage(tag .. "--------------------------------------------------------------------------------", -1)
				sampAddChatMessage(tag .. "{FF0000}Обнаружено злоупотребление символами!", -1)
				sampAddChatMessage(tag .. "Сообщение: " .. name .. " (" .. id .. "): {FFFFFF}" .. msg, -1)
				sampAddChatMessage(tag .. flood_type .. ": " .. flood_count, -1)
				sampAddChatMessage(tag .. "--------------------------------------------------------------------------------", -1)
			end
		end
	end

	-- Игрок не в сети
	if text:find("Игрок не в сети") then
        ResetReconState()
		sampSendChat("/reoff")
        return true
    end

	-- Автовход в админку + префикс + команды
	if text:find("Администратор " .. name) and text:find("авторизовался в админ") then
		local myNick = atlibs.getMyNick()
		local id  = atlibs.getMyId()
		lua_thread.create(function()
			wait(100)
			if elm.boolean.random_prefix.v then
				for pref in elm.input.auto_prefix.v:gmatch("[^\n]+") do
					pref = pref:match("^%s*(.-)%s*$")
					local color = getRandomColor()
					sampSendChat("/prefix " .. id .. " " .. u8:decode(pref) .. " " .. color)
				end
			end
			if #elm.input.after_login_commands.v > 0 then
				local commands_text = elm.input.after_login_commands.v:gsub("~", "\n")
				local cmds = atlibs.string_split(commands_text, "\n")
				for _, cmd in ipairs(cmds) do
					cmd = cmd:match("^%s*(.-)%s*$")
					if #cmd > 0 then
						if cmd:sub(1,1) ~= "/" then cmd = "/" .. cmd end
						sampSendChat(u8(cmd))
					end
				end
			end
		end)
	end

	-- Проверка на флуд
	if elm.boolean.notf_flood.v then
		local _, check_flood_id, _, check_flood = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
		local _, check_floodv_id, check_floodv = string.match(text, "[VIP чат] (.+)%[(%d+)%]: (.+)")
		if not isGamePaused() and not isPauseMenuActive() then
			local playername, playerid, msg
			if check_floodv ~= nil and check_floodv_id ~= nil then
				playername, playerid, msg = text:match("[VIP чат] (.+)%[(%d+)%]: (.+)")
			elseif check_flood ~= nil and check_flood_id ~= nil then
				playername, playerid, _, msg = text:match("(.+)%((.+)%): {(.+)}(.+)")
			else
				return true
			end
			if not msgs.chat[playername] then msgs.chat[playername] = {} end
			local current_time = os.clock()
			local new_messages = {}
			for _, v in ipairs(msgs.chat[playername]) do
				if current_time - v.time <= string_time then table.insert(new_messages, v) end
			end
			msgs.chat[playername] = new_messages
			local last_msg = msgs.chat[playername][#msgs.chat[playername]]
			if last_msg and last_msg.msg == msg and last_msg.id == playerid then
				table.insert(msgs.chat[playername], {id = playerid, msg = msg, time = current_time})
				local identical_count = 0
				for i = #msgs.chat[playername], 1, -1 do
					if msgs.chat[playername][i].msg == msg and msgs.chat[playername][i].id == playerid then
						identical_count = identical_count + 1
					else break end
				end
				if identical_count >= string_number_max then
					local time_diff = current_time - msgs.chat[playername][#msgs.chat[playername] - identical_count + 1].time
					if time_diff < string_time then
						detectedFlood(playername, playerid, msg, math.ceil(time_diff), identical_count, nil)
						msgs.chat[playername] = {}
					else
						local last_only = {}
						for i = #msgs.chat[playername] - identical_count + 2, #msgs.chat[playername] do
							table.insert(last_only, msgs.chat[playername][i])
						end
						msgs.chat[playername] = last_only
					end
				end
			else
				if #msgs.chat[playername] > 0 and last_msg and (last_msg.msg ~= msg or last_msg.id ~= playerid) then
					msgs.chat[playername] = {}
				end
				table.insert(msgs.chat[playername], {id = playerid, msg = msg, time = current_time})
			end
			while #msgs.chat[playername] > 20 do table.remove(msgs.chat[playername], 1) end
		end
	end
    return true
end
-- ================================================================
-- ## ИВЕНТ: СЕРВЕРНЫЕ СООБЩЕНИЯ ##
-- ================================================================


-- ================================================================
-- ## ИВЕНТ: ДИАЛОГИ ##
-- ================================================================
function sampev.onShowDialog(id, style, title, button1, button2, text)
	-- Смена названия банды
	if title == '{9980cc}Статистика персонажа' and changegname then
		if param_for_chgn ~= nil then
			sampAddChatMessage("ID: " .. param_for_chgn, -1)
			dialog_text = atlibs.string_split(text, '\n')
			for _, dialog_text_value in pairs(dialog_text) do
				if dialog_text_value:match("{ffffff}ID:(.+)") then
					id_gang = dialog_text_value:match("{ffffff}ID:(.+)")
					id_gang = id_gang:gsub("{......}", "")
					param_for_chgn2 = id_gang
				end
			end
		end
	end

	-- Автоблокировка за чит на оружие
	if button1 == 'Готово' and button2 ~= 'Закрыть' and iwep_check_enabled then
		lua_thread.create(function()
			need_confirmation = false
			local text = atlibs.string_split(text, '\n')
			local player_cheater   = false
			local ban_player_name  = nil
			local weapon_names = {
				[10]='Член/дилдо',[11]='Член/дилдо',[12]='Член/дилдо',[13]='Член/дилдо',
				[35]='РПГ',[36]='Ракетная установка',[38]='Миниган',
			}
			local found_weapons = {}
			for i = 1, #text - 1 do
				local _, weapon, patron = text[i]:match('(%d+)%s+Weapon: (%d+)%s+Ammo: (.+)')
				if weapon then
					weapon = tonumber(weapon)
					table.insert(found_weapons, {weapon=weapon, patron=patron, has_minus=text[i]:find('%-')~=nil})
				end
			end
			-- Проверка: Миниган, рпг, ракетную установку с дальнейшей проверкой и подтверждения
			local function ask_confirmation(wname, weapon, patron, hint)
				detected_player = title; detected_weapon = weapon; detected_patron = patron
				need_confirmation = true; confirmed_action = nil; pause_check = true
				sampAddChatMessage(tag .. title .. '[' .. atlibs.playernickname(title) .. ']', -1)
				sampAddChatMessage(tag .. 'Оружие: ' .. wname .. '(' .. weapon .. '). Патроны: ' .. patron, -1)
				sampAddChatMessage(tag .. hint, -1)
				sampAddChatMessage(tag .. 'Подтвердите бан: /bda (да) или /bne (нет)', -1)
				wait(100)
				ffi.cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
				while need_confirmation do wait(100) end
				pause_check = false
				if confirmed_action == 'yes' then sampAddChatMessage(tag .. 'Блокировка подтверждена.', -1); return true
				else sampAddChatMessage(tag .. 'Блокировка отклонена.', -1); return false end
			end
	
			-- Проверка: weapon 0 с патронами >= 1 (автобан)
			if not player_cheater then
				for _, entry in ipairs(found_weapons) do
					local ammo = tonumber(tostring(entry.patron):match('%d+')) or 0
					if entry.weapon == 0 and ammo >= 1 then
						sampAddChatMessage(tag .. title .. '[' .. atlibs.playernickname(title) .. ']', -1)
						sampAddChatMessage(tag .. 'Оружие (ID): ' .. entry.weapon .. '. Патроны: ' .. entry.patron, -1)
						wait(100); ffi.cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
						player_cheater = true; ban_player_name = title; break
					end
				end
			end
			-- Проверка: если патроны минус, то есть бесконечные
			for _, entry in ipairs(found_weapons) do
				if entry.has_minus then
					sampAddChatMessage(tag .. title .. '[' .. atlibs.playernickname(title) .. ']', -1)
					sampAddChatMessage(tag .. 'Оружие (ID): ' .. entry.weapon .. '. Патроны: ' .. entry.patron, -1)
					wait(100); ffi.cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
					player_cheater = true; ban_player_name = title; break
				end
			end
			-- Проверка: на дилдо, их невозможно получить серверным путем - читер.
			if not player_cheater then
				for _, entry in ipairs(found_weapons) do
					local w = entry.weapon
					if w==10 or w==11 or w==12 or w==13 then
						sampAddChatMessage(tag .. 'Обнаружено запрещённое оружие у ' .. title .. '[' .. atlibs.playernickname(title) .. ']', -1)
						sampAddChatMessage(tag .. 'Оружие: ' .. weapon_names[w] .. '(' .. w .. '). Патроны: ' .. entry.patron, -1)
						wait(100); ffi.cast("void (*__stdcall)()", sampGetBase() + 0x70FC0)()
						player_cheater = true; ban_player_name = title; break
					end
				end
			end
			if not player_cheater then
				for _, entry in ipairs(found_weapons) do
					if entry.weapon == 38 then
						if ask_confirmation(weapon_names[38], entry.weapon, entry.patron, 'Проверьте, является ли игрок админом. Если не админ - читер.') then
							player_cheater = true; ban_player_name = title
						end; break
					end
				end
			end
			if not player_cheater then
				for _, entry in ipairs(found_weapons) do
					if entry.weapon == 35 or entry.weapon == 36 then
						if ask_confirmation(weapon_names[entry.weapon], entry.weapon, entry.patron, 'Проверьте, есть ли у игрока вип DIAMOND и выше. Если нет - он читер.') then
							player_cheater = true; ban_player_name = title
						end; break
					end
				end
			end
			wait(100); sampCloseCurrentDialogWithButton(0)
			if player_cheater and ban_player_name then
				while sampIsDialogActive() do wait(0) end
				local playerId = atlibs.playernickname(ban_player_name)
				if playerId and sampIsPlayerConnected(tonumber(playerId)) then
					sampSendChat('/getip ' .. playerId)
					sampSendChat('/iban ' .. playerId .. ' 7 Weapon Hack')
				else
					sampSendChat('/ioffban ' .. ban_player_name .. ' 7 Weapon Hack')
				end
			end
			detected_player = nil
		end)
	end

    if config.main.report_interface then
        if id == 2349 then
            if text:match("Игрок: {......}(%S+)") and text:match("Жалоба:\n{......}(.*)\n\n{......}") then
                nick_rep = text:match("Игрок: {......}(%S+)")
                text_rep = text:match("Жалоба:\n{......}(.*)\n\n{......}")
                pid_rep  = atlibs.playernickname(nick_rep)
                if pid_rep == nil then pid_rep = "None" end
                rep_text  = u8:encode(text_rep)
                id_punish = rep_text:match("(%d+)")
                original_rep_text = rep_text
                is_layout_changed = false
            end
            if not ATReportShow.v then
                ATReportShow.v = true
				need_focus_input = true
            end
            return false
		elseif ATReportShow.v then
			ATReportShow.v  = false
		end
        if id == 2350 then return false end
        if id == 2351 then return false end
    end
	-- Автологин
	if id == 658 and elm.boolean.auto_login.v then
        if button1 == 'Принять' then
			sampSendDialogResponse(id, 0, -1, "")
			sampSendChat("/alogin " .. u8:decode(elm.input.password.v))
        end
		return false
    end
end
-- ================================================================
-- ## ИВЕНТ: ДИАЛОГИ ##
-- ================================================================


-- ================================================================
-- ## ИВЕНТ: ИГРОВОЙ ТЕКСТ ##
-- ================================================================
function sampev.onDisplayGameText(style, time, text)
	if text:find("~w~RECON ~r~OFF") and elm.boolean.recon_menu.v then
		ResetReconState()
	end
end
-- ================================================================
-- ## ИВЕНТ: ИГРОВОЙ ТЕКСТ ##
-- ================================================================


-- ================================================================
-- ## ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ НАКАЗАНИЙ ##
-- ================================================================
local function sendPunishment(cmd, id, time, reason, hasAccess)
    local needGetIp = cmd == "/ban" or cmd == "/iban" or cmd == "/sban" or cmd == "/siban" or cmd == "/jail"
    if needGetIp then
        sampSendChat('/getip ' .. id)
    end
    local body = cmd .. " " .. id .. " " .. time .. " " .. reason
    sampSendChat(hasAccess and body or ("/a " .. body))
end

local function handleMultiplyLogic(key, data, playerID, playerNick, hasAccess, isCheatJail)
    local foundRecord   = false
    local newTimeToSend = nil
    local recordIndex   = nil

    for i, v in ipairs(multiply_punish_frame) do
        local splited = atlibs.textSplit(v, "~")
        if #splited >= 6 then
            local recAdmin = splited[5] or ""
            if splited[1] == playerNick and splited[2] == data.reason
                and (recAdmin == "" or recAdmin == name) and splited[6] == data.cmd
            then
                foundRecord   = true
                newTimeToSend = (tonumber(splited[3]) or 0) + tonumber(data.time)
                recordIndex   = i
                if isCheatJail then
                    local tempMult = math.floor(newTimeToSend / tonumber(data.time))
                    if tempMult >= 3 then
                        local nick = sampIsPlayerConnected(playerID) and sampGetPlayerNickname(playerID) or "-"
                        if config.access.ban then
                            sampSendChat("/iban " .. playerID .. " 7 cheat x" .. tempMult)
                        else
                            sampSendChat("/a /iban " .. playerID .. " 7 cheat x" .. tempMult)
                        end
                        table.remove(multiply_punish_frame, i)
                        return true
                    end
                end
                break
            end
        end
    end

    local maxMult = isCheatJail and 3 or 10

    if foundRecord and newTimeToSend then
        local multiplier = math.floor(newTimeToSend / tonumber(data.time))
        if multiplier > maxMult then
            multiplier    = maxMult
            newTimeToSend = tonumber(data.time) * maxMult
            sampAddChatMessage(tag .. "Достигнут максимальный множитель x" .. maxMult .. " для " .. data.cmd, -1)
        end
        multiply_punish_frame[recordIndex] = playerNick .. "~" .. data.reason .. "~"
            .. tostring(newTimeToSend) .. "~" .. os.date("%H:%M:%S") .. "~" .. name .. "~" .. data.cmd
        sendPunishment(data.cmd, playerID, newTimeToSend, data.reason .. " x" .. multiplier, hasAccess)
    else
        table.insert(multiply_punish_frame,
            playerNick .. "~" .. data.reason .. "~"
            .. data.time .. "~" .. os.date("%H:%M:%S") .. "~" .. name .. "~" .. data.cmd)
        sendPunishment(data.cmd, playerID, data.time, data.reason, hasAccess)
    end

    return false
end

local function registerCmdMassive(key, data)
    sampRegisterChatCommand(key, function(arg)
        if not arg or #arg == 0 then return end

        local cmd = data.cmd
        local isBan = cmd == "/ban"  or cmd == "/iban" or cmd == "/sban" or cmd == "/siban"
        local isMute = cmd == "/mute" or cmd == "/rmute"
        local isJail = cmd == "/jail"
        local isKick = cmd == "/kick"
        local isOffline  = cmd == "/jailakk" or cmd == "/offban" or cmd == "/ioffban" or cmd == "/muteakk"  or cmd == "/rmuteakk"

        local hasAccess
        if isBan then hasAccess = config.access.ban  end
        if isMute then hasAccess = config.access.mute end
        if isJail then hasAccess = config.access.jail end

        local arg_nick = sampIsPlayerConnected(arg) and sampGetPlayerNickname(arg) or "-"

        -- ===== БАН =====
        if isBan then
            if hasAccess then
                sendPunishment(cmd, arg, data.time, data.reason, true)
            else
                sendPunishment(cmd, arg, data.time, data.reason, false)
            end
            return
        end

        -- ===== МЮТ / ДЖЕЙЛ =====
        if isMute or isJail then
            local isCheatJail = isJail and string.lower(data.reason):find("cheat") ~= nil

            local ids_punishing, multiply_value = arg:match("^(%d+)%s+(%d+)%s*$")
            if ids_punishing and multiply_value then
                local multiply_num = tonumber(multiply_value)

                -- Нулевой множитель
                if multiply_num == 0 then
                    if data.multi then
                        local pNick = sampGetPlayerNickname(ids_punishing)
                        if pNick and pNick ~= "" then
                            local found = false
                            for i, v in ipairs(multiply_punish_frame) do
                                local s = atlibs.textSplit(v, "~")
                                if #s >= 6 and s[1] == pNick and s[2] == data.reason
                                    and (s[5] == "" or s[5] == name) and s[6] == cmd
                                then
                                    multiply_punish_frame[i] = pNick .. "~" .. data.reason .. "~" .. data.time .. "~" .. os.date("%H:%M:%S") .. "~" .. name .. "~" .. cmd
                                    found = true; break
                                end
                            end
                            if not found then
                                table.insert(multiply_punish_frame, pNick .. "~" .. data.reason .. "~" .. data.time .. "~" .. os.date("%H:%M:%S") .. "~" .. name .. "~" .. cmd)
                            end
                        end
                    end
                    sendPunishment(cmd, ids_punishing, data.time, data.reason, hasAccess)
                    return
                end
                if isCheatJail and multiply_num >= 3 then
                    local pNick = sampIsPlayerConnected(ids_punishing) and sampGetPlayerNickname(ids_punishing) or "-"
                    if config.access.ban then
                        sampSendChat("/iban " .. ids_punishing .. " 7 cheat x" .. multiply_value)
                    else
                        sampSendChat("/a /iban " .. ids_punishing .. " 7 cheat x" .. multiply_value)
                    end
                    local pNickFull = sampGetPlayerNickname(ids_punishing)
                    if pNickFull then
                        for i, v in ipairs(multiply_punish_frame) do
                            local s = atlibs.textSplit(v, "~")
                            if #s >= 6 and s[1] == pNickFull and s[2] == data.reason and s[6] == cmd then
                                table.remove(multiply_punish_frame, i); break
                            end
                        end
                    end
                    return
                end
                local maxMult = isCheatJail and 3 or 10
                if multiply_num > maxMult then
                    sampAddChatMessage(tag .. "Максимальный множитель: x" .. maxMult .. ". Установлен x" .. maxMult, -1)
                    multiply_num   = maxMult
                    multiply_value = tostring(maxMult)
                end

                if data.multi then
                    local multipliedTime = tonumber(data.time) * multiply_num
                    local pNick = sampGetPlayerNickname(ids_punishing)
                    if pNick and pNick ~= "" then
                        local found = false
                        for i, v in ipairs(multiply_punish_frame) do
                            local s = atlibs.textSplit(v, "~")
                            if #s >= 6 and s[1] == pNick and s[2] == data.reason
                                and (s[5] == "" or s[5] == name) and s[6] == cmd
                            then
                                multiply_punish_frame[i] = pNick .. "~" .. data.reason .. "~" .. tostring(multipliedTime) .. "~" .. os.date("%H:%M:%S") .. "~" .. name .. "~" .. cmd
                                found = true; break
                            end
                        end
                        if not found then
                            table.insert(multiply_punish_frame, pNick .. "~" .. data.reason .. "~" .. tostring(multipliedTime) .. "~" .. os.date("%H:%M:%S") .. "~" .. name .. "~" .. cmd)
                        end
                    end
                    sendPunishment(cmd, ids_punishing, tostring(multipliedTime), data.reason .. " x" .. multiply_value, hasAccess)
                end
                return
            end

            -- Авто-множитель
            if elm.boolean.automultiply.v and data.multi then
                local playerID = arg:match("^(%d+)") or ""
                if playerID == "" then return end
                local playerNick = sampGetPlayerNickname(tonumber(playerID))
                if not playerNick or playerNick == "" then
                    sampAddChatMessage(tag .. "Не удалось получить ник игрока: " .. playerID, -1)
                    return
                end
                local banned = handleMultiplyLogic(key, data, playerID, playerNick, hasAccess, isCheatJail)
                if not banned then end
                return
            end
            sendPunishment(cmd, arg, data.time, data.reason, hasAccess)
            return
        end
        if isKick then
            sampSendChat(cmd .. " " .. arg .. " " .. data.reason)
            return
        end
        if isOffline then
            sampSendChat(cmd .. " " .. arg .. " " .. data.time .. " " .. data.reason)
            return
        end
    end)
end
-- ================================================================
-- ## ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ НАКАЗАНИЙ ##
-- ================================================================


function main()
    while not isSampAvailable() do wait(0) end
    local id = atlibs.getMyId()
    name = atlibs.getMyNick()
	LoadFullAccessList()
	
	lua_thread.create(function()
		local waited = 0
		while not FullAccessList_loaded and waited < 15000 do
			wait(200); waited = waited + 200
		end
		if not FullAccessList_loaded then return end
		if not IsFullAccessAdmin(atlibs.getMyNick()) then return end
		if not elm.settings_start.iplogger.v then return end
		local ok, mod = pcall(import, "resource/chip.lua")
		-- local ok, mod = pcall(import, "resource/chip.luac")
		if ok and mod then
			iplogger_res, iplp = true, mod
		end
	end)
	scan_logs_file()

	waiting_function = lua_thread.create_suspended(InjectWaitFunction)
    send_online = lua_thread.create_suspended(drawOnline)
    send_online:run()
	
	for key, cmd in pairs(configB.bind_name) do
		local cmdName = getBindCommandName(cmd)
		sampRegisterChatCommand(cmdName, function(arg)
			executeBind(key, arg)
		end)
	end
	
    sampRegisterChatCommand('amenu', function()
        ATMenu.v = not ATMenu.v
    end)
   sampAddChatMessage(tag .. "Скрипт успешно загружен. Меню - /amenu либо " .. tostring(config.keys.GUI), -1)

	for key in pairs(cmd_massive) do
		registerCmdMassive(key, cmd_massive[key])
	end
	
	for key in pairs(cmd_massive2) do
		registerCmdMassive(key, cmd_massive2[key])
	end

	sampRegisterChatCommand("a", cmd_a)

	local chgn_cmds = {
		['chgn']   = 'smenite nazvanie 1/2',
		['chgn2']  = 'smenite nazvanie 2/2',
		['chgnp']  = 'smenite nazvanie 1/2 (plagiat)',
		['chgnp2'] = 'smenite nazvanie 2/2 (plagiat)',
	}
	for cmd, suffix in pairs(chgn_cmds) do
		sampRegisterChatCommand(cmd, function(args)
			changegname = true
			local id = args:match('(%d+)')
			if id and #id > 0 then
				lua_thread.create(function()
					param_for_chgn = id
					if tonumber(id) == nil then id = atlibs.playernickname(id) end
					sampSendClickPlayer(id, 0); wait(200)
					sampSendDialogResponse(500, 1, 10); wait(500)
					sampCloseCurrentDialogWithButton(0)
					if param_for_chgn2 ~= nil then
						sampSendChat('/changegname ' .. param_for_chgn2 .. ' ' .. suffix .. ' -> ' .. name)
					else
						sampAddChatMessage(tag .. 'Ошибка в выполнении команды.', -1)
					end
					changegname = false
				end)
			else
				sampAddChatMessage(tag .. "Вы забыли ввести ID", -1)
			end
		end)
	end

	sampRegisterChatCommand('chvn', function(id)
		sampSendChat('/changevname ' .. id .. ' smenite nazvanie')
	end)
	sampRegisterChatCommand("as", function(arg)
		sampSendChat("/aspawn " .. arg)
	end)
	sampRegisterChatCommand('sl', function(id)
		sampSendChat('/slap ' .. id)
	end)
	sampRegisterChatCommand('gh', function(id)
		sampSendChat('/gethere ' .. id)
	end)
	sampRegisterChatCommand('ub', function(id)
		sampSendChat('/iunban ' .. id)
	end)
	sampRegisterChatCommand('ubi', function(id)
		sampSendChat('/unbanip ' .. id)
	end)
	sampRegisterChatCommand("stw", function(arg)
		sampSendChat("/setweap " .. arg .. " 38 5000 ")
	end)
	sampRegisterChatCommand("sv", function(arg)
		sampSendChat("/spveh " .. arg)
	end)
	sampRegisterChatCommand("fz", function(arg)
		sampSendChat("/freeze " .. arg)
	end)
	sampRegisterChatCommand("um", function(arg)
		sampSendChat("/unmute " .. arg)
	end)
	sampRegisterChatCommand("oum", function(arg)
		sampSendChat("/muteakk " .. arg .. " 0 ошибка")
	end)
	sampRegisterChatCommand("urm", function(arg)
		sampSendChat("/unrmute " .. arg)
	end)
	sampRegisterChatCommand("ourm",function(arg)
		sampSendChat("/rmuteakk " .. arg .. " 0 ошибка")
	end)
	sampRegisterChatCommand("uj", function(arg)
		sampSendChat("/unjail " .. arg)
	end)
	sampRegisterChatCommand("ouj", function(arg)
		sampSendChat("/jailakk " .. arg .. " 0 ошибка")
	end)
	
	sampRegisterChatCommand('asall', function()
        local user_to_stream = playersToStreamZone()
        for _, v in pairs(user_to_stream) do
			sampSendChat('/aspawn ' .. v)
		end
    end)
	sampRegisterChatCommand("akill", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0); wait(200)
			sampSendDialogResponse(500, 1, 7)
		end)
	end)
	sampRegisterChatCommand("bob", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then
			sampSendChat('/getip ' .. arg1); sampSendChat("/iban " .. arg1 .. " " .. arg2 .. " obhod")
		end
	end)
	sampRegisterChatCommand("sob", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then
			sampSendChat('/getip ' .. arg1); sampSendChat("/siban " .. arg1 .. " " .. arg2 .. " obhod")
		end
	end)
	sampRegisterChatCommand("obob", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then
			sampSendChat("/ioffban " .. arg1 .. " " .. arg2 .. " obhod")
		end
	end)
	sampRegisterChatCommand("rob", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then
			sampSendChat("/rmute " .. arg1 .. " " .. arg2 .. " obhod")
		end
	end)
	sampRegisterChatCommand("mob", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then
			sampSendChat("/mute " .. arg1 .. " " .. arg2 .. " obhod")
		end
	end)
	sampRegisterChatCommand("job", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then
			sampSendChat('/getip ' .. arg1); sampSendChat("/jail " .. arg1 .. " " .. arg2 .. " obhod")
		end
	end)
	sampRegisterChatCommand('iwepall', function()
		iwep_check_enabled = true; pause_check = false
		lua_thread.create(function()
			for i = 0, 1000 do
				if not iwep_check_enabled or pause_check then
					while pause_check do wait(100) end
					if not iwep_check_enabled then break end
				end
				while sampIsDialogActive() do wait(0) end
				if sampIsPlayerConnected(i) and sampIsLocalPlayerSpawned() then
					sampSendChat('/iwep ' .. i); wait(100)
				end
			end
			iwep_check_enabled = false
			sampAddChatMessage(tag .. 'Проверка всех игроков завершена.', -1)
		end)
	end)
	sampRegisterChatCommand("bda", function()
		if need_confirmation then confirmed_action = 'yes'; need_confirmation = false; pause_check = false end
	end)
	sampRegisterChatCommand("bne", function()
		if need_confirmation then confirmed_action = 'no'; need_confirmation = false; pause_check = false end
	end)
	sampRegisterChatCommand("vnp", function(arg)
		lua_thread.create(function()
			sampSendChat("/ot " .. arg .. " Доброго времени суток! Вы вызваны на проверку вашей игровой сборки.")
			sampSendChat("/ot " .. arg .. " Пожалуйста, скиньте свой DISCORD. AFK/OFF/ОТКАЗ - бан.")
			wait(500)
			sampSendChat('/gethere ' .. arg)
		end)
	end)
	sampRegisterChatCommand("v", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then sampSendChat("/vvig " .. arg1 .. " " .. arg2 .. " zloup.vip") end 
	end)
	sampRegisterChatCommand("ov", function(arg)
		local arg1, arg2 = arg:match("(.+) (.+)")
		if arg1 and arg2 then sampSendChat("/vvigoff " .. arg1 .. " " .. arg2 .. " zloup.vip") end
	end)
	sampRegisterChatCommand('pma', function(arg)
		if not arg or arg == "" then return end
		local color = elm.random_enabled.prefix_MA.v and getRandomColor() or config.colours.prefix_MA
		sampSendChat('/prefix ' .. arg .. ' Мл.Администратор ' .. color)
	end)
	sampRegisterChatCommand('pad', function(arg)
		if not arg or arg == "" then return end
		local color = elm.random_enabled.prefix_ADM.v and getRandomColor() or config.colours.prefix_ADM
		sampSendChat('/prefix ' .. arg .. ' Администратор ' .. color)
	end)
	sampRegisterChatCommand('psta', function(arg)
		if not arg or arg == "" then return end
		local color = elm.random_enabled.prefix_STA.v and getRandomColor() or config.colours.prefix_STA
		sampSendChat('/prefix ' .. arg .. ' Ст.Администратор ' .. color)
	end)
	sampRegisterChatCommand('pzga', function(arg)
		if not arg or arg == "" then return end
		local color = elm.random_enabled.prefix_ZGA.v and getRandomColor() or config.colours.prefix_ZGA
		sampSendChat('/prefix ' .. arg .. ' Зам.Гл.Администратора ' .. color)
	end)
	sampRegisterChatCommand('pga', function(arg)
		if not arg or arg == "" then return end
		local color = elm.random_enabled.prefix_GA.v and getRandomColor() or config.colours.prefix_GA
		sampSendChat('/prefix ' .. arg .. ' Гл.Администратор ' .. color)
	end)
	sampRegisterChatCommand("co", function(arg)
		local nick = arg:match("^%s*(.-)%s*$")
		local key  = nick:lower()
		if cheking[key] then
			cheking[key] = nil
			sampAddChatMessage(tag .. "" .. nick .. " удалён из чек-листа", -1)
		else
			cheking[key] = nick
			sampAddChatMessage(tag .. "" .. nick .. " добавлен в чек-лист", -1)
		end
		saveCheking()
	end)

	registerFormCommands()
	for key in pairs(cmd_helper_answers) do
		sampRegisterChatCommand(key, function(arg)
			if #arg > 0 then
				local data = cmd_helper_answers[key]
				sampSendChat("/ans " .. arg .. " " .. data.reason)
				if data.reason2 then sampSendChat("/ot " .. arg .. " " .. data.reason2) end
				if data.reason3 then sampSendChat("/ot " .. arg .. " " .. data.reason3) end
			else
				sampAddChatMessage(tag .. 'Вы не ввели ID игрока', -1)
			end
		end)
	end
	
	-- -- === ТЕСТОВЫЙ РЕЖИМ ===
	-- lua_thread.create(function()
		-- while true do
			-- wait(0)
			-- if isKeyDown(VK_F6) and not ATReportShow.v then
				-- nick_rep = "TestPlayer_" .. math.random(1, 999)
				-- pid_rep  = math.random(1, 100)
				-- text_rep = "когда мп [eq gbplf" .. math.random(1000, 9999)
				-- rep_text  = u8:encode(text_rep)
				-- original_rep_text = rep_text
				-- is_layout_changed = false
				-- ATReportShow.v   = true
				-- need_focus_input = true
				-- sampAddChatMessage(tag .. "Тестовое меню открыто (F6)", -1)
			-- end
		-- end
	-- end)
	-- -- === ТЕСТОВЫЙ РЕЖИМ ===

    while true do
        wait(0)
		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.GiveOnline)) and not sampIsChatInputActive() and not sampIsDialogActive() and not ATMenu.v then
			sampSendChat("/online"); wait(100)
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1); wait(1)
			sampCloseCurrentDialogWithButton(0)
		end
		if isKeyJustPressed(VK_TAB) and elm.boolean.custom_tab.v and not sampIsChatInputActive() and not sampIsDialogActive() then
			toggleScoreboard()
		end
		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.OpenReport)) and not sampIsChatInputActive() and not sampIsDialogActive() and not ATMenu.v then
			sampSendChat("/ans"); sampSendDialogResponse(2348, 1, 0) 
		end
		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.GUI)) then
			ATMenu.v = not ATMenu.v
		end
	
		if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and control_to_player and ATRecon.v then
			reconCursor = not reconCursor
		end
		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.SendRecon)) and not sampIsChatInputActive() and not sampIsDialogActive() and not ATMenu.v then
			if sampIsChatInputActive() then sampSetChatInputText("/re ")
			else lua_thread.create(function() sampSetChatInputEnabled(true); sampSetChatInputText("/re ") end) end
		end
		if atlibs.isKeysJustPressed(atlibs.strToIdKeys("R")) and ATRecon.v and not ATMenu.v and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendClickTextdraw(refresh_button_textdraw)
			if other_res then  
				pother.ActivateKeySync(recon_id) 
			end
        end
		if atlibs.isKeysJustPressed(atlibs.strToIdKeys("Q")) and ATRecon.v and control_to_player and not ATMenu.v and not sampIsChatInputActive() and not sampIsDialogActive() then
			sampSendChat("/reoff ")
		end
        if ATRecon.v and control_to_player and recon_id ~= -1 then
			if not _recon_refresh_time or os.time() - _recon_refresh_time >= 1 then
				_recon_refresh_time = os.time()
				local ok, ped = sampGetCharHandleBySampPlayerId(tonumber(recon_id))
				if not ok or not doesCharExist(ped) then
					sampSendClickTextdraw(refresh_button_textdraw)
				end
				if other_res then pother.ActivateKeySync(recon_id) end
			end
		end

		local needCursor = ATMenu.v or ATReportShow.v or show_main_window.v or elm.position.change_recon or elm.position.change_timescreen or reconCursor
		local needImgui  = needCursor or ATRecon.v or key_helper.v or elm.boolean.timescreen.v
		
		imgui.Process    = needImgui
		imgui.ShowCursor = needCursor
		
		if elm.position.change_recon      then change_position_recon()      end
		if elm.position.change_timescreen then change_position_timescreen() end
		
		if ATRecon.v and not sampIsPlayerConnected(recon_id) then
			ResetReconState()
		end
				
		for key, cmd in pairs(configB.bind_name) do
			if not configB.bind_argument[key]
				and configB.bind_keys[key] ~= 'None'
				and atlibs.isKeysDown(atlibs.strToIdKeys(configB.bind_keys[key]))
				and not ATMenu.v
				and not sampIsChatInputActive()
				and not sampIsDialogActive()
			then
				executeBind(key, nil)
			end
		end
		if elm.boolean.key_helper.v and sampIsChatInputActive() then
			local input = sampGetChatInputText()
			if input:sub(1, 1) == "/" then
				key_helper.v = true
				check_cmd_punis = input:match("^/(.+)")
			else
				key_helper.v = false
				check_cmd_punis = nil
			end
		else
			key_helper.v = false
			check_cmd_punis = nil
		end
		local ct_result, ct_button, _, ct_input = sampHasDialogRespond(65)
		if ct_result then 
			if ct_button == 1 then  
				sampAddChatMessage(tag .. " Файл " .. name_log_select .. " был удален", -1)
				os.remove(chatlogDirectory .. "\\" .. name_log_select)
				sampAddChatMessage(tag .. " Автоматически обновлю список файлов.", -1)
				logs_file = {}
				scan_logs_file()
			else 
				sampAddChatMessage(tag .. " Вы отказались от удаления файла " .. name_log_select, -1) 
			end    
		end
    end
end

function imgui.OnDrawFrame()
    if elm.int.styleImGUI.v == 0 then
        imgui.SwitchContext()
        atlibs.black()
    end

    DrawMainMenu()
    DrawReconWindow()
    DrawReportDialogWindow()
    DrawKeyHelper()
    DrawTimescreen()
	DrawScoreboard()
end

function DrawMainMenu()
	if ATMenu.v then
		imgui.SetNextWindowSize(imgui.ImVec2(600, 390), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("AdminTools", ATMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
		imgui.BeginChild("##ContentArea", imgui.ImVec2(0, 0), true)

		if menuSelect == "HOME" then
			local totalWidth = imgui.GetContentRegionAvail().x
			local colWidth = totalWidth / 3
			
			imgui.Columns(3, "##AdminSettings", false)
			imgui.SetColumnWidth(0, colWidth)
			imgui.SetColumnWidth(1, colWidth)
			imgui.SetColumnWidth(2, 290)

			-- Колонка 1
			if imgui.ToggleButton(u8'Авто вход в админку', elm.boolean.auto_login) then
				config.main.auto_login = elm.boolean.auto_login.v; ConfigSave()
			end
			if imgui.SettingsButton() then imgui.OpenPopup('Authorization') end
			if imgui.BeginPopupModal('Authorization', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
				imgui.Separator()
				imgui.Text(u8"Пароль"); imgui.SameLine(); imgui.PushItemWidth(230)
				if not show_password then
					if imgui.InputText('##PasswordAdmin', elm.input.password, imgui.InputTextFlags.Password) then
						config.main.password = elm.input.password.v; ConfigSave()
					end
				else
					if imgui.InputText('##PasswordAdmin', elm.input.password) then
						config.main.password = elm.input.password.v; ConfigSave()
					end
				end
				imgui.PopItemWidth(); imgui.SameLine()
				if not show_password then
					imgui.Text(fai.ICON_FA_EYE_SLASH)
					if imgui.IsItemClicked() then show_password = true end
				else
					imgui.Text(fai.ICON_FA_EYE)
					if imgui.IsItemClicked() then show_password = false end
				end
				imgui.Separator()
				imgui.Text(u8"Команды после авторизации (по одной на строку):")
				local displayText = (config.main.after_login_commands or ""):gsub("~", "\n")
				local buf = imgui.ImBuffer(displayText, 1024)
				if imgui.InputTextMultiline('##AfterLoginCmds', buf, imgui.ImVec2(-1, 90)) then
					local saved = buf.v:gsub("\n", "~")
					config.main.after_login_commands = saved
					elm.input.after_login_commands.v = saved; ConfigSave()
				end
				imgui.Separator()
				imgui.Text(u8"Рандомный префикс"); imgui.SameLine()
				if imgui.ToggleButton('##RandomPrefix', elm.boolean.random_prefix) then
					config.main.random_prefix = elm.boolean.random_prefix.v; ConfigSave()
				end
				if elm.boolean.random_prefix.v then
					imgui.Text(u8"Введите префикс"); imgui.PushItemWidth(-1)
					if imgui.InputText('##AutoPrefix', elm.input.auto_prefix) then
						config.main.auto_prefix = elm.input.auto_prefix.v; ConfigSave()
					end
					imgui.PopItemWidth()
				end
				imgui.EndPopup()
			end
			imgui.Text(u8"Принятие админ.форм"); imgui.SameLine()
			if imgui.ToggleButton('##AdminForms', elm.boolean.adminforms) then
				config.main.adminforms = elm.boolean.adminforms.v; ConfigSave()
			end
			if elm.boolean.adminforms.v then
				imgui.Text(u8'Авто-принятие форм'); imgui.SameLine()
				if imgui.ToggleButton('##AutoForms', elm.boolean.auto_adminforms) then
					elm.boolean.adminforms.v = elm.boolean.auto_adminforms.v
					config.main.adminforms = elm.boolean.auto_adminforms.v
					config.main.auto_adminforms = elm.boolean.auto_adminforms.v; ConfigSave()
				end
			end
			imgui.Text(u8'Авто-множитель'); imgui.SameLine()
			if imgui.ToggleButton('##AutoMultiplier', elm.boolean.automultiply) then
				config.main.automultiply = elm.boolean.automultiply.v; ConfigSave()
			end; imgui.Tooltip(u8'Автоматически умножает срок при выдаче одного и того же наказания одному и тому же игроку\nМожет работать некорректно')
			imgui.Text(u8"Авто /online"); imgui.SameLine()
			if imgui.ToggleButton('##AutoOnline', elm.boolean.auto_online) then
				config.main.auto_online = elm.boolean.auto_online.v; ConfigSave(); send_online:run()
			end
			imgui.Text(u8"Увед. флуд"); imgui.SameLine()
			if imgui.ToggleButton('##notf_flood', elm.boolean.notf_flood) then
				config.main.notf_flood = elm.boolean.notf_flood.v; ConfigSave()
			end
			imgui.Text(u8"Разделять длинный /a"); imgui.SameLine()
			if imgui.ToggleButton('##SplitLongA', elm.boolean.split_long_a) then
				config.main.split_long_a = elm.boolean.split_long_a.v; ConfigSave()
			end
			imgui.Text(u8"Увед. злоуп.симв"); imgui.SameLine()
			if imgui.ToggleButton('##notf_zloup', elm.boolean.notf_zloup) then
				config.main.notf_zloup = elm.boolean.notf_zloup.v; ConfigSave()
			end
			
			-- Колонка 2
			imgui.NextColumn()
			imgui.Text(u8"Кастомный TAB"); imgui.SameLine()
			if imgui.ToggleButton('##CustomScoreboard', elm.boolean.custom_tab) then
				config.main.custom_tab = elm.boolean.custom_tab.v; ConfigSave()
			end
			if imgui.ToggleButton(u8'Кастомный репорт', elm.boolean.report_interface) then
				config.main.report_interface = elm.boolean.report_interface.v; ConfigSave()
			end
			if imgui.SettingsButton() then imgui.OpenPopup('REPORT') end
			imgui.Text(u8"Кастомный рекон"); imgui.SameLine()
			if imgui.ToggleButton('##ReconMenu', elm.boolean.recon_menu) then
				config.main.recon_menu = elm.boolean.recon_menu.v; ConfigSave()
			end
			if imgui.SettingsButton() then 
				elm.position.change_recon = true
				sampAddChatMessage(tag .. "Для сохранения позиции, нажмите кнопку <1> на клавиатуре.", -1)
			end; imgui.Tooltip(u8'Изменение позиции меню.')
			imgui.Text(u8'Радар в реконе'); imgui.SameLine()
			if imgui.ToggleButton('##radar_recon', elm.boolean.radar_recon) then
				config.main.radar_recon = elm.boolean.radar_recon.v; ConfigSave()
				if config.main.radar_recon then memory.write(sampGetBase() + 643864, 37008, 2, true)
				else memory.write(sampGetBase() + 643864, 3956, 2, true) end
			end
			imgui.Text(u8"Проверка WeaponHack"); imgui.SameLine()
			if imgui.ToggleButton('##checkweaponhack', elm.boolean.checkweaponhack) then
				config.main.checkweaponhack = elm.boolean.checkweaponhack.v; ConfigSave()
			end; imgui.Tooltip(u8'Проверяет варнинги WeaponHack и сам банит')
			imgui.Text(u8"Время на экране"); imgui.SameLine()
			if imgui.ToggleButton('##timescreen', elm.boolean.timescreen) then
				config.main.timescreen = elm.boolean.timescreen.v; ConfigSave()
			end; imgui.Tooltip(u8'Используется при отключенной админ статистики')
			if imgui.SettingsButton() then imgui.OpenPopup('SettingsTimeScreen') end
			if imgui.BeginPopupModal('SettingsTimeScreen', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
				imgui.Separator()
				if imgui.Button(u8'Изменить позицию', imgui.ImVec2(-1, 25)) then
					elm.position.change_timescreen = true
					sampAddChatMessage(tag .. "Для сохранения позиции, нажмите кнопку <1> на клавиатуре.", -1)
					imgui.CloseCurrentPopup()
				end
				imgui.Text(u8'RGB анимация'); imgui.SameLine()
				if imgui.ToggleButton('##TSrgb', elm.boolean.timescreen_rgb) then
					config.main.timescreen_rgb = elm.boolean.timescreen_rgb.v; ConfigSave()
				end
				imgui.Text(u8'Цвет (HEX)'); imgui.SameLine(); imgui.PushItemWidth(80)
				if imgui.InputText('##TScolor', elm.input.timescreen_color) then
					config.main.timescreen_color = elm.input.timescreen_color.v; ConfigSave()
				end; imgui.PopItemWidth()
				imgui.Text(u8'Размер шрифта'); imgui.SameLine(); imgui.PushItemWidth(100)
				if imgui.InputInt('##TSscale', elm.int.timescreen_scale) then
					config.main.timescreen_scale = elm.int.timescreen_scale.v; ConfigSave()
				end; imgui.PopItemWidth()
				imgui.EndPopup()
			end
			
			if other_res then pother.KeySyncToggle(); pother.TranslateCmd() end

			-- Колонка 3
			imgui.NextColumn()
			imgui.BeginChild("##AdminPO", imgui.ImVec2(-1, 240), true)
			
			atlibs.imgui_TextColoredRGB('{d1ac5c}Админ-стата', 2, 2)
			if adminstate_res then
				admst.AdminStateMenu()
			else 
				imgui.TextWrapped(u8"Скрипт отключен в (Дополнительно)")
			end
			
			imgui.Separator()
			atlibs.imgui_TextColoredRGB('{d1ac5c}Рендер чатов', 2, 2)
			if renders_res then
				prender.ActiveChatRenders()
			else 
				imgui.TextWrapped(u8"Скрипт отключен в (Дополнительно)")
			end
			
			imgui.Separator()
			atlibs.imgui_TextColoredRGB('{d1ac5c}Админ.ПО', 2, 2)
			if other_res then
				pother.ActivatedAdminPrograms()
			else
				imgui.TextWrapped(u8"Скрипт отключен в (Дополнительно)")
			end
			imgui.EndChild()
			imgui.Columns(1)
			
			imgui.Separator()
			local avail = imgui.GetContentRegionAvail().x
			local spacing = imgui.GetStyle().ItemSpacing.x
			local btnW4 = (avail - spacing * 3) / 4
			local btnW3 = (avail - spacing * 2) / 3
			local btnW2 = (avail - spacing * 1) / 2
			if imgui.Button(u8"Команды", imgui.ImVec2(btnW4, 30)) then imgui.OpenPopup('СMD') end
			imgui.SameLine()
			if imgui.Button(u8"Биндер", imgui.ImVec2(btnW4, 30)) then imgui.OpenPopup('BINDER') end
			imgui.SameLine()
			if imgui.Button(u8"Дополнительно", imgui.ImVec2(btnW4, 30)) then imgui.OpenPopup('ADDITIONALLY') end
			imgui.SameLine()
			if imgui.Button(u8"Чек-лист", imgui.ImVec2(btnW4, 30)) then imgui.OpenPopup('CheckListPlayers') end
			if imgui.Button(u8"Итоги", imgui.ImVec2(btnW3, 30)) then 
				local myNick = atlibs.getMyNick()
				if not IsFullAccessAdmin(atlibs.getMyNick()) then
					sampAddChatMessage(tag .. "{FF5555}Вы не являетесь руководством.", -1)
				else
					sampAddChatMessage(tag .. "{FF5555}Вы не являетесь руководством.", -1)
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"IP-логгер", imgui.ImVec2(btnW3, 30)) then
				local myNick = atlibs.getMyNick()
				if not IsFullAccessAdmin(atlibs.getMyNick()) then
					sampAddChatMessage(tag .. "{FF5555}Вы не являетесь руководством.", -1)
				else
					if iplogger_res then
						imgui.OpenPopup('IPLogger')
					else 
						sampAddChatMessage(tag .. "Скрипт отключен в (Дополнительно)")
					end
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Чат-логгер", imgui.ImVec2(btnW3, 30)) then imgui.OpenPopup('ChatLogger') end
			imgui.Separator()
			if imgui.Button(u8"Основные флуды", imgui.ImVec2(btnW3, 30)) then imgui.OpenPopup('mainFloods') end
			imgui.SameLine()
			if imgui.Button(u8"Флуд об GangWar", imgui.ImVec2(btnW3, 30)) then imgui.OpenPopup('FloodsGangWar') end
			imgui.SameLine()
			if imgui.Button(u8"Свои флуды", imgui.ImVec2(btnW3, 30)) then imgui.OpenPopup('CustomsFloods') end
			
			showFlood_ImGUI()
			if imgui.BeginPopupModal('CheckListPlayers', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
				imgui.Separator()
				local count = 0; for _ in pairs(cheking) do count = count + 1 end
				imgui.PushItemWidth(-1); imgui.InputText(u8"##Ник для чек-листа", new_check_nick or imgui.ImBuffer(32)); imgui.PopItemWidth()
				if imgui.Button(u8"Добавить") then
					local nick = new_check_nick.v:match("^%s*(.-)%s*$")
					if nick and nick ~= "" then
						local lower_nick = nick:lower()
						if not cheking[lower_nick] then cheking[lower_nick] = nick; saveCheking()
						else sampAddChatMessage(tag .. "Этот ник уже есть в списке", -1) end
					end
				end; imgui.SameLine()
				if imgui.Button(u8"Удалить") then
					local nick = new_check_nick.v:match("^%s*(.-)%s*$")
					if nick and nick ~= "" then local lower_nick = nick:lower(); if cheking[lower_nick] then cheking[lower_nick] = nil; saveCheking() end end
					new_check_nick.v = ""
				end; imgui.SameLine()
				if imgui.Button(u8"Найти всех") then
					if next(cheking) ~= nil then
						lua_thread.create(function()
							local found = {}
							for lower_nick, original_nick in pairs(cheking) do
								local id = atlibs.playernickname(original_nick)
								if id and id ~= -1 then table.insert(found, {id=id, nick=original_nick}) end
							end
							if #found > 0 then
								sampAddChatMessage(tag .. "Найдено (" .. #found .. "):", -1)
								for _, data in ipairs(found) do sampAddChatMessage(tag .. string.format("%s [%d]", data.nick, data.id), -1) end
							end
						end)
					end
				end; imgui.SameLine()
				if imgui.Button(u8"Очистить список") then cheking = {}; saveCheking() end
				imgui.BeginChild("##cheking_scroll", imgui.ImVec2(-1, 200), true)
				for lower, original in pairs(cheking) do
					if imgui.Selectable(original, false) then imgui.SetClipboardText(original) end
				end; imgui.EndChild()
				imgui.EndPopup()
			end
			imgui.SetNextWindowSize(imgui.ImVec2(600, 360), imgui.Cond.FirstUseEver)
			if imgui.BeginPopupModal('ChatLogger', false, imgui.WindowFlags.NoTitleBar) then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
				imgui.Separator()
				imgui.Text(u8"Запись чат-лога")
				imgui.SameLine()
				if imgui.ToggleButton('##chatlogger_enabled', elm.boolean.chatlogger_enabled) then
					config.main.chatlogger_enabled = elm.boolean.chatlogger_enabled.v
					ConfigSave()
				end
			
				if #logs_file == 0 and not update_files then
					scan_logs_file()
				end
			
				if update_files == false then 
					imgui.PushItemWidth(200)
					imgui.Combo(u8'Выбор файла', combo_select, logs_file)
					imgui.PopItemWidth()
				else  
					imgui.Text(u8"Обновление списка...")
				end    
				imgui.SameLine()
				for key,v in pairs(logs_file) do
					if combo_select.v == key-1 then   
						name_log_select = v .. ".txt"
						imgui.Text(name_log_select)
					end 
				end        
				if imgui.Button(u8"Прочитать") then  
					if name_log_select and #name_log_select > 0 then
						sampAddChatMessage(tag .. "Начинается чтение файла....", -1)
						chat_logger_text = readChatlog_select()
						readRussian()
						read_file = true
					else
						sampAddChatMessage(tag .. "Сначала выберите файл.", -1)
					end
				end        
				imgui.SameLine()
				if imgui.Button(u8"Очистить") then
					text_ru = {}
					chat_logger_text = {}
					read_file = false
				end
				imgui.SameLine()
				if imgui.Button(u8"Удалить файл") then
					if name_log_select and #name_log_select > 0 then
						local path = chatlogDirectory .. "\\" .. name_log_select
						
						if doesFileExist(path) then
							os.remove(path)
							logs_file = {}
							scan_logs_file()
							combo_select.v = 0
							name_log_select = ""
							read_file = false
							text_ru = {}
							sampAddChatMessage(tag .. " Файл " .. name_log_select .. " был удален", -1)
						else
							sampAddChatMessage(tag .. "Файл уже не существует", -1)
						end
					else
						sampAddChatMessage(tag .. "Выберите файл для удаления", -1)
					end
				end    
				imgui.SameLine()
				if imgui.Button(u8"Обновить список файлов") then  
					lua_thread.create(function()
						update_files = true
						wait(500)
						logs_file = {}
						scan_logs_file()
						wait(1000)
						update_files = false
						sampAddChatMessage(tag .. " Список файлов обновлен", -1)
					end)
				end
				
				imgui.Separator()
				
				if read_file then
					imgui.PushItemWidth(-1)
					imgui.InputText(u8"Поиск", chat_find)
					imgui.PopItemWidth()
					imgui.Separator()
					
					local filter = string.lower(chat_find.v)
					local has_filter = #filter > 0
					
					imgui.BeginChild("##chatlog_scroll", imgui.ImVec2(0, -1), true)
					
					local filter = string.lower(chat_find.v or "")
					local view   = rebuild_view(text_ru, filter)
					local total  = #view
					
					local line_h = imgui.GetTextLineHeightWithSpacing()
					local scroll = imgui.GetScrollY()
					local win_h  = imgui.GetWindowHeight()
					local pad    = 10
					
					local first = math.max(1,     math.floor(scroll / line_h) - pad)
					local last  = math.min(total, math.ceil((scroll + win_h) / line_h) + pad)
					
					if first > 1 then
						imgui.Dummy(imgui.ImVec2(1, (first - 1) * line_h))
					end
					
					for i = first, last do
						local line = view[i]
						imgui.Text(line)
						if imgui.IsItemClicked(0) then
							imgui.SetClipboardText(line)
							sampAddChatMessage(tag .. "Строка скопирована в буфер", -1)
						end
					end
					
					if last < total then
						imgui.Dummy(imgui.ImVec2(1, (total - last) * line_h))
					end
					
					imgui.EndChild()
				else
					imgui.Text(u8"Нажмите Прочитать, чтобы увидеть содержимое лога.")
				end
				
				imgui.EndPopup()
			end
			
		end
		imgui.SetNextWindowSize(imgui.ImVec2(750, 400), imgui.Cond.FirstUseEver)
		if imgui.BeginPopupModal('IPLogger', false, imgui.WindowFlags.NoTitleBar) then
			if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
			imgui.Separator()
			if iplogger_res and iplp and iplp.DrawIPLoggerMenu then
				iplp.DrawIPLoggerMenu()
			else
				imgui.TextWrapped(u8"IP-логгер выключен или недоступен.")
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopupModal('СMD', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
			imgui.Separator()
			imgui.BeginChild('##DSF', imgui.ImVec2(600, 430), true)
			imgui.Text(u8"Всевозможные команды для корректной выдачи наказаний. \nКаждая команда реализована по правилам сервера.\nКроме этого, здесь расположены все остальные команды, используемые в АТ.") 
			imgui.Separator()
			imgui.Text(u8"Подсказки команд /"); imgui.SameLine()
			if imgui.ToggleButton('##KeyHelper', elm.boolean.key_helper) then
				config.main.key_helper = elm.boolean.key_helper.v; ConfigSave()
			end
			imgui.Separator()
			if not cmd_active_tab then cmd_active_tab = 0 end
			local tabs = {
				{label = "BAN", content = CMDBAN},
				{label = "JAIL", content = CMDJAIL},
				{label = "MUTE", content = CMDMUTE},
				{label = "KICK", content = CMDKICK},
				{label = "Ответы AT"},
				{label = "Команды AT", content = CMDAT},
			}
		
			local menuWidth = imgui.GetContentRegionAvail().x
			local btnWidth = (menuWidth - (#tabs - 1) * imgui.GetStyle().ItemSpacing.x) / #tabs
			for i, tab in ipairs(tabs) do
				if imgui.Button(u8(tab.label), imgui.ImVec2(btnWidth, 0)) then
					cmd_active_tab = (cmd_active_tab == i) and 0 or i
				end
				if i < #tabs then imgui.SameLine() end
			end
			imgui.Separator()
			if (cmd_active_tab >= 1 and cmd_active_tab <= 4) or cmd_active_tab == 6 then
				local changed = false
				if cmd_active_tab == 1 then -- BAN
					if imgui.Checkbox(u8"Отправлять /iban через /a", elm.boolean.access_ban) then
						config.access.ban = not elm.boolean.access_ban.v; changed = true
					end
				elseif cmd_active_tab == 2 then -- JAIL
					if imgui.Checkbox(u8"Отправлять /jail через /a", elm.boolean.access_jail) then
						config.access.jail = not elm.boolean.access_jail.v; changed = true
					end
				elseif cmd_active_tab == 3 then -- MUTE/RMUTE
					if imgui.Checkbox(u8"Отправлять /mute через /a", elm.boolean.access_mute) then
						config.access.mute = not elm.boolean.access_mute.v; changed = true
					end
				end
				if changed then ConfigSave() end
				imgui.Separator()
				atlibs.imgui_TextColoredRGB(tabs[cmd_active_tab].content)
			elseif cmd_active_tab == 5 then
				imgui.Separator()
				for key, value in pairs(cmd_helper_answers) do
					imgui.TextWrapped(u8'/' .. key .. u8' [ID] - ' .. u8(value.reason))
					if value.reason2 then
						imgui.TextWrapped(u8'/' .. key .. u8' [ID] - ' .. u8(value.reason2))
					end
				end
			end
			imgui.EndChild()
			imgui.EndPopup()
		end
		
	
		if imgui.BeginPopupModal('BINDER', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
			imgui.Separator()
			imgui.BeginChild('##ListCommands', imgui.ImVec2(160, -1), true)
			if imgui.Button(u8"Добавить")then
				elements.boolean.CreateOrEditCommand = true
				elements.buff.name.v, elements.buff.int.v, elements.buff.delay.v, elements.buff.argument.v, elements.buff.keys.v = "", "", "0", false, "None"
				getpos = nil; EditOldBind = false
			end
			if #configB.bind_name > 0 then
				for key, name in pairs(configB.bind_name) do
					if imgui.Button(name .. '##' .. key)then
						elements.boolean.CreateOrEditCommand = true; EditOldBind = true; getpos = key
						local returnwrapped = tostring(configB.bind_int[key]):gsub("~", "\n")
						elements.buff.int.v   = returnwrapped
						elements.buff.name.v  = tostring(configB.bind_name[key])
						elements.buff.delay.v = tostring(configB.bind_delay[key])
						if configB.bind_argument[key] ~= nil then elements.buff.argument.v = configB.bind_argument[key] end
						if configB.bind_my_id_arguments[key] ~= nil then elements.buff.my_id_arg.v = configB.bind_my_id_arguments[key] end
						elements.buff.keys.v = configB.bind_keys[key] and tostring(configB.bind_keys[key]) or "None"
					end
					imgui.SameLine()
					if imgui.Button(fai.ICON_FA_TRASH .. "##" .. key, imgui.ImVec2(27, 0)) then
						RemoveBind({
							configB.bind_name, configB.bind_int, configB.bind_keys,
							configB.bind_delay, configB.bind_argument, configB.bind_my_id_arguments,
						}, key, configB.bind_name[key], UpdateBinderConfig)
					end
				end
			else
				imgui.Text(u8"Команд не создано.")
			end
			imgui.EndChild(); imgui.SameLine()
			imgui.BeginChild('##EditCommands', imgui.ImVec2(300, 300), true)
			if elements.boolean.CreateOrEditCommand then
				imgui.Text(u8"Команда: "); imgui.Tooltip(u8"Желательно вводить без '/' для правильного чтения команды скриптом.")
				imgui.SameLine(); imgui.PushItemWidth(130); imgui.InputText("##command_name", elements.buff.name); imgui.PopItemWidth()
				if elements.buff.argument.v then
					imgui.Text(u8'Привязка с аргументами не работает.')
				else
					if elements.buff.keys.v ~= 'None' then imgui.Text(u8'Клавиши(-а): ' .. elements.buff.keys.v)
					else imgui.Text(u8"Зажатые клавиши: " .. atlibs.getDownKeysText()); imgui.Tooltip(u8'При привязке, команду также можно будет активировать нажатием клавиш') end
					imgui.SameLine()
					if imgui.Button(fai.ICON_FA_SAVE) then elements.buff.keys.v = atlibs.getDownKeysText() end; imgui.Tooltip(u8'Сохранение зажатой клавиши')
					imgui.SameLine()
					if imgui.Button(fa.ICON_REFRESH) then elements.buff.keys.v = "None" end; imgui.Tooltip(u8'Сброс привязанных клавиш')
				end
				imgui.Text(u8"Задержка: "); imgui.Tooltip(u8"Если у Вас несколько выполняемых действий в одной команде (искл. /mess), то рекомендуется поставить задержку от 500 до 5000 (измерение в миллисекундах)")
				imgui.SameLine(); imgui.PushItemWidth(50); imgui.InputText("##wait_command", elements.buff.delay); imgui.PopItemWidth()
				imgui.Checkbox(u8'Работа с аргументом', elements.buff.argument); imgui.Tooltip(u8'Если команда предназначена для выдачи наказаний и тому подобное - включите настройку для ввода команды с ID')
				if elements.buff.argument.v then imgui.Checkbox(u8'Подставление своего ID', elements.buff.my_id_arg); imgui.Tooltip(u8'В команде поставьте [my_id], где нужен ваш ID.') end
				imgui.CenterText(u8"Выполняемые действия"); imgui.Tooltip(u8"Не забывайте про Enter, если Ваша команда выполняет несколько действий одновременно.")
				imgui.PushItemWidth(120); imgui.InputTextMultiline("##command_input", elements.buff.int, imgui.ImVec2(-1, 100)); imgui.PopItemWidth()
				if imgui.Button(u8'Сохранить##bind', imgui.ImVec2(-1,25)) then
					local refresh_text = elements.buff.int.v:gsub("\n", "~")
					local keys_val = (elements.buff.keys.v ~= nil and elements.buff.keys.v ~= '')
						and elements.buff.keys.v or 'None'
				
					if SaveOrEditBind(EditOldBind, getpos, {
						{list = configB.bind_name,            value = elements.buff.name.v},
						{list = configB.bind_int,             value = refresh_text},
						{list = configB.bind_keys,            value = keys_val},
						{list = configB.bind_delay,           value = elements.buff.delay.v},
						{list = configB.bind_argument,        value = elements.buff.argument.v},
						{list = configB.bind_my_id_arguments, value = elements.buff.my_id_arg.v},
					}, elements.buff.name.v, UpdateBinderConfig) then
						elements.buff.name.v, elements.buff.int.v, elements.buff.delay.v,
						elements.buff.argument.v, elements.buff.my_id_arg.v = "", "", "0", false, false
						elements.boolean.CreateOrEditCommand = false
						EditOldBind = false
					end
				end
			end
			imgui.EndChild()
			imgui.EndPopup()
        end
		

		imgui.SetNextWindowSize(imgui.ImVec2(430, 430), imgui.Cond.Always)
		if imgui.BeginPopupModal('REPORT', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
			imgui.Separator()
			imgui.Text(u8"Здесь можно создать ответы для ответа на репорты.")
			if imgui.Button(u8'Создать', imgui.ImVec2(-0,25)) then
				EditOldBind = false
				elm.binder.reports.name.v, elm.binder.reports.text.v = '', ''
				imgui.OpenPopup(u8'OpenBinderReports')
			end
			
			if #config.report_bind_name > 0 then
				for key_bind, name_bind in pairs(config.report_bind_name) do
					imgui.Button(name_bind..'##'..key_bind, imgui.ImVec2(-0,25))
					imgui.SameLine()
					if imgui.Button(fai.ICON_FA_EDIT.."##"..key_bind, imgui.ImVec2(-0,25)) then
						EditOldBind = true; getpos = key_bind
						elm.binder.reports.text.v = tostring(config.report_bind_text[key_bind]):gsub('~', '\n')
						elm.binder.reports.name.v = tostring(config.report_bind_name[key_bind])
						imgui.OpenPopup(u8'OpenBinderReports')
					end; imgui.SameLine()
					if imgui.Button(fai.ICON_FA_TRASH.."##"..key_bind, imgui.ImVec2(-0,25)) then
						RemoveBind({config.report_bind_name, config.report_bind_text}, key_bind, config.report_bind_name[key_bind])
					end
				end
			else
				imgui.Text(u8('Здесь пока пусто :( Порадуйте интерфейс, создайте ответ...'))
			end	
			if imgui.BeginPopupModal(u8'OpenBinderReports', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then 
					elm.binder.reports.name.v, elm.binder.reports.text.v = '', ''; imgui.CloseCurrentPopup()
				end
				imgui.Separator()
				imgui.Text(u8'Название бинда:'); imgui.SameLine(); imgui.PushItemWidth(150); imgui.InputText("##binder_name", elm.binder.reports.name); imgui.PopItemWidth()
				imgui.Separator(); imgui.Text(u8'Текст бинда:'); imgui.PushItemWidth(-1); imgui.InputText("##BinderS", elm.binder.reports.text); imgui.PopItemWidth()
				if #elm.binder.reports.name.v > 0 and #elm.binder.reports.text.v > 0 then
					if imgui.Button(u8'Сохранить##bind1', imgui.ImVec2(-1,25)) then
						local refresh_text = elm.binder.reports.text.v:gsub("\n", "~")
						if SaveOrEditBind(EditOldBind, getpos, {
							{list = config.report_bind_name, value = elm.binder.reports.name.v},
							{list = config.report_bind_text, value = refresh_text},
						}, elm.binder.reports.name.v) then
							elm.binder.reports.name.v, elm.binder.reports.text.v = '', ''
							EditOldBind = false
							imgui.CloseCurrentPopup()
						end
					end
				end
				imgui.EndPopup()
			end
			imgui.EndPopup()
		end

		imgui.SetNextWindowSize(imgui.ImVec2(430, 430), imgui.Cond.Always)
		if imgui.BeginPopupModal('ADDITIONALLY', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then imgui.CloseCurrentPopup() end
			imgui.Separator()
			
            imgui.Text(u8"Зажаты клавиши: "); imgui.SameLine(); imgui.Text(atlibs.getDownKeysText()); imgui.Separator()
            local function ATBindRow(label, keyName, suffix)
                imgui.Text(u8(label)); imgui.SameLine()
                imgui.Text(tonumber(config.keys[keyName]) and tostring(config.keys[keyName]) or config.keys[keyName])
                imgui.SameLine(); imgui.SetCursorPosX(imgui.GetWindowWidth() - 150)
                if imgui.Button(u8("Записать ##"..suffix), imgui.ImVec2(70,0)) then config.keys[keyName] = atlibs.getDownKeysText(); ConfigSave() end
                imgui.SameLine()
                if imgui.Button(u8("Очистить ##"..suffix)) then config.keys[keyName] = "None"; ConfigSave() end
                imgui.Separator()
            end
            ATBindRow("AT Меню:  ", "GUI", "1")
            ATBindRow("Открытие /ans:  ", "OpenReport", "2")
            ATBindRow("Выдача /online:  ","GiveOnline", "3")
            ATBindRow("/re в чат:  ", "SendRecon", "4")
			
			-- Мл.Администратор (без рандома)
			imgui.PushItemWidth(100)
			if imgui.InputText(u8'##MA_input', elm.input.prefix_MA) then
				config.colours.prefix_MA = elm.input.prefix_MA.v
				ConfigSave()
			end
			imgui.SameLine()
			imgui.Text(u8'/pma - Мл.Администратор')
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Checkbox(u8'Рандом##PMA_random', elm.random_enabled.prefix_MA) then
				config.random_enabled.prefix_MA = elm.random_enabled.prefix_MA.v
				ConfigSave()
			end
			
			-- Администратор (без рандома)
			imgui.PushItemWidth(100)
			if imgui.InputText(u8'##ADM_input', elm.input.prefix_ADM) then
				config.colours.prefix_ADM = elm.input.prefix_ADM.v
				ConfigSave()
			end
			imgui.SameLine()
			imgui.Text(u8'/pad - Администратор')
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Checkbox(u8'Рандом##ADM_random', elm.random_enabled.prefix_ADM) then
				config.random_enabled.prefix_ADM = elm.random_enabled.prefix_ADM.v
				ConfigSave()
			end
			
			-- Ст.Администратор
			imgui.PushItemWidth(100)
			if imgui.InputText(u8'##STA_input', elm.input.prefix_STA) then
				config.colours.prefix_STA = elm.input.prefix_STA.v
				ConfigSave()
			end
			imgui.SameLine()
			imgui.Text(u8'/psta - Ст.Администратор')
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Checkbox(u8'Рандом##STA_random', elm.random_enabled.prefix_STA) then
				config.random_enabled.prefix_STA = elm.random_enabled.prefix_STA.v
				ConfigSave()
			end
			
			-- Зам.Гл.Администратора
			imgui.PushItemWidth(100)
			if imgui.InputText(u8'##ZGA_input', elm.input.prefix_ZGA) then
				config.colours.prefix_ZGA = elm.input.prefix_ZGA.v
				ConfigSave()
			end
			imgui.SameLine()
			imgui.Text(u8'/pzga - Зам.Гл.Администратора')
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Checkbox(u8'Рандом##ZGA_random', elm.random_enabled.prefix_ZGA) then
				config.random_enabled.prefix_ZGA = elm.random_enabled.prefix_ZGA.v
				ConfigSave()
			end
			
			-- Гл.Администратор
			imgui.PushItemWidth(100)
			if imgui.InputText(u8'##GA_input', elm.input.prefix_GA) then
				config.colours.prefix_GA = elm.input.prefix_GA.v
				ConfigSave()
			end
			imgui.SameLine()
			imgui.Text(u8'/pga - Гл.Администратор')
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Checkbox(u8'Рандом##GA_random', elm.random_enabled.prefix_GA) then
				config.random_enabled.prefix_GA = elm.random_enabled.prefix_GA.v
				ConfigSave()
			end
			imgui.Separator()
				
			imgui.Text(u8'Скрипт админ статистики')
			imgui.SameLine()
			if imgui.ToggleButton('##adminstate', elm.settings_start.adminstate) then  
				config.settings_start.adminstate = elm.settings_start.adminstate.v  
				ConfigSave()
			end
			
			imgui.Text(u8'Скрипт рендера чатов')
			imgui.SameLine()
			if imgui.ToggleButton('##renders', elm.settings_start.renders) then  
				config.settings_start.renders = elm.settings_start.renders.v 
				ConfigSave()
			end
			imgui.Text(u8'Скрипт админ скриптов')
			imgui.SameLine()
			if imgui.ToggleButton('##others', elm.settings_start.others) then  
				config.settings_start.others = elm.settings_start.others.v  
				ConfigSave()
			end
			
			imgui.Text(u8'Скрипт МП(/amp)')
			imgui.SameLine()
			if imgui.ToggleButton('##ATEvent', elm.settings_start.ATEvents) then  
				config.settings_start.ATEvents = elm.settings_start.ATEvents.v  
				ConfigSave()
			end		
			imgui.Text(u8'Скрипт IP-логгер')
			imgui.SameLine()
			if imgui.ToggleButton('##iplogger', elm.settings_start.iplogger) then  
				config.settings_start.iplogger = elm.settings_start.iplogger.v  
				ConfigSave()
			end	
			if imgui.Button(u8'Перезагрузить скрипты') then reloadScripts() end
			imgui.EndPopup()
        end

		imgui.EndChild()
		imgui.PopStyleVar()
        imgui.End()
    end
end

function DrawReconWindow()
	if ATRecon.v then
		if control_to_player then
			if not sampIsPlayerConnected(recon_id) then recon_nick = '-'
			else recon_nick = sampGetPlayerNickname(recon_id) end
			imgui.SetNextWindowPos(imgui.ImVec2(config.position.reX, config.position.reY), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(280, 305), imgui.Cond.FirstUseEver)
			imgui.Begin(u8"" .. recon_nick .. " [" .. recon_id .. "]", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
			if imgui.IsWindowHovered() and imgui.IsMouseClicked(0) and imgui.GetMousePos().y < imgui.GetWindowPos().y + 25 then
				imgui.SetClipboardText(recon_nick)
			end
			
			id_spectator = "" .. recon_id
			imgui.BeginChild("LeftPanel", imgui.ImVec2(80, -0), true)
			if imgui.Button(u8"Спавн", imgui.ImVec2(-1,25)) then
				sampSendChat("/aspawn " .. recon_id)
			end
			if imgui.Button(u8"Слап", imgui.ImVec2(-1,25)) then
				sampSendChat("/slap " .. recon_id)
			end
			if imgui.Button(u8"Фриз", imgui.ImVec2(-1,25)) then
				sampSendChat("/freeze " .. recon_id)
			end
			if imgui.Button(u8"Убить", imgui.ImVec2(-1,25)) then
				lua_thread.create(function()
					sampSendClickPlayer(recon_id, 0)
					wait(200)
					sampSendDialogResponse(500, 1, 7)
				end)
			end
			imgui.Separator()
			if imgui.Button(u8"Посадить", imgui.ImVec2(-1,25)) then select_recon = 1 end
			if imgui.Button(u8"Забанить", imgui.ImVec2(-1,25)) then select_recon = 2 end
			if imgui.Button(u8"Кикнуть", imgui.ImVec2(-1,25)) then select_recon = 3 end
			if imgui.Button(u8"Выйти",imgui.ImVec2(-1,25)) then
				sampSendChat("/reoff ")
			end
			imgui.EndChild(); imgui.SameLine()
			
			imgui.BeginChild("RightPanel", imgui.ImVec2(-0, -0), true)
			if select_recon == 0 then
				for key, v in pairs(info_to_player) do
					if show_stats[key] then
						if key == 1 then imgui.Text(u8:encode(recon_info[1]) .. " " .. info_to_player[1]) end
						if key == 2 and tonumber(info_to_player[2]) ~= 0 then imgui.Text(u8:encode(recon_info[2]) .. " " .. info_to_player[2]) end
						if key == 3 and tonumber(info_to_player[3]) ~= -1 then imgui.Text(u8:encode(recon_info[3]) .. " " .. info_to_player[3]) end
						if key == 4 then
							local text  = tostring(info_to_player[4] or "")
							local speed = tonumber(text:match("^(%d+)")) or 0
							local max_speed = tonumber(text:match("/%s*(%d+)"))
							if max_speed and speed > max_speed then speed = max_speed end
							imgui.Text(u8:encode(recon_info[4]) .. " " .. speed)
						end
						if key ~= 1 and key ~= 2 and key ~= 3 and key ~= 4 then
							if key == 11 then
								local lvl = string.match(info_to_player[11], "(%d+)")
								local str_lvl = ({[0]=u8'N/A',[1]=u8'VIP',[2]=u8'PREMIUM',[3]=u8'DIAMOND',[4]=u8'PLATINUM',[5]=u8'PERSONAL'})[tonumber(lvl)] or ''
								imgui.Text(u8:encode(recon_info[key]) .. " " .. str_lvl)
							elseif key == 15 then
								local chkdrv = string.match(info_to_player[15], '(.+)')
								if chkdrv == 'DISABLED' then imgui.Text(u8:encode(recon_info[key]) .. " " .. u8'Отключено')
								elseif chkdrv == 'ENABLED' then imgui.Text(u8:encode(recon_info[key]) .. " " .. u8'Включено') end
							else
								imgui.Text(u8:encode(recon_info[key]) .. " " .. info_to_player[key])
							end
						end
					end
				end
				imgui.Separator()
				if imgui.Button(u8"Взаимодействие", imgui.ImVec2(-1,25)) then
					imgui.OpenPopup('ReconWithSpecterPlayer')
				end
				if imgui.BeginPopup('ReconWithSpecterPlayer') then
					if imgui.Button(u8'Статистика', imgui.ImVec2(-1,25)) then
						sampSendChat('/statpl ' .. recon_id)
					end
					if imgui.Button(u8'Оффлайн статистика', imgui.ImVec2(-1,25)) then
						sampSendChat('/offstats ' .. recon_nick)
					end
					if imgui.Button(u8'Таб-стата', imgui.ImVec2(-1,25)) then
						lua_thread.create(function()
							sampSendClickPlayer(recon_id,0);
							wait(200);
							sampSendDialogResponse(500,1,10)
						end)
					end
					if imgui.Button(u8'IP-адрес', imgui.ImVec2(-1,25)) then
						lua_thread.create(function()
							sampSendClickPlayer(recon_id,0);
							wait(200);
							sampSendDialogResponse(500,1,12);
							sampCloseCurrentDialogWithButton(0)
						end)
					end
					if imgui.Button(u8'IP-адрес(рук.состав)',imgui.ImVec2(-1,25)) then
						sampSendChat('/getip ' .. recon_id)
					end
					if imgui.Button(u8'Aккаунты с одного IP',imgui.ImVec2(0,25)) then
						lua_thread.create(function()
							checkip = true; sampSendChat('/getip ' .. recon_id)
							while (reg_ip == nil and reg_ip2 == nil and last_ip == nil) do wait(100) end
							if reg_ip   then sampSendChat('/pgetip ' .. reg_ip)   end
							if reg_ip2  then sampSendChat('/pgetip ' .. reg_ip2)  end
							if last_ip  then sampSendChat('/pgetip ' .. last_ip)  end
							reg_ip = nil; reg_ip2 = nil; last_ip = nil; checkip = false
						end)
					end
					if imgui.Button(u8'Оружия игрока', imgui.ImVec2(-1,25)) then 
						sampSendChat('/iwep ' .. recon_id) 
					end
					if imgui.Button(u8'Логи игрока', imgui.ImVec2(-1,25)) then
						sampSendChat('/logsn ' .. recon_nick)
					end
					if imgui.Button(u8'История наказаний', imgui.ImVec2(-1,25)) then
						sampSendChat('/phistory ' .. recon_nick)
					end
					if imgui.Button(u8'ТП к игроку', imgui.ImVec2(-1,25)) then
						lua_thread.create(function() 
							sampSendChat('/reoff')
							ResetReconState()
							wait(200)
							sampSendChat('/agt ' .. id_spectator) 
						end)
					end
					if imgui.Button(u8'ТП игрока к себе', imgui.ImVec2(-1,25)) then
						lua_thread.create(function() 
							sampSendChat('/reoff')
							ResetReconState()
							wait(200)
							sampSendChat('/gethere ' .. id_spectator)
						end)
					end
					imgui.EndPopup()
				end
			elseif select_recon == 1 then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(-1,0)) then select_recon = 0 end
				imgui.Separator()
				if imgui.Button(u8"CHEAT 3000", imgui.ImVec2(-1,25)) then
					local hasAccess  = config.access.jail
					local pid = tonumber(recon_id)
					local playerNick = (pid and sampIsPlayerConnected(pid)) and sampGetPlayerNickname(pid) or ""
					local data = { cmd = "/jail", time = 3000, reason = "CHEAT" }
					sendPunishment(data.cmd, recon_id, data.time, data.reason, hasAccess)
				end
				if imgui.Button(u8"cheat 900", imgui.ImVec2(-1,25)) then
					local hasAccess = config.access.jail
					local pid = tonumber(recon_id)
					local playerNick = (pid and sampIsPlayerConnected(pid)) and sampGetPlayerNickname(pid) or ""
					local data = { cmd = "/jail", time = 900, reason = "cheat", multi = true }
					if elm.boolean.automultiply.v and data.multi and playerNick ~= "" then
						handleMultiplyLogic("cheat_jail_900", data, tostring(recon_id), playerNick, hasAccess, true)
					else
						sendPunishment(data.cmd, recon_id, data.time, data.reason, hasAccess)
					end
				end
				for key in pairs(cmd_massive) do
					local data = cmd_massive[key]
					if data.cmd == "/jail" and data.reason ~= "cheat" and data.reason ~= "CHEAT" then
						if imgui.Button(u8(data.reason), imgui.ImVec2(-1,25)) then
							local hasAccess   = config.access.jail
							local isCheatJail = string.lower(data.reason):find("cheat") ~= nil
							local pid         = tonumber(recon_id)
							local playerNick  = (pid and sampIsPlayerConnected(pid)) and sampGetPlayerNickname(pid) or ""
							if elm.boolean.automultiply.v and data.multi and playerNick ~= "" then
								handleMultiplyLogic(key, data, tostring(recon_id), playerNick, hasAccess, isCheatJail)
							else
								sendPunishment(data.cmd, recon_id, data.time, data.reason, hasAccess)
							end
						end
					end
				end
			elseif select_recon == 2 then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(-1,0)) then select_recon = 0 end
				imgui.Separator()
				for key in pairs(cmd_massive) do
					local data = cmd_massive[key]
					if data.cmd == "/ban" or data.cmd == '/iban' then
						if imgui.Button(u8(data.reason), imgui.ImVec2(-1,25)) then
							local hasAccess  = config.access.ban
							local pid = tonumber(recon_id)
							local playerNick = (pid and sampIsPlayerConnected(pid)) and sampGetPlayerNickname(pid) or ""
							if elm.boolean.automultiply.v and data.multi and playerNick ~= "" then
								handleMultiplyLogic(key, data, tostring(recon_id), playerNick, hasAccess, false)
							else
								sendPunishment(data.cmd, recon_id, data.time, data.reason, hasAccess)
							end
							ResetReconState()
						end
					end
				end
			elseif select_recon == 3 then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(-1,0)) then select_recon = 0 end
				imgui.Separator()
				for key in pairs(cmd_massive) do
					if cmd_massive[key].cmd == "/kick" then
						if imgui.Button(u8(cmd_massive[key].reason), imgui.ImVec2(-1,25)) then
							sampSendChat(cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].reason)
							ResetReconState()
						end
					end
				end
			end
			imgui.EndChild()
		else
			imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
			imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
		end
		imgui.PopStyleVar()
		imgui.End()
	end

	if elm.position.change_recon and not ATRecon.v then
		imgui.SetNextWindowPos(imgui.ImVec2(config.position.reX, config.position.reY), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(280, 305), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Nickname [0]", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
		imgui.BeginChild("PreviewLeftPanel", imgui.ImVec2(80, -0), true)
		imgui.Button(u8"Спавн", imgui.ImVec2(-1,25))
		imgui.Button(u8"Слап", imgui.ImVec2(-1,25))
		imgui.Button(u8"Фриз", imgui.ImVec2(-1,25))
		imgui.Button(u8"Убить", imgui.ImVec2(-1,25))
		imgui.Separator()
		imgui.Button(u8"Посадить", imgui.ImVec2(-1,25))
		imgui.Button(u8"Забанить", imgui.ImVec2(-1,25))
		imgui.Button(u8"Кикнуть", imgui.ImVec2(-1,25))
		imgui.Button(u8"Выйти", imgui.ImVec2(-1,25))
		imgui.EndChild(); imgui.SameLine()
	
		imgui.BeginChild("PreviewRightPanel", imgui.ImVec2(-0, -0), true)
		imgui.TextWrapped(u8"Перетащите окно на нужное место и нажмите <1> для сохранения позиции.")
		imgui.EndChild()
	
		imgui.PopStyleVar()
		imgui.End()
	end
end

function DrawReportDialogWindow()
	if ATReportShow.v and config.main.report_interface then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(530, 300), imgui.Cond.FirstUseEver)
 
		imgui.Begin("##ReportShow", ATReportShow,
			imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize +
			imgui.WindowFlags.NoMove + imgui.WindowFlags.MenuBar)
 
		imgui.BeginMenuBar()
			imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10)
 
			if report_select_menu == 1 then
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 26)
				if imgui.Button(fai.ICON_FA_ARROW_LEFT .. '##ReportBackButton', imgui.ImVec2(27,0)) then
					report_select_menu = 0
				end
			else
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 26)
				if imgui.Button(fai.ICON_FA_TIMES .. '##ReportCloseButton', imgui.ImVec2(27,0)) then
					lua_thread.create(function()
						sampSendDialogResponse(2349, 0, 0)
						wait(50)
						sampSendDialogResponse(2348, 0, 0)
						ATReportShow.v = false
					end)
				end
			end
 
			imgui.PopStyleVar(2)
		imgui.EndMenuBar()
 
		if report_select_menu == 0 then
			imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
 
			if nick_rep and pid_rep and rep_text then
				imgui.Text(nick_rep);  imgui.ToClipboard(nick_rep); imgui.SameLine()
				imgui.Text("[" .. pid_rep .. "]"); imgui.ToClipboard(pid_rep)
				imgui.BeginChild("##ReportText", imgui.ImVec2(397, 45), true, imgui.WindowFlags.HorizontalScrollbar)
					imgui.TextWrapped(u8(u8:decode(rep_text)))
				imgui.EndChild()
			end
			local row_next_y = imgui.GetCursorPosY()
			imgui.SameLine()
			local layout_btn_x = imgui.GetCursorPosX()
			local layout_btn_y = imgui.GetCursorPosY()
			if imgui.Button(u8"ENG -> RUS", imgui.ImVec2(-1,0)) then
				if rep_text and #rep_text > 0 and original_rep_text ~= "" then
					if is_layout_changed then
						rep_text = original_rep_text
						text_rep = original_rep_text
						is_layout_changed = false
					else
						local new_text = atlibs.change_layout(original_rep_text)
						rep_text = new_text
						text_rep = new_text
						is_layout_changed = true
					end
					elm.report.text.v = ""
				else
					sampAddChatMessage(tag .. "{FF5555}Текст не найден", -1)
				end
			end
			local layout_btn_h = imgui.GetItemRectSize().y
 
			imgui.SetCursorPos(imgui.ImVec2(layout_btn_x, layout_btn_y + layout_btn_h + imgui.GetStyle().ItemSpacing.y))
			if imgui.Button(u8"Передать в /a", imgui.ImVec2(-1,0)) then
				SendReportAnswer('Передам ваш репорт!', function()
					sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "]: " .. text_rep)
				end)
			end
 
			imgui.SetCursorPosY(math.max(imgui.GetCursorPosY(), row_next_y))
			imgui.PushItemWidth(397)
			if need_focus_input then
				imgui.SetKeyboardFocusHere()
				need_focus_input = false
			end
			imgui.InputText('##ReportAnswerInput', elm.report.text)
			imgui.PopItemWidth()
 
			imgui.SameLine()
			if imgui.Button(u8"Сохранить ответ", imgui.ImVec2(-1,0)) then
				imgui.OpenPopup('ReportSaveBind')
			end
 
			if imgui.BeginPopupModal(u8'ReportSaveBind', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then
					elm.binder.reports.name.v = ''; imgui.CloseCurrentPopup()
				end
				imgui.Separator()
				imgui.Text(u8'Название бинда:'); imgui.SameLine(); imgui.PushItemWidth(150); imgui.InputText("##report_binder_name", elm.binder.reports.name); imgui.PopItemWidth()
				imgui.Separator(); imgui.Text(u8'Текст бинда:'); imgui.PushItemWidth(-1); imgui.InputText("##report_binder_text", elm.report.text); imgui.PopItemWidth()
				imgui.Separator()
				if #elm.binder.reports.name.v > 0 and #elm.report.text.v > 0 then
					if imgui.Button(u8'Сохранить##reportbind1', imgui.ImVec2(-1,25)) then
						local refresh_text = elm.report.text.v:gsub("\n", "~")
						if SaveOrEditBind(EditOldBind, getpos, {
							{list = config.report_bind_name, value = elm.binder.reports.name.v},
							{list = config.report_bind_text, value = refresh_text},
						}, elm.binder.reports.name.v) then
							elm.binder.reports.name.v = ''
							EditOldBind = false
							imgui.CloseCurrentPopup()
						end
					end
				end
				imgui.EndPopup()
			end
 
			imgui.BeginChild("##ReportAnswersList", imgui.ImVec2(0, 150), true)
				
				local spacing = imgui.GetStyle().ItemSpacing.x
				local avail   = imgui.GetContentRegionAvail().x
				local btnW3   = (avail - 2 * spacing) / 3
				local btnW4   = (avail - 3 * spacing) / 4
				
				if imgui.Button(u8"Работа по репорту", imgui.ImVec2(btnW3, 25)) then
					SendReportAnswer('Приступил(а) к рассмотрению репорта')
				end
				imgui.SameLine()
				if imgui.Button(u8"Следить за ...", imgui.ImVec2(btnW3, 25)) then
					SendReportAnswer('Благодарю за бдительность, начинаю слежку!', function()
						if tonumber(id_punish) ~= nil then sampSendChat("/re " .. id_punish) end
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8"Наказан", imgui.ImVec2(btnW3, 25)) then
					SendReportAnswer('Игрок уже наказан!')
				end
 
				if imgui.Button(u8"Уточните репорт/ID", imgui.ImVec2(btnW3, 25)) then SendReportAnswer('Уточните репорт/ID') end
				imgui.SameLine()
				if imgui.Button(u8"Жб форум", imgui.ImVec2(btnW3, 25)) then SendReportAnswer('Оставьте жалобу на форуме forumrds.ru') end
				imgui.SameLine()
				if imgui.Button(u8'Жб на баг', imgui.ImVec2(btnW3, 25)) then SendReportAnswer('Вам в тех.раздел на forumrds.ru') end
 
				if imgui.Button(u8'+forumrds.ru', imgui.ImVec2(btnW3, 25)) then
					if #elm.report.text.v > 0 then
						elm.report.text.v = elm.report.text.v .. " forumrds.ru"
					else
						elm.report.text.v = "forumrds.ru"
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Не знаем', imgui.ImVec2(btnW3, 25)) then SendReportAnswer('Не знаем') end
				imgui.SameLine()
				if imgui.Button(u8'Ожидайте', imgui.ImVec2(btnW3, 25)) then SendReportAnswer('Ожидайте') end
 
				if imgui.Button(u8'Мут оффтоп', imgui.ImVec2(btnW3, 25)) then
					SendReportAnswer('Пожалуйста, не оффтопьте', function()
						sampSendChat("/rmute " .. pid_rep .. " 120 offtоp")
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Респавн авто', imgui.ImVec2(btnW3, 25)) then
					SendReportAnswer('Уважаемый игрок, сейчас заспавню авто', function()
						sampSendChat("/spawncars 15")
					end)
				end
				imgui.SameLine()
				if imgui.Button(fai.ICON_FA_QUESTION_CIRCLE .. u8" Ответы от AT", imgui.ImVec2(btnW3, 25)) then
					report_select_menu = 1
					elm.report.answers_search.v = ""
					need_focus_search = true
				end
 
				imgui.Separator()
 
				if #config.report_bind_name > 0 then
					for key_bind, name_bind in ipairs(config.report_bind_name) do
						if imgui.Button(name_bind .. "##reportbind" .. key_bind, imgui.ImVec2(btnW3, 25)) then
							local bind_text = config.report_bind_text[key_bind]:gsub("~", "\n")
							if #elm.report.text.v > 0 then
								elm.report.text.v = elm.report.text.v .. " " .. bind_text
							else
								elm.report.text.v = bind_text
							end
						end
						if key_bind % 3 ~= 0 then imgui.SameLine() end
					end
				end
			imgui.EndChild()
 
			if imgui.Button(u8"Ответить", imgui.ImVec2(btnW4,25)) then
				local text = elm.report.text.v
		
				if #text >= 0 and #text <= 5 then
					text = "{AFAFAF}" .. text
				end
				local char_count = math.floor(#text / 2)
				local total_len  = char_count
 
				if total_len < 84 then
					lua_thread.create(function()
						sampSendDialogResponse(2349, 1, 0); wait(50)
						sampSendDialogResponse(2350, 1, 0); wait(50)
						sampSendDialogResponse(2351, 1, 0, u8:decode(text)); wait(50)
						sampCloseCurrentDialogWithButton(13); wait(50)
						elm.report.text.v = ""
					end)
					ATReportShow.v = false
				else
					local half        = math.ceil(char_count / 2)
					local first_part  = text:sub(1, half * 2)
					local second_part = text:sub(half * 2 + 1)
					lua_thread.create(function()
						sampSendDialogResponse(2349, 1, 0); wait(50)
						sampSendDialogResponse(2350, 1, 0); wait(50)
						if sampIsPlayerConnected(pid_rep) then
							local part1 = first_part .. '...'
							sampSendDialogResponse(2351, 1, 0, u8:decode(part1)); wait(50)
							sampCloseCurrentDialogWithButton(13); wait(50)
							elm.report.text.v = ""
							local part2 = '...' .. second_part
							sampSendChat('/ans ' .. pid_rep .. ' ' .. u8:decode(part2))
						else
							sampSendDialogResponse(2351, 1, 0, u8:decode(text)); wait(50)
							sampCloseCurrentDialogWithButton(13); wait(50)
							elm.report.text.v = ""
						end
					end)
					ATReportShow.v = false
				end
			end
 
			local win_padding = imgui.GetStyle().WindowPadding.x
			imgui.SameLine(imgui.GetWindowWidth() - btnW4 - win_padding)
			if imgui.Button(u8"Отклонить", imgui.ImVec2(btnW4,25)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0); wait(50)
					sampSendDialogResponse(2350, 1, 1); wait(50)
					sampSendDialogResponse(2351, 0, 0)
					ATReportShow.v   = false
				end)
			end
 
			imgui.PopStyleVar(1)
		end
 
		if report_select_menu == 1 then
			imgui.PushItemWidth(-1)
			if need_focus_search then
				imgui.SetKeyboardFocusHere()
				need_focus_search = false
			end
			imgui.InputText(u8"##ReportAnswersSearch", elm.report.answers_search)
			imgui.PopItemWidth()
 
			imgui.BeginChild("##ReportAnswersSearchResults", imgui.ImVec2(0, -1), true)
				local query = toLowerCP1251(u8:decode(elm.report.answers_search.v))
 
				if #query == 0 then
					imgui.TextWrapped(u8"")
				else
					local found = false
					for _, item in ipairs(all_answers) do
						if item.search_name:find(query, 1, true) or item.search_desc:find(query, 1, true) then
							found = true
							if imgui.Button(item.name, imgui.ImVec2(-1,25)) then
								SendReportAnswer(item.desc)
								elm.report.answers_search.v = ""
								report_select_menu = 0
							end
						end
					end
					if not found then
						imgui.TextWrapped(u8"Ничего не найдено")
					end
				end
			imgui.EndChild()
		end
 
		imgui.End()
	end
end

function DrawKeyHelper()
	if config.main.key_helper and key_helper.v then
		local inputPtr = sampGetInputInfoPtr()
		local in1 = getStructElement(inputPtr, 0x8, 4)
		local in2 = getStructElement(in1, 0x8, 4)
		local in3 = getStructElement(in1, 0xC, 4)
		fib = in3 + 50; fib2 = in2 + 10
		imgui.SetNextWindowPos(imgui.ImVec2(fib2, fib), imgui.Cond.FirstUseEver, imgui.ImVec2(0, -0.1))
		imgui.SetNextWindowSize(imgui.ImVec2(590, 120), imgui.Cond.FirstUseEver)
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.09, 0.09, 0.09, 0.80))
		imgui.Begin("##HelperCommands", key_helper, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
		local lowerInput = check_cmd_punis and string.lower(check_cmd_punis)
		local function matchesInput(key)
			if not lowerInput then return true end
			return key:find(lowerInput, 1, true) ~= nil or key == lowerInput:match("(.+) (.+)") or key == lowerInput:match("(.+)")
		end
		local function drawCmd(key, source, labels)
			local info = labels[source[key].cmd]; if not info then return end
			imgui.Text(info[1] .. ': /' .. key .. info[2] .. u8:encode(source[key].reason))
			if imgui.IsItemClicked() then sampSetChatInputText("/" .. key) end
		end
		for key in pairs(cmd_massive)  do if matchesInput(key) then drawCmd(key, cmd_massive,  cmdLabels) end end
		for key in pairs(cmd_massive2)  do if matchesInput(key) then drawCmd(key, cmd_massive2,  cmdLabels) end end
		if lowerInput then
			local match1, match2 = lowerInput:match("([^%s]+)%s([^%s]+)"); local match3 = lowerInput:match("([^%s]+)")
			for key in pairs(cmd_helper_others) do
				if key:find(lowerInput,1,true)~=nil or key==match1 or key==match2 or key==match3 then
					imgui.Text('/' .. key .. u8:encode(cmd_helper_others[key].reason))
					if imgui.IsItemClicked() then sampSetChatInputText("/" .. key) end
				end
			end
		else
			for key in pairs(cmd_helper_others) do
				imgui.Text('/' .. key .. u8:encode(cmd_helper_others[key].reason))
				if imgui.IsItemClicked() then sampSetChatInputText("/" .. key) end
			end
		end
		for key in pairs(cmd_helper_answers) do
			if matchesInput(key) then
				local reasons = {cmd_helper_answers[key].reason, cmd_helper_answers[key].reason2, cmd_helper_answers[key].reason3}
				for _, reason in ipairs(reasons) do
					if reason then
						if lowerInput then imgui.Text(u8'Ответ в чат: /' .. key .. u8:encode(reason))
						else imgui.Text(u8'Ответ в чат: /' .. key .. ' [ID] - ' .. u8:encode(reason)) end
						if imgui.IsItemClicked() then sampSetChatInputText('/' .. key .. ' ID') end
					end
				end
			end
		end
		imgui.End(); imgui.PopStyleColor()
	end
end

function DrawTimescreen()
	if elm.boolean.timescreen.v then
		local posX  = elm.position.timescreen_posX
		local posY  = elm.position.timescreen_posY
		local scale = (elm.int.timescreen_scale.v or 15) / 10.0
		imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Always, imgui.ImVec2(1.0, 0.0))
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0,0,0,0))
		imgui.PushStyleColor(imgui.Col.Border,   imgui.ImVec4(0,0,0,0))
		imgui.Begin('##NickTimeDisplay', nil, imgui.WindowFlags.NoResize+imgui.WindowFlags.NoMove+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.AlwaysAutoResize+imgui.WindowFlags.NoTitleBar+imgui.WindowFlags.NoScrollbar)
		imgui.SetWindowFontScale(scale)
		local _, myid = sampGetPlayerIdByCharHandle(playerPed)
		local mynick  = sampGetPlayerNickname(myid)
		local display_text = mynick .. " [" .. myid .. "] | " .. os.date("%d.%m.%y | %H:%M:%S", os.time())
		if elm.boolean.timescreen_rgb.v then
			local r, g, b = getTimeScreenColor()
			imgui.TextColored(imgui.ImVec4(r/255, g/255, b/255, 1), u8(display_text))
		else
			local hex = elm.input.timescreen_color.v or "FFFFFF"
			local r = tonumber("0x" .. hex:sub(1,2)) or 255
			local g = tonumber("0x" .. hex:sub(3,4)) or 255
			local b = tonumber("0x" .. hex:sub(5,6)) or 255
			imgui.TextColored(imgui.ImVec4(r/255, g/255, b/255, 1), u8(display_text))
		end
		imgui.SetWindowFontScale(1.0)
		imgui.End(); imgui.PopStyleColor(2)
	end
end

function DrawScoreboard()
	if not show_main_window.v then return end

    local mainW, mainH, mainX, mainY
    if config.scoreboard.type == 0 then
        mainW, mainH = 320, 400
    elseif config.scoreboard.type == 1 then
        mainW, mainH = 400, 480
    elseif config.scoreboard.type == 2 then
        mainW, mainH = 500, 560
    else
        mainW, mainH = sw, sh
    end

    local logW, logH, logX, logY = 370, sh, 0, 0
    local xOffset = 0

    if show_set_window.v then
        local setW, setH = 220, 185
        imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
        local setX = sw - setW - 10
        local setY = 30
        imgui.SetNextWindowPos(imgui.ImVec2(setX, setY), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(setW, setH), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Настройки', show_set_window, 2+4+32)

        imgui.Text(u8"Размер окна:") imgui.SameLine() imgui.PushItemWidth(127)
        if imgui.Combo("##type", cType, {u8"Маленький", u8"Средний", u8"Большой", u8"На весь экран"}) then config.scoreboard.type = cType.v end

        imgui.Text(u8"Заголовок:") imgui.SameLine() imgui.PushItemWidth(139)
        if imgui.Combo("##header", bTitlebar, {u8"Стандарт", u8"Только текст", u8"Скрыть"}) then config.scoreboard.titlebar = bTitlebar.v end

        imgui.Text(u8"Ники игроков:") imgui.SameLine() imgui.PushItemWidth(120)
        if imgui.Combo("##ntype", cNType, {u8"Стандарт", u8"Цвет отдельно", u8"Без цвета"}) then config.scoreboard.nickType = cNType.v end
        if imgui.Checkbox(u8"Журнал подключений", bLog) then config.scoreboard.clog = bLog.v end

        if imgui.Button(u8"Сохранить изменения", imgui.ImVec2(-1, 25)) then
            ConfigSave()
        end
        imgui.End()
        imgui.PopStyleVar()
    end

    playerCount = 0

    if bLog.v then
        imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 4.0))
        imgui.SetNextWindowPos(imgui.ImVec2(logX, logY), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(logW, logH), imgui.Cond.Always)
        imgui.Begin(u8"##connectLogBar", nil,
            imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove +
            imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar +
            imgui.WindowFlags.NoBringToFrontOnFocus)
        imgui.Separator()

        imgui.PushItemWidth(logW - 8)
        imgui.InputText("##logConFilter", logConFilter)
        imgui.PopItemWidth()
        if not imgui.IsItemActive() and logConFilter.v:len() == 0 then
            imgui.SameLine(5)
            imgui.TextColored(imgui.ImColor(180,180,180,180):GetVec4(), u8"Поиск...")
        end

        imgui.Separator()

        local childH = logH - 70
        imgui.BeginChild("##connectLog", imgui.ImVec2(logW - 8, childH))
        imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 2))

        if #logConnect > 0 then
            local viewLog = {}
            for k, v in ipairs(logConnect) do
                if logConFilter.v:len() > 0 then
                    if string.find(atlibs.string_rlower(v), atlibs.string_rlower(u8:decode(logConFilter.v)), 1, true) then
                        table.insert(viewLog, v)
                    end
                else
                    table.insert(viewLog, v)
                end
            end

            local clipper = imgui.ImGuiListClipper(#viewLog)
            while clipper:Step() do
                for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
                    imgui.TextWrapped(u8(viewLog[i]))
                    if (imgui.IsItemClicked(0) or imgui.IsItemClicked(1)) then
                        local nick = viewLog[i]:match("%[%d+:%d+:%d+%] (.+)%[%d+%]")
                        if nick then setClipboardText(nick) end
                    end
                end
            end

            if logConFilter.v:len() > 0 and #viewLog == 0 then
                imgui.Text(u8"Не найдено...")
            end
        else
            imgui.Text(u8"Журнал подключений пуст...")
        end

        if ScrollToButton then
            imgui.SetScrollHere()
            ScrollToButton = false
        end

        imgui.PopStyleVar()
        imgui.EndChild()
        imgui.End()
        imgui.PopStyleVar()
    end

    if config.scoreboard.type == 3 then
        mainX, mainY = xOffset, 0
        mainW, mainH = sw - xOffset, sh
    else
        local availW = sw - xOffset
        mainX = xOffset + math.max(0, (availW - mainW) / 2)
        mainY = math.max(0, (sh - mainH) / 2)
    end

    imgui.SetNextWindowPos(imgui.ImVec2(mainX, mainY), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(mainW, mainH), imgui.Cond.Always)

    local servername = u8(sampGetCurrentServerName())
    imgui.Begin(servername, show_main_window,
        imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove +
        imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar +
        (bTitlebar.v > 0 and imgui.WindowFlags.NoTitleBar or 0))

    if bTitlebar.v == 1 then
        local snSize = imgui.CalcTextSize(servername)
        imgui.SetCursorPos(imgui.ImVec2(mainW / 2 - snSize.x / 2, 3))
        imgui.Text(servername)
        imgui.Separator()
    end

    imgui.AlignTextToFramePadding()
    imgui.Text(u8"Всего игроков: " .. sampGetPlayerCount(false))

    local bText = u8"Настройки"
    local sText = u8"Поиск игроков"
    local bSize = imgui.CalcTextSize(bText)

    local cColumns = 4
    if cNType.v == 1 then cColumns = cColumns + 1 end

    imgui.SameLine(mainW - 155)
    imgui.PushItemWidth(150)
    imgui.PushAllowKeyboardFocus(false)
    imgui.InputText("##search", searchBuf, imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.CharsNoBlank)
    imgui.PopAllowKeyboardFocus()
    imgui.PopItemWidth()
    if not imgui.IsItemActive() and #searchBuf.v == 0 then
        imgui.SameLine(mainW - 153)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(180, 180, 180, 180):GetVec4())
        imgui.Text(sText)
        imgui.PopStyleColor()
    end

    imgui.SameLine(mainW - (bSize.x + 155 + 9))
    if imgui.Button(bText) then
        show_set_window.v = not show_set_window.v
    end

    local id_width    = 32
    local color_width = (cNType.v == 1 and 70 or 0)
    local score_width = 60
    local ping_width  = 40
    local nick_width  = mainW - id_width - score_width - ping_width - color_width - 25

    imgui.Columns(cColumns)
    imgui.Separator()
    imgui.NewLine()
    imgui.SameLine(2)

    imgui.SetColumnWidth(-1, id_width); imgui.Text('ID'); imgui.NextColumn()
    imgui.SetColumnWidth(-1, nick_width); imgui.Text(u8'Ник'); imgui.NextColumn()
    if cNType.v == 1 then
        imgui.SetColumnWidth(-1, color_width); imgui.Text(u8'Цвет'); imgui.NextColumn()
    end
    imgui.SetColumnWidth(-1, score_width); imgui.Text(u8'Счет'); imgui.NextColumn()
    imgui.SetColumnWidth(-1, ping_width); imgui.Text(u8'Пинг'); imgui.NextColumn()

    imgui.Columns(1)
    imgui.Separator()

    imgui.BeginChild("##scoreboardScroll", imgui.ImVec2(0, 0), false)
    imgui.Columns(cColumns)

    imgui.SetColumnWidth(-1, id_width); imgui.NextColumn()
    imgui.SetColumnWidth(-1, nick_width); imgui.NextColumn()
    if cNType.v == 1 then
        imgui.SetColumnWidth(-1, color_width); imgui.NextColumn()
    end
    imgui.SetColumnWidth(-1, score_width); imgui.NextColumn()
    imgui.SetColumnWidth(-1, ping_width); imgui.NextColumn()

    local local_id = atlibs.getMyId()
    if #searchBuf.v == 0 or string.find(sampGetPlayerNickname(local_id):lower(), searchBuf.v:lower(), 1, true) or tostring(local_id) == searchBuf.v then
        drawScoreboardPlayer(local_id)
    end

    local viewPlayers = {}
    for i = 0, sampGetMaxPlayerId(false) do
        if i == local_id then goto continue end
        if not sampIsPlayerConnected(i) then goto continue end
        if #searchBuf.v == 0 or string.find(sampGetPlayerNickname(i):lower(), searchBuf.v:lower(), 1, true) or tostring(i) == searchBuf.v then
            table.insert(viewPlayers, i)
        end
        ::continue::
    end

    if #viewPlayers > 0 then
        local clipper = imgui.ImGuiListClipper(#viewPlayers)
        while clipper:Step() do
            for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
                drawScoreboardPlayer(viewPlayers[i])
            end
        end
    end

    imgui.Columns(1)
    if playerCount == 0 then
        imgui.SameLine(5)
        imgui.Text(u8"Список пуст...")
    end
    imgui.Separator()
    imgui.EndChild()

    imgui.End()
end

function drawScoreboardPlayer(id)
    local nick = encoding.UTF8(sampGetPlayerNickname(id))
    local score = sampGetPlayerScore(id)
    local ping = sampGetPlayerPing(id)
    local color = sampGetPlayerColor(id)
    local r = bitex.bextract(color, 16, 8)
    local g = bitex.bextract(color, 8, 8)
    local b = bitex.bextract(color, 0, 8)
    local imgui_RGBA = imgui.ImVec4(r/255, g/255, b/255, 1)

    playerCount = playerCount + 1

    imgui.NewLine()
    imgui.SameLine(2)
    imgui.PushID(id)

    if imgui.Selectable(tostring(id), id == focusId, imgui.SelectableFlags.SpanAllColumns + imgui.SelectableFlags.AllowDoubleClick) then
        if imgui.IsMouseDoubleClicked(0) then
            sampSendClickPlayer(id, 0)
            lua_thread.create(function() wait(150) toggleScoreboard(false) end)
        else
            focusId = focusId == id and -1 or id
        end
    end

    if imgui.BeginPopupContextItem() then
        imgui.TextColored(imgui_RGBA, nick .. "[" .. id .. "]")
        imgui.Separator()
        imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(8, 6))
        if imgui.Button(u8'Копировать никнейм', imgui.ImVec2(math.max(180, imgui.GetContentRegionAvail().x), 0)) then
            setClipboardText(nick)
            imgui.CloseCurrentPopup()
        end
        imgui.PopStyleVar()
        imgui.EndPopup()
    end

    imgui.PopID()
    imgui.NextColumn()

    if cNType.v == 0 then
        imgui.TextColored(imgui_RGBA, nick)
    else
        imgui.Text(nick)
    end
    imgui.NextColumn()

    if cNType.v == 1 then
        imgui.TextColored(imgui_RGBA, "0x" .. string.upper(string.format("%08X", color):sub(1,8)))
        imgui.NextColumn()
    end

    imgui.Text(tostring(score)); imgui.NextColumn()
    imgui.Text(tostring(ping)); imgui.NextColumn()

    if scrollToId and focusId == id then
        scrollToId = false
        imgui.SetScrollHere(0.43)
    end
end
function showFlood_ImGUI()
	if imgui.BeginPopup('mainFloods') then
		if imgui.Button(u8'Флуд про репорты', imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 4 ===================== | ПОМОЩЬ АДМИНИСТРАЦИИ | ====================")
			sampSendChat("/mess 4 Увидели подозрительного игрока или нарушителя? Не молчите!")
			sampSendChat("/mess 4 Используйте /report и укажите ID нарушителя")
			sampSendChat("/mess 4 Администраторы обязательно придут на помощь и разберутся в ситуации!")
			sampSendChat("/mess 4 ===================== | ПОМОЩЬ АДМИНИСТРАЦИИ | ====================")
		end
		if imgui.Button(u8'Флуд про набор адм', imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 6 ===================== | НАБОР В АДМИНИСТРАЦИЮ | ====================")
			sampSendChat("/mess 6 Друзья, а вы уже знакомы с нашими правилами?")
			sampSendChat("/mess 6 Всегда мечтали помогать игрокам и поддерживать порядок? Сейчас отличный момент!")
			sampSendChat("/mess 6 На форуме открыт набор в команду! Ждём именно вас: forumrds.ru")
			sampSendChat("/mess 6 ===================== | НАБОР В АДМИНИСТРАЦИЮ | ====================")
		end
		if imgui.Button(u8'Спавн каров на 15 секунд', imgui.ImVec2(0,25)) then
			sampSendChat("/spawncars 15")
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopup('FloodsGangWar') then
		if imgui.Button(u8"Aztecas vs Ballas", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 3 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs East Side Ballas ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 3 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Aztecas vs Groove", imgui.ImVec2(0,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 2 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Groove Street ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 2 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Aztecas vs Vagos", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 4 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Los Santos Vagos ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 4 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Aztecas vs Rifa", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 5 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs The Rifa ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 5 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Grove vs Ballas", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 6 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Grove Street  ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 6 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Ballas vs Rifa", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 7 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs The Rifa ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 7 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Groove vs Rifa", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 8 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street  vs The Rifa ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 8 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Groove vs Vagos", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 9 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street vs Los Santos Vagos ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 9 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Vagos vs Rifa", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 10 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 Los Santos Vagos vs The Rifa ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 10 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		if imgui.Button(u8"Ballas vs Vagos", imgui.ImVec2(-1,25)) then
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
			sampSendChat("/mess 11 Игра -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Los Santos Vagos ")
			sampSendChat("/mess 0 Помогите своим братьям, заходите через /gw за любимую банду")
			sampSendChat("/mess 11 Игра - GangWar: /gw")
			sampSendChat("/mess 13 •------------------- GangWar -------------------•")
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopup('CustomsFloods') then
		if #config.flood_name > 0 then
			for key, name in pairs(config.flood_name) do
				if imgui.Button(name .. '##'..key, imgui.ImVec2(-0,25)) then 
					for stream_text_flood in config.flood_text[key]:gmatch('[^~]+') do
						sampSendChat('/mess ' .. u8:decode(tostring(stream_text_flood)))
					end
				end
				imgui.SameLine()
				if imgui.Button(fai.ICON_FA_EDIT .. '##'..key..'CreatorFlood', imgui.ImVec2(-0,25)) then
					EditOldBind = true; getpos = key
					local returnwrapped = tostring(config.flood_text[key]):gsub('~', '\n')
					elm.binder.flood.text.v = returnwrapped
					elm.binder.flood.name.v = tostring(config.flood_name[key])
					imgui.OpenPopup('CreateFloodFrame')
				end
				imgui.SameLine()
				if imgui.Button(fai.ICON_FA_TRASH .. '##'..key..'CreatorFlood', imgui.ImVec2(-0,25)) then
					RemoveBind({config.flood_name, config.flood_text}, key, config.flood_name[key])
				end
			end
			imgui.Separator()
			if imgui.Button(u8'Создать флуд') then
				EditOldBind = false
				elm.binder.flood.name.v, elm.binder.flood.text.v = '', ''
				imgui.OpenPopup('CreateFloodFrame')
			end
		else
			imgui.Text(u8'Здесь пусто. Нет флудов. Создайте лучше <3')
			if imgui.Button(u8'Создать флуд') then
				EditOldBind = false
				elm.binder.flood.name.v, elm.binder.flood.text.v = '', ''
				imgui.OpenPopup('CreateFloodFrame')
			end
		end
		if imgui.BeginPopupModal('CreateFloodFrame', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27,0)) then 
				elm.binder.flood.name.v, elm.binder.flood.text.v = '', ''
				imgui.CloseCurrentPopup()
			end
			imgui.Separator()
			imgui.Text(u8'Название флуда:'); imgui.SameLine(); imgui.PushItemWidth(130)
			imgui.InputText('##Flood_Name', elm.binder.flood.name)
			imgui.PopItemWidth(); imgui.PushItemWidth(100); imgui.Separator()
			imgui.Text(u8'Текст бинда:'); imgui.PushItemWidth(400)
			imgui.InputTextMultiline('##Flood_Text', elm.binder.flood.text)
			imgui.PopItemWidth()
			if #elm.binder.flood.name.v > 0 and #elm.binder.flood.text.v > 0 then
				if imgui.Button(u8"Сохранить##FloodCreator", imgui.ImVec2(-1,25)) then
					local refresh_text = elm.binder.flood.text.v:gsub('\n', "~")
					if SaveOrEditBind(EditOldBind, getpos, {
						{list = config.flood_name, value = elm.binder.flood.name.v},
						{list = config.flood_text, value = refresh_text},
					}, elm.binder.flood.name.v) then
						elm.binder.flood.name.v, elm.binder.flood.text.v = '', ''
						EditOldBind = false
						imgui.CloseCurrentPopup()
					end
				end
			end
			imgui.EndPopup()
		end
		imgui.EndPopup()
	end
end