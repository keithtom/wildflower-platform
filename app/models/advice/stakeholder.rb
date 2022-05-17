# A stakeholder is someone impacted by the decision
#
# Open Question: It seems like it can also be an expert who offers advice but it isn't clear if this distinction should be formalized (Cam thinks it is a very bad idea, also check w/ Betsy/Matt)
#
# Technically, a stakeholder can delegate to a Person object but it doesn't have to be someone in the directory.
# It could be a parent or board member; however, as long as stakeholders can adhere to the same interface, the system should not care.
class Advice::Stakeholder < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  belongs_to :decision
  belongs_to :person, optional: true

  has_many :messages
  has_many :records

  def name
    person&.name || external_name
  end

  def email
    person&.email || external_email
  end

  def phone
    person&.phone || external_phone
  end

  # move me to a service.
  def calendar_url
    event_title = "[Advice] #{decision.creator.first_name} / #{name}"
    stakeholder_email = email
    event_details = "Hi #{name},
I am seeking advice for a decision I intend to make in my role as #{decision.role}.
Please see the link below for additional details.

I need to advice by #{decision.advice_by&.strftime("%m/%d")}.

Thank you,
#{decision.creator.first_name}


Decision
  I intend to #{decision.title}.

Context
  #{decision.context}

Proposal
  #{decision.proposal}

Advice URL
  #{decision.title}
"
  # change URL to be created from a service and we can use routes there?
    if person
      "https://calendar.google.com/calendar/u/2/r/eventedit?text=#{event_title}&details=#{event_details}&add=#{stakeholder_email}"
    else
      external_calendar_url
    end
  end

  # support comma-separated list
  def roles
    person&.roles || external_roles&.split(',')&.map(&:strip)
  end

  # support comma-separated list
  def subroles
    person&.subroles || external_subroles&.split(',')&.map(&:strip)
  end

end
