require 'net/http'
require 'net/https'
require 'json'

http = Net::HTTP.new('getpocket.com', 443)
http.use_ssl = true
path = '/v3/oauth/request'
data = 'consumer_key=16476-243f9d81fe1b678256480298&redirect_uri=localhost:8888'

headers = {'Content-Type'=> 'application/x-www-form-urlencoded'}

resp, data = http.post(path, data, headers)

puts 'Code = ' + resp.code
puts 'request_token = ' + resp.body.split("code=").last
# save token code
request_token = resp.body.split("code=").last

url2='https://getpocket.com/auth/authorize?request_token=' + request_token + '&redirect_uri=http://any1.io'
puts url2
system("open #{url2}")

sleep(4)

path = '/v3/oauth/authorize'
data = 'consumer_key=16476-243f9d81fe1b678256480298&code=' + request_token

last_url=""
resp, data = http.post(path, data, headers)
puts '**************** authorize, convert request_token to access_token *****************'
puts 'Code = ' + resp.code
puts 'Message = ' + resp.message
puts 'Body = ' + resp.body.split("access_token=").last
access_token = resp.body.split("access_token=").last.split("&username=").first
resp.each {|key, val| puts key + ' = ' + val}
puts data


while true
	puts '************* retrive ************'
	path = '/v3/get'
	data = 'consumer_key=16476-243f9d81fe1b678256480298&access_token=' + access_token
	resp, data = http.post(path, data, headers)
	resp.each {|key, val| puts key + ' = ' + val}
	puts data
	parsed = JSON.parse(resp.body)
	puts "********** JSON Parsed ************"
	h = Hash.new
	parsed["list"].each do |key, value|
		h["#{key}"] = value["given_url"]
	end
	p "new hash created"
	sleep(10)
	p "last opened: " + last_url
	p "new link: " + h.first[1]
	unless last_url==h.first[1]
		system("open #{h.first[1]}")
		last_url=h.first[1]
	else
		puts "no new link"
	end
end


