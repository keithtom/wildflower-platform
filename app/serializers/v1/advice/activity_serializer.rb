class V1::Advice::ActivitySerializer < ApplicationSerializer
  attribute :type do |obj|
    obj[:type]
  end

  attribute :person do |obj|
    obj[:person]
  end

  attribute :title do |obj|
    obj[:title]
  end

  attribute :content do |obj|
    obj[:content]
  end

  attribute :updated_at do |obj|
    obj[:updated_at]
  end
end
