require 'date'

class Rent
  CURRENCY = 'PHP'.freeze
  FREQUENCIES = %w[weekly fortnightly monthly].freeze

  class InvalidInputError < StandardError; end
  class InvalidDateError < StandardError; end

  def initialize(rent_details)
    @rent_amount = validate_amount(rent_details[:rent_amount])
    @rent_frequency = validate_frequency(rent_details[:rent_frequency])
    @rent_start_date = parse_date(rent_details[:rent_start_date], 'rent_start_date')
    @rent_end_date = parse_date(rent_details[:rent_end_date], 'rent_end_date')

    validate_date_range
  end

  def calculate_payment_dates
    payment_dates = []
    current_date = @rent_start_date

    while current_date <= @rent_end_date
      payment_dates << current_date
      current_date = next_payment_date(current_date)
    end

    payment_dates
  end

  private

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
