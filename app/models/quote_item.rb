class QuoteItem < ApplicationRecord
  belongs_to :quote

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum category: {
    labour: 0,
    materials: 1
  }

  before_save :set_position
  after_save :recalculate_quote_totals
  after_destroy :recalculate_quote_totals

  def line_total
    quantity * unit_price
  end

  private

  def set_position
    if position.blank? || position.zero?
      max_position = quote.quote_items.where(category: category).maximum(:position) || 0
      self.position = max_position + 1
    end
  end

  def recalculate_quote_totals
    # This could trigger any quote total recalculations if needed
    # For now, totals are calculated dynamically
  end
end
