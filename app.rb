require 'date'
require_relative 'rent_schedule'

def get_user_input
  rent_details = {}

  # Define input requirements
  input_requirements = {
    rent_amount: {
      prompt: "Enter Rent Amount (e.g., 15000.00): ",
      validate: ->(input) { input =~ /^\d+(\.\d{1,2})?$/ },
      error: "Invalid amount. Please enter a valid number (e.g., 15000.00).",
      transform: ->(input) { input.to_f } # this "transorm" lambda function converts the input to a float 
    },
    rent_frequency: {
      prompt: "Select Rent Frequency:\n  1. Weekly\n  2. Fortnightly\n  3. Monthly\nEnter your choice (1, 2, or 3): ",
      validate: ->(input) { (1..3).cover?(input.to_i) },
      error: "Invalid choice. Please enter 1, 2, or 3.",
      transform: ->(input) { %w[weekly fortnightly monthly][input.to_i - 1] } # this "transform" lambda function converts the input to a string based on the index of the array
    },
    rent_start_date: {
      prompt: "Enter Rent Start Date (YYYY-MM-DD): ",
      validate: ->(input) { input.match?(/^\d{4}-\d{2}-\d{2}$/) && valid_date?(input) },
      error: "Invalid date format. Please use YYYY-MM-DD.",
      transform: ->(input) { input } # this "transform" lambda function returns the input as is
    },
    rent_end_date: {
      prompt: "Enter Rent End Date (YYYY-MM-DD): ",
      validate: ->(input) { 
        input.match?(/^\d{4}-\d{2}-\d{2}$/) && 
        valid_date?(input) && 
        Date.parse(input) > Date.parse(rent_details[:rent_start_date]) 
      },
      error: "Invalid date format or end date must be after start date. Please use YYYY-MM-DD.",
      transform: ->(input) { input }
    }
  }

  # Get each input
  input_requirements.each do |field, config|
    rent_details[field] = get_valid_input(config)
  end

  rent_details
end

private

def get_valid_input(config)
  loop do
    print config[:prompt]
    input = gets.chomp
    
    if config[:validate].call(input)
      return config[:transform].call(input)
    else
      puts config[:error]
    end
  end
end

def valid_date?(date_str)
  Date.parse(date_str)
  true
rescue Date::Error
  false
end

# Main
puts "--- Rent Payment Scheduler --- \n\n"
begin
  rent_input = get_user_input
  rent_schedule = RentSchedule.new(rent_input)
  payment_dates = rent_schedule.calculate_payment_dates

  puts "\nCalculated Payment Dates:"
  payment_dates.each { |date| puts date.to_s }
rescue ArgumentError => e
  puts "Error: #{e.message}"
rescue => e
  puts "An unexpected error occurred: #{e.message}"
end