module OpenSchools
  class DateCalculator
    def due_date(month)
      # hardcoding school year for now.
      school_year_start = 2024
      school_year_end = 2025
      year = month < 9 ? school_year_end : school_year_start
      Date.new(year, month, 1).end_of_month
    end

    def suggested_start_date(due_date, duration_in_months)
      (due_date - (duration_in_months - 1).months).beginning_of_month
    end
  end
end