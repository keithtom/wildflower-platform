class WorkflowSerializer
  include JSONAPI::Serializer

  set_type :movie  # optional
  set_id :owner_id # optional
  attributes :name, :year
  has_many :processes
  belongs_to :owner, record_type: :user
  belongs_to :movie_type
end
