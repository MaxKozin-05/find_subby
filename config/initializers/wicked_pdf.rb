# config/initializers/wicked_pdf.rb
WickedPdf.config ||= {}

# Ensure the embedded wkhtmltopdf binary provided by the gem is used
if WickedPdf.respond_to?(:binary_path)
  WickedPdf.config.merge!(exe_path: WickedPdf.binary_path)
end

# Provide sensible defaults for page rendering; override per-call if needed
WickedPdf.config.merge!(
  layout: false,
  margin: {
    top: '0.75in',
    bottom: '0.75in',
    left: '0.75in',
    right: '0.75in'
  }
)
