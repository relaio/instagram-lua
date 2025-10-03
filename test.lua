require 'utils'

UTILS.log_message(true)

UTILS.log_message(not true)
UTILS.log_message(not false)
UTILS.log_message(not nil)

local a = nil

UTILS.log_message(not a)

local b = false

UTILS.log_message(not b)