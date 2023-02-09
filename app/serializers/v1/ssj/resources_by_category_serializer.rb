class V1::Ssj::ResourcesByCategorySerializer < ApplicationSerializer
  include V1::Categorizable

  def serializable_hash
    grouped_by_category(@resource)
  end

  def grouped_by_category(documents)
    grouped_documents = {}

    documents.each do |document|
      get_categories(document.documentable.process).each do |category|
        if grouped_documents[category].nil?
          grouped_documents[category] = []
        end
        grouped_documents[category] << V1::Workflow::ResourceSerializer.new(document, root: false, include: @includes)
      end
    end

    return grouped_documents
  end

  def get_categories(process)
    self.class.get_categories(process)
  end
end
