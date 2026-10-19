import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "container", "storeName", "cardNumber", "svgContainer"]

  show(event) {
    event.preventDefault()
    const store = event.currentTarget.dataset.store || "Gift Card"
    const number = event.currentTarget.dataset.number || ""

    if (this.hasStoreNameTarget) this.storeNameTarget.textContent = store
    if (this.hasCardNumberTarget) this.cardNumberTarget.textContent = number

    this.renderBarcode(number)

    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  renderBarcode(text) {
    if (!this.hasSvgContainerTarget) return
    const cleaned = text.replace(/[^A-Za-z0-9]/g, "").toUpperCase()
    if (!cleaned) return

    // Generate high-contrast SVG Code 128 barcode
    const svg = this.generateCode128Svg(cleaned)
    this.svgContainerTarget.innerHTML = svg
  }

  generateCode128Svg(text) {
    // Code 128-B implementation
    const patterns = [
      "212222", "222122", "222221", "121223", "121322", "131222", "122213", "122312", "132212", "221213",
      "221312", "231212", "112232", "122132", "122231", "113222", "123122", "123221", "223211", "221132",
      "221231", "213212", "223112", "312131", "311222", "321122", "321221", "312212", "322112", "322211",
      "212123", "212321", "232121", "111323", "131123", "131321", "112313", "132113", "132311", "211313",
      "231113", "231311", "112133", "112331", "132131", "113123", "113321", "133121", "313121", "211331",
      "231131", "213113", "213311", "213131", "311123", "311321", "331121", "312113", "312311", "332111",
      "314111", "221411", "431111", "111224", "111422", "121124", "121421", "141122", "141221", "112214",
      "112412", "122114", "122411", "142112", "142211", "241211", "221114", "413111", "241112", "134111",
      "111242", "121142", "121241", "114212", "124112", "124211", "411212", "421112", "421211", "212141",
      "214121", "412121", "111143", "111341", "131141", "114113", "114311", "411113", "411311", "113141",
      "114131", "311141", "411131", "211412", "211214", "211232", "2331112"
    ]

    const START_B = 104
    const STOP = 106

    let codes = [START_B]
    let checksum = START_B

    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i) - 32
      if (code >= 0 && code <= 95) {
        codes.push(code)
        checksum += code * (i + 1)
      }
    }

    const checkDigit = checksum % 103
    codes.push(checkDigit)
    codes.push(STOP)

    let modules = ""
    codes.forEach(c => {
      const p = patterns[c]
      if (!p) return
      for (let j = 0; j < p.length; j++) {
        const width = parseInt(p[j], 10)
        const isBar = j % 2 === 0
        modules += (isBar ? "1" : "0").repeat(width)
      }
    })

    const barWidth = 2
    const height = 90
    const totalWidth = modules.length * barWidth
    let rects = ""

    for (let i = 0; i < modules.length; i++) {
      if (modules[i] === "1") {
        rects += `<rect x="${i * barWidth}" y="0" width="${barWidth}" height="${height}" fill="#000000" />`
      }
    }

    return `
      <svg class="w-full max-w-sm mx-auto h-24" viewBox="0 0 ${totalWidth} ${height}" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="#ffffff" />
        ${rects}
      </svg>
    `
  }
}
