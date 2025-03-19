# Preview all emails at http://localhost:3000/rails/mailers/school_mailer
class SchoolMailerPreview < ActionMailer::Preview
  def add_partner
    SchoolMailer.add_partner(User.first.id, 'School Test Name')
  end
end
