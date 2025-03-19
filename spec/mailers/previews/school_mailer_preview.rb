# Preview all emails at http://localhost:3000/rails/mailers/school_mailer
class SchoolMailerPreview < ActionMailer::Preview
  def add_partner
    SchoolMailer.add_partner(User.first.id, 'School Test Name')
  end

  def notify_partners_new_workflow
    SchoolMailer.notify_partners_new_workflow(School.first.id)
  end
end
