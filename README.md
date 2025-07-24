# rent_app

## Description
A simple command-line application that calculates rent payment dates based on the user's input, handles rent changes over time, and incorporates different payment methods with varying processing times

## Requirements
- Ruby 2.7 or higher
- RSpec (for running tests)

## Installation
1. Clone the repository
2. Install RSpec if you want to run tests:
   ```
   gem install rspec
   ```
- Run `bundle install` to install dependencies

## Usage
```
ruby app.rb
```

Follow the prompts to enter rent details. The application will calculate and display the payment dates based on the payment method (instant, credit card, or bank transfer).

## Running Tests
```
rspec spec
```

## Features
- Supports weekly, fortnightly, and monthly rent frequencies
- Handles rent changes with effective dates
- Accounts for different payment processing times:
  - Instant: Payment on the due date
  - Credit Card: Payment 2 days before due date
  - Bank Transfer: Payment 3 days before due date
