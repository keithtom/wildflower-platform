module V1::Categorizable
  extend ActiveSupport::Concern

  class_methods do
    def get_categories(process)
      process.categories.map(&:name)
    end
  end
end
