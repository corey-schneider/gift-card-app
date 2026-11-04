import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "feedback", "icon"]
  static values = { text: String }

  async copy(event) {
    event?.preventDefault()

    const textToCopy = this.hasTextValue && this.textValue
      ? this.textValue
      : (this.hasSourceTarget ? this.sourceTarget.textContent.trim() : "")

    if (!textToCopy) return

    let copied = false
    let clipboardError

    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(textToCopy)
        copied = true
      } catch (error) {
        clipboardError = error
      }
    }

    if (!copied) {
      try {
        copied = this.copyWithFallback(textToCopy)
      } catch (error) {
        console.error("Clipboard fallback failed", error)
      }
    }

    if (copied) {
      this.showCopiedState()
    } else {
      if (clipboardError) console.error("Clipboard API failed", clipboardError)
      this.showCopyFailedState()
    }
  }

  copyWithFallback(text) {
    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.setAttribute("readonly", "")
    textarea.style.position = "fixed"
    textarea.style.opacity = "0"
    document.body.appendChild(textarea)

    try {
      textarea.focus()
      textarea.select()
      textarea.setSelectionRange(0, textarea.value.length)
      return document.execCommand("copy")
    } finally {
      textarea.remove()
    }
  }

  showCopiedState() {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = "Copied"
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

  showCopyFailedState() {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = "Copy failed"
      this.feedbackTarget.classList.remove("hidden")
      setTimeout(() => {
        this.feedbackTarget.classList.add("hidden")
        this.feedbackTarget.textContent = "Copied"
      }, 1800)
    }
  }
}
