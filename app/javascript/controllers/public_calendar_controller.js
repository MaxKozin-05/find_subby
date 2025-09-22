// app/javascript/controllers/public_calendar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Public calendar controller connected")
  }

  // Future: Could add hover effects or click to show availability details
  showAvailabilityInfo(event) {
    const dayElement = event.currentTarget
    const date = dayElement.dataset.date
    const state = dayElement.dataset.state

    if (state && date) {
      // Could show a tooltip or modal with availability info
      console.log(`${date}: ${state}`)
    }
  }
}