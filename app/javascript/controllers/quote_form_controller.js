// app/javascript/controllers/quote_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subtotal", "gstAmount", "total", "gstRow", "gstRate",
                   "labourItems", "materialsItems", "labourItemTemplate",
                   "materialsItemTemplate", "itemRow"]
  static values = { gstRate: Number }

  connect() {
    console.log("Quote form controller connected")
    this.updateTotals()
  }

  toggleGST(event) {
    const enabled = event.target.checked
    if (enabled) {
      this.gstRowTarget.style.display = "flex"
    } else {
      this.gstRowTarget.style.display = "none"
    }
    this.updateTotals()
  }

  addLabourItem() {
    this.addItem('labour')
  }

  addMaterialsItem() {
    this.addItem('materials')
  }

  addItem(category) {
    const container = category === 'labour' ? this.labourItemsTarget : this.materialsItemsTarget
    const template = category === 'labour' ? this.labourItemTemplateTarget : this.materialsItemTemplateTarget

    const newId = new Date().getTime()
    const content = template.innerHTML.replace(/NEW_RECORD/g, newId)

    container.insertAdjacentHTML('beforeend', content)
    this.updateTotals()
  }

  removeItem(event) {
    const row = event.target.closest('.quote-item-row')
    const destroyInput = row.querySelector('input[name*="_destroy"]')

    if (destroyInput) {
      // Mark for destruction if persisted
      destroyInput.value = '1'
      row.style.display = 'none'
    } else {
      // Remove from DOM if new
      row.remove()
    }

    this.updateTotals()
  }

  updateTotals() {
    let subtotal = 0

    // Calculate subtotal from all visible rows
    this.itemRowTargets.forEach(row => {
      if (row.style.display !== 'none') {
        const quantityInput = row.querySelector('input[name*="[quantity]"]')
        const priceInput = row.querySelector('input[name*="[unit_price]"]')
        const lineTotalSpan = row.querySelector('.line-total')

        const quantity = parseFloat(quantityInput?.value) || 0
        const price = parseFloat(priceInput?.value) || 0
        const lineTotal = quantity * price

        if (lineTotalSpan) {
          lineTotalSpan.textContent = this.formatCurrency(lineTotal)
        }

        subtotal += lineTotal
      }
    })

    // Update subtotal display
    this.subtotalTarget.textContent = this.formatCurrency(subtotal)

    // Calculate GST
    const gstEnabled = document.querySelector('input[name*="[gst_enabled]"]')?.checked
    let gstAmount = 0

    if (gstEnabled) {
      const gstRate = parseFloat(this.gstRateTarget.value) || 0
      gstAmount = subtotal * gstRate
      this.gstAmountTarget.textContent = this.formatCurrency(gstAmount)
    }

    // Calculate total
    const total = subtotal + gstAmount
    this.totalTarget.textContent = this.formatCurrency(total)
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat('en-AU', {
      style: 'currency',
      currency: 'AUD'
    }).format(amount)
  }
}
