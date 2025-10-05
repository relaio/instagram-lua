require 'instagram'
require 'utils'
require 'network'

DEVICE_ID = UTILS.fetch_device_id()
UTILS.log_message('Device ID: ' .. DEVICE_ID)

UTILS.startup()

INSTAGRAM.new_instagram('dev')