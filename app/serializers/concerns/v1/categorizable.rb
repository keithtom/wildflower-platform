module V1::Categorizable
  extend ActiveSupport::Concern

  class_methods do
    def get_categories(process)
      if process.class == Workflow::Instance::Process && process.category_list.empty?
        process.definition.try(:category_list)
      else
        process.category_list
      end
    end
  end
end
