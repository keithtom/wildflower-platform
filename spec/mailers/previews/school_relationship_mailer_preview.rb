# Preview all emails at http://localhost:3000/rails/mailers/school_relationship_mailer
class SchoolRelationshipMailerPreview < ActionMailer::Preview
  def add_partner
    user = FactoryBot.create(:user, authentication_token: Devise.friendly_token)
    school_name = 'Wildflower Test School'

    SchoolRelationshipMailer.add_partner(user.id, school_name)
  end
end
