require 'rspec'
require_relative '../rent_schedule'

RSpec.describe RentSchedule do
  let(:valid_rent) do
    {
      rent_amount: 1000,
      rent_frequency: 'monthly',
      rent_start_date: '2025-07-01',
      rent_end_date: '2025-10-01'
    }
  end

  let(:valid_rent_change) do
    [
      { rent_amount: 1200, effective_date: '2025-08-01' },
      { rent_amount: 1500, effective_date: '2025-09-01' }
    ]
  end

  describe 'initialization' do
    subject { described_class.new(rent, rent_change: rent_change) }

    let(:rent_change) { [] }

    context 'with valid rent' do
      let(:rent) { valid_rent }

      it 'initializes with correct attributes' do
        expect(subject.instance_variable_get(:@rent_amount)).to eq(1000)
        expect(subject.instance_variable_get(:@rent_frequency)).to eq('monthly')
        expect(subject.instance_variable_get(:@rent_start_date)).to eq(Date.parse('2025-07-01'))
        expect(subject.instance_variable_get(:@rent_end_date)).to eq(Date.parse('2025-10-01'))
        expect(subject.instance_variable_get(:@rent_change)).to eq([])
      end
    end

    context 'with invalid rent amount' do
      let(:rent) { valid_rent.merge(rent_amount: -100) }
      
      it 'raises an InvalidInputError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidInputError,
          'Amount must be a positive number'
        )
      end
    end

    context 'with non-numeric rent amount' do
      let(:rent) { valid_rent.merge(rent_amount: 'one thousand') }
      
      it 'raises an InvalidInputError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidInputError,
          'Amount must be a positive number'
        )
      end
    end

    context 'with invalid frequency' do
      let(:rent) { valid_rent.merge(rent_frequency: 'daily') }
      
      it 'raises an InvalidInputError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidInputError, 
          "Invalid frequency: 'daily'. Must be one of: weekly, fortnightly, monthly"
        )
      end
    end

    context 'with invalid rent date format' do
      let(:rent) { valid_rent.merge(rent_start_date: '2025/07/01') }
      
      it 'raises an InvalidDateError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidDateError,
          "Invalid rent_start_date: '2025/07/01'. Please use YYYY-MM-DD format"
        )
      end
    end

    context 'with invalid date range' do
      let(:rent) { valid_rent.merge(rent_start_date: '2025-10-01', rent_end_date: '2025-07-01') }
      
      it 'raises an InvalidDateError' do
        expect { subject }.to raise_error(
          RentSchedule::InvalidDateError,
          'Start date (2025-10-01) cannot be after end date (2025-07-01)'
        )
      end
    end

    context 'with rent change' do
      let(:rent) { valid_rent }
      let(:rent_change) { valid_rent_change }
      let(:expected_rent_change) do
        [
          { amount: 1200, effective_date: Date.parse('2025-08-01') },
          { amount: 1500, effective_date: Date.parse('2025-09-01') }
        ]
      end
  
      it 'initializes with sorted rent change' do
        expect(subject.instance_variable_get(:@rent_change)).to eq(expected_rent_change)
      end
    end

    context 'with invalid rent amount in rent change' do
      let(:rent) { valid_rent }
      let(:rent_change) { [{ rent_amount: -100, effective_date: '2025-08-01' }] }
        
      it 'raises an InvalidInputError' do
        expect { subject }.to raise_error(
          described_class::InvalidInputError,
          'Amount must be a positive number'
        )
      end
    end

    context 'with invalid effective date in rent change' do
      let(:rent) { valid_rent }
      let(:rent_change) { [{ rent_amount: 1200, effective_date: '2025/08/01' }] }
      
      it 'raises an InvalidDateError' do
        expect { subject }.to raise_error(
          described_class::InvalidDateError,
          "Invalid effective_date: '2025/08/01'. Please use YYYY-MM-DD format"
        )
      end
    end
  end

  describe '#calculate_payment_dates' do
    subject { described_class.new(rent, rent_change: rent_change).calculate_payment_dates }
    let(:rent) { valid_rent }
    let(:rent_change) { [] }

    context 'with weekly frequency' do
      let(:rent) do
        {
          rent_amount: 1000,
          rent_frequency: 'weekly',
          rent_start_date: '2025-07-01',
          rent_end_date: '2025-07-22'
        }
      end

      context 'without rent change' do
        it 'returns correct weekly payment dates' do
          expected_dates = [
            { date: '2025-07-01', amount: 1000 },
            { date: '2025-07-08', amount: 1000 },
            { date: '2025-07-15', amount: 1000 },
            { date: '2025-07-22', amount: 1000 }
          ]
          expect(subject).to eq(expected_dates)
        end
      end

      context 'with rent change' do
        let(:rent_change) { [ { rent_amount: 1200, effective_date: '2025-07-15' } ] }

        it 'applies rent changes at correct effective dates' do
          expected_dates = [
            { date: '2025-07-01', amount: 1000 },
            { date: '2025-07-08', amount: 1000 },
            { date: '2025-07-15', amount: 1200 },
            { date: '2025-07-22', amount: 1200 }
          ]

          expect(subject).to eq(expected_dates)
        end
      end
    end

    context 'with fortnightly frequency' do
      let(:rent) do
        {
          rent_amount: 1000,
          rent_frequency: 'fortnightly',
          rent_start_date: '2025-07-01',
          rent_end_date: '2025-08-22'
        }
      end
      
      context 'without rent change' do
        it 'returns correct fortnightly payment dates' do
          expected_dates = [
            { date: '2025-07-01', amount: 1000 },
            { date: '2025-07-15', amount: 1000 },
            { date: '2025-07-29', amount: 1000 },
            { date: '2025-08-12', amount: 1000 }
          ]

          expect(subject).to eq(expected_dates)
        end
      end

      context 'with rent change' do
        let(:rent_change) { [ { rent_amount: 1200, effective_date: '2025-07-29' } ] }

        it 'applies rent changes at correct effective dates' do
          expected_dates = [
            { date: '2025-07-01', amount: 1000 },
            { date: '2025-07-15', amount: 1000 },
            { date: '2025-07-29', amount: 1200 },
            { date: '2025-08-12', amount: 1200 }
          ]

          expect(subject).to eq(expected_dates)
        end
      end
    end

    context 'with monthly frequency' do
      let(:rent) do
        {
          rent_amount: 1000,
          rent_frequency: 'monthly',
          rent_start_date: '2025-07-15',
          rent_end_date: '2025-10-15'
        }
      end
      
      context 'without rent change' do
        it 'returns correct monthly payment dates' do
          expected_dates = [
            { date: '2025-07-15', amount: 1000 },
            { date: '2025-08-15', amount: 1000 },
            { date: '2025-09-15', amount: 1000 },
          { date: '2025-10-15', amount: 1000 }
        ]
        
          expect(subject).to eq(expected_dates)
        end
      end

      context 'with rent change' do
        let(:rent_change) { [ { rent_amount: 1200, effective_date: '2025-08-01' } ] }

        it 'applies rent changes at correct effective dates' do
          expected_dates = [
            { date: '2025-07-15', amount: 1000 },
            { date: '2025-08-15', amount: 1200 },
            { date: '2025-09-15', amount: 1200 },
            { date: '2025-10-15', amount: 1200 }
          ]

          expect(subject).to eq(expected_dates)
        end
      end
    end
  end
end
