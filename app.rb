require "sinatra/base"
class App < Sinatra::Base
	helpers Sinatra::FormHelpers
	redis_uri = URI.parse(ENV['REDISTOGO_URL'])
	REDIS = Redis.new(:host => redis_uri.host, :port => redis_uri.port, :password => redis_uri.password)

	get '/' do
		@pins = initPins(7,7)
		REDIS.hincrby( "stats", "connections", 1 )
		haml :showme
	end

	post '/updown' do
		if params[:action]
			p = params[:action] 
			spark_digital("digitalwrite", p[:pin], p[:value])
		end
	end

	def initPins(d, a)
		array = []
		while d >= 0 do
			pin = "D" + d.to_s
			array << pin
			state = REDIS.hget( ENV['DEVISE_NAME'], pin.to_s)
			state == "1" ? array << "1" : array << "0" 
			d -= 1
		end
		while a >= 0 do
			pin = "A" + a.to_s
			array << pin
			state = REDIS.hget( ENV['DEVISE_NAME'], pin.to_s)
			state == "1" ? array << "1" : array << "0" 
			a -= 1
		end
		hash = Hash[*array]
		return hash
	end

	def spark_digital(action, pin, value)
		pin, value = pin.upcase, value.upcase
		url = "https://api.spark.io/v1/devices/#{ENV['DEVISE_ID']}/" + action.downcase
		data = [
			Curl::PostField.content("access_token", ENV['AUTH']),
			Curl::PostField.content("params", [pin,value].join(','))
		]
		c = Curl::Easy.http_post(url, *data) do |curl|
			curl.headers["User-Agent"] = "Curl/Ruby"
			curl.verbose = true
		end
		response = JSON.parse(c.body)
		incr("presses")
		if response["return_value"] == "1"
			value == "HIGH" ? v = "1" : v = "0"
			REDIS.hset( ENV['DEVISE_NAME'], pin, v)
		end
	end

	def incr(name)
		REDIS.hincrby( "stats", name, 1 )
	end
end