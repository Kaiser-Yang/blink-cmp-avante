local function default_enable()
    return vim.bo.filetype == 'AvanteInput'
end

local function default_get_kind_name(_)
    return 'Avante'
end

local function default_mention_get_items()
    local items = require('avante.utils').get_mentions()
    local side_bar, _, _ = require('avante').get()
    table.insert(items, {
        description = "file",
        command = "file",
        details = "add files...",
        callback = function() side_bar.file_selector:open() end,
    })
    table.insert(items, {
        description = "quickfix",
        command = "quickfix",
        details = "add files in quickfix list to chat context",
        callback = function() side_bar.file_selector:add_quickfix_files() end,
    })
    return items
end

local function default_command_get_items()
    local items = require("avante.utils").get_commands()
    -- clear the callback
    for _, item in ipairs(items) do
        item.callback = nil
    end
    return items
end

local function default_get_documentation(item)
    return item.details
end

local function default_mention_get_label(item)
    return '@' .. item.command
end

local function default_command_get_label(item)
    return '/' .. item.name
end

--- @type blink-cmp-avante.Options
return {
    kind_icons = {
        Avante = '󰖷',
    },
    avante = {
        command = {
            enable = default_enable,
            triggers = { '/' },
            get_items = default_command_get_items,
            get_label = default_command_get_label,
            get_kind_name = default_get_kind_name,
            get_insert_text = default_command_get_label,
            get_documentation = default_get_documentation,
        },
        mention = {
            enable = default_enable,
            triggers = { '@' },
            get_items = default_mention_get_items,
            get_label = default_mention_get_label,
            get_kind_name = default_get_kind_name,
            get_insert_text = default_mention_get_label,
            get_documentation = default_get_documentation,
        },
    }
}
