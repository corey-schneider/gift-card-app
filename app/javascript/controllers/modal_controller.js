import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "content"]

  open() {
    this.element.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("translate-y-full", "scale-95", "opacity-0")
      this.contentTarget.classList.add("translate-y-0", "scale-100", "opacity-100")
    }
  }

  close() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add("translate-y-full", "opacity-0")
      setTimeout(() => {
        this.element.classList.add("hidden")
        document.body.classList.remove("overflow-hidden")
      }, 200)
    } else {
      this.element.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) {
      this.close()
    }
  }

  closeOnEsc(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
