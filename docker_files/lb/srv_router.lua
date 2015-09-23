-- Thanks: https://github.com/vlipco/srv-router/blob/master/conf/srv_router.lua
local resolver = require "resty.dns.resolver"

function abort(reason, code)
    ngx.status = code
    ngx.say(reason)
    return code
end

function log(msg)
    ngx.log(ngx.ERR, msg, "\n")
end

-- log("Checking if it's in the " .. #domains .." known domains")

-- for k,domain in pairs(domains) do
--         log(" - " .. domain)
-- end

function service_name(reqdomain)
        for k,domain in pairs(domains) do
                --log("matching " .. reqdomain .. " with " .. domain)
                if string.match(reqdomain, domain) then
                        --log("matched!")
                        pattern = "%.?" .. domain -- includes separation dot if present
                        --log("pattern: " .. pattern)
                        upstream = string.gsub(reqdomain,pattern,"")

                        -- strip the port from the host header
                        upstream = string.gsub(upstream,":%d+","")

                        if upstream == "" then
                                return "home"
                        end

                        -- return full subdomain if keep_tags in enabled
                        if ngx.var.keep_tags == "true" then
                                return upstream
                        end

                        -- return leftmost zone if keep_tags is disabled (in case further subdomains exists)
                        return string.match(upstream,"[^\\.]*$")
                else
                        log("no match :(")
                end
        end
        return "unknown"
end

--log("Service should be in " .. service_name(ngx.var.http_host))
-- TODO remove domain from host
-- TODO handle root of the domain

-- I'm only load balancing a single service, so no need for subdomains
local query_subdomain = ngx.var.target_domain
local nameserver = {ngx.var.ns_ip, ngx.var.ns_port}

local dns, err = resolver:new{
  nameservers = {nameserver}, retrans = 2, timeout = 250
}

if not dns then
        log("failed to instantiate the resolver: " .. err)
    return abort("DNS error", 500)
end
log("Querying " .. query_subdomain)
local records, err = dns:query(query_subdomain, {qtype = dns.TYPE_SRV})

if not records then
        log("failed to query the DNS server: " .. err)
    return abort("Internal routing error", 500)
end

if records.errcode then
    -- error code meanings available in http://bit.ly/1ppRk24
    if records.errcode == 3 then
        return abort("Not found", 404)
    else
        log("DNS error #" .. records.errcode .. ": " .. records.errstr)
        return abort("DNS error", 500)
    end
end

if records[1].port then
    -- resolve the target to an IP
    local target_ip = dns:query(records[1].target)[1].address
    -- pass the target ip to avoid resolver errors
        ngx.var.target = target_ip .. ":" .. records[1].port
else
        log("DNS answer didn't include a port")
        return abort("Unknown destination port", 500)
end
