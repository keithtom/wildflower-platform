module V1::Categorizable
  extend ActiveSupport::Concern

  class_methods do
    def get_categories(process)
      if process.class == Workflow::Instance::Process && process.categories.empty?
        process.definition&.categories&.map(&:name)
      else
        process.categories.map(&:name)
      end
    end
  end
end
