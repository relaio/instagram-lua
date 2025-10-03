require 'network'
require 'wda'

UTILS = {}

-- ACTIONS

function UTILS.tap_coordinate(x, y, duration)
    duration = duration or 100
    touch.tap(x, y, duration)
end

-- FETCH

function UTILS.get_current_datetime_utc_iso()
    return os.date('!%Y-%m-%d %H:%M:%S')
end


function UTILS.generate_random_uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local uuid = string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
    return uuid
end

-- LOG

function UTILS.log_message(...)
    local arg = {...}
    if type(arg[1]) == 'string' then
        sys.toast(arg[1])
    end
    sys.log(table.unpack(arg))
end

-- LOCATION

function UTILS.simulate_location(location_info)
    os.run('locsim stop', 10)

    sys.sleep(2)

    local success, reason, exit_code, stdout, stderr = os.run('locsim start -x ' .. location_info.latitude .. ' -y ' .. location_info.longitude)

    if not (success and exit_code == 0) then
        UTILS.log_message('Failed to simulate location.', 'Reason: ' .. (reason or 'unknown') .. ', Exit code: ' .. (exit_code or 'unknown') .. ', stdout: ' .. (stdout or 'unknown') .. ', stderr: ' .. (stderr or 'unknown'))
        return false
    end

    return true
    
end


function UTILS.stop_location_simulation()
    os.run('locsim stop', 10)
end

-- NETWORK

function UTILS.check_internet_connection()
    local status_code = http.get('https://www.google.com', 10)

    if status_code == 200 then
        return true
    else
        return false
    end
end


function UTILS.get_current_ip()
    local data, error_data = NETWORK.send_request_with_retries({
        url = 'https://api.ipify.org/?format=json',
        method = 'GET'
    })

    if not data then
        return nil, error_data
    end

    if not data.response_body.ip then
        return nil, {
            message = 'Response body doesnt have ip',
            data = data
        }
    end

    return data.response_body.ip
end


function UTILS.wait_for_internet_connection()
    local start_timestamp = os.time()
    local ran_comm_center = false
    local connected = false
    while not connected do
        connected = UTILS.check_internet_connection()
        if connected then break end
        sys.sleep(1)
        local current_timestamp = os.time()
        if current_timestamp - start_timestamp > 30 and not ran_comm_center then
            os.run('killall -9 CommCenter')
            ran_comm_center = true
        elseif current_timestamp - start_timestamp > 60 then
            return false, {
                message = 'Internet connection not detected after 60 seconds'
            }
        end
    end
    return true
end


-- CRANE-CLI

function UTILS.create_app_container(bid, container_name)
    if type(bid) ~= 'string' then
        error('bid must be a string')
    end

    local container_uuid = UTILS.generate_random_uuid()
    local command = 'crane-cli -c ' .. container_name .. ' ' .. bid .. ' ' .. container_uuid

    local success, reason, exit_code, stdout, stderr = os.run(command, 30)

    if not (success and exit_code == 0) then
        UTILS.log_message('Failed to create new container using crane-cli.', 'Reason: ' .. (reason or 'unknown') .. ', Exit code: ' .. (exit_code or 'unknown') .. ', stdout: ' .. (stdout or 'unknown') .. ', stderr: ' .. (stderr or 'unknown'))
        return false
    end

    return container_uuid
end


function UTILS.open_app_container(bid, container_uuid)
    if type(bid) ~= 'string' then
        error('bid must be a string')
    elseif type(container_uuid) ~= 'string' then
        error('container_uuid must be a string')
    end

    local command = 'crane-cli -o ' .. bid .. ' ' .. container_uuid

    local success, reason, exit_code, stdout, stderr = os.run(command, 30)

    if not (success and exit_code == 0) then
        UTILS.log_message('Failed to open container (' .. container_uuid .. ')', 'Reason: ' .. (reason or 'unknown') .. ', Exit code: ' .. (exit_code or 'unknown') .. ', stdout: ' .. (stdout or 'unknown') .. ', stderr: ' .. (stderr or 'unknown'))
        return false
    end

    sys.sleep(2)

    return true
end


return UTILS