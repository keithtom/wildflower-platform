module OpenSchools
  class DateCalculator
    # Class variables for school year configuration
    @@school_year_start = 2025
    @@school_year_end = 2026

    class << self
      def school_year_start
        @@school_year_start
      end

      def school_year_end
        @@school_year_end
      end

      def school_year_start=(year)
        @@school_year_start = year
      end

      def school_year_end=(year)
        @@school_year_end = year
      end
    end

    def due_date(month)
      # Use class variables for school year configuration
      school_year_start = self.class.school_year_start
      school_year_end = self.class.school_year_end
      year = month < 9 ? school_year_end : school_year_start
      Date.new(year, month, 1).end_of_month
    end

    def suggested_start_date(due_date, duration_in_months)
      (due_date - (duration_in_months - 1).months).beginning_of_month
    end
  end
end
