import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "container"]
  static values = { seconds: Number }

  connect() {
    if (this.secondsValue > 0) {
      this.remaining = this.secondsValue
      this.updateDisplay()
      this.timer = setInterval(() => this.tick(), 1000)
    }
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  tick() {
    this.remaining--
    if (this.remaining <= 0) {
      clearInterval(this.timer)
      this.lockSession()
    } else {
      this.updateDisplay()
    }
  }

  updateDisplay() {
    const mins = Math.floor(this.remaining / 60)
    const secs = this.remaining % 60
    const formatted = `${mins}:${secs.toString().padStart(2, "0")}`
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = formatted
    }
  }

  lockSession() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    fetch("/lock", {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "text/html"
      }
    }).then(() => {
      window.location.reload()
    }).catch(() => {
      window.location.reload()
    })
  }
}
