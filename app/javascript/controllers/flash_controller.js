import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dismissTimeout = setTimeout(() => {
      this.element.classList.add("opacity-0", "pointer-events-none")
      this.removeTimeout = setTimeout(() => this.element.remove(), 300)
    }, 5000)
  }

  disconnect() {
    clearTimeout(this.dismissTimeout)
    clearTimeout(this.removeTimeout)
  }
}
