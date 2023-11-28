unless Rails.env.production?
  Audited.auditing_enabled = false
end