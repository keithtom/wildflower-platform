# frozen_string_literal: true

class V1::SchoolRelationshipsController < ApiController
  def index
    @school_relationships = SchoolRelationship.all
    render json: V1::SchoolRelationshipSerializer.new(@school_relationships, serializer_options)
  end

  def create
    @school_relationship = SchoolRelationship.new(school_relationship_params)

    if @school_relationship.save
      render json: V1::SchoolRelationshipSerializer.new(@school_relationship, serializer_options), status: :created
    else
      render json: @school_relationship.errors, status: :unprocessable_entity
    end
  end

  def show
    @school_relationship = SchoolRelationship.find(params[:id])
    render json: V1::SchoolRelationshipSerializer.new(@school_relationship, serializer_options)
  end

  def update
    @school_relationship = SchoolRelationship.find(params[:id])

    if @school_relationship.update(school_relationship_params)
      render json: V1::SchoolRelationshipSerializer.new(@school_relationship, serializer_options)
    else
      render json: @school_relationship.errors, status: :unprocessable_entity
    end
  end

  def delete
    @school_relationship = SchoolRelationship.find(params[:id])
    @school_relationship.destroy
    head :no_content
  end

  private

  def school_relationship_params
    params.require(:school_relationship).permit(
      :name,
      :description,
      :start_date,
      :end_date,
      :title,
      [role_list: []]
    )
  end
end
