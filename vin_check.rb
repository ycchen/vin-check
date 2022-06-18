require 'pry'
require 'net/http'
require 'json'

# VIN examples
# INKDLUOX33R385016
# 2NKWL00X16M149834
# INKDLUOX33R385016
# 1XPBDP9X1FD257820
# 1XKYDPPX4MJ442156
# 3HSDJAPRSFN657165
# JBDCUB16657005393

NHTSA_DECODE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues".freeze
ALLOW_CHARS = "0123456789.ABCDEFGH..JKLMN.P.R..STUVWXYZ".freeze
              
vin = ARGV[0].upcase.to_s

def calculate_check_digit(vin)
  map     = [0,1,2,3,4,5,6,7,8,9,10,'X']
  weights = [8,7,6,5,4,3,2,10,0,9,8,7,6,5,4,3,2]
  sum     = 0

  vin.split('').each_with_index do |char, i| 
    vin_char_index = ALLOW_CHARS.split('').index(char)
    sum += (vin_char_index % 10) * weights[i] unless vin_char_index.nil?
  end

  map[sum % 11]
end

def check_invalid_charaters?(vin)
  (/^[^IOQ]+$/ =~ vin).nil?
end

def valid?(vin)
  calculate_check_digit(vin) == vin[8].to_i
end

def suggest_vin(vin, chk_digit)
  new_vin = vin.dup
  new_vin[8] = chk_digit.to_s
  new_vin
end

def replace_invalid_char(vin)
  vin.gsub('I','1').gsub('O','0').gsub('Q','0')
end

def nhtsa_api(vin)
  response = Net::HTTP.get(URI("#{NHTSA_DECODE_URL}/#{vin}?format=json"), nil,  { 'Accept' => 'application/json' })
  parsed = JSON.parse(response)
  results = parsed["Results"].first
  
  puts "Vehicle information for #{vin}:"
  puts "- Engine model: #{results["EngineModel"]}"
  puts "- Fuel type primary model: #{results["FuelTypePrimary"]}"
  puts "- Manufacturer: #{results["Manufacturer"]}"

rescue StandardError => e
  puts "Oops something went wrong! Cannot reach to NHTSA API"
end


return unless vin.instance_of?(String)
return if vin.length != 17

chk_digit = calculate_check_digit(vin)
is_valid = valid?(vin)

puts "-"*70
puts "Provided  VIN: #{vin}"
puts "Check Digit: #{is_valid ? 'VALID' : 'INVALID'}" 

suggest_vin = if check_invalid_charaters?(vin)
                replace_invalid_char(vin)
              else
                vin
              end

unless is_valid
  rechk_digit = calculate_check_digit(suggest_vin)
  suggest_vin = suggest_vin(suggest_vin, rechk_digit)
end

if is_valid
  puts 'This looks like a VALID VIN!'
  nhtsa_api(suggest_vin)
else
  puts "Suggested VIN: #{suggest_vin}"
  nhtsa_api(suggest_vin)
end

puts "-"*70
