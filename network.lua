--[[

Methods allowed: GET, POST, PUT, DELETE

success:
{
    code: number,
    response_headers: table | nil
    response_body: table | nil
}

failed:
{
    message: string
    data: nil | {
        code: number,
        response_headers: table | nil
        response_body: table | nil
    }
}

--]]

NETWORK = {}

local default_timeout = 30


function NETWORK.send_request_with_retries(params)
    local url = params.url
    local method = params.method
    local headers = params.headers or {}
    local body = params.body or ''

    if type(body) == 'table' then
        body = json.encode(body)
    end

    local max_retries = params.max_retries or 3

    if not url then
        return nil, { message = 'URL is required' }
    end

    if not (method == 'GET' or method == 'POST' or method == 'PUT' or method == 'DELETE') then
        return nil, { message = 'Invalid HTTP method' }
    end

    local attempt = 0
    local code, response_headers, response_body

    repeat
        if method == 'GET' then
            code, response_headers, response_body = http.get(url, default_timeout, headers)
        elseif method == 'POST' then
            code, response_headers, response_body = http.post(url, default_timeout, headers, body)
        elseif method == 'PUT' then
            code, response_headers, response_body = http.put(url, default_timeout, headers, body)
        elseif method == 'DELETE' then
            code, response_headers, response_body = http.delete(url, default_timeout, headers)
        end

        response_headers = json.decode(response_headers)
        response_body = json.decode(response_body)

        if type(code) == 'string' then
            sys.log('HTTP request failed (' .. code .. '), retrying in ' .. 2 ^ attempt .. ' seconds.')
            sys.sleep(2 ^ attempt)
            attempt = attempt + 1
        elseif type(code) == 'nil' then
            sys.log('HTTP request failed (code is nil), retrying in ' .. 2 ^ attempt .. ' seconds.')
            sys.sleep(2 ^ attempt)
            attempt = attempt + 1
        elseif type(code) == 'number' then
            if code >= 500 or code == 429 then
                sys.log('HTTP request failed (' .. code .. '), retrying in ' .. 2 ^ attempt .. ' seconds.')
                sys.sleep(2 ^ attempt)
                attempt = attempt + 1
            elseif code >= 400 then
                return nil, {
                    message = 'HTTP client error ' .. code,
                    data = {
                        code = code,
                        response_headers = response_headers,
                        response_body = response_body
                    }
                }
            else
                return {
                    code = code,
                    response_headers = response_headers,
                    response_body = response_body
                }
            end
        end
    until attempt > max_retries

    return nil, {
        message = 'Request failed after ' .. max_retries .. ' retries.',
        data = {
            code = code,
            response_headers = response_headers,
            response_body = response_body
        }
    }
end


return NETWORK