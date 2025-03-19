module MailerHelper
  def format_names(partners)
    return partners.first&.first_name if partners.size <= 1

    "#{partners[0..-2].map(&:first_name).join(', ')} and #{partners.last.first_name}"
  end
end
