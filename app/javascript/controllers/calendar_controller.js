// app/javascript/controllers/calendar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["day"]
  static values = { year: Number, month: Number }

  connect() {
    console.log("Calendar controller connected")
    this.selectedDays = new Set()
  }

  toggleDay(event) {
    const dayElement = event.currentTarget
    const date = dayElement.dataset.date
    const currentState = dayElement.dataset.state
    const source = dayElement.dataset.source

    // Don't allow toggling booked days (they come from jobs)
    if (source === 'job') {
      this.showMessage("Cannot modify booked days - they are automatically set based on accepted jobs.", "warning")
      return
    }

    // Don't allow toggling past dates
    const targetDate = new Date(date)
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    if (targetDate < today) {
      this.showMessage("Cannot modify past dates.", "warning")
      return
    }

    this.updateDayState(date, dayElement)
  }

  async updateDayState(date, dayElement) {
    try {
      const response = await fetch('/calendar_days/toggle', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ date: date })
      })

      if (response.ok) {
        const data = await response.json()
        this.updateDayDisplay(dayElement, data.state)
        this.showMessage(`Date marked as ${data.state}`, "success")
      } else {
        const errorData = await response.json()
        this.showMessage(errorData.error || "Failed to update calendar", "error")
      }
    } catch (error) {
      console.error('Calendar update error:', error)
      this.showMessage("Network error. Please try again.", "error")
    }
  }

  updateDayDisplay(dayElement, newState) {
    // Update data attributes
    dayElement.dataset.state = newState
    dayElement.dataset.source = 'manual'

    // Update visual indicators
    const indicator = dayElement.querySelector('.w-3.h-3')
    const badge = dayElement.querySelector('.text-xs.px-2')

    if (indicator) {
      indicator.className = `w-3 h-3 rounded-full ${this.getStateColorClass(newState)}`
    }

    if (badge) {
      badge.className = `text-xs px-2 py-1 rounded-full text-center ${this.getStateBadgeClass(newState)}`
      badge.textContent = this.capitalizeFirst(newState)
    }
  }

  getStateColorClass(state) {
    switch(state) {
      case 'available': return 'bg-green-400'
      case 'busy': return 'bg-red-400'
      case 'booked': return 'bg-blue-400'
      default: return 'bg-green-400'
    }
  }

  getStateBadgeClass(state) {
    switch(state) {
      case 'available': return 'bg-green-100 text-green-800'
      case 'busy': return 'bg-red-100 text-red-800'
      case 'booked': return 'bg-blue-100 text-blue-800'
      default: return 'bg-green-100 text-green-800'
    }
  }

  capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  // Quick action methods
  markWeekend() {
    const weekendDates = this.getWeekendDates()
    this.bulkUpdateDays(weekendDates, 'busy')
  }

  clearWeekend() {
    const weekendDates = this.getWeekendDates()
    this.bulkUpdateDays(weekendDates, 'available')
  }

  markWeekAvailable() {
    const currentWeekDates = this.getCurrentWeekDates()
    this.bulkUpdateDays(currentWeekDates, 'available')
  }

  getWeekendDates() {
    const dates = []
    const startDate = new Date(this.yearValue, this.monthValue - 1, 1)
    const endDate = new Date(this.yearValue, this.monthValue - 1 + 1, 0)

    for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
      if (d.getDay() === 0 || d.getDay() === 6) { // Sunday or Saturday
        dates.push(new Date(d).toISOString().split('T')[0])
      }
    }
    return dates
  }

  getCurrentWeekDates() {
    const today = new Date()
    const dates = []
    const startOfWeek = new Date(today)
    startOfWeek.setDate(today.getDate() - today.getDay()) // Go to Sunday

    for (let i = 0; i < 7; i++) {
      const date = new Date(startOfWeek)
      date.setDate(startOfWeek.getDate() + i)

      // Only include dates in current month
      if (date.getMonth() === this.monthValue - 1 && date.getFullYear() === this.yearValue) {
        dates.push(date.toISOString().split('T')[0])
      }
    }
    return dates
  }

  async bulkUpdateDays(dates, state) {
    if (dates.length === 0) {
      this.showMessage("No applicable dates found", "warning")
      return
    }

    try {
      const response = await fetch('/calendar_days/bulk_update', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({
          dates: dates,
          state: state
        })
      })

      if (response.ok) {
        const data = await response.json()

        // Update display for each changed day
        data.updated_days.forEach(dayData => {
          const dayElement = this.dayTargets.find(el => el.dataset.date === dayData.date)
          if (dayElement) {
            this.updateDayDisplay(dayElement, dayData.state)
          }
        })

        this.showMessage(`${data.updated_days.length} days updated to ${state}`, "success")
      } else {
        const errorData = await response.json()
        this.showMessage(errorData.error || "Failed to bulk update", "error")
      }
    } catch (error) {
      console.error('Bulk update error:', error)
      this.showMessage("Network error. Please try again.", "error")
    }
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }

  showMessage(message, type = "info") {
    // Remove any existing messages
    const existingMessage = document.querySelector('.calendar-message')
    if (existingMessage) {
      existingMessage.remove()
    }

    // Create message element
    const messageDiv = document.createElement('div')
    messageDiv.className = `calendar-message fixed top-4 right-4 px-4 py-2 rounded-lg shadow-lg z-50 ${this.getMessageClass(type)}`
    messageDiv.textContent = message

    // Add to page
    document.body.appendChild(messageDiv)

    // Auto-remove after 3 seconds
    setTimeout(() => {
      if (messageDiv.parentNode) {
        messageDiv.remove()
      }
    }, 3000)
  }

  getMessageClass(type) {
    switch(type) {
      case 'success': return 'bg-green-500 text-white'
      case 'error': return 'bg-red-500 text-white'
      case 'warning': return 'bg-yellow-500 text-white'
      default: return 'bg-blue-500 text-white'
    }
  }
}
