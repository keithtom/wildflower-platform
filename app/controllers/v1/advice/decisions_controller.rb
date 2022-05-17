class V1::Advice::DecisionsController < ApiController

  def index
    # find a way to figure out if we are /draft/open/clsoed; and convert it into a standard url param.
    # @person.decisions # filter state if required.
    # routing should just rename /draft/open/close to a url param.
    #
    head :ok
  end

  def open
    head :ok
  end

  def amend
    head :ok
  end

  def close
    head :ok
  end

  def create
    head :ok
  end

  def show
    head :ok
  end

  def update
    head :ok
  end
end
