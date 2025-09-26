# app/models/quote.rb
class Quote < ApplicationRecord
  belongs_to :user
  belongs_to :job, optional: true
  belongs_to :parent_quote, class_name: 'Quote', optional: true
  has_many :child_quotes, class_name: 'Quote', foreign_key: 'parent_quote_id', dependent: :destroy
  has_many :quote_items, -> { order(:position) }, dependent: :destroy
  has_one_attached :pdf_file

  validates :title, presence: true
  validates :gst_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  enum status: {
    draft: 0,
    sent: 1,
    accepted: 2,
    expired: 3
  }

  enum pricing_model: {
    fixed_price: 0,
    hourly_rate: 1,
    cost_plus: 2
  }

  scope :current_versions, -> { where(parent_quote_id: nil) }

  accepts_nested_attributes_for :quote_items, allow_destroy: true

  def subtotal
    quote_items.sum { |item| item.quantity * item.unit_price }
  end

  def gst_amount
    return 0 unless gst_enabled?
    subtotal * gst_rate
  end

  def total
    subtotal + gst_amount
  end

  def generate_and_store_pdf!
    pdf_content = Quotes::PdfRenderer.new(self).render

    # Create a temporary file
    temp_file = Tempfile.new(['quote', '.pdf'])
    temp_file.binmode
    temp_file.write(pdf_content)
    temp_file.rewind

    # Attach the PDF
    pdf_file.attach(
      io: temp_file,
      filename: "quote_#{id}_v#{version}.pdf",
      content_type: 'application/pdf'
    )

    temp_file.close
    temp_file.unlink

    pdf_file
  end

  def duplicate_for_new_version
    new_quote = self.dup
    new_quote.version = (parent_quote&.child_quotes&.maximum(:version) || version) + 1
    new_quote.parent_quote = parent_quote || self
    new_quote.status = :draft
    new_quote.save!

    # Copy quote items
    quote_items.each do |item|
      new_quote.quote_items.create!(
        description: item.description,
        quantity: item.quantity,
        unit: item.unit,
        unit_price: item.unit_price,
        category: item.category,
        position: item.position
      )
    end

    new_quote
  end
end
