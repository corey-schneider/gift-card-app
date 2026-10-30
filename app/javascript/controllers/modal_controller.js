import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "content"]

  disconnect() {
    clearTimeout(this.closeTimeout)
    this.unlockPageScroll()
  }

  open() {
    clearTimeout(this.closeTimeout)
    this.element.classList.remove("hidden")
    this.lockPageScroll()
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("translate-y-full", "scale-95", "opacity-0")
      this.contentTarget.classList.add("translate-y-0", "scale-100", "opacity-100")
    }
  }

  close() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add("translate-y-full", "opacity-0")
      this.closeTimeout = setTimeout(() => {
        this.element.classList.add("hidden")
        this.unlockPageScroll()
      }, 200)
    } else {
      this.element.classList.add("hidden")
      this.unlockPageScroll()
    }
  }

  lockPageScroll() {
    if (this.scrollPosition !== undefined) return

    this.scrollPosition = window.scrollY
    this.previousBodyStyles = {
      position: document.body.style.position,
      top: document.body.style.top,
      left: document.body.style.left,
      right: document.body.style.right,
      width: document.body.style.width
    }
    this.previousDocumentOverflow = document.documentElement.style.overflow

    document.body.style.position = "fixed"
    document.body.style.top = `-${this.scrollPosition}px`
    document.body.style.left = "0"
    document.body.style.right = "0"
    document.body.style.width = "100%"
    document.documentElement.style.overflow = "hidden"
    document.body.classList.add("overflow-hidden")
  }

  unlockPageScroll() {
    if (this.scrollPosition === undefined) return

    const scrollPosition = this.scrollPosition
    Object.assign(document.body.style, this.previousBodyStyles)
    document.documentElement.style.overflow = this.previousDocumentOverflow
    document.body.classList.remove("overflow-hidden")
    this.scrollPosition = undefined
    window.scrollTo(0, scrollPosition)
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
