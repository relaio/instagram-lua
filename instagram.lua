require 'utils'

INSTAGRAM = {
    bid = 'com.burbn.instagram'
}


function INSTAGRAM.new_instagram(prefix) 
    local container_name = prefix and prefix .. '-' .. tostring(os.time()) or tostring(os.time())
    local container_uuid = UTILS.create_app_container(INSTAGRAM.bid, container_name)

    local to_return = false
    local attempts = 1

    while not container_uuid do
        if attempts > 3 then
            to_return = true
            break
        end
        sys.sleep(attempts)
        container_name = tostring(os.time())
        container_uuid = UTILS.create_app_container(INSTAGRAM.bid, container_name)
        attempts = attempts + 1
    end
    if to_return then
        UTILS.log_message('Could not create new Instagram container after 3 retries.')
        return nil, nil, {
            message = 'Could not create new Instagram container after 3 retries.'
        }
    end

    UTILS.log_message('Instagram container ' .. container_name .. ' created.')

    local opened = UTILS.open_app_container(INSTAGRAM.bid, container_uuid)
    attempts = 1

    while not opened do
        if attempts > 3 then
            to_return = true
            break
        end
        sys.sleep(attempts)
        opened = UTILS.open_app_container(INSTAGRAM.bid, container_uuid)
        attempts = attempts + 1
    end
    if to_return then
        return nil, nil, {
            message = 'Failed to open Instagram container after 3 retries.'
        }
    end

    return container_name, container_uuid
end


return INSTAGRAM