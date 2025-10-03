require 'network'
require 'wda'

UTILS = {}


function UTILS.get_current_datetime_utc_iso()
    return os.date('!%Y-%m-%d %H:%M:%S')
end


function UTILS.log_message(...)
    local arg = {...}
    if type(arg[1]) == 'string' then
        sys.toast(arg[1])
    end
    sys.log(table.unpack(arg))
end


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


function UTILS.check_internet_connection()
    local status_code = http.get('https://www.google.com', 10)

    if status_code == 200 then
        return true
    else
        return false
    end
end


return UTILS