# Preview all emails at http://localhost:3000/rails/mailers/school_relationship
class SchoolRelationshipPreview < ActionMailer::Preview
  def add_partner
    SchoolRelationshipMailer.add_partner(User.first.id, 'School Test Name')
  end
end
