_addon.name = 'BrokeWatch'
_addon.author = 'Antigravity Department'
_addon.version = '1.0'
_addon.commands = {'broke', 'brokewatch'}

local texts = require('texts')
local config = require('config')
local user_settings = require('user_settings')
require('chat')

-- Localized Lua standard functions and Windower APIs
local math_floor = math.floor
local string_format = string.format
local tostring = tostring
local os_clock = os.clock
local ipairs = ipairs
local table_insert = table.insert
local table_remove = table.remove

local windower_ffxi = windower.ffxi
local windower_ffxi_get_items = windower_ffxi.get_items
local windower_ffxi_get_player = windower_ffxi.get_player
local windower_ffxi_get_info = windower_ffxi.get_info
local windower_file_exists = windower.file_exists
local windower_play_sound = windower.play_sound

-- Default settings referencing user_settings
local default_settings = {
    all_time_spent = 0,
    highest_total_milestone = 0,
    sound_effect = user_settings.sounds.default_effect,
    sound_enabled = user_settings.sounds.enabled_by_default,
    hud = {
        pos = {
            x = 100,
            y = 100
        },
        bg = {
            alpha = user_settings.fonts.header.bg.alpha,
            red = user_settings.fonts.header.bg.red,
            green = user_settings.fonts.header.bg.green,
            blue = user_settings.fonts.header.bg.blue,
            visible = user_settings.fonts.header.bg.visible
        },
        text = {
            font = user_settings.fonts.header.font,
            size = user_settings.fonts.header.size,
            color = {
                alpha = user_settings.fonts.header.color.alpha,
                red = user_settings.fonts.header.color.red,
                green = user_settings.fonts.header.color.green,
                blue = user_settings.fonts.header.color.blue
            },
            stroke = {
                alpha = user_settings.fonts.header.stroke.alpha,
                red = user_settings.fonts.header.stroke.red,
                green = user_settings.fonts.header.stroke.green,
                blue = user_settings.fonts.header.stroke.blue,
                width = user_settings.fonts.header.stroke.width
            }
        },
        flags = {
            draggable = true,
            bold = true
        },
        padding = 8
    },
    body = {
        pos = {
            x = 100,
            y = 138
        },
        bg = {
            alpha = user_settings.fonts.body.bg.alpha,
            red = user_settings.fonts.body.bg.red,
            green = user_settings.fonts.body.bg.green,
            blue = user_settings.fonts.body.bg.blue,
            visible = user_settings.fonts.body.bg.visible
        },
        text = {
            font = user_settings.fonts.body.font,
            size = user_settings.fonts.body.size,
            color = {
                alpha = user_settings.fonts.body.color.alpha,
                red = user_settings.fonts.body.color.red,
                green = user_settings.fonts.body.color.green,
                blue = user_settings.fonts.body.color.blue
            },
            stroke = {
                alpha = user_settings.fonts.body.stroke.alpha,
                red = user_settings.fonts.body.stroke.red,
                green = user_settings.fonts.body.stroke.green,
                blue = user_settings.fonts.body.stroke.blue,
                width = user_settings.fonts.body.stroke.width
            }
        },
        flags = {
            draggable = false,
            bold = true
        },
        padding = 8
    },
    flair = {
        pos = {
            x = 100,
            y = 80
        },
        bg = {
            alpha = user_settings.fonts.flair.bg.alpha,
            red = user_settings.fonts.flair.bg.red,
            green = user_settings.fonts.flair.bg.green,
            blue = user_settings.fonts.flair.bg.blue,
            visible = user_settings.fonts.flair.bg.visible
        },
        text = {
            font = user_settings.fonts.flair.font,
            size = user_settings.fonts.flair.size,
            color = {
                alpha = user_settings.fonts.flair.color.alpha,
                red = user_settings.fonts.flair.color.red,
                green = user_settings.fonts.flair.color.green,
                blue = user_settings.fonts.flair.color.blue
            },
            stroke = {
                alpha = user_settings.fonts.flair.stroke.alpha,
                red = user_settings.fonts.flair.stroke.red,
                green = user_settings.fonts.flair.stroke.green,
                blue = user_settings.fonts.flair.stroke.blue,
                width = user_settings.fonts.flair.stroke.width
            }
        },
        flags = {
            draggable = false,
            bold = true
        },
        padding = 0
    },
    side = {
        pos = {
            x = 260,
            y = 104
        },
        bg = {
            alpha = user_settings.fonts.side.bg.alpha,
            red = user_settings.fonts.side.bg.red,
            green = user_settings.fonts.side.bg.green,
            blue = user_settings.fonts.side.bg.blue,
            visible = user_settings.fonts.side.bg.visible
        },
        text = {
            font = user_settings.fonts.side.font,
            size = user_settings.fonts.side.size,
            color = {
                alpha = user_settings.fonts.side.color.alpha,
                red = user_settings.fonts.side.color.red,
                green = user_settings.fonts.side.color.green,
                blue = user_settings.fonts.side.color.blue
            },
            stroke = {
                alpha = user_settings.fonts.side.stroke.alpha,
                red = user_settings.fonts.side.stroke.red,
                green = user_settings.fonts.side.stroke.green,
                blue = user_settings.fonts.side.stroke.blue,
                width = user_settings.fonts.side.stroke.width
            }
        },
        flags = {
            draggable = false,
            bold = true
        },
        padding = 0
    }
}

local settings = config.load(default_settings)
local session_spent = 0
local current_gil = nil

-- Define milestones lists and maps populated from user_settings
local session_milestones = {}
local session_milestone_sounds = {}
local session_milestone_texts = {}

local total_milestones = {}
local total_milestone_sounds = {}
local total_milestone_texts = {}

for _, item in ipairs(user_settings.milestones.session) do
    table_insert(session_milestones, item.value)
    session_milestone_sounds[item.value] = item.sound
    session_milestone_texts[item.value] = item.text
end

for _, item in ipairs(user_settings.milestones.total) do
    table_insert(total_milestones, item.value)
    total_milestone_sounds[item.value] = item.sound
    total_milestone_texts[item.value] = item.text
end

-- Sort the milestone arrays descending
table.sort(session_milestones, function(a, b) return a > b end)
table.sort(total_milestones, function(a, b) return a > b end)

local session_highest_milestone = 0

-- Initialize the text boxes
local hud_header = texts.new('', settings.hud, settings)
local hud_body = texts.new('', settings.body, settings)
local hud_flair = texts.new('', settings.flair, settings)
local hud_side = texts.new('', settings.side, settings)

local flair_visible = false
local flair_fading = false
local flair_fade_start = 0

-- Auto-dimming state variables
local last_activity_time = os_clock()
local last_active_state = false
local current_hud_alpha = 255
local is_visible = false
local is_tracking_active = false
local last_x, last_y = nil, nil
local spend_history = {}
local frame_counter = 0
local target_alpha = 255

local function get_recent_spend()
    local now = os_clock()
    local cutoff = now - (user_settings.recent_interval or 900)
    local total = 0
    
    -- Prune old entries from the front of the queue
    while #spend_history > 0 and spend_history[1].time < cutoff do
        table_remove(spend_history, 1)
    end
    
    for _, entry in ipairs(spend_history) do
        total = total + entry.amount
    end
    
    return total
end

-- Initialize milestones helper
local function init_milestones()
    -- Initialize session milestone
    for _, milestone in ipairs(session_milestones) do
        if session_spent >= milestone then
            session_highest_milestone = milestone
            break
        end
    end
    -- Initialize total milestone
    for _, milestone in ipairs(total_milestones) do
        if settings.all_time_spent >= milestone then
            settings.highest_total_milestone = milestone
            config.save(settings)
            break
        end
    end
end

init_milestones()

-- Trigger floating flair animation
local function trigger_flair(text, is_dramatic, sound_path)
    hud_flair:text(text)
    flair_fade_start = os_clock()
    flair_visible = true
    flair_fading = true
    
    if is_dramatic and sound_path then
        if windower_file_exists(sound_path) then
            windower_play_sound(sound_path)
        end
    end
end

-- Synchronize positions and animate flair in prerender
windower.register_event('prerender', function()
    frame_counter = frame_counter + 1
    
    if frame_counter % 10 == 0 then
        if is_visible then
            local x, y = hud_header:pos()
            if x ~= last_x or y ~= last_y then
                hud_body:pos(x, y + 38) -- snaps body 38 pixels below header
                hud_side:pos(x + (user_settings.side_offset_x or 195), y + (user_settings.side_offset_y or 11))
                last_x, last_y = x, y
            end
        end
        
        -- Auto-dimming threshold check
        if os_clock() - last_activity_time > 180 then
            target_alpha = 80
        else
            target_alpha = 255
        end
    end
    
    if flair_visible and flair_fading then
        local now = os_clock()
        local t = (now - flair_fade_start) / 2.0 -- 2-second animation
        if t >= 1 then
            hud_flair:hide()
            flair_visible = false
            flair_fading = false
        else
            local alpha = math_floor(255 * (1 - t))
            local float_offset = math_floor(30 * t) -- floats up 30 pixels
            local x = last_x or 100
            local y = last_y or 100
            hud_flair:pos(x, y - 20 - float_offset) -- floats above the header
            hud_flair:alpha(alpha)
            hud_flair:stroke_alpha(alpha)
            hud_flair:show()
        end
    end

    -- Keep fading transition running every frame for fluid animation
    if current_hud_alpha ~= target_alpha then
        local step = 5
        if current_hud_alpha < target_alpha then
            current_hud_alpha = math.min(target_alpha, current_hud_alpha + step)
        else
            current_hud_alpha = math.max(target_alpha, current_hud_alpha - step)
        end
        hud_header:alpha(current_hud_alpha)
        hud_header:stroke_alpha(current_hud_alpha)
        hud_body:alpha(current_hud_alpha)
        hud_body:stroke_alpha(current_hud_alpha)
        hud_side:alpha(current_hud_alpha)
        hud_side:stroke_alpha(current_hud_alpha)
    end
end)

-- Format thousands with commas (high-performance fast-path formatting)
local function format_thousands(num)
    local formatted = tostring(num)
    local len = #formatted
    if len <= 3 then
        return formatted
    elseif len <= 6 then
        return formatted:sub(1, len - 3) .. ',' .. formatted:sub(len - 2)
    elseif len <= 9 then
        return formatted:sub(1, len - 6) .. ',' .. formatted:sub(len - 5, len - 3) .. ',' .. formatted:sub(len - 2)
    else
        -- Fallback for extremely large numbers
        while true do
            local k
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end
end

local function format_shorthand(num)
    if num >= 1000000 then
        local val = math_floor(num / 100000) / 10
        return val .. 'mil'
    elseif num >= 1000 then
        local val = math_floor(num / 100) / 10 -- e.g. 500k or 12.5k
        if val % 1 == 0 then
            return string_format("%.0fk", val)
        else
            return string_format("%.1fk", val)
        end
    else
        return tostring(num)
    end
end

-- Detects if "Hoxne Ampulla" (item ID 22310) is equipped in the ammo slot
local function is_hoxne_equipped()
    local equip = windower_ffxi_get_items('equipment')
    if not equip then return false end
    
    local ammo_slot = equip.ammo
    local ammo_bag = equip.ammo_bag
    if not ammo_slot or not ammo_bag or ammo_slot == 0 then
        return false
    end
    
    local item = windower_ffxi_get_items(ammo_bag, ammo_slot)
    return item and item.id == 22310
end

-- Detects if the player has the "enchantment" buff (ID 162) active
local function is_enchantment_active()
    local player = windower_ffxi_get_player()
    if not player or not player.buffs then return false end
    
    for _, buff_id in ipairs(player.buffs) do
        if buff_id == 162 then
            return true
        end
    end
    return false
end

-- Update the text box display
local function update_ui()
    local equipped = is_hoxne_equipped()
    local active = equipped and is_enchantment_active()
    
    is_tracking_active = active
    
    if active ~= last_active_state then
        last_activity_time = os_clock()
        last_active_state = active
    end
    
    if not equipped then
        hud_header:hide()
        hud_body:hide()
        hud_side:hide()
        is_visible = false
        return
    end
    
    hud_header:show()
    hud_body:show()
    hud_side:show()
    is_visible = true
    
    local x, y = hud_header:pos()
    last_x, last_y = x, y
    hud_body:pos(x, y + 38)
    hud_side:pos(x + (user_settings.side_offset_x or 195), y + (user_settings.side_offset_y or 11))
    
    local active_text = active 
        and ('\\cs(' .. user_settings.colors.active_status .. ')SPENDING v\\cr') 
        or ('\\cs(' .. user_settings.colors.inactive_status .. ')SAVING ^\\cr')
        
    hud_header:text('\\cs(' .. user_settings.colors.title .. ')[ BROKE WATCH ]\\cr')
    
    local recent_spent = get_recent_spend()
    local shorthand = format_shorthand(recent_spent)
    hud_side:text('\\cs(' .. user_settings.colors.side_label .. ')15m:\\cr \\cs(' .. user_settings.colors.side_value .. ')' .. shorthand .. '\\cr')
    
    hud_body:text(
        '\\cs(' .. user_settings.colors.divider .. ')------------------------\\cr\n' ..
        'Status:       ' .. active_text .. '\n' ..
        'Session Loss: \\cs(' .. user_settings.colors.session_loss .. ')-' .. format_thousands(session_spent) .. '\\cr gil\n' ..
        'Total Tossed: \\cs(' .. user_settings.colors.total_loss .. ')-' .. format_thousands(settings.all_time_spent) .. '\\cr gil'
    )
    
    -- Force opacity to persist through text modifications
    hud_header:alpha(current_hud_alpha)
    hud_header:stroke_alpha(current_hud_alpha)
    hud_body:alpha(current_hud_alpha)
    hud_body:stroke_alpha(current_hud_alpha)
    hud_side:alpha(current_hud_alpha)
    hud_side:stroke_alpha(current_hud_alpha)
end

-- Check gil difference and update tracking
local function check_gil()
    local info = windower_ffxi_get_info()
    if not info or not info.logged_in then
        current_gil = nil
        return
    end

    local items = windower_ffxi_get_items()
    if not items then return end
    
    local new_gil = items.gil
    if not new_gil then return end

    if not current_gil then
        current_gil = new_gil
        update_ui()
        return
    end

    if new_gil < current_gil then
        local diff = current_gil - new_gil
        
        last_activity_time = os_clock()
        if is_tracking_active then
            local actual_spent = math_floor((diff + 500) / 1000) * 1000
            if actual_spent > 0 then
                table_insert(spend_history, { time = os_clock(), amount = actual_spent })
                session_spent = session_spent + actual_spent
                settings.all_time_spent = settings.all_time_spent + actual_spent
                
                -- Check session milestones (e.g. 100K Session Loss!)
                for _, milestone in ipairs(session_milestones) do
                    if session_spent >= milestone then
                        if session_highest_milestone < milestone then
                            session_highest_milestone = milestone
                            local label = milestone >= 1000000 and ((milestone / 1000000) .. 'M') or ((milestone / 1000) .. 'K')
                            local text = session_milestone_texts[milestone] or (label .. ' Session Loss!')
                            trigger_flair(text, false)
                            
                            if settings.sound_enabled then
                                local sound_effect = session_milestone_sounds[milestone] or settings.sound_effect
                                local sound_file = windower.addon_path .. 'sounds/' .. sound_effect
                                if windower_file_exists(sound_file) then
                                    windower_play_sound(sound_file)
                                end
                            end
                        end
                        break
                    end
                end

                -- Check total milestones (e.g. ★ 1 MILLION TOTAL LOSS! ★)
                for _, milestone in ipairs(total_milestones) do
                    if settings.all_time_spent >= milestone then
                        if settings.highest_total_milestone < milestone then
                            settings.highest_total_milestone = milestone
                            local label = milestone >= 1000000 and ((milestone / 1000000) .. ' MILLION') or ((milestone / 1000) .. 'K')
                            local text = total_milestone_texts[milestone] or ('★ ' .. label .. ' TOTAL LOSS! ★')
                            local sound_file = total_milestone_sounds[milestone] or 'C:\\Windows\\Media\\tada.wav'
                            trigger_flair(text, true, sound_file)
                        end
                        break
                    end
                end
            end
        end
    end
    
    current_gil = new_gil
    update_ui()
end

-- Incoming chunk listener for tracking gil state changes
local check_scheduled = false
windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x01D or id == 0x020 or id == 0x00A then
        if not check_scheduled then
            check_scheduled = true
            coroutine.schedule(function()
                check_scheduled = false
                check_gil()
            end, 0.1)
        end
    end
end)

-- Event listeners for buff changes to dynamically update status UI
windower.register_event('buff change', function(id, gain)
    if id == 162 then
        update_ui()
    end
end)

-- Event listeners for login and load states
windower.register_event('login', function()
    session_spent = 0
    current_gil = nil
    init_milestones()
    coroutine.schedule(check_gil, 0.5)
end)

windower.register_event('load', function()
    init_milestones()
    if windower_ffxi_get_info().logged_in then
        coroutine.schedule(check_gil, 0.5)
    else
        update_ui()
    end
end)

windower.register_event('unload', function()
    config.save(settings)
end)

windower.register_event('logout', function()
    config.save(settings)
end)

windower.register_event('zone change', function(new_zone_id, old_zone_id)
    config.save(settings)
end)

-- Command handler
windower.register_event('addon command', function(comm, ...)
    last_activity_time = os_clock()
    local args = {...}
    comm = comm and comm:lower() or nil
    
    if not comm then
        windower.add_to_chat(8, 'BrokeWatch: Available commands: reset [session/all], show, hide, sound [on/off/set [1/2/5]], font [header/body/size]')
        return
    end

    if comm == 'reset' then
        local sub = args[1] and args[1]:lower() or 'session'
        if sub == 'session' then
            session_spent = 0
            session_highest_milestone = 0
            spend_history = {}
            windower.add_to_chat(8, 'BrokeWatch: Session loss and milestones reset to 0 gil.')
            update_ui()
        elseif sub == 'all' then
            settings.all_time_spent = 0
            settings.highest_total_milestone = 0
            spend_history = {}
            config.save(settings)
            windower.add_to_chat(8, 'BrokeWatch: Total loss and milestones reset to 0 gil.')
            update_ui()
        else
            windower.add_to_chat(8, 'BrokeWatch: Unknown reset target. Use "session" or "all".')
        end
    elseif comm == 'show' then
        hud_header:show()
        hud_body:show()
        hud_side:show()
        is_visible = true
        windower.add_to_chat(8, 'BrokeWatch: UI shown.')
    elseif comm == 'hide' then
        hud_header:hide()
        hud_body:hide()
        hud_side:hide()
        is_visible = false
        windower.add_to_chat(8, 'BrokeWatch: UI hidden.')
    elseif comm == 'sound' then
        local sub = args[1] and args[1]:lower() or nil
        if not sub then
            windower.add_to_chat(8, 'BrokeWatch: Sound is currently ' .. (settings.sound_enabled and 'on' or 'off') .. '. Current effect: ' .. settings.sound_effect)
            return
        end

        if sub == 'on' then
            settings.sound_enabled = true
            config.save(settings)
            windower.add_to_chat(8, 'BrokeWatch: Sound effects enabled.')
        elseif sub == 'off' then
            settings.sound_enabled = false
            config.save(settings)
            windower.add_to_chat(8, 'BrokeWatch: Sound effects disabled.')
        elseif sub == 'set' then
            local val = args[2]
            if val == '1' or val == '2' or val == '5' then
                settings.sound_effect = 'cash_register_0' .. val .. '.wav'
                config.save(settings)
                windower.add_to_chat(8, 'BrokeWatch: Sound effect set to ' .. settings.sound_effect)
                
                -- play preview
                local sound_file = windower.addon_path .. 'sounds/' .. settings.sound_effect
                if windower_file_exists(sound_file) then
                    windower_play_sound(sound_file)
                else
                    windower.add_to_chat(8, 'BrokeWatch: Preview sound file not found at: ' .. sound_file)
                end
            else
                windower.add_to_chat(8, 'BrokeWatch: Invalid sound. Choose 1, 2, or 5.')
            end
        else
            windower.add_to_chat(8, 'BrokeWatch: Unknown sound command. Use "on", "off", or "set [1/2/5]".')
        end
    elseif comm == 'font' then
        local target = args[1] and args[1]:lower() or nil
        if not target then
            windower.add_to_chat(8, 'BrokeWatch: Current fonts: Header="'..settings.hud.text.font..'" (Size '..settings.hud.text.size..'), Body="'..settings.body.text.font..'" (Size '..settings.body.text.size..')')
            windower.add_to_chat(8, 'BrokeWatch: Commands: //broke font header <name> | body <name> | size header <num> | size body <num>')
            return
        end
        
        if target == 'header' then
            local font_name = table.concat(args, ' ', 2)
            if font_name ~= '' then
                settings.hud.text.font = font_name
                settings.flair.text.font = font_name
                config.save(settings)
                hud_header:font(font_name)
                hud_flair:font(font_name)
                windower.add_to_chat(8, 'BrokeWatch: Header font set to "' .. font_name .. '".')
                update_ui()
            else
                windower.add_to_chat(8, 'BrokeWatch: Please specify a font name.')
            end
        elseif target == 'body' then
            local font_name = table.concat(args, ' ', 2)
            if font_name ~= '' then
                settings.body.text.font = font_name
                config.save(settings)
                hud_body:font(font_name)
                windower.add_to_chat(8, 'BrokeWatch: Body font set to "' .. font_name .. '".')
                update_ui()
            else
                windower.add_to_chat(8, 'BrokeWatch: Please specify a font name.')
            end
        elseif target == 'size' then
            local sub = args[2] and args[2]:lower() or nil
            local size = tonumber(args[3])
            if (sub == 'header' or sub == 'body') and size then
                if sub == 'header' then
                    settings.hud.text.size = size
                    config.save(settings)
                    hud_header:size(size)
                    windower.add_to_chat(8, 'BrokeWatch: Header font size set to ' .. size .. '.')
                else
                    settings.body.text.size = size
                    config.save(settings)
                    hud_body:size(size)
                    windower.add_to_chat(8, 'BrokeWatch: Body font size set to ' .. size .. '.')
                end
                update_ui()
            else
                windower.add_to_chat(8, 'BrokeWatch: Usage: //broke font size [header/body] <number>')
            end
        else
            windower.add_to_chat(8, 'BrokeWatch: Unknown font subcommand. Use "header", "body", or "size".')
        end
    else
        windower.add_to_chat(8, 'BrokeWatch: Unknown command. Use "reset", "show", "hide", "sound", or "font".')
    end
end)
