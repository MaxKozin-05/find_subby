module Quotes
  class PdfRenderer
    attr_reader :quote

    def initialize(quote)
      @quote = quote
    end

    def render
      WickedPdf.new.pdf_from_string(
        html_content,
        pdf_options
      )
    end

    private

    def html_content
      ApplicationController.render(
        template: 'quotes/pdf',
        layout: false,
        assigns: { quote: @quote, profile: @quote.user.profile }
      )
    end

    def pdf_options
      {
        page_size: 'A4',
        margin: {
          top: '0.75in',
          bottom: '0.75in',
          left: '0.75in',
          right: '0.75in'
        },
        encoding: 'UTF-8',
        footer: {
          right: 'Page [page] of [topage]',
          font_size: 10,
          spacing: 10
        }
      }
    end
  end
end
