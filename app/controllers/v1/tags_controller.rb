class V1::TagsController < ApplicationController
  before_action :authenticate_admin!

  # example params = { context: 'categories'}
  # example params = { context: 'phase'}
  def index
    tag_names = ActsAsTaggableOn::Tag.for_context(params[:context].to_sym).map(&:name)
    render json: { data: tag_names }, status: :ok
  end

  def create
    tag = ActsAsTaggableOn::Tag.create!(tag_params)
    render json: { data: tag.name }, status: :ok
  end

  def update
    tag = ActsAsTaggableOn::Tag.find(params[:id])
    tag.update!(tag_params)
    render json: { data: tag.reload.name }, status: :ok
  end

  def destroy
    tag = ActsAsTaggableOn::Tag.find(params[:id])
    tag.destroy!
    render json: { message: 'successfully removed' }, status: :ok
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end