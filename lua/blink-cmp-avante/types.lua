--- @class (exact) blink-cmp-avante.AvanteOptions
--- @field enable? boolean|fun(): boolean
--- @field triggers? string[]|fun(): string[]
--- @field get_items? fun(): AvanteSlashCommand[]|AvanteMention[]
--- @field get_label? fun(item: AvanteSlashCommand|AvanteMention): string
--- @field get_kind_name? fun(item: AvanteSlashCommand|AvanteMention): string
--- @field get_insert_text? fun(item: AvanteSlashCommand|AvanteMention): string
--- @field get_documentation? fun(item: AvanteSlashCommand|AvanteMention): string

--- @alias blink-cmp-avante.AvanteSourceType 'command' | 'mention'

--- @class (exact) blink-cmp-avante.Options
--- @field kind_icons? table<string, string>
--- @field avante? table<blink-cmp-avante.AvanteSourceType, blink-cmp-avante.AvanteOptions>
