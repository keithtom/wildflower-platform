class Api::V1::PeopleController < ApiController
  def index
    @people = Person.all
    render json: V1::PeopleSerializer.new(@people)
  end

  def show
    @person = Person.find_by!(external_identifier: params[:id])
    render json: V1::PeopleSerializer.new(@person)
  end
end
