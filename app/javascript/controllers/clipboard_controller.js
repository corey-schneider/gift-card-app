import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "feedback", "icon"]
  static values = { text: String }

  copy(event) {
    if (event) event.preventDefault()

    const textToCopy = this.hasTextValue && this.textValue
      ? this.textValue
      : (this.hasSourceTarget ? this.sourceTarget.textContent.trim() : "")

    if (!textToCopy) return

    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showCopiedState()
    }).catch(err => {
      // Fallback
      const textarea = document.createElement("textarea")
      textarea.value = textToCopy
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand("copy")
      document.body.removeChild(textarea)
      this.showCopiedState()
    })
  }

  showCopiedState() {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.classList.remove("hidden")
      setTimeout(() => {
        this.feedbackTarget.classList.add("hidden")
      }, 1800)
    }

    if (this.hasIconTarget) {
      const originalHtml = this.iconTarget.innerHTML
      this.iconTarget.innerHTML = `
        <svg class="w-4 h-4 text-emerald-400 animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
        </svg>
      `
      setTimeout(() => {
        this.iconTarget.innerHTML = originalHtml
      }, 1800)
    }
  }
}
