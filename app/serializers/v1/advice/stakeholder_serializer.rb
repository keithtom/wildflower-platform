class V1::Advice::StakeholderSerializer < ApplicationSerializer
  attributes :name, :email, :phone, :calendar_url, :roles, :subroles, :status

  belongs_to :decision, serializer: V1::Advice::DecisionSerializer, id_methodname: :external_identifier

  # we would serialize messages as part of a general api but not needed for now
  # has_many :messages, serializer: V1::Advice::MessageSerializer, id_methodname: :external_identifier

  # we would never serialize records, it would appear as part of an activity feed?
  # same argument as for messages.

  # formalize concept of activity, feeds event, messages, record
  # and generates a list of 'activity' that has a common interface.

  # use last record's status
  attribute :status do |obj|
    obj.records.order("created_at DESC").first&.status
  end

  attribute :last_activity do |obj|
    # activities.last
  end

  def activities
    (decision.events.where(:originator => decision.creator).all
    + messages.all + records.all).map { |obj| normalize_activity(obj) }.sort_by { |h| h[:timestamp] }.reverse
  end

  # normalizes objects into activities interface
  # this is presentation logic, seems like serializers are closest
  def normalize_activity(activity)
    case activity
    when Advice::Event
      # if its a stakeholder, check if that's a person too.
      profile_pic = activity.originator.is_a?(Person) ? activity.originator.profile : nil  # external stakeholders don't have profile pics unless we look up gravatar from email
      {
        type: "event",
        person: { name: activity.originator.name, profile_pic: profile_pic },
        title: activity.name,
        content: activity.description,
        timestamp: activity.updated_at
      }
    when Advice::Message
      # if its a stakeholder, check if that's a person too.
      profile_pic = activity.sender.is_a?(Person) ? activity.sender.profile : nil  # external stakeholders don't have profile pics unless we look up gravatar from email
      {
        type: "message",
        person: { name: activity.sender.name, profile_pic: profile_pic },
        content: activity.content,
        timestamp: activity.updated_at
      }
    when Advice::Record
      # if its a stakeholder, check if that's a person too.
      profile_pic = activity.stakeholder.person ? activity.stakeholder.person.profile : nil  # external stakeholders don't have profile pics unless we look up gravatar from email
      {
        type: "record",
        person: { name: activity.sender.name, profile_pic: profile_pic },
        title: activity.status,
        content: activity.content,
        timestamp: activity.updated_at
      }
    end
  end
end
