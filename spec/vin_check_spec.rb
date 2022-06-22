
require 'spec_helper'
require_relative '../lib/vin_check'

RSpec.describe VinCheck do

  describe '#is_check_digit_valid?' do
    context 'with valid VIN' do
      let(:vin) { '2NKWL00X16M149834' }
      
      it 'returns true' do
        validator = VinCheck.new(vin)
        result = validator.is_check_digit_valid?
      
        expect(result).to eq(true)
      end
    end

    context 'with invalid VIN' do
      let(:vin) { '1XPBDP9X1FD257820' }
      
      it 'returns false' do
        validator = VinCheck.new(vin)
        result = validator.is_check_digit_valid?
      
        expect(result).to eq(false)
      end
    end
  end

  describe '#calculate_check_digit' do
    context 'with valid VIN' do
      let(:vin) { '2NKWL00X16M149834' }
      
      it 'returns the right check digit' do
        validator = VinCheck.new(vin)
        result = validator.calculate_check_digit(vin)
      
        expect(result).to eq(vin[8].to_i)
      end
    end

    context 'with invalid VIN' do
      let(:vin) { '1XPBDP9X1FD257820' }
      
      it 'returns the right check digit' do
        validator = VinCheck.new(vin)
        result = validator.calculate_check_digit(vin)
      
        expect(result).to_not eq(vin[8].to_i)
      end
    end
  end

  describe '#any_invalid_charaters?' do
    context 'with valid characters in VIN' do
      let(:vin) { '1XPBDP9X1FD257820' }
      it 'returns false' do
        validator = VinCheck.new(vin)
        result = validator.any_invalid_characters?
  
        expect(result).to eq(false)
      end
    end
    
    context 'with invalid characters I,O and Q' do
      let(:vin) { 'INKDLUOX33R385016' }
      it 'returns true' do
        validator = VinCheck.new(vin)
        result = validator.any_invalid_characters?

        expect(result).to eq(true)
      end
    end
  end

  describe '#replace_invalid_char' do
    context 'with invalid characters I,O and Q' do
      let(:vin) { 'INKDLUOX33R385016' }

      it 'returns correct string' do
        validator = VinCheck.new(vin)
        result = validator.replace_invalid_char

        expect(result).to eq('1NKDLU0X33R385016')
      end
    end

    context 'with valid VIN' do
      let(:vin) { '2NKWL00X16M149834' }

      it 'does not change' do
        validator = VinCheck.new(vin)
        result = validator.replace_invalid_char

        expect(result).to eq(vin)
      end
    end
  end

  describe '#replace_chk_digit' do
    context 'with invalid characters I,O and Q' do
      let(:vin) { '2NKWL00X15M149834' }

      it 'returns new VIN with 9 position changed' do
        validator = VinCheck.new(vin)
        chk_digit = validator.calculate_check_digit(vin)
        result = validator.replace_chk_digit(vin, chk_digit)

        expect(result).to eq('2NKWL00X35M149834')
      end
    end
  end
end
