import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dot", "form", "submitBtn", "errorMsg"]
  static values = { autoSubmitLength: { type: Number, default: 4 } }

  connect() {
    this.updateDots()
    // Auto-focus input on open
    setTimeout(() => {
      if (this.hasInputTarget) this.inputTarget.focus()
    }, 100)
  }

  pressDigit(event) {
    const digit = event.currentTarget.dataset.digit
    if (this.hasInputTarget && digit !== undefined) {
      if (this.inputTarget.value.length < 12) {
        this.inputTarget.value += digit
        this.updateDots()
        this.checkAutoSubmit()
      }
    }
  }

  backspace() {
    if (this.hasInputTarget) {
      this.inputTarget.value = this.inputTarget.value.slice(0, -1)
      this.updateDots()
    }
  }

  clear() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.updateDots()
    }
  }

  onInput() {
    this.updateDots()
    this.checkAutoSubmit()
  }

  updateDots() {
    const currentLength = this.hasInputTarget ? this.inputTarget.value.length : 0
    if (this.hasDotTargets) {
      this.dotTargets.forEach((dot, index) => {
        if (index < currentLength) {
          dot.classList.add("bg-white", "scale-110")
          dot.classList.remove("bg-neutral-700")
        } else {
          dot.classList.remove("bg-white", "scale-110")
          dot.classList.add("bg-neutral-700")
        }
      })
    }
  }

  checkAutoSubmit() {
    if (this.hasInputTarget && this.hasFormTarget) {
      const len = this.inputTarget.value.length
      if (len >= this.autoSubmitLengthValue && this.autoSubmitLengthValue > 0) {
        this.formTarget.requestSubmit()
      }
    }
  }
}
