module Quotes
  class PdfController < ApplicationController
    before_action :set_quote

    def show
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
      @quote = current_user.quotes.find(params[:quote_id])
      authorize @quote, :show?
    end
  end
end
