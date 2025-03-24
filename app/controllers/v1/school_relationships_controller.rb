# frozen_string_literal: true

class V1::SchoolRelationshipsController < ApiController
  def index
    @school_relationships = SchoolRelationship.all
    render json: V1::SchoolRelationshipSerializer.new(@school_relationships, serializer_options)
  end

  def create
    begin
      @school_relationship = SchoolRelationship::Create.run(school_relationship_params, current_user)
      # Refetch with includes to avoid N+1
      @school_relationship = SchoolRelationship.includes(school: [:people]).find(@school_relationship.id)
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: V1::SchoolRelationshipSerializer.new(@school_relationship, serializer_options), status: :created
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
