
require 'net/http'
require 'json'

class VinCheck
  NHTSA_DECODE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues".freeze
  ALLOW_CHARS = "0123456789.ABCDEFGH..JKLMN.P.R..STUVWXYZ".freeze
  
  attr_accessor :vin

  def initialize(vin)
    @vin = vin.upcase.to_s
  end

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

  def is_check_digit_valid?
    calculate_check_digit(vin) == vin[8].to_i
  end

  def any_invalid_characters?
    (/^[^IOQ]+$/ =~ vin).nil?
  end
  
  
  def replace_chk_digit(vin, chk_digit)
    new_vin = vin.dup
    new_vin[8] = chk_digit.to_s
    new_vin
  end
  
  def replace_invalid_char
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
end