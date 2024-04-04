class V1::DocumentsController < ApiController
  before_action :authenticate_admin!, only: [:destroy]

  def create
    # scope permissions of documentable...
    @decision = Advice::Decision.find_by!(external_identifier: document_params[:documentable_id])
    @document = @decision.documents.create!(link: document_params[:link])
    render json: V1::DocumentSerializer.new(@document), status: :created
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy!
    head :ok
  end

  protected

  def document_params
    params.require(:document).permit(:documentable_type, :documentable_id, :link, :type)
  end
end
