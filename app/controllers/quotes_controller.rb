# app/controllers/quotes_controller.rb
class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :duplicate, :generate_pdf, :pdf]

  def index
    @quotes = policy_scope(Quote).includes(:quote_items, :job).current_versions.order(created_at: :desc)

    # Filter by status if provided
    if params[:status].present?
      @quotes = @quotes.where(status: params[:status])
    end
  end

  def show
    # Quote details are handled in the view
  end

  def new
    @quote = current_user.quotes.build
    @quote.quote_items.build(category: :labour)
    @quote.quote_items.build(category: :materials)
    authorize @quote
  end

  def create
    @quote = current_user.quotes.build(quote_params)
    authorize @quote

    if @quote.save
      if params[:commit] == "Generate PDF"
        @quote.generate_and_store_pdf!
        redirect_to @quote, notice: 'Quote was successfully created and PDF generated.'
      else
        redirect_to @quote, notice: 'Quote was successfully created.'
      end
    else
      # Ensure we have at least one item of each category for the form
      @quote.quote_items.build(category: :labour) unless @quote.quote_items.any?(&:labour?)
      @quote.quote_items.build(category: :materials) unless @quote.quote_items.any?(&:materials?)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Add empty items if none exist for each category
    @quote.quote_items.build(category: :labour) unless @quote.quote_items.any?(&:labour?)
    @quote.quote_items.build(category: :materials) unless @quote.quote_items.any?(&:materials?)
  end

  def update
    if @quote.update(quote_params)
      if params[:commit] == "Generate PDF"
        @quote.generate_and_store_pdf!
        redirect_to @quote, notice: 'Quote was successfully updated and PDF generated.'
      else
        redirect_to @quote, notice: 'Quote was successfully updated.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_path, notice: 'Quote was successfully deleted.'
  end

  def duplicate
    @new_quote = @quote.duplicate_for_new_version
    redirect_to edit_quote_path(@new_quote), notice: "Created new version (v#{@new_quote.version}) of the quote."
  end

  def generate_pdf
    @quote.generate_and_store_pdf!
    redirect_to @quote, notice: 'PDF has been generated successfully.'
  end

  def pdf
    if @quote.pdf_file.attached?
      redirect_to rails_blob_path(@quote.pdf_file, disposition: "inline")
    else
      # Generate PDF on the fly if it doesn't exist
      pdf_content = Quotes::PdfRenderer.new(@quote).render
      send_data pdf_content,
                filename: "quote_#{@quote.id}_v#{@quote.version}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
    end
  end

  private

  def set_quote
    @quote = current_user.quotes.find(params[:id])
    authorize @quote
  end

  def quote_params
    params.require(:quote).permit(
      :title, :description, :status, :pricing_model, :gst_enabled, :gst_rate, :job_id,
      quote_items_attributes: [:id, :description, :quantity, :unit, :unit_price, :category, :position, :_destroy]
    )
  end
end

# app/controllers/quotes/pdf_controller.rb
