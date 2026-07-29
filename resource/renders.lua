script_description('Скрипт для отображения различных чатов и событий на экране (рендер)')
script_author('alfantasyz')
require "lib.moonloader"
local fflags = require("moonloader").font_flag
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local imgui = require 'imgui'
local atlibs = require 'ATLibs'
local fa = require 'faicons'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local tag = "{7d00ff} [AdminTools] {FFFFFF}"

-- ========================================================================
-- Конфиг
-- ========================================================================
local directIni = "AdminTools\\renders.ini"
local config = inicfg.load({
    settings = {
        dchat = false, pmchat = false, reportchat = false,
        warningchat = false, lquit = false, achat = false,
    },
    dchat       = { X=0, Y=0, lines=10, Font=10 },
    pmchat      = { X=0, Y=0, lines=10, Font=10 },
    reportchat  = { X=0, Y=0, lines=10, Font=10 },
    warningchat = { X=0, Y=0, lines=10, Font=10 },
    lquit       = { X=0, Y=0, lines=10, Font=10 },
    achat       = { X=50, Y=300, lines=10, Font=10, centered=0, nickside=1 },
}, directIni) or {}

if not config.settings then config.settings = {} end
inicfg.save(config, directIni)

-- ========================================================================
-- Шрифты (храним в таблице)
-- ========================================================================
local fonts = {}

local function createFont(size)
    return renderCreateFont("Arial", size, fflags.BOLD + fflags.SHADOW)
end


function imgui.SettingsButton()
    imgui.SameLine()
    imgui.PushFont(minimalfont)
    imgui.TextDisabled(fa.ICON_FA_COG)
    imgui.PopFont()
    return imgui.IsItemClicked()
end

local function updateFont(key, size)
    if fonts[key] then
        renderReleaseFont(fonts[key])
    end
    fonts[key] = createFont(size)
end

local function updateAllFonts()
    updateFont("dchat",       config.dchat.Font       or 10)
    updateFont("pmchat",      config.pmchat.Font      or 10)
    updateFont("reportchat",  config.reportchat.Font  or 10)
    updateFont("warningchat", config.warningchat.Font or 10)
    updateFont("lquit",       config.lquit.Font       or 10)
    updateFont("achat",       config.achat.Font       or 10)
end

-- ========================================================================
-- Данные чатов
-- ========================================================================
local elements = {
    boolean = {
        dchat       = imgui.ImBool(config.settings.dchat       or false),
        pmchat      = imgui.ImBool(config.settings.pmchat      or false),
        reportchat  = imgui.ImBool(config.settings.reportchat  or false),
        warningchat = imgui.ImBool(config.settings.warningchat or false),
        lquit       = imgui.ImBool(config.settings.lquit       or false),
        achat       = imgui.ImBool(config.settings.achat       or false),
    },
    dchat = {
        chat_lines = {}, X = config.dchat.X       or 0, Y = config.dchat.Y       or 0,
        lines = imgui.ImInt(config.dchat.lines or 10),
        Font  = imgui.ImInt(config.dchat.Font  or 10),
    },
    pmchat = {
        chat_lines = {}, X = config.pmchat.X      or 0, Y = config.pmchat.Y      or 0,
        lines = imgui.ImInt(config.pmchat.lines or 10),
        Font  = imgui.ImInt(config.pmchat.Font  or 10),
    },
    reportchat = {
        chat_lines = {}, X = config.reportchat.X  or 0, Y = config.reportchat.Y  or 0,
        lines = imgui.ImInt(config.reportchat.lines or 10),
        Font  = imgui.ImInt(config.reportchat.Font or 10),
    },
    warningchat = {
        chat_lines = {}, X = config.warningchat.X or 0, Y = config.warningchat.Y or 0,
        lines = imgui.ImInt(config.warningchat.lines or 10),
        Font  = imgui.ImInt(config.warningchat.Font or 10),
    },
    lquit = {
        chat_lines = {}, X = config.lquit.X       or 0, Y = config.lquit.Y       or 0,
        lines = imgui.ImInt(config.lquit.lines or 10),
        Font  = imgui.ImInt(config.lquit.Font  or 10),
    },
    achat = {
        chat_lines = {},
        X = config.achat.X or 50,
        Y = config.achat.Y or 300,
        lines    = imgui.ImInt(config.achat.lines or 10),
        Font     = imgui.ImInt(config.achat.Font  or 10),
        centered = imgui.ImInt(config.achat.centered or 0),
        nickside = imgui.ImInt(config.achat.nickside or 1),
        pos      = false,
    }
}

local no_saved = { X=0, Y=0 }
local quitReason = { "вылетел / краш", "вышел из игры", "кикнут / забанен" }

-- ========================================================================
-- Сохранение / загрузка
-- ========================================================================
local function save()
    config.settings.dchat       = elements.boolean.dchat.v
    config.settings.pmchat      = elements.boolean.pmchat.v
    config.settings.reportchat  = elements.boolean.reportchat.v
    config.settings.warningchat = elements.boolean.warningchat.v
    config.settings.lquit       = elements.boolean.lquit.v
    config.settings.achat       = elements.boolean.achat.v

    config.dchat       = { X=elements.dchat.X,       Y=elements.dchat.Y,       lines=elements.dchat.lines.v,       Font=elements.dchat.Font.v       }
    config.pmchat      = { X=elements.pmchat.X,      Y=elements.pmchat.Y,      lines=elements.pmchat.lines.v,      Font=elements.pmchat.Font.v      }
    config.reportchat  = { X=elements.reportchat.X,  Y=elements.reportchat.Y,  lines=elements.reportchat.lines.v,  Font=elements.reportchat.Font.v  }
    config.warningchat = { X=elements.warningchat.X, Y=elements.warningchat.Y, lines=elements.warningchat.lines.v, Font=elements.warningchat.Font.v }
    config.lquit       = { X=elements.lquit.X,       Y=elements.lquit.Y,       lines=elements.lquit.lines.v,       Font=elements.lquit.Font.v       }
    config.achat       = { X=elements.achat.X,       Y=elements.achat.Y,       lines=elements.achat.lines.v,       Font=elements.achat.Font.v,
                                 centered=elements.achat.centered.v, nickside=elements.achat.nickside.v }

    inicfg.save(config, directIni)
end

local function loadAll()
    for _, k in ipairs({"dchat","pmchat","reportchat","warningchat","lquit","achat"}) do
        local sec = elements[k]
        local cfg = config[k] or {}
        sec.X = cfg.X or sec.X
        sec.Y = cfg.Y or sec.Y
        sec.lines.v   = cfg.lines   or sec.lines.v
        sec.Font.v    = cfg.Font    or sec.Font.v
    end

    elements.achat.centered.v = config.achat.centered or 0
    elements.achat.nickside.v = config.achat.nickside or 1
end

-- ========================================================================
-- Перемещение
-- ========================================================================
local function changePosition(what)
    if isKeyJustPressed(49) then
        what.pos = false
        save()
    else
        what.X, what.Y = getCursorPos()
    end
end

-- ========================================================================
-- Рендер
-- ========================================================================
local function drawChatBlock(font, lines_table, x, y, count, active)
    if not active or not font then return end

    local lineHeight = (renderGetFontDrawHeight(font) or 16) + 4

    for i = count, 1, -1 do
        local txt = lines_table[i] or ""
        local cy = y + lineHeight * (count - i)
        renderFontDrawText(font, txt, x, cy, 0xFF9999FF)
    end
end

local function drawAdminChat()
    local ac = elements.achat
    if not elements.boolean.achat.v or not fonts.achat then return end

    local lineHeight = (renderGetFontDrawHeight(fonts.achat) or 16) + 4

    for i = ac.lines.v, 1, -1 do
        local txt = ac.chat_lines[i] or ""
        if txt == "" then goto continue end

        local cy = ac.Y + lineHeight * (ac.lines.v - i)
        local cx = ac.X
        local textLen = renderGetFontDrawTextLength(fonts.achat, txt) or 0

        if ac.centered.v == 1 then
            cx = cx - textLen / 2
        elseif ac.centered.v == 2 then
            cx = cx - textLen
        end

        renderFontDrawText(fonts.achat, txt, cx, cy, 0xFFFFFFFF)

        ::continue::
    end
end

local function addTestLine(chat_key, example_text)
    local t = elements[chat_key].chat_lines
    local time = os.date("%H:%M:%S")
    local line = example_text:gsub("{TIME}", time)
    table.insert(t, 1, line)
    if #t > elements[chat_key].lines.v then
        table.remove(t)
    end
end

-- ========================================================================
-- События
-- ========================================================================
function sampev.onServerMessage(color, text)
    local time = os.date("%H:%M:%S")

	-- /pm
	if text:find("%[A] SMS:") and elements.boolean.pmchat.v then
		local body, sender, receiver = text:match("%[A] SMS: (.+) | отправил (.+) игроку (.+)")
		local t = elements.pmchat.chat_lines
		if body then
			table.insert(t, 1, "{FFFFFF}["..time.."] {d1ac5c}/pm:{FFFFFF} "..body.." | "..sender.." -> "..receiver)
		else
			table.insert(t, 1, "{FFFFFF}["..time.."] {d1ac5c}/pm:{FFFFFF} "..(text:match("%[A] SMS: (.+)") or ""))
		end
		if #t > elements.pmchat.lines.v then table.remove(t) end
		return false
	end
	
	-- /d
	if text:find("%[A] NEARBY CHAT:") and elements.boolean.dchat.v then
		local body, sender = text:match("%[A] NEARBY CHAT: (.+) | отправил (.+)")
		local t = elements.dchat.chat_lines
		if body then
			table.insert(t, 1, "{FFFFFF}["..time.."] {8c8c8c}/d:{FFFFFF} "..body.." | "..sender)
		else
			table.insert(t, 1, "{FFFFFF}["..time.."] {8c8c8c}/d:{FFFFFF} "..(text:match("%[A] NEARBY CHAT: (.+)") or ""))
		end
		if #t > elements.dchat.lines.v then table.remove(t) end
		return false
	end

    -- /report
    if text:find("Жалоба .+ | {AFAFAF}.+%[%d+%]:") and elements.boolean.reportchat.v then
        local t = elements.reportchat.chat_lines
        table.insert(t, 1, text)
        if #t > elements.reportchat.lines.v then table.remove(t) end
        return false
    end

    -- Warning / Kick
    if elements.boolean.warningchat.v and (text:find("<AC%-WARNING>") or text:find("<AC%-KICK>")) then
        local t = elements.warningchat.chat_lines
        table.insert(t, 1, text)
        if #t > elements.warningchat.lines.v then table.remove(t) end
        return false
    end

    -- Admin Chat
    if elements.boolean.achat.v then
        local lvl, adm, clr, nick, id, msg = text:match("%[A%-(%d+)%] %(([^%s]+){([^}]+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")
        if not lvl then
            lvl, nick, id, msg = text:match("%[A%-(%d+)%]([^%[]+)%[(%d+)%]: {FFFFFF}(.+)")
            adm, clr = nil, nil
        end
        if lvl then
            local colorhex = clr or bit.tohex(color):sub(3,8)
            local line
            if elements.achat.nickside.v == 1 then
                if adm then
                    line = adm.."{"..colorhex.."} • "..lvl.." • "..nick.."["..id.."] : {FFFFFF}"..msg
                else
                    line = lvl.." • "..nick.."["..id.."] : {FFFFFF}"..msg
                end
            else
                if adm then
                    line = "{FFFFFF}"..msg.." {"..colorhex.."} : "..nick.."["..id.."] • "..lvl.." • "..adm
                else
                    line = "{FFFFFF}"..msg.." : "..nick.."["..id.."] • "..lvl
                end
            end

            local t = elements.achat.chat_lines
            table.insert(t, 1, line)
            if #t > elements.achat.lines.v then table.remove(t) end

            return false
        end
    end
end

function sampev.onPlayerJoin(id, color, isNpc, nickname)
    if not elements.boolean.lquit.v then return end
    local t = elements.lquit.chat_lines
    table.insert(t, 1, string.format("%s[%d] {00FF00}подключился", nickname, id))
    if #t > elements.lquit.lines.v then table.remove(t) end
end

function sampev.onPlayerQuit(id, reason)
    if not elements.boolean.lquit.v then return end
    local t = elements.lquit.chat_lines
    table.insert(t, 1, string.format("%s[%d] %s", sampGetPlayerNickname(id), id, quitReason[reason+1] or "неизвестно"))
    if #t > elements.lquit.lines.v then table.remove(t) end
end

-- ========================================================================
-- ImGui
-- ========================================================================
imgui.ToggleButton = require('imgui_addons').ToggleButton
local rbutton = imgui.ImInt(0)

function EXPORTS.ActiveChatRenders()
    local choices = {
        { key = "pmchat",      label = u8"/pm" },
        { key = "dchat",       label = u8"/d" },
        { key = "reportchat",  label = u8"/report" },
        { key = "warningchat", label = u8"Warning" },
        { key = "lquit",       label = u8"Вход/Выход" },
        { key = "achat",       label = u8"Админ-чат" },
    }
    for i, item in ipairs(choices) do
        local key = item.key
        local sec = elements[key]
        local bool = elements.boolean[key]

        imgui.Text(item.label)
        imgui.SameLine()
        if imgui.ToggleButton('##toggle_'..key, bool) then
            save()
        end

        if imgui.SettingsButton() then
            imgui.OpenPopup('settings_popup_'..key)
        end
        if imgui.BeginPopupModal('settings_popup_'..key, false,
            imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        then
            if imgui.Button(fa.ICON_FA_ARROW_LEFT, imgui.ImVec2(27, 0)) then
                imgui.CloseCurrentPopup()
            end
            imgui.SameLine()
            imgui.Text(item.label)
            imgui.Separator()

            imgui.PushItemWidth(120)
            local prevLines = sec.lines.v
            imgui.InputInt(u8"Строки##lines_"..key, sec.lines)
            if sec.lines.v ~= prevLines then
                save()
            end

            local prevFont = sec.Font.v
            imgui.InputInt(u8"Шрифт##font_"..key, sec.Font)
            if sec.Font.v ~= prevFont then
                updateFont(key, sec.Font.v)
                save()
            end
            imgui.PopItemWidth()

            if key == "achat" then
                local ac = elements.achat

                local prevCentered = ac.centered.v
                imgui.Combo(u8"Выравнивание##centered", ac.centered,
                    {u8"Слева", u8"По центру", u8"Справа"})
                if ac.centered.v ~= prevCentered then
                    save()
                end

                local prevNickside = ac.nickside.v
                imgui.Combo(u8"Расположение ника##nickside", ac.nickside,
                    {u8"Слева от текста", u8"Справа от текста"})
                if ac.nickside.v ~= prevNickside then
                    save()
                end
            end

            imgui.Separator()

            if imgui.Button(u8"Тест##test_"..key) then
                if key == "pmchat" then
                    addTestLine("pmchat", "{FFFFFF}[{TIME}] {d1ac5c}/pm:{FFFFFF} Привет, тест | David(123) -> Kirill(321)")
                elseif key == "dchat" then
                    addTestLine("dchat", "{FFFFFF}[{TIME}] {8c8c8c}/d:{FFFFFF} Всем привет | David(123)")
                elseif key == "reportchat" then
                    addTestLine("reportchat", "Жалоба #1 | {AFAFAF}David[123]: {FFFFFF}Читер на арене")
                elseif key == "warningchat" then
                    addTestLine("warningchat", "<AC-WARNING> {ffffff}David[123]{82b76b} подозревается в использовании чит-программ: {ffffff}SpeedHack (onfoot) [code: 009]")
                elseif key == "lquit" then
                    addTestLine("lquit", "Tester[123] {00FF00}подключился")
                elseif key == "achat" then
                    addTestLine("achat", "Администратор • 15 • David[123]: {FFFFFF}Тестовое сообщение админ-чата")
                end
            end
            imgui.SameLine()
            if imgui.Button(u8"Очистить##clear_"..key) then
                elements[key].chat_lines = {}
            end
            imgui.SameLine()
            if imgui.Button(u8"Позиция##pos_"..key) then
                no_saved.X, no_saved.Y = sec.X, sec.Y
                sec.pos = true
                sampAddChatMessage(tag .. "Для сохранения позиции, нажмите кнопку <1> на клавиатуре.", -1)
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
    end
end

-- ========================================================================
-- main
-- ========================================================================
function main()

    while not isSampAvailable() do wait(0) end

    updateAllFonts()
    loadAll()

	while true do
		wait(0)
	
		drawChatBlock(fonts.dchat,       elements.dchat.chat_lines,       elements.dchat.X,       elements.dchat.Y,       elements.dchat.lines.v,       elements.boolean.dchat.v)
		drawChatBlock(fonts.pmchat,      elements.pmchat.chat_lines,      elements.pmchat.X,      elements.pmchat.Y,      elements.pmchat.lines.v,      elements.boolean.pmchat.v)
		drawChatBlock(fonts.reportchat,  elements.reportchat.chat_lines,  elements.reportchat.X,  elements.reportchat.Y,  elements.reportchat.lines.v,  elements.boolean.reportchat.v)
		drawChatBlock(fonts.warningchat, elements.warningchat.chat_lines, elements.warningchat.X, elements.warningchat.Y, elements.warningchat.lines.v, elements.boolean.warningchat.v)
		drawChatBlock(fonts.lquit,       elements.lquit.chat_lines,       elements.lquit.X,       elements.lquit.Y,       elements.lquit.lines.v,       elements.boolean.lquit.v)
		drawAdminChat()
	
		local needCursor = elements.dchat.pos or elements.pmchat.pos
						or elements.reportchat.pos or elements.warningchat.pos
						or elements.lquit.pos or elements.achat.pos
	
		imgui.Process    = needCursor
		imgui.ShowCursor = needCursor
	
		if elements.dchat.pos       then changePosition(elements.dchat)       end
		if elements.pmchat.pos      then changePosition(elements.pmchat)      end
		if elements.reportchat.pos  then changePosition(elements.reportchat)  end
		if elements.warningchat.pos then changePosition(elements.warningchat) end
		if elements.lquit.pos       then changePosition(elements.lquit)       end
		if elements.achat.pos       then changePosition(elements.achat)       end
	end
end

function EXPORTS.OffScript()
    for _, f in pairs(fonts) do
        if f then renderReleaseFont(f) end
    end

    imgui.Process = false
    imgui.ShowCursor = false
    thisScript():unload()
end