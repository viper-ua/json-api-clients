require 'net/http'
require 'json'

APPID = "0a71a999bd57ac9d0bd363c952461167"

def get_weather_forecast (city, hours)
  results_count = hours.to_i / 3 # Calculating interval 
  uri = URI "http://api.openweathermap.org/data/2.5/forecast?q=#{city}&APPID=#{APPID}&cnt=#{results_count}&units=metric&lang=ua"

  req = Net::HTTP::Get.new(uri)
  req['Accept'] = 'application/json'

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  json_data = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  #puts "Response: #{res.code}:#{res.message}"

  if json_data
  #  puts "JSON returned #{json_data['list'].length} records: "
    puts "Forecast for #{city[0...-3]}(#{city[-2..-1].upcase}), next #{hours} hrs"
    json_data['list'].each do |interval|
      puts "#{interval['dt_txt'][8...-3]}: #{interval['weather'][0]['description']}, температура #{interval['main']['temp']}"
    end
  end
  puts
end

get_weather_forecast("Kiev,ua",48)
get_weather_forecast("Odessa,ua",12)