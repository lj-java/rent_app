require 'date'

class RentSchedule
  CURRENCY = 'PHP'.freeze
  FREQUENCIES = %w[weekly fortnightly monthly].freeze

  class InvalidInputError < StandardError; end
  class InvalidDateError < StandardError; end

  def initialize(rent, rent_change: [])
    @rent_amount = validate_amount(rent[:rent_amount])
    @rent_frequency = validate_frequency(rent[:rent_frequency])
    @rent_start_date = parse_date(rent[:rent_start_date], 'rent_start_date')
    @rent_end_date = parse_date(rent[:rent_end_date], 'rent_end_date')
    @rent_change = normalize_rent_change(rent_change)

    validate_date_range
  end

  def calculate_payment_dates
    payment_dates = []
    current_date = @rent_start_date
    current_rent_amount = @rent_amount
    change_index = 0

    while current_date <= @rent_end_date
      while change_index < @rent_change.length && 
         @rent_change[change_index][:effective_date] <= current_date
        current_rent_amount = @rent_change[change_index][:amount]
        change_index += 1
      end

      payment_dates << {
        date: current_date.to_s,
        amount: current_rent_amount
      }
      
      current_date = next_payment_date(current_date)
    end

    payment_dates
  end

  private

  def normalize_rent_change(rent_change)
    rent_change.map do |change|
      {
        amount: validate_amount(change[:rent_amount]),
        effective_date: parse_date(change[:effective_date], 'effective_date')
      }
    end.sort_by { |change| change[:effective_date] }
  end

  def validate_amount(amount)
    raise InvalidInputError, 'Amount must be a positive number' unless amount.is_a?(Numeric) && amount.positive?
    amount
  end

  def validate_frequency(frequency)
    unless FREQUENCIES.include?(frequency.to_s.downcase)
      raise InvalidInputError, 
            "Invalid frequency: '#{frequency}'. Must be one of: #{FREQUENCIES.join(', ')}"
    end
    frequency.downcase
  end

  def parse_date(date_str, date_type)
    unless date_str.to_s.match?(/^\d{4}-\d{2}-\d{2}$/)
      raise InvalidDateError, "Invalid #{date_type}: '#{date_str}'. Please use YYYY-MM-DD format"
    end
  
    begin
      Date.parse(date_str)
    rescue Date::Error
      raise InvalidDateError, "Invalid #{date_type}: '#{date_str}'. Please use YYYY-MM-DD format"
    end
  end

  def validate_date_range
    if @rent_start_date > @rent_end_date
      raise InvalidDateError, 
            "Start date (#{@rent_start_date}) cannot be after end date (#{@rent_end_date})"
    end
  end

  def next_payment_date(current_date)
    case @rent_frequency
    when 'weekly'      then current_date.next_day(7)
    when 'fortnightly' then current_date.next_day(14)
    when 'monthly'     then current_date.next_month
    end
  end
end
