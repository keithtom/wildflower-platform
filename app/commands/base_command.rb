# frozen_string_literal: true

class BaseCommand
  def self.call(*args)
    new(*args).call
  end

  class Error < StandardError
  end
end
