# frozen_string_literal: true

class V1::SchoolRelationshipsController < ApiController
  def index
    @school_relationships = SchoolRelationship.all
    render json: V1::SchoolRelationshipSerializer.new(@school_relationships, serializer_options)
  end

  def create
    school = School.find_by!(external_identifier: school_relationship_params.delete(:school_id))
    person = Person.find_by!(external_identifier: school_relationship_params.delete(:person_id))
    @school_relationship = SchoolRelationship.new(school_relationship_params)
    @school_relationship.school = school
    @school_relationship.person = person

    if @school_relationship.save
      render json: V1::SchoolRelationshipSerializer.new(@school_relationship, serializer_options), status: :created
    else
      render json: @school_relationship.errors, status: :unprocessable_entity
    end
  end

  def show
    @school_relationship = SchoolRelationship.find_by!(external_identifier: params[:id])
    render json: V1::SchoolRelationshipSerializer.new(@school_relationship, serializer_options)
  end

  def update
    @school_relationship = SchoolRelationship.find_by!(external_identifier: params[:id])

    if @school_relationship.update(school_relationship_params)
      render json: V1::SchoolRelationshipSerializer.new(@school_relationship, serializer_options)
    else
      render json: @school_relationship.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @school_relationship = SchoolRelationship.find_by!(external_identifier: params[:id])
    @school_relationship.destroy
    head :no_content
  end

  private

  def serializer_options
    { include: %w[school person] }
  end

  def school_relationship_params
    params.require(:school_relationship).permit(
      :name,
      :description,
      :start_date,
      :end_date,
      :title,
      :school_id,
      :person_id,
      [role_list: []]
    )
  end
end
