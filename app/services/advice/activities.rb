# formalize concept of activity, feeds event, messages, record
# and generates a list of 'activity' that has a common interface.
class Advice::Activities < BaseService
  def initialize(decisions, group_by)
    @decisions = decisions
    @group_by = group_by
  end

  def run
    case @group_by
    when :decision
      result = {}
      @decisions.each do |decision|
        result[decision.id] = activities_by_decision(decision)
      end
      return result
    when :stakeholder
      decision = @decisions
      return activities_by_stakeholder(decision)
      # group by stakeholder, but some events are replicated across stakeholder so this doesn't work
    else
      raise "unknown option"
    end
  end

  private

  # get activities
  def activities_by_decision(decision)
    filtered_events = decision.events.select { |e| e.originator == decision.creator }
    messages = decision.messages.includes(:sender)
    records = decision.records
    activities = (filtered_events + messages + records).map { |obj| normalize_activity(obj) }
    activities = activities.compact.sort_by { |h| h[:updated_at] }.reverse
  end

  def activities_by_stakeholder(decision)
    creator_events = decision.events.select { |e| e.originator == decision.creator }

    stakeholder_events = decision.events.select { |e| e.originator != decision.creator }
    stakeholder_messages = decision.messages
    stakeholder_records = decision.records

    grouped_by_stakeholder = (stakeholder_events + stakeholder_messages + stakeholder_records).group_by do |obj|
      case obj
      when Advice::Event
        obj.originator_id
      else
        obj.stakeholder_id
      end
    end

    results = {}
    grouped_by_stakeholder.each do |stakeholder_id, events_messages_records|
      activities = (events_messages_records + creator_events).map { |o| normalize_activity(o) }
      results[stakeholder_id] = activities.compact.sort_by { |h| h[:updated_at] }.reverse
    end

    results
  end


  # normalizes objects into activities interface
  # this is presentation logic, seems like serializers are closest
  # handle "You requested advice", "Meera added a note"
  def normalize_activity(activity)
    case activity
    when Advice::Event
      # external stakeholders don't have profile pics unless we look up gravatar from emailprofile_pic = activity.sender.image_url
      image_url = activity.originator.image_url
      Advice::Activity.new(
        id: "n/a",
        type: "event",
        person: { name: activity.originator.name, profile_pic: image_url },
        title: activity.name,
        content: activity.description,
        updated_at: activity.updated_at
      )
    when Advice::Message
      # external stakeholders don't have profile pics unless we look up gravatar from emailprofile_pic = activity.sender.image_url
      sender = activity.sender
      Advice::Activity.new(
        id: "n/a",
        type: "message",
        person: { name: sender.name, image_url: sender.image_url },
        title: "Message",
        content: activity.content,
        updated_at: activity.updated_at
      )
    when Advice::Record
      # external stakeholders don't have profile pics unless we look up gravatar from email
      # https://en.gravatar.com/site/implement/images/
      image_url = activity.stakeholder.image_url ? activity.stakeholder.image_url : nil
      Advice::Activity.new(
        id: "n/a",
        type: "record",
        person: { name: activity.stakeholder.name, image_url: image_url },
        title: activity.status,
        content: activity.content,
        updated_at: activity.updated_at
      )
    end
  end
end
