require_relative 'lib/vin_check'

vin = ARGV[0]

if vin.length != 17 || !vin.instance_of?(String)
  puts "You must provide a VIN / VIN must be 17 characters"
  return
end


validator =  VinCheck.new(vin)
check_digit_valid = validator.is_check_digit_valid?
suggested_vin = if validator.any_invalid_characters?
                  validator.replace_invalid_char
                else
                  vin
                end


puts "Provided  VIN: #{vin}"
puts "Check Digit: #{check_digit_valid ? 'VALID' : 'INVALID'}" 

if !check_digit_valid
  rechk_digit = validator.calculate_check_digit(suggested_vin)
  suggested_vin = validator.replace_chk_digit(suggested_vin, rechk_digit)
end

if check_digit_valid
  puts 'This looks like a VALID VIN!'
  validator.nhtsa_api(suggested_vin)
else
  puts "Suggested VIN: #{suggested_vin}"
  validator.nhtsa_api(suggested_vin)
end