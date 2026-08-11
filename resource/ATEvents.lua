script_author('alfantasyz // modded: madoka')
require 'lib.moonloader'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local sampev = require 'lib.samp.events'
local atlibs = require 'ATLibs'
local fai = require "fAwesome5"
local fa = require 'faicons'
local dlstatus = require('moonloader').download_status
local tag = "{7d00ff} [AdminTools] {FFFFFF}"
encoding.default = 'CP1251'
u8 = encoding.UTF8

local ATMainDirect = "AdminTools\\settings.ini"
local ATMainConfig = inicfg.load({
    main = {
        styleImGUI = 0,
    },
}, ATMainDirect)

local directIni = "AdminTools\\events.ini"

local config = inicfg.load({
    main = {
        auto_tp = false,
        stream_window = false,
    },
}, directIni)
inicfg.save(config, directIni)

local BinderMP = "AdminTools\\evbinder.ini"
local BinderMPcfg = inicfg.load({
    bind_name = {},
    bind_text = {},
    bind_delay = {},
    bind_vdt = {},
    bind_coords = {}
}, BinderMP)
inicfg.save(BinderMPcfg, BinderMP)

function save()
    inicfg.save(config, directIni)
end

local elements = {
    main = {
        auto_tp = imgui.ImBool(config.main.auto_tp),
        stream_window = imgui.ImBool(config.main.stream_window),
    },
    buffers = {
        name = imgui.ImBuffer(128),
        dt_vt = imgui.ImBuffer(32),
        rules = imgui.ImBuffer(65536),
        win_player = imgui.ImBuffer(32),
        bin_name = imgui.ImBuffer(256),
        bin_text = imgui.ImBuffer(65536),
        bin_delay = imgui.ImBuffer(2500),
        bin_vdt = imgui.ImBuffer(32),
        bin_coord = imgui.ImBuffer(4096),
        gun_player = imgui.ImBuffer(64),
        freezeplayer = imgui.ImBuffer(128),
        tweapplayer = imgui.ImBuffer(128),
        spawnplayer = imgui.ImBuffer(128),
    },
}

-- ## Блок переменных связанных с конфигами ## --

local READY_EVENTS_URL  = 'https://raw.githubusercontent.com/madokaez/AdminTools/main/config/evbinder.ini'
local READY_EVENTS_PATH = getWorkingDirectory() .. '/config/AdminTools/evbinder.ini'

function InstallReadyEvents()
    lua_thread.create(function()
        sampAddChatMessage(tag .. 'Загружаю готовые мероприятия...', -1)
        local done = false
        downloadUrlToFile(READY_EVENTS_URL, READY_EVENTS_PATH, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA
            or status == dlstatus.STATUS_ENDDOWNLOADDATA_ERR then
                done = true
            end
        end)
        local waited = 0
        while not done and waited < 30000 do wait(200); waited = waited + 200 end

        local fresh = inicfg.load({
            bind_name = {}, bind_text = {}, bind_delay = {}, bind_vdt = {}, bind_coords = {}
        }, BinderMP)

        if not fresh or not fresh.bind_name then
            sampAddChatMessage(tag .. 'Ошибка чтения файла мероприятий', -1)
            return
        end

        local function clear(t) for k in pairs(t) do t[k] = nil end end
        clear(BinderMPcfg.bind_name)
        clear(BinderMPcfg.bind_text)
        clear(BinderMPcfg.bind_delay)
        clear(BinderMPcfg.bind_vdt)
        clear(BinderMPcfg.bind_coords)
        for k, v in pairs(fresh.bind_name)   do BinderMPcfg.bind_name[k]   = v end
        for k, v in pairs(fresh.bind_text)   do BinderMPcfg.bind_text[k]   = v end
        for k, v in pairs(fresh.bind_delay)  do BinderMPcfg.bind_delay[k]  = v end
        for k, v in pairs(fresh.bind_vdt)    do BinderMPcfg.bind_vdt[k]    = v end
        for k, v in pairs(fresh.bind_coords) do BinderMPcfg.bind_coords[k] = v end

        sampAddChatMessage(tag .. ('Готовые мероприятия установлены (%d шт.).'):format(#BinderMPcfg.bind_name), -1)
    end)
end

local function parseCoordPoints(str)
    local valid = {}
    if type(str) ~= "string" or #str < 5 then return valid end
    local points = atlibs.string_split(str, "|")
    for _, p in ipairs(points) do
        local xyz = atlibs.string_split(p, ",")
        if xyz[1] and xyz[2] and xyz[3]
        and tonumber(xyz[1]) and tonumber(xyz[2]) and tonumber(xyz[3]) then
            table.insert(valid, {
                tonumber(xyz[1]), tonumber(xyz[2]), tonumber(xyz[3])
            })
        end
    end
    return valid
end

local function pickRandomVW()
    math.randomseed(os.time() + math.floor(os.clock() * 1000))
    math.random(); math.random(); math.random()
    return math.random(500, 999)
end

-- ## Блок переменных связанных с MoonImGUI ## --

local sw, sh = getScreenResolution()

local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })

function imgui.BeforeDrawFrame()
    if fai_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fai_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fai_glyph_ranges)
    end
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
    end
end

imgui.ToggleButton     = require('imgui_addons').ToggleButton
imgui.VerticalSeparator = require('imgui_addons').VerticalSeparator
imgui.Spinner          = require('imgui_addons').Spinner
imgui.BufferingBar     = require('imgui_addons').BufferingBar
imgui.TextQuestion     = require('imgui_addons').TextQuestion
imgui.CenterText       = require('imgui_addons').CenterText
imgui.Tooltip          = require('imgui_addons').Tooltip

local ATEvent = imgui.ImBool(false)
local EventStream = imgui.ImBool(false)
local menuSelect = 0

local Stream_Text
local current_mp_name = ""
function main()
    while not isSampAvailable() do wait(0) end

    sampRegisterChatCommand("amp", function()
        ATEvent.v = not ATEvent.v
        imgui.Process = ATEvent.v
        imgui.ShowCursor = ATEvent.v
    end)

    while true do
        wait(0)
        local needImgui  = ATEvent.v or EventStream.v
        imgui.Process    = needImgui
        if not needImgui then imgui.ShowCursor = false end

        if isKeyJustPressed(VK_X) and not sampIsChatInputActive() and EventStream.v and not sampIsDialogActive() then
            imgui.ShowCursor = not imgui.ShowCursor
        end
    end
end

-- ## Блок обработки ивентов и пакетов SA:MP ## --
function sampev.onServerMessage(color, text)
    if text:find("Администратор " .. atlibs.getMyNick() .. "%[(%d+)%] создал мероприятие") then
        sampAddChatMessage(tag .. " Мероприятие было открыто.", -1)
        if elements.main.stream_window.v then
            sampAddChatMessage(tag .. " Интерфейс для управления MP запущено.", -1)
            EventStream.v = true
        end
    end
end

function playersToStreamZone()
    local peds = getAllChars()
    local streaming_player = {}
    local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    for key, v in pairs(peds) do
        local result, id = sampGetPlayerIdByCharHandle(v)
        if result and id ~= pid and id ~= tonumber(recon_id) then
            streaming_player[key] = id
        end
    end
    return streaming_player
end

function imgui.OnDrawFrame()
    if ATMainConfig.main.styleImGUI == 0 then
        imgui.SwitchContext()
        atlibs.black()
    end

    if ATEvent.v then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 280), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(fai.ICON_FA_NEWSPAPER .. " AT Events", ATEvent, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar + imgui.WindowFlags.NoScrollbar)

        imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))

        imgui.BeginMenuBar()
        imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10)
        if imgui.Button(fai.ICON_FA_WAREHOUSE, imgui.ImVec2(27, 0)) then
            menuSelect = 0
        end; imgui.Tooltip(u8"Настройки скрипта AT Events")
        if imgui.Button(fai.ICON_FA_TERMINAL, imgui.ImVec2(27, 0)) then
            menuSelect = 2
        end; imgui.Tooltip(u8"Использование заготовленных мероприятий | создание новых заготовок. \nПредусматривает использование введенных мероприятий разработчиком, их модернизация и добавление своих.")
        imgui.PopStyleVar(1)
        imgui.EndMenuBar()

        if menuSelect == 0 then
            positionX, positionY, positionZ = getCharCoordinates(playerPed)
            imgui.Text(u8"Здесь Вы можете создать мероприятие и управлять им.")
            imgui.Text(u8"AT Events предполагает создание своего мероприятия \nс нуля или использования заготовленных разработчиком.")
            imgui.Text("")
            imgui.Text(u8"Ваши координаты: \nX: " .. positionX .. " | Y: " .. positionY .. " | Z: " .. positionZ)
            if imgui.IsItemClicked() then
                imgui.LogToClipboard()
                imgui.LogText(positionX .. " " .. positionY .. " " .. positionZ)
                imgui.LogFinish()
            end
            imgui.Tooltip(u8"Кликнув на координаты, Вы их можете скопировать. Это поможет в создании мероприятия.")
            imgui.Separator()

            if imgui.ToggleButton(fai.ICON_FA_CAMERA .. u8' Управление MP', elements.main.stream_window) then
                config.main.stream_window = elements.main.stream_window.v
                sampAddChatMessage(tag .. "Сохранение настроек AT Events", -1)
                inicfg.save(config, directIni)
            end

            if imgui.Button(u8"Ручное открытие управления МП", imgui.ImVec2(-1, 25)) then
                ATEvent.v = false
                EventStream.v = not EventStream.v
            end; imgui.Tooltip(u8"Используйте, если Вы случайно во время МП его закрыли.")
        end

        if menuSelect == 2 then
            imgui.Text(u8"В данном разделе можно использовать мероприятия от \nразработчика, либо создать свои и использовать их в дальнейшем.")

            imgui.Text(u8"Помощник по созданию. Наведите мышкой! \nЯ могу показывать Вам сообщение помощника :D");
            imgui.Tooltip(u8"И так. Легкое объяснение по созданию своего мероприятия. \nТекст в правилах/описание следует следующему правилу:\n1. Вводится по принципу флудов, т.е. номер цвета mess и текст. Пример: \n 6 Участие в МП могут принять все! \n 6 Запрещено пользоваться /heal, /r и /s\n2. Каждая строчка делается отдельно для правильного вывода. \n\n Координаты: можно указывать несколько точек через '|', скрипт выберет случайную. \n Мероприятия стабильно редактируются, поэтому Вы все можете подстроить под себя.")
            imgui.Separator()

            if imgui.Button(u8"Создать мероприятие", imgui.ImVec2(200, 25)) then
                elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_coord.v = '', '', "2500", ""
                elements.buffers.bin_vdt.v = "0"
                getpos = nil
                EditOldBind = false
                imgui.OpenPopup('EventsBinder')
            end
            imgui.SameLine()
            if imgui.Button(u8"Установить готовые", imgui.ImVec2(-1, 25)) then
                InstallReadyEvents()
            end
            if #BinderMPcfg.bind_name > 0 then
                for key_bind, name_bind in pairs(BinderMPcfg.bind_name) do
                    if imgui.Button(name_bind .. '##' .. key_bind, imgui.ImVec2(0, 25)) then
                        lua_thread.create(function()
                            local raw_coords = tostring(BinderMPcfg.bind_coords[key_bind] or "")
                            local valid = parseCoordPoints(raw_coords)
                            if #valid > 0 then
                                math.randomseed(os.time() + math.floor(os.clock() * 1000))
                                math.random(); math.random(); math.random()
                                local idx = math.random(1, #valid)
                                local pick = valid[idx]
                                setCharCoordinates(PLAYER_PED, pick[1], pick[2], pick[3])
                            end
                            local auto_vw = tostring(pickRandomVW())
                            BinderMPcfg.bind_vdt[key_bind] = auto_vw
                            inicfg.save(BinderMPcfg, BinderMP)

                            current_mp_name = tostring(BinderMPcfg.bind_name[key_bind] or "")

                            Stream_Text = atlibs.string_split(BinderMPcfg.bind_text[key_bind], "~")
                            wait(500)
                            sampSendChat("/mp")
                            sampSendDialogResponse(5343, 1, 15)
                            wait(1)
                            sampSendDialogResponse(16069, 1, 1)
                            sampSendDialogResponse(16070, 1, 0, auto_vw)
                            sampSendDialogResponse(16069, 1, 2)
                            sampSendDialogResponse(16071, 1, 0, "0")
                            sampSendDialogResponse(16069, 0, 0)
                            sampSendDialogResponse(5343, 1, 0)
                            wait(200)
                            sampSendDialogResponse(5344, 1, 0, u8:decode(tostring(BinderMPcfg.bind_name[key_bind])))
                            sampCloseCurrentDialogWithButton(0)
                            wait(500)
                            for _, input in pairs(Stream_Text) do
                                sampSendChat("/mess " .. u8:decode(tostring(input)))
                            end
                            sampSendChat("/s")
                        end)
                    end
                    imgui.SameLine()
                    if imgui.Button(fai.ICON_FA_EDIT .. '##' .. key_bind, imgui.ImVec2(27, 0)) then
                        EditOldBind = true
                        getpos = key_bind
                        local returnwrapped = tostring(BinderMPcfg.bind_text[key_bind]):gsub('~', '\n')
                        elements.buffers.bin_text.v = returnwrapped
                        elements.buffers.bin_name.v = tostring(BinderMPcfg.bind_name[key_bind])
                        elements.buffers.bin_delay.v = tostring(BinderMPcfg.bind_delay[key_bind])
                        elements.buffers.bin_coord.v = tostring(BinderMPcfg.bind_coords[key_bind] or "")
                        elements.buffers.bin_vdt.v = tostring(BinderMPcfg.bind_vdt[key_bind] or "0")
                        imgui.OpenPopup('EventsBinder')
                    end
                    imgui.SameLine()
                    if imgui.Button(fai.ICON_FA_TRASH .. "##" .. key_bind, imgui.ImVec2(27, 0)) then
                        sampAddChatMessage(tag .. 'МП "' .. u8:decode(BinderMPcfg.bind_name[key_bind]) .. '" удалено!', -1)
                        table.remove(BinderMPcfg.bind_name,   key_bind)
                        table.remove(BinderMPcfg.bind_text,   key_bind)
                        table.remove(BinderMPcfg.bind_delay,  key_bind)
                        table.remove(BinderMPcfg.bind_vdt,    key_bind)
                        table.remove(BinderMPcfg.bind_coords, key_bind)
                        inicfg.save(BinderMPcfg, BinderMP)
                    end
                end
            else
                imgui.Text(u8('Ни одно мероприятие не зарегистрировано. Может, создадим?'))
            end

            if imgui.BeginPopupModal('EventsBinder', false, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
                if imgui.Button(fai.ICON_FA_ARROW_LEFT, imgui.ImVec2(27, 0)) then
                    elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_coord.v = '', '', "2500", ""
                    elements.buffers.bin_vdt.v = "0"
                    imgui.CloseCurrentPopup()
                end
                imgui.Separator()
                imgui.Text(u8"Название МП: "); imgui.SameLine()
                imgui.PushItemWidth(200)
                imgui.InputText('##name_events', elements.buffers.bin_name)
                imgui.PopItemWidth()
                imgui.Text(u8"Координаты (несколько точек через '|'):")
                imgui.PushItemWidth(-1)
                imgui.InputText("##CoordsEvent", elements.buffers.bin_coord)
                imgui.PopItemWidth()
                imgui.Tooltip(u8"Формат одной точки: x,y,z\nНесколько точек разделяются символом '|'.\nПри запуске МП скрипт выберет случайную точку из списка.\nПример: 1234.5,678.9,10.0|2000.0,-1500.0,15.0")

                if imgui.Button(u8"Мои координаты", imgui.ImVec2(150, 25)) then
                    local px, py, pz = getCharCoordinates(playerPed)
                    local function fmt(n) return string.format("%.4f", n) end
                    local newPoint = fmt(px) .. "," .. fmt(py) .. "," .. fmt(pz)
                    if #elements.buffers.bin_coord.v > 0 then
                        elements.buffers.bin_coord.v = elements.buffers.bin_coord.v .. "|" .. newPoint
                    else
                        elements.buffers.bin_coord.v = newPoint
                    end
                end; imgui.Tooltip(u8"Добавляет ваши текущие координаты как новую точку.\nМожно нажимать несколько раз, чтобы задать несколько точек ТП.")

                imgui.SameLine()
                if imgui.Button(u8"Очистить точки", imgui.ImVec2(150, 25)) then
                    elements.buffers.bin_coord.v = ""
                end; imgui.Tooltip(u8"Удаляет все точки телепорта из этого мероприятия.")

                imgui.SameLine()
                do
                    local _pts = parseCoordPoints(elements.buffers.bin_coord.v or "")
                    imgui.Text(u8("Точек: ") .. tostring(#_pts))
                end

                imgui.Separator()
                if imgui.Button(u8"Стандартные правила МП##bindstd", imgui.ImVec2(-1, 25)) then
                    local std_rules = u8"6 После телепортации - в строй. Команды, дм - запрещено"
                    if #elements.buffers.bin_text.v > 0 then
                        elements.buffers.bin_text.v = elements.buffers.bin_text.v .. "\n" .. std_rules
                    else
                        elements.buffers.bin_text.v = std_rules
                    end
                end; imgui.Tooltip(u8"Вставляет стандартные правила мероприятия в поле правил.")
                imgui.PushItemWidth(300)
                imgui.InputTextMultiline("##EventText", elements.buffers.bin_text, imgui.ImVec2(400, 100))
                imgui.PopItemWidth()

                if imgui.Button(u8'Сохранить##bind', imgui.ImVec2(-1, 25)) then
                    if #elements.buffers.bin_name.v > 0 and #elements.buffers.bin_text.v > 0 then
                        if not EditOldBind then
                            local refresh_text = elements.buffers.bin_text.v:gsub("\n", "~")
                            table.insert(BinderMPcfg.bind_name,   elements.buffers.bin_name.v)
                            table.insert(BinderMPcfg.bind_text,   refresh_text)
                            table.insert(BinderMPcfg.bind_delay,  elements.buffers.bin_delay.v)
                            table.insert(BinderMPcfg.bind_vdt,    "0")
                            table.insert(BinderMPcfg.bind_coords, elements.buffers.bin_coord.v)
                            if inicfg.save(BinderMPcfg, BinderMP) then
                                sampAddChatMessage(tag .. 'МП "' .. u8:decode(elements.buffers.bin_name.v) .. '" успешно создано!', -1)
                                elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_coord.v = '', '', "2500", ""
                                elements.buffers.bin_vdt.v = "0"
                            end
                            imgui.CloseCurrentPopup()
                        else
                            local refresh_text = elements.buffers.bin_text.v:gsub("\n", "~")
                            BinderMPcfg.bind_name[getpos]   = elements.buffers.bin_name.v
                            BinderMPcfg.bind_text[getpos]   = refresh_text
                            BinderMPcfg.bind_delay[getpos]  = elements.buffers.bin_delay.v
                            BinderMPcfg.bind_vdt[getpos]    = BinderMPcfg.bind_vdt[getpos] or "0"
                            BinderMPcfg.bind_coords[getpos] = elements.buffers.bin_coord.v
                            if inicfg.save(BinderMPcfg, BinderMP) then
                                sampAddChatMessage(tag .. 'МП "' .. u8:decode(elements.buffers.bin_name.v) .. '" успешно отредактировано!', -1)
                                elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_coord.v = '', '', "2500", ""
                                elements.buffers.bin_vdt.v = "0"
                            end
                            EditOldBind = false
                            imgui.CloseCurrentPopup()
                        end
                    else
                        sampAddChatMessage(tag .. u8:decode(u8"Заполните название и правила МП!"), -1)
                    end
                end
                imgui.EndPopup()
            end
        end

        imgui.PopStyleVar()
        imgui.End()
    end

    if EventStream.v then
        local id_to_stream = playersToStreamZone()

        imgui.SetNextWindowPos(imgui.ImVec2(sw, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(1.0, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(360, math.min(600, sh - 80)), imgui.Cond.FirstUseEver)
        imgui.Begin("Event Stream", EventStream, imgui.WindowFlags.NoCollapse)
        imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))

        if imgui.Button(u8"Закрыть окно", imgui.ImVec2(-1, 25)) then EventStream.v = false end; imgui.Tooltip(u8"Использовать в том случае, когда данное окно не является необходимым для проведения мероприятия; \nЛибо же мероприятие закончилось, а окно автоматически не закрылось")
        if imgui.Button(u8"Закрыть /tpmp", imgui.ImVec2(170, 25)) then
            lua_thread.create(function()
                sampSendChat("/mp")
                wait(10)
                sampSendDialogResponse(5343, 1, 0)
                wait(100)
                sampCloseCurrentDialogWithButton(0)
                current_mp_name = ""
            end)
        end
        imgui.SameLine()
        if imgui.Button(u8"Призыв к /tpmp", imgui.ImVec2(-1, 25)) then
            local mp_label
            if current_mp_name ~= nil and #current_mp_name > 0 then
                mp_label = u8:decode(current_mp_name)
            else
                mp_label = "мероприятие"
                sampAddChatMessage(tag .. "Название МП неизвестно - сначала запусти МП из списка. Использую слово \"мероприятие\".", -1)
            end
            sampSendChat('/mess 6 Телепорт на "' .. mp_label .. '" ещё открыт! Используйте /tpmp')
            sampSendChat("/mess 6 После телепортации - в строй.")
            sampSendChat("/mess 6 Успейте, до начала мероприятия!")
        end
        if imgui.Button(u8"Удачно/Неудачно (/try)", imgui.ImVec2(170, 25)) then
            sampSendChat("/try Убит?")
        end
        imgui.SameLine()
        if imgui.Button(u8"Начать отсчет", imgui.ImVec2(-1, 25)) then
            sampAddChatMessage(tag .. " Функция в разработке", -1)
        end
        if imgui.Button(u8"Выдать миниган", imgui.ImVec2(-1, 25)) then
            sampSendChat("/setweap " .. atlibs.getMyId() .. " 38 5000")
        end

        if imgui.Button(u8"Закончить МП, если недостаточно участников", imgui.ImVec2(-1, 25)) then
            lua_thread.create(function()
                if #id_to_stream > 0 then
                    for _, v in pairs(id_to_stream) do
                        sampSendChat("/aspawn " .. v)
                    end
                    sampSendChat("/mp")
                    wait(10)
                    sampSendDialogResponse(5343, 1, 0)
                    wait(100)
                    sampCloseCurrentDialogWithButton(0)
                    sampSendChat("/mess 6 Мероприятие было отменено из-за недостатка участников.")
                    sampSendChat("/tweap " .. atlibs.getMyId())
                    sampSendChat("/spawn")
                    current_mp_name = ""
                end
            end)
        end
        imgui.Separator()
        imgui.Text(u8"ID игрока, которого нужно заморозить/разморозить")
        imgui.PushItemWidth(30)
        imgui.InputText('##input1', elements.buffers.freezeplayer)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(u8"Заморозить/Разморозить игрока", imgui.ImVec2(-1, 25)) then
            sampSendChat("/freeze " .. elements.buffers.freezeplayer.v)
        end
        if imgui.Button(u8"Заморозить/Разморозить всех", imgui.ImVec2(-1, 25)) then
            if #id_to_stream > 0 then
                for _, v in pairs(id_to_stream) do
                    sampSendChat("/freeze " .. v)
                end
            end
        end
        imgui.Separator()
        imgui.Text(u8"ID игрока, которого нужно обезоружить")
        imgui.PushItemWidth(30)
        imgui.InputText('##input2', elements.buffers.tweapplayer)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(u8"Обезоружить игрока", imgui.ImVec2(-1, 25)) then
            sampSendChat("/tweap " .. elements.buffers.tweapplayer.v)
        end
        if imgui.Button(u8"Обезоружить всех", imgui.ImVec2(-1, 25)) then
            lua_thread.create(function()
                sampSendChat("/mp ")
                sampSendDialogResponse(5343, 1, 3)
                wait(100)
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        imgui.Separator()
        imgui.Text(u8"ID игрока, которого нужно заспавнить")
        imgui.PushItemWidth(30)
        imgui.InputText('##input3', elements.buffers.spawnplayer)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(u8"Заспавнить игрока", imgui.ImVec2(-1, 25)) then
            sampSendChat("/aspawn " .. elements.buffers.spawnplayer.v)
        end
        if imgui.Button(u8"Заспавнить всех", imgui.ImVec2(-1, 25)) then
            if #id_to_stream > 0 then
                for _, v in pairs(id_to_stream) do
                    sampSendChat("/aspawn " .. v)
                end
            end
        end
        imgui.Separator()
        imgui.Text(u8"ID победителя")
        imgui.PushItemWidth(30)
        imgui.InputText('##WinPlayerEndEvent', elements.buffers.win_player)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(u8"Выдать приз", imgui.ImVec2(-1, 25)) then
            lua_thread.create(function()
                if #id_to_stream > 0 then
                    for _, v in pairs(id_to_stream) do
                        sampSendChat("/aspawn " .. v)
                    end
                    sampSendChat("/mpwin " .. elements.buffers.win_player.v)
                    sampSendChat("/tweap " .. atlibs.getMyId())
                    sampSendChat("/spawn")
                end
            end)
        end
        imgui.Separator()
        imgui.Text(u8'Выдать оружия участникам МП'); imgui.Tooltip(u8'Если нужно выдать одно оружие, введите просто его ID. Если нужно выдать несколько, введите список через запятую.\nПример: 24,38,23')
        imgui.PushItemWidth(75)
        imgui.InputText('##GunPlayerEvent', elements.buffers.gun_player)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(u8"Выдать оружие", imgui.ImVec2(-1, 25)) then
            gun_ids = atlibs.string_split(elements.buffers.gun_player.v, ",")
            if #id_to_stream > 0 then
                for _, v in pairs(id_to_stream) do
                    for _, vid in pairs(gun_ids) do
                        sampSendChat("/setweap " .. v .. " " .. vid .. " 5000")
                    end
                end
            end
        end

        imgui.Separator()
        if #id_to_stream > 0 then
            imgui.BeginChild("##players_list", imgui.ImVec2(500, 200), true)
            for _, v in pairs(id_to_stream) do
                if imgui.Button(" - " .. sampGetPlayerNickname(v) .. "[" .. v .. "]", imgui.ImVec2(0, 25)) then
                    sampSendChat("/aspawn " .. v)
                end; imgui.Tooltip(u8"При клике - игрока заспавнит")
                imgui.SameLine()
                if imgui.Button(u8"Нарушение правил мп##jail" .. v, imgui.ImVec2(0, 25)) then
                    sampSendChat("/jail " .. v .. " 300 нарушение правил мп")
                end
                imgui.SameLine()
                if imgui.Button(u8"Срыв мп##jail2" .. v, imgui.ImVec2(0, 25)) then
                    sampSendChat("/jail " .. v .. " 3000 нарушение правил мп")
                end
            end
            imgui.EndChild()
        else
            imgui.Text(u8"Кроме Вас нет никого рядом...")
        end

        imgui.PopStyleVar()
        imgui.End()
    end
end

function EXPORTS.OffScript()
    imgui.Process = false
    imgui.ShowCursor = false
    thisScript():unload()
end