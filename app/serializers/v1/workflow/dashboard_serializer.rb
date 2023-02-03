class ProcessesByStatusSerializer < ActiveModel::Serializer

  # method override
  def serializable_hash
    @object.map do |some_group_key, some_models|
      [ some_group_key , serialized_some_models(some_models) ]
    end.to_h
  end

  private

    def serialized_some_models some_models
      some_models.map{ |some_model| SomeModelSerializer.new(some_model, root: false) }
    end

end
