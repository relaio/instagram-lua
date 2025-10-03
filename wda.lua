--[[

init()
get_bid()

ensure_running()
create_session()

find_element()
find_elements()

find_element_inside_element()
find_elements_inside_element()

click_element()
send_keys_to_element()

]]

require 'network'

-- INIT

WDA = {
    session_id = nil
}

local config = {
    bid = 'com.nathaniel.WebDriverAgentRunner.xctrunner',
    base_url = 'http://localhost:8100'
}


function WDA.init()
    local identifier_list = app.bundles()

    local wda_bid = nil

    for _, bid in ipairs(identifier_list) do
        local matches = string.find(string.lower(bid), 'webdriveragentrunner')
        if type(matches) ~= 'nil' then
            wda_bid = bid
        end
    end

    if type(wda_bid) == 'nil' then
        return nil, {
            message = 'Could not find webdriveragentrunner in identifier list'
        }
    end

    sys.log('WDA bid: ' .. wda_bid)

    config.bid = wda_bid

    return WDA.ensure_running()
end


function WDA.get_bid()
    return config.bid
end


function WDA.ensure_running()
    local is_running = app.is_running(config.bid)

    if is_running then
        return true
    end
    
    local attempts = 0

    while not is_running do
        if attempts >= 5 then
            return nil, {
                message = 'Could not run WDA after 5 retries'
            }
        else
            app.run(config.bid)
            sys.sleep(2)
            is_running = app.is_running(config.bid)
            attempts = attempts + 1
        end
    end

    sys.sleep(3)

    local data, error_data = WDA.create_session()

    if type(data) == 'nil' then
        return nil, error_data
    end
    
    return true
end


function WDA.create_session()
    local url = config.base_url .. '/session'
    local body = json.encode({
        capabilities = {}
    })

    local data, error_data = NETWORK.send_request_with_retries({
        url = url,
        method = 'POST',
        body = body
    })

    if type(data) == 'nil' then
        return nil, error_data
    end

    local response_json = data.response_body

    if not response_json.sessionId then
        return nil, {
            message = 'No session ID returned',
            data = data
        }
    end

    WDA.session_id = response_json.sessionId

    sys.log('WDA SESSION ID IS ' .. WDA.session_id)

    return true
end

-- FUNCTIONS

function WDA.find_element(using, value)
    if not WDA.session_id then
        error('WDA not initialized')
    end
    
    local url = config.base_url .. '/session/' .. WDA.session_id .. '/element'
    local body = json.encode({
        using = using,
        value = value
    })

    local data, error_data = NETWORK.send_request_with_retries({
        url = url,
        method = 'POST',
        body = body
    })

    if type(data) == 'nil' then
        return nil, error_data
    end

    local response_json = data.response_body
    local response_value = response_json.value or {}
    local element_id = response_value.ELEMENT or {}

    return element_id
end


function WDA.find_elements(using, value)
    if not WDA.session_id then
        error('WDA not initialized')
    end

    local url = config.base_url .. '/session/' .. WDA.session_id .. '/elements'
    local body = json.encode({
        using = using,
        value = value
    })

    local data, error_data = NETWORK.send_request_with_retries({
        url = url,
        method = 'POST',
        body = body
    })

    if type(data) == 'nil' then
        return nil, error_data
    end

    local response_json = data.response_body
    local response_value = response_json.value or {}

    local element_ids = {}

    for i,v in ipairs(response_value) do
        element_ids[i] = v.ELEMENT
    end

    return element_ids
end


function WDA.find_element_inside_element(element_id, using, value)
    if not element_id then
        return nil, 'element_id cannot be nil'
    end
    
    if not WDA.session_id then
        error('WDA not initialized')
    end
    
    local url = config.base_url .. '/session/' .. WDA.session_id .. '/element/' .. element_id .. '/element'
    local body = json.encode({
        using = using,
        value = value
    })

    local data, error_data = NETWORK.send_request_with_retries({
        url = url,
        method = 'POST',
        body = body
    })

    if type(data) == 'nil' then
        return nil, error_data
    end

    local response_json = data.response_body
    local response_value = response_json.value or {}
    local response_element_id = response_value.ELEMENT or {}

    return response_element_id
end


function WDA.find_elements_inside_element(element_id, using, value)
    if not element_id then
        return nil, 'element_id cannot be nil'
    end
    
    if not WDA.session_id then
        error('WDA not initialized')
    end
    
    local url = config.base_url .. '/session/' .. WDA.session_id .. '/element/' .. element_id .. '/elements'
    local body = json.encode({
        using = using,
        value = value
    })

    local data, error_data = NETWORK.send_request_with_retries({
        url = url,
        method = 'POST',
        body = body
    })

    if type(data) == 'nil' then
        return nil, error_data
    end

    local response_json = data.response_body
    local response_value = response_json.value or {}

    local element_ids = {}

    for i,v in ipairs(response_value) do
        element_ids[i] = v.ELEMENT
    end

    return element_ids
end


function WDA.click_element(element_id)
    if not element_id then
        return nil, 'element_id cannot be nil'
    end
    
    if not WDA.session_id then
        error('WDA not initialized')
    end

    local url = config.base_url .. '/session/' .. WDA.session_id .. '/element/' .. element_id .. '/click'

    local data, error_data = NETWORK.send_request_with_retries({
        url = url,
        method = 'POST'
    })

    if type(data) == 'nil' then
        return nil, error_data
    end

    return true
end


function WDA.send_keys_to_element(element_id, text)
    if not element_id then
        return nil, 'element_id cannot be nil'
    end
    
    if not WDA.session_id then
        error('WDA not initialized')
    end

    local url = config.base_url .. '/session/' .. WDA.session_id .. '/element/' .. element_id .. '/value'
    local body = json.encode({
        text = text
    })

    local data, error_data = NETWORK.send_request_with_retries({
        url = url,
        method = 'POST',
        body = body
    })

    if type(data) == 'nil' then
        return nil, error_data
    end

    return true
end


return WDA