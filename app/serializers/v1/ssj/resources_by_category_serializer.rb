class V1::SSJ::ResourcesByCategorySerializer < ApplicationSerializer
  include V1::Categorizable

  def serializable_hash
    {
      by_phase: grouped_by_phase(@resource),
      by_category: grouped_by_category(@resource)
    }
  end

  def grouped_by_category(documents)
    grouped_documents = {}
    SSJ::Category::CATEGORIES.each do |category|
      grouped_documents[category] = []
    end

    documents.each do |document|
      get_categories(document.documentable.process).each do |category|
        if grouped_documents[category].nil?
          Rails.logger.warn("process (id: #{document.documentable.process_id}) tagged with unknown category: #{category}")
        else
          grouped_documents[category] << V1::Workflow::ResourceSerializer.new(document, root: false, include: @includes)
        end
      end
    end

    grouped_documents.map do |key, value|
      {key => value}
    end
  end

  def grouped_by_phase(documents)
    grouped_documents = {}
    Workflow::Definition::Process::PHASES.each do |phase|
      grouped_documents[phase] = []
    end

    documents.each do |document|
      document.documentable.process.phase.each do |phase|
        grouped_documents[phase.name] << V1::Workflow::ResourceSerializer.new(document, root: false, include: @includes)
      end
    end

    grouped_documents.map do |key, value|
      {key => value}
    end
  end

  def get_categories(process)
    self.class.get_categories(process)
  end
end
