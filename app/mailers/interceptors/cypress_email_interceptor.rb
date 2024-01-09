module Interceptors
  class CypressEmailInterceptor
    def self.delivering_email(message)
      if message.to.any? { |address| address.start_with?("cypress_test_") }
        message.perform_deliveries = false
      end
      if message.to.any? { |address| address.start_with?("partner@test.com") }
        message.perform_deliveries = false
      end
    end
  end
end
