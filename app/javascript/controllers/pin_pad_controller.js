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
    const input = this.element.querySelector('input[name="pin"]')
    const currentLength = input?.value.length || 0

    this.element.querySelectorAll('[data-pin-pad-target~="dot"]').forEach((dot, index) => {
      const filled = index < currentLength
      dot.classList.toggle("bg-white", filled)
      dot.classList.toggle("bg-neutral-700", !filled)
      dot.classList.toggle("scale-110", filled)
      dot.style.backgroundColor = filled ? "#fff" : "#404040"
    })
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
