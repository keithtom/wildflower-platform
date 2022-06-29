class V1::DocumentsController < ApiController
  def create
    # scope permissions of documentable...
    @decision = Advice::Decision.find_by!(external_identifier: document_params[:documentable_id])
    @document = @decision.documents.create!(link: document_params[:link])
    render json: V1::DocumentSerializer.new(@document), status: :created
  end

  def destroy
    # scope permissions
    # hard since it can come from multiple objects.
    @document = Document.find_by!(external_identifier: params[:id])
    @document.destroy!
    head :ok
  end

  protected

  def document_params
    params.require(:document).permit(:documentable_type, :documentable_id, :link, :type)
  end
end
