require 'utils'

while true do
    sys.sleep(0.1)
    local current_app = app.front_bid()
    UTILS.log_message(current_app)
end