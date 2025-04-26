--- @module 'blink.cmp'

local untils = require('blink-cmp-avante.utils')
local default = require('blink-cmp-avante.default')

--- @class blink.cmp.Source
--- @field avante_source_config blink-cmp-avante.Options
local AvanteSource = {}

function AvanteSource.new(opts, _)
    local self = setmetatable({}, { __index = AvanteSource })
    self.avante_source_config = vim.tbl_deep_extend('force', default, opts or {})
    local completion_item_kind = require('blink.cmp.types').CompletionItemKind
    local blink_kind_icons = require('blink.cmp.config').appearance.kind_icons
    for kind_name, icon in pairs(self.avante_source_config.kind_icons) do
        if completion_item_kind[kind_name] then
            goto continue
        end
        completion_item_kind[#completion_item_kind + 1] = kind_name
        completion_item_kind[kind_name] = #completion_item_kind
        blink_kind_icons[kind_name] = icon
        vim.api.nvim_set_hl(0, 'BlinkCmpKind' .. kind_name, { default = true, fg = '#89b4fa' })
        ::continue::
    end
    return self
end

function AvanteSource:get_trigger_characters()
    local triggers = {}
    for _, feature in pairs(self:get_enabled_features()) do
        local feature_triggers = untils.get_option(feature.triggers)
        if untils.truthy(feature_triggers) then
            for _, trigger in pairs(feature_triggers) do
                table.insert(triggers, trigger)
            end
        end
    end
    return triggers
end

--- @return blink-cmp-avante.AvanteOptions[]
function AvanteSource:get_enabled_features()
    --- @type blink-cmp-avante.AvanteOptions[]
    local features = {}
    for _, feature in pairs(vim.tbl_values(self.avante_source_config.avante)) do
        if untils.get_option(feature.enable) then
            table.insert(features, feature)
        end
    end
    return features
end

local function get_kind_from_kind_name(kind_name)
    return require('blink.cmp.types').CompletionItemKind[kind_name] or 0
end

--- @param context blink.cmp.Context
function AvanteSource:should_show_items(context, _)
    return context.mode ~= 'cmdline' and
        vim.tbl_contains(self:get_trigger_characters(), context.trigger.initial_character)
end

--- @param context blink.cmp.Context
--- @return lsp.TextEdit
local function get_text_edit_range(context)
    return {
        -- This range make it possible to remove the trigger character
        start = {
            line = context.cursor[1] - 1,
            character = context.cursor[2] - 1
        },
        ['end'] = {
            line = context.cursor[1] - 1,
            character = context.cursor[2]
        }
    }
end

--- @param context blink.cmp.Context
--- @param callback fun(response?: blink.cmp.CompletionResponse)
function AvanteSource:get_completions(context, callback)
    local trigger = context.trigger.initial_character
    --- @type blink-cmp-avante.AvanteOptions[]
    local active_features = {}
    for _, feature in pairs(self:get_enabled_features()) do
        local feature_triggers = untils.get_option(feature.triggers)
        if untils.truthy(feature_triggers) and vim.tbl_contains(feature_triggers, trigger) then
            table.insert(active_features, feature)
        end
    end
    local items = {}
    for _, feature in pairs(active_features) do
        for i, item in ipairs(feature.get_items()) do
            items[i] = {
                label = feature.get_label(item),
                kind = get_kind_from_kind_name(feature.get_kind_name(item)),
                documentation = feature.get_documentation(item),
                textEdit = {
                    newText = feature.get_insert_text(item),
                    range = get_text_edit_range(context),
                },
                ---@diagnostic disable-next-line: undefined-field
                callback = item.callback,
            }
        end
    end
    callback({
        is_incomplete_backward = false,
        is_incomplete_forward = false,
        items = items,
    })
    return function() end
end

--- @param item blink.cmp.CompletionItem
--- @param callback fun()
function AvanteSource:execute(_, item, callback, default_implementation)
    ---@diagnostic disable-next-line: undefined-field
    if item.callback and type(item.callback) == 'function' then
        ---@diagnostic disable-next-line: undefined-field
        item.callback()
    else
      default_implementation()
    end
    callback()
end

return AvanteSource
