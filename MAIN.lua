require 'instagram'
require 'utils'
require 'network'


-- STARTUP

DEVICE_ID = UTILS.fetch_device_id()
UTILS.log_message('Device ID: ' .. DEVICE_ID)

UTILS.startup()


-- GLOBALS

CONTAINER_NAME = nil
CONTAINER_UUID = nil


-- MAIN

do -- New Instagram
    local container_data, error_data = INSTAGRAM.new_instagram('dev')
    if not container_data then
        UTILS.log_message('[CRITICAL] Failed to create and open new Instagram container. Error message: ' .. (error_data and error_data.message or 'nil'))
        os.exit(1)
    end
    CONTAINER_NAME = container_data.container_name
    CONTAINER_UUID = container_data.container_uuid
end