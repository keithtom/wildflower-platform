# frozen_string_literal: true

class BaseService
  def self.run(*args)
    new(*args).run
  end

  class Error < StandardError
  end
end
