# vin-check
## Overview

The `VIN` or `vehicle identification number` is an (_almost_) unique identifier used in our Industry to identify assets.

More information about VINs can be found here: https://en.wikipedia.org/wiki/Vehicle_identification_number

An example of a `VIN` we see today is:

`1XPTD40X6JD456115`


This seemingly nonsensical identifier actually has quite a bit of information embedded within it including:

* Vehicle Manufacturer
* Model Year
* Serial Number
* Body Style / Engine Type
* Country of Origin
* Assembly Plant
* Security Check Digit

The `security check digit` is a key identifier in determining what constitutes a valid `VIN`.

Unfortunately, vins are also sometimes easily mistyped because (after all) humans are prone to mistakes.

### Expected Output

Our script will have 2 potential outcomes:

1. When the provided VIN appears valid
2. When the provided VIN is invalid

When we encounter an invalid VIN, we should try to suggest the correct VIN


#### Successful Response

```
Provided VIN: <VIN>
Check Digit: VALID
This looks like a VALID vin!
```

#### Error Response

```
Provided VIN: <VIN>
Check Digit: VALID || INVALID
Suggested VIN(s):
  * NEW_VIN
  * NEW_VIN
```

Example vins for testing / implementation:

* INKDLUOX33R385016
* 2NKWL00X16M149834
* INKDLUOX33R385016
* 1XPBDP9X1FD257820
* 1XKYDPPX4MJ442156
* 3HSDJAPRSFN657165
* JBDCUB16657005393

#### How to run the script version 1
```
ruby vin_check.rb <VIN>
```

#### How to run the script version 2
```
ruby vin.rb <VIN>
```

## Bonus Activity
```
Are you able to provide any suggested attributes based upon the decoding of the VIN given your newfound knowledge of this identifier?
* All attributes related to the safty such as 
- "AirBagLocFront": "1st Row (Driver and Passenger)"
- "AirBagLocSide": "1st Row (Driver and Passenger)"
- "SeatBeltsAll": "Manual"
- "EngineHP": "300"


If we wanted to replicate or enhance behavior in our GET /vins/:vin endpoint in Global Assets how might this script help us? Do you see any opportunities in the API contract to allow this when a consumer receives an HTTP 400 - Bad Request response.
```

### NHTSA Vin Decoder

Several resources are available online which offer VIN decoding and check digit calculating services.  NHTSA is a service which we use conditionally and can be used as a resource for your work.

https://vpic.nhtsa.dot.gov/decoder/

### Global Assets API

Currently, our Global Assets API (https://global-assets.decisivapps.com/api-docs/v1/index.html) offers an endpoint which decodes a VIN and provides identifiable information about the asset based upon this VIN.   Before this decoding occurs, it also validates the VIN and provides information about why a VIN failed to be decoded.  You can learn more about this by inspecting the `HTTP 400` response on the call to `GET /vins/:vin`.

Valid VINs return suggested attributes about the VIN including:

* Make
* Model
* Year

## The Code

```ruby
vin = ARGV[0]

def transliterate(char)
  "0123456789.ABCDEFGH..JKLMN.P.R..STUVWXYZ".split('').index(char) % 10
end

def calculate_check_digit(vin)
  map     = [0,1,2,3,4,5,6,7,9,10,'X']
  weights = [8,7,6,5,4,3,2,10,0,9,8,7,6,5,4,3,2]
  sum = 0
  vin.split('').each_with_index do |char, i|
    sum += transliterate(char) * weights[i]
  end
  map[sum % 11]
end

chk_digit = calculate_check_digit(vin)
```
