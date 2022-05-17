class V1::Advice::StakeholderSerializer < ApplicationSerializer
  attributes :name, :email, :phone, :calendar_url, :roles, :subroles, :status

  belongs_to :decision, serializer: V1::Advice::DecisionSerializer, id_methodname: :external_identifier

  # formalize concept of activity, feeds event, messages, record
  # and generates a list of 'activity' that has a common interface.

  # use last record's status
  attribute :status do |obj|
    obj.order("created_at DESC").first.status
  end

  # select objects, map to activities, sort by timestamp and group?  group message sequences...?
  def activities
    decision.events # filter to creator and this stakeholder.
    + messages + records
  end

  # normalizes objects into activities interface
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
