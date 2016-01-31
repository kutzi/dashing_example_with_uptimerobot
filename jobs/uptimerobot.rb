require 'rest-client'
require 'json'

api_key = ENV['UPTIMEROBOT_API_KEY'] || ''

config = YAML::load_file('config/uptimerobot.yml')


# Returns an array of uptimes [today,week,month,year]
def calc_uptime(api_key)
  urlUptime = "https://api.uptimerobot.com/getMonitors?apiKey=#{api_key}&format=json&noJsonCallback=1&responseTimes=1&logs=1&customUptimeRatio=1-7-30-365"
  response = RestClient.get(urlUptime)
  if response.code == 200
    responseUptime = JSON.parse(response.body, :symbolize_names => true)
    uptime = responseUptime[:monitors][:monitor][0][:customuptimeratio]
    return uptime.split('-')
  else
    puts 'Error: ' + response.code + ' ' + response.body
    return ['?','?','?','?']
  end
  
end

#puts 'API key:' + api_key

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

#  config['checks'].each do |id|
#    uptime_24h = calc_uptime(user, password, api_key, id, last24_hours, nowTime)
#    uptime_48h = calc_uptime(user, password, api_key, id, last48_hours, last24_hours)
#    uptime_72h = calc_uptime(user, password, api_key, id, last72_hours, last48_hours)

#    send_event("pingdom-uptime-#{id}", { current: uptime_24h.to_s + '%',
#                                  last: uptime_48h.to_s + '%',
#                                  lastlast: uptime_72h.to_s + '%',
#                                })

#  end

uptime = calc_uptime(api_key)
#puts 'Uptime ' + uptime.inspect
send_event("uptimerobot-uptime", { today: uptime[0] + '%',
                                  week: uptime[1] + '%',
                                  month: uptime[2] + '%',
                                })

end
