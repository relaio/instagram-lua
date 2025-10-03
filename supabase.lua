
SUPABASE = {}

local config = {
    supabase_url = nil,
    supabase_service_role_key = nil
}


function SUPABASE.init(supabase_url, supabase_service_role_key)
    if type(supabase_url) ~= 'string' or type(supabase_service_role_key) ~= 'string' then
        error('Supabase URL and service role key must be strings')
    end
    
    config.supabase_url = supabase_url
    config.supabase_service_role_key = supabase_service_role_key
end


function SUPABASE.build_headers(content_type)
    if not config.supabase_service_role_key then
        error('Supabase not initialized')
    end
    
    local headers = {
        ['Authorization'] = 'Bearer ' .. config.supabase_service_role_key,
        ['apikey'] = config.supabase_service_role_key,
        ['Content-Type'] = content_type or 'application/json',
        ['Prefer'] = 'return=representation'
    }
    
    return headers
end


function SUPABASE.build_crud_url(table_name, param_string)
    if not config.supabase_url then
        error('Supabase not initialized')
    end
    return config.supabase_url .. '/rest/v1/' .. table_name .. param_string
end


function SUPABASE.build_rpc_url(function_name)
    if not config.supabase_url then
        error('Supabase not initialized')
    end
    
    return config.supabase_url .. '/rest/v1/rpc/' .. function_name
end


return SUPABASE