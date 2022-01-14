class V1::PeopleController < ApiController
  def index
    @people = Person.all
    render json: V1::PersonSerializer.new(@people)
  end

  def show
    @person = Person.find_by!(external_identifier: params[:id])
    render json: V1::PersonSerializer.new(@person)
  end
end
