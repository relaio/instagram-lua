require 'network'
require 'wda'
require 'supabase'

UTILS = {}


-- FLOWS

function UTILS.startup()
    UTILS.init_wda()

    UTILS.kill_app(WDA.get_bid())

    UTILS.respring()

    -- INIT
    UTILS.log_message('Initializing: Supabase, WDA')

    SUPABASE.init('', '')  --TODO: Add creds
    UTILS.init_wda()
end


function UTILS.delete_container(container_name)
    if not container_name then
        return nil, {
            message = 'container_name must not be nil'
        }
    end

    UTILS.kill_app('com.apple.Preferences')

    app.run('com.apple.Preferences')

    sys.sleep(2)

    UTILS.swipe_to_bottom()

    local crane_id, error_data = UTILS.find_element_until('name', 'Crane')
    if not crane_id then
        return nil, {
            message = 'Couldnt find crane in settings. Error message: ' .. (error_data and error_data.message or 'nil')
        }
    end
    WDA.click_element(crane_id)

    local applications, error_data = UTILS.find_element_until('name', 'Applications')
    if not applications then
        WDA.click_element(WDA.find_element('name', 'Crane'))
        applications = WDA.find_element('name', 'Applications')
        if not applications then
            return nil, {
                message = 'Couldnt find Applications in crane settings. Error message: ' .. (error_data and error_data.message or 'nil')
            }
        end
    end
    WDA.click_element(applications)

    local insta, error_data = UTILS.find_element_until('name', 'Instagram')
    if not insta then
        WDA.click_element(WDA.find_element('name', 'Applications'))
        insta = WDA.find_element('name', 'Instagram')
        if not insta then
            return nil, {
                message = 'Couldnt find Instagram in crane applications. Error message: ' .. (error_data and error_data.message or 'nil')
            }
        end
    end
    WDA.click_element(insta)

    local edit, error_data = UTILS.find_element_until('name', 'Edit')
    if not edit then
        WDA.click_element(WDA.find_element('name', 'Instagram'))
        edit = WDA.find_element('name', 'Edit')
        if not edit then
            return nil, {
                message = 'Couldnt find Edit in crane Instagram settings. Error message: ' .. (error_data and error_data.message or 'nil')
            }
        end
    end
    WDA.click_element(edit)

    local delete_button, error_data = UTILS.find_element_until('name', 'Delete ' .. container_name)
    if not delete_button then
        WDA.click_element(WDA.find_element('name', 'Edit'))
        delete_button = WDA.find_element('name', 'Delete ' .. container_name)
        if not delete_button then
            return nil, {
                message = 'Couldnt find delete button for container name in crane Instagram settings. Error message: ' .. (error_data and error_data.message or 'nil')
            }
        end
    end
    WDA.click_element(delete_button)

    local delete, error_data = UTILS.find_element_until('name', 'Delete')
    if not delete then
        return nil, {
            message = 'Couldnt find actual delete button for container name in crane Instagram settings. Error message: ' .. (error_data and error_data.message or 'nil')
        }
    end
    WDA.click_element(delete)

    delete, error_data = UTILS.find_element_until('name', 'Delete')
    if not delete then
        return nil, {
            message = 'Couldnt find actual actual delete button for container name in crane Instagram settings. Error message: ' .. (error_data and error_data.message or 'nil')
        }
    end
    WDA.click_element(delete)

    UTILS.kill_app('com.apple.Preferences')
end


-- WDA

function UTILS.init_wda()
    local data, error_data = WDA.init()
    if not data then
        UTILS.log_message('Critical error, cannot initialize WDA. Error message: ' .. (error_data and error_data.message or 'nil'), error_data)
        error('Critical error, cannot initialize WDA. Error message: ' .. (error_data and error_data.message or 'nil'))
    end
end


function UTILS.ensure_wda_running()
    local is_running, error_data = WDA.init()
    if not is_running then
        UTILS.log_message('Critical error, cannot run WDA. Error message: ' .. (error_data and error_data.message or 'nil'), error_data)
        error('Critical error, cannot run WDA. Error message: ' .. (error_data and error_data.message or 'nil'))
    end
end


function UTILS.find_element_until(using, value, duration)
    duration = duration or 20

    local ensure_running = true
    local start_time = os.time()

    local element_id = WDA.find_element(using, value)
    while not element_id do
        sys.sleep(0.25)
        if os.time() - start_time > duration then
            return nil, {
                message = 'Could not find element'
            }
        elseif os.time() - start_time > duration / 2 and ensure_running then
            UTILS.ensure_wda_running()
            ensure_running = false
        end
        element_id = WDA.find_element(using, value)
    end

    return element_id
end


function UTILS.find_elements_until(using, value, duration)
    duration = duration or 20
    
    local ensure_running = true
    local start_time = os.time()

    local element_ids = WDA.find_elements(using, value)
    while #element_ids < 1 do
        sys.sleep(0.25)
        if os.time() - start_time > duration then
            return nil, {
                message = 'Could not find elements'
            }
        elseif os.time() - start_time > duration / 2 and ensure_running then
            UTILS.ensure_wda_running()
            ensure_running = false
        end
        element_ids = WDA.find_elements(using, value)
    end

    return element_ids
end


-- DEVICE ID

function UTILS.fetch_device_id()
    local device_id = file.get_line('/private/var/mobile/device_id.txt', 1)
    if not device_id then
        UTILS.log_message('No device ID found. Exiting.')
        error('No device ID found. Exiting.')
    end
    return device_id
end


-- ACTIONS

function UTILS.respring()
    UTILS.log_message('Respringing.')
    sys.respring()
    while app.front_bid() ~= 'com.apple.springboard' do
        sys.sleep(1)
        device.unlock_screen()
        sys.log('waiting for springboard')
    end
    sys.sleep(2)
    device.unlock_screen()
    sys.sleep(1)
    -- UTILS.kill_all_running_apps()
    app.run('ch.xxtou.XXTExplorer')
    UTILS.log_message('Respring complete.')
end


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
        return false, {
            message = 'Failed to simulate location.', 'Reason: ' .. (reason or 'unknown') .. ', Exit code: ' .. (exit_code or 'unknown') .. ', stdout: ' .. (stdout or 'unknown') .. ', stderr: ' .. (stderr or 'unknown')
        }
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
        return false, {
            message = 'Not connected'
        }
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


-- APPS

function UTILS.create_app_container(bid, container_name)
    if type(bid) ~= 'string' then
        error('bid must be a string')
    end

    local container_uuid = UTILS.generate_random_uuid()
    local command = 'crane-cli -c ' .. container_name .. ' ' .. bid .. ' ' .. container_uuid

    local success, reason, exit_code, stdout, stderr = os.run(command, 30)

    if not (success and exit_code == 0) then
        UTILS.log_message('Failed to create new container using crane-cli.', 'Reason: ' .. (reason or 'unknown') .. ', Exit code: ' .. (exit_code or 'unknown') .. ', stdout: ' .. (stdout or 'unknown') .. ', stderr: ' .. (stderr or 'unknown'))
        return false, {
            message = 'Failed to create new container using crane-cli.', 'Reason: ' .. (reason or 'unknown') .. ', Exit code: ' .. (exit_code or 'unknown') .. ', stdout: ' .. (stdout or 'unknown') .. ', stderr: ' .. (stderr or 'unknown')
        }
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
        return false, {
            message = 'Failed to open container (' .. container_uuid .. ')', 'Reason: ' .. (reason or 'unknown') .. ', Exit code: ' .. (exit_code or 'unknown') .. ', stdout: ' .. (stdout or 'unknown') .. ', stderr: ' .. (stderr or 'unknown')
        }
    end

    return true
end


function UTILS.kill_app(bid)
    UTILS.log_message('Killing app: ' .. bid)
    local is_running = app.is_running(bid)
    while is_running do
        app.run(bid)
        sys.sleep(0.5)
        app.close(bid)
        sys.sleep(0.5)
        app.quit(bid)
        sys.sleep(1)
        is_running = app.is_running(bid)
    end
end


function UTILS.kill_all_running_apps()
    local identifier_list = app.bundles()
    for _,bid in pairs(identifier_list) do
        if app.is_running(bid) and bid ~= 'ch.xxtou.XXTExplorer' and bid ~= WDA.get_bid() then
            UTILS.kill_app(bid)
        end
    end
end


function UTILS.verify_app_in_fg(bid)
    if type(bid) ~= 'string' then
        error('bid must be a string')
    end
    local current_app = app.front_bid()
    if current_app ~= bid then
        return false, {
            message = 'App with bid ' .. bid .. ' is not in foreground'
        }
    end
    return true
end


function UTILS.swipe_to_bottom(num_swipes)
    num_swipes = num_swipes or 1
    
    local screen_width, screen_height = screen.size()

    local x = math.floor(screen_width / 2)
    local start_y = screen_height - 200
    local end_y = 200

    for _=1,num_swipes do
        touch.on(x, start_y)
            :step_delay(0)
            :step_len(10)
            :msleep(50)
            :move(x, end_y, 5)
            :msleep(10)
        :off()
        sys.sleep(2)
    end
end


-- HELPERS

function UTILS.split(str, delimiter)
    local result = {}
    local pattern = '(.-)' .. delimiter
    local last_end = 1
    local s, e, cap = str:find(pattern, 1)
    
    while s do
        if s ~= 1 or cap ~= '' then
            table.insert(result, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(pattern, last_end)
    end
    
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(result, cap)
    end
    
    return result
end


function UTILS.random_choices(array, k)
    if k <= 0 then return {} end
    if k >= #array then k = #array end
    
    local copy = {}
    for i = 1, #array do
        copy[i] = array[i]
    end
    
    for i = #copy, 2, -1 do
        local j = math.random(i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    
    local result = {}
    for i = 1, k do
        result[i] = copy[i]
    end
    
    return result
end


return UTILS