class V1::Advice::ActivitySerializer < ApplicationSerializer
  set_id :id
  attributes :type, :person, :title, :content, :updated_at
end
