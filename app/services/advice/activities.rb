# formalize concept of activity, feeds event, messages, record
# and generates a list of 'activity' that has a common interface.
class Advice::Activities < BaseService
  def initialize(decisions)
    @decisions = decisions
  end

  def run
    if @decisions.is_a?(Array)
      result = {}
      @decisions.each do |decision|
        result[decision.id] = activities(decision)
      end
      return result
    else
      decision = @decisions
      return activities(decision)
      # group by stakeholder, but some events are replicated across stakeholder so this doesn't work
    end
  end

  private

  # get activities
  def activities(decision)
    filtered_events = decision.events.select { |e| e.originator == decision.creator }
    messages = decision.messages
    records = decision.records
    activities = (filtered_events + messages + records).map { |obj| normalize_activity(obj) }
    activities = activities.sort_by { |h| h[:timestamp] }.reverse
  end


  # normalizes objects into activities interface
  # this is presentation logic, seems like serializers are closest
  # handle "You requested advice", "Meera added a note"
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
        updated_at: activity.updated_at
      }
    when Advice::Message
      # if its a stakeholder, check if that's a person too.
      profile_pic = activity.sender.is_a?(Person) ? activity.sender.profile : nil  # external stakeholders don't have profile pics unless we look up gravatar from email
      {
        type: "message",
        person: { name: activity.sender.name, profile_pic: profile_pic },
        content: activity.content,
        updated_at: activity.updated_at
      }
    when Advice::Record
      # if its a stakeholder, check if that's a person too.
      profile_pic = activity.stakeholder.person ? activity.stakeholder.person.profile : nil  # external stakeholders don't have profile pics unless we look up gravatar from email
      {
        type: "record",
        person: { name: activity.sender.name, profile_pic: profile_pic },
        title: activity.status,
        content: activity.content,
        updated_at: activity.updated_at
      }
    end
  end
end
