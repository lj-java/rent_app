require 'rspec'
require_relative '../rent_schedule'

RSpec.describe RentSchedule do
  let(:valid_input) do
    {
      rent_amount: 1000,
      rent_frequency: 'monthly',
      rent_start_date: '2025-07-01',
      rent_end_date: '2025-10-01'
    }
  end

  describe 'initialization' do
    subject { described_class.new(input) }

    context 'with valid input' do
      let(:input) { valid_input }

      it 'initializes with correct attributes' do
        expect(subject.instance_variable_get(:@rent_amount)).to eq(1000)
        expect(subject.instance_variable_get(:@rent_frequency)).to eq('monthly')
        expect(subject.instance_variable_get(:@rent_start_date)).to eq(Date.parse('2025-07-01'))
        expect(subject.instance_variable_get(:@rent_end_date)).to eq(Date.parse('2025-10-01'))
      end
    end

    context 'with invalid rent amount' do
      let(:input) { valid_input.merge(rent_amount: -100) }
      
      it 'raises an InvalidInputError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidInputError,
          'Amount must be a positive number'
        )
      end
    end

    context 'with non-numeric rent amount' do
      let(:input) { valid_input.merge(rent_amount: 'one thousand') }
      
      it 'raises an InvalidInputError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidInputError,
          'Amount must be a positive number'
        )
      end
    end

    context 'with invalid frequency' do
      let(:input) { valid_input.merge(rent_frequency: 'daily') }
      
      it 'raises an InvalidInputError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidInputError, 
          "Invalid frequency: 'daily'. Must be one of: weekly, fortnightly, monthly"
        )
      end
    end

    context 'with invalid rent date format' do
      let(:input) { valid_input.merge(rent_start_date: '2025/07/01') }
      
      it 'raises an InvalidDateError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidDateError,
          "Invalid rent_start_date: '2025/07/01'. Please use YYYY-MM-DD format"
        )
      end
    end

    context 'with invalid date range' do
      let(:input) { valid_input.merge(rent_start_date: '2025-10-01', rent_end_date: '2025-07-01') }
      
      it 'raises an InvalidDateError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidDateError,
          'Start date (2025-10-01) cannot be after end date (2025-07-01)'
        )
      end
    end
  end

  describe '#calculate_payment_dates' do
    subject { calculator.calculate_payment_dates }

    context 'with weekly frequency' do
      let(:calculator) do
        described_class.new(
          rent_amount: 1000,
          rent_frequency: 'weekly',
          rent_start_date: '2025-07-01',
          rent_end_date: '2025-07-22'
        )
      end
      
      let(:expected_dates) do
        [
          Date.parse('2025-07-01'),
          Date.parse('2025-07-08'),
          Date.parse('2025-07-15'),
          Date.parse('2025-07-22')
        ]
      end
      
      it 'returns correct weekly payment dates' do
        expect(subject).to eq(expected_dates)
      end
    end

    context 'with fortnightly frequency' do
      let(:calculator) do
        described_class.new(
          rent_amount: 1000,
          rent_frequency: 'fortnightly',
          rent_start_date: '2025-07-01',
          rent_end_date: '2025-08-22'
        )
      end
      
      let(:expected_dates) do
        [
          Date.parse('2025-07-01'),
          Date.parse('2025-07-15'),
          Date.parse('2025-07-29'),
          Date.parse('2025-08-12')
        ]
      end
      
      it 'returns correct fortnightly payment dates' do
        expect(subject).to eq(expected_dates)
      end
    end

    context 'with monthly frequency' do
      let(:calculator) do
        described_class.new(
          rent_amount: 1000,
          rent_frequency: 'monthly',
          rent_start_date: '2025-07-15',
          rent_end_date: '2025-10-15'
        )
      end
      
      let(:expected_dates) do
        [
          Date.parse('2025-07-15'),
          Date.parse('2025-08-15'),
          Date.parse('2025-09-15'),
          Date.parse('2025-10-15')
        ]
      end
      
      it 'returns correct monthly payment dates' do
        expect(subject).to eq(expected_dates)
      end
    end
  end
end
