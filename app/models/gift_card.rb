class GiftCard < ApplicationRecord
  # Encrypt sensitive card details at rest (AES-256-GCM)
  encrypts :card_number
  encrypts :pin

  validates :store_name, presence: true, length: { maximum: 100 }
  validates :card_number, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(redeemed: false) }
  scope :redeemed, -> { where(redeemed: true) }

  # Default sort: Unexpired cards expiring soonest first, then cards without expiration date, then expired cards
  scope :expiring_first, -> {
    order(
      Arel.sql(
        "CASE " \
        "  WHEN expiration_date IS NOT NULL AND expiration_date >= DATE('now') THEN 0 " \
        "  WHEN expiration_date IS NULL THEN 1 " \
        "  ELSE 2 " \
        "END ASC, expiration_date ASC, store_name ASC"
      )
    )
  }

  scope :by_sort, ->(option) {
    case option.to_s
    when "exp_asc"
      order(Arel.sql("expiration_date IS NULL ASC, expiration_date ASC, store_name ASC"))
    when "exp_desc"
      order(Arel.sql("expiration_date IS NULL ASC, expiration_date DESC, store_name ASC"))
    when "name_asc"
      order(Arel.sql("LOWER(store_name) ASC"))
    when "name_desc"
      order(Arel.sql("LOWER(store_name) DESC"))
    when "amount_desc"
      order(Arel.sql("balance IS NULL ASC, balance DESC, store_name ASC"))
    when "amount_asc"
      order(Arel.sql("balance IS NULL ASC, balance ASC, store_name ASC"))
    else
      expiring_first
    end
  }

  scope :filter_status, ->(status) {
    case status.to_s
    when "redeemed"
      where(redeemed: true)
    when "all"
      all
    else # default "active"
      where(redeemed: false)
    end
  }

  scope :search, ->(query) {
    return all if query.blank?

    term = "%#{query.strip.downcase}%"
    where(
      "LOWER(store_name) LIKE :term OR LOWER(notes) LIKE :term OR LOWER(value_description) LIKE :term",
      term: term
    )
  }

  # Deep, high-contrast finishes keep brand colors recognizable while keeping card details readable.
  CARD_FINISHES = {
    "classic" => { name: "Charcoal", background: "linear-gradient(135deg, #27272a, #09090b)", border: "#52525b" },
    "navy" => { name: "Midnight blue", background: "linear-gradient(135deg, #1e3a8a, #0c1a3b)", border: "#3b5998" },
    "stone" => { name: "Warm stone", background: "linear-gradient(135deg, #57534e, #1c1917)", border: "#78716c" },
    "zinc" => { name: "Obsidian", background: "linear-gradient(135deg, #27272a, #09090b)", border: "#52525b" },
    "forest" => { name: "Evergreen", background: "linear-gradient(135deg, #065f46, #022c22)", border: "#047857" },
    "emerald" => { name: "Evergreen", background: "linear-gradient(135deg, #065f46, #022c22)", border: "#047857" },
    "amber" => { name: "Warm amber", background: "linear-gradient(135deg, #92400e, #431407)", border: "#b45309" },
    "evergreen" => { name: "Evergreen", background: "linear-gradient(135deg, #065f46, #022c22)", border: "#047857" },
    "ocean" => { name: "Ocean blue", background: "linear-gradient(135deg, #1d4ed8, #172554)", border: "#3b82f6" },
    "ruby" => { name: "Ruby red", background: "linear-gradient(135deg, #9f1239, #4c0519)", border: "#e11d48" },
    "violet" => { name: "Violet", background: "linear-gradient(135deg, #6d28d9, #2e1065)", border: "#8b5cf6" },
    "rose" => { name: "Rose", background: "linear-gradient(135deg, #be185d, #500724)", border: "#ec4899" },
    "teal" => { name: "Teal", background: "linear-gradient(135deg, #0f766e, #042f2e)", border: "#14b8a6" },
    "gold" => { name: "Gold", background: "linear-gradient(135deg, #a16207, #422006)", border: "#ca8a04" },
    "ifly" => { name: "iFLY", background: "linear-gradient(135deg, #0284c7, #082f49)", border: "#38bdf8" },
    "starbucks" => { name: "Starbucks", background: "linear-gradient(135deg, #00704a, #003b2a)", border: "#00a86b" },
    "dunkin" => { name: "Dunkin'", background: "linear-gradient(120deg, #c2410c 0%, #7c2d12 52%, #9d174d 100%)", border: "#fb923c" },
    "chipotle" => { name: "Chipotle", background: "linear-gradient(135deg, #7f1d1d, #3f1515)", border: "#b91c1c" },
    "amazon" => { name: "Amazon", background: "linear-gradient(135deg, #142b45, #111827)", border: "#f59e0b" },
    "topgolf" => { name: "Topgolf", background: "linear-gradient(135deg, #14532d, #071b12)", border: "#84cc16" },
    "ulta" => { name: "Ulta Beauty", background: "linear-gradient(135deg, #9d174d, #3b1028)", border: "#ec4899" },
    "homegoods" => { name: "HomeGoods family", background: "linear-gradient(135deg, #991b1b, #450a0a)", border: "#dc2626" },
    "carvel" => { name: "Carvel", background: "linear-gradient(135deg, #1d4ed8, #172554)", border: "#ef4444" },
    "bath_body_works" => { name: "Bath & Body Works", background: "linear-gradient(135deg, #312e81, #111827)", border: "#818cf8" },
    "grubhub" => { name: "Grubhub", background: "linear-gradient(135deg, #c2410c, #14532d)", border: "#fb923c" },
    "target" => { name: "Target", background: "linear-gradient(135deg, #b91c1c, #450a0a)", border: "#ef4444" },
    "sephora" => { name: "Sephora", background: "linear-gradient(135deg, #27272a, #09090b)", border: "#a1a1aa" },
    "barnes_noble" => { name: "Barnes & Noble", background: "linear-gradient(135deg, #166534, #052e16)", border: "#22c55e" },
    "petco" => { name: "Petco", background: "linear-gradient(135deg, #075985, #052e16)", border: "#38bdf8" },
    "home_depot" => { name: "The Home Depot", background: "linear-gradient(135deg, #c2410c, #431407)", border: "#fb923c" },
    "lowes" => { name: "Lowe's", background: "linear-gradient(135deg, #1e40af, #172554)", border: "#60a5fa" },
    "ebay" => { name: "eBay", background: "linear-gradient(115deg, #1d4ed8, #15803d 38%, #a16207 68%, #b91c1c)", border: "#60a5fa" },
    "prepaid_network" => { name: "Visa / Mastercard", background: "linear-gradient(120deg, #172554 0%, #172554 49%, #7f1d1d 51%, #431407 100%)", border: "#f97316" },
    "amc" => { name: "AMC Theatres", background: "linear-gradient(135deg, #b91c1c, #450a0a)", border: "#ef4444" },
    "macys" => { name: "Macy's", background: "linear-gradient(135deg, #991b1b, #18181b)", border: "#ef4444" },
    "apple" => { name: "Apple", background: "linear-gradient(135deg, #3f3f46, #18181b)", border: "#a1a1aa" },
    "best_buy" => { name: "Best Buy", background: "linear-gradient(135deg, #1e3a8a, #172554)", border: "#facc15" },
    "walmart" => { name: "Walmart", background: "linear-gradient(135deg, #1d4ed8, #172554)", border: "#facc15" },
    "costco" => { name: "Costco", background: "linear-gradient(135deg, #1e3a8a, #450a0a)", border: "#ef4444" },
    "whole_foods" => { name: "Whole Foods Market", background: "linear-gradient(135deg, #166534, #052e16)", border: "#86efac" },
    "walgreens" => { name: "Walgreens", background: "linear-gradient(135deg, #b91c1c, #450a0a)", border: "#ef4444" },
    "nike" => { name: "Nike", background: "linear-gradient(135deg, #27272a, #09090b)", border: "#f97316" },
    "airbnb" => { name: "Airbnb", background: "linear-gradient(135deg, #be123c, #500724)", border: "#fb7185" },
    "delta" => { name: "Delta", background: "linear-gradient(135deg, #1e3a8a, #450a0a)", border: "#ef4444" },
    "disney" => { name: "Disney", background: "linear-gradient(135deg, #1e40af, #111827)", border: "#60a5fa" },
    "netflix" => { name: "Netflix", background: "linear-gradient(135deg, #b91c1c, #18181b)", border: "#ef4444" },
    "doordash" => { name: "DoorDash", background: "linear-gradient(135deg, #b91c1c, #450a0a)", border: "#fb7185" },
    "chick_fil_a" => { name: "Chick-fil-A", background: "linear-gradient(135deg, #b91c1c, #450a0a)", border: "#ef4444" }
  }.freeze

  BRAND_ALIASES = {
    "ifly" => %w[ifly],
    "starbucks" => %w[starbucks],
    "dunkin" => ["dunkin", "dunkin donuts"],
    "chipotle" => %w[chipotle],
    "amazon" => %w[amazon],
    "topgolf" => ["topgolf", "top golf"],
    "ulta" => %w[ulta],
    "homegoods" => %w[homegoods tjmaxx tj maxx marshalls sierra homesense],
    "carvel" => %w[carvel],
    "bath_body_works" => ["bath & body works", "bath and body works", "bbw"],
    "grubhub" => %w[grubhub],
    "target" => %w[target],
    "sephora" => %w[sephora],
    "barnes_noble" => ["barnes & noble", "barnes and noble"],
    "petco" => %w[petco],
    "home_depot" => ["the home depot", "home depot"],
    "lowes" => ["lowe's", "lowes"],
    "ebay" => %w[ebay],
    "prepaid_network" => ["prepaid card", "visa", "mastercard", "master card"],
    "amc" => ["amc", "amc theatres", "amc theaters"],
    "macys" => ["macy's", "macys"],
    "apple" => %w[apple],
    "best_buy" => ["best buy"],
    "walmart" => %w[walmart],
    "costco" => %w[costco],
    "whole_foods" => ["whole foods", "whole foods market"],
    "walgreens" => %w[walgreens],
    "nike" => %w[nike],
    "airbnb" => %w[airbnb],
    "delta" => %w[delta],
    "disney" => %w[disney],
    "netflix" => %w[netflix],
    "doordash" => ["doordash", "door dash"],
    "chick_fil_a" => ["chick-fil-a", "chick fil a"]
  }.freeze

  AUTO_COLOR_THEMES = %w[evergreen ocean ruby violet rose teal gold].freeze

  def self.brand_theme_for(store_name)
    normalized_name = store_name.to_s.downcase.gsub(/[^a-z0-9]/, "")
    return "classic" if normalized_name.empty?

    BRAND_ALIASES.each do |theme, aliases|
      return theme if aliases.any? { |name| normalized_name.include?(name.downcase.gsub(/[^a-z0-9]/, "")) }
    end

    color_index = normalized_name.bytes.reduce(0) { |hash, byte| (hash * 31 + byte) % AUTO_COLOR_THEMES.length }
    AUTO_COLOR_THEMES[color_index]
  end

  def finish_config
    theme = color_theme == "auto" || color_theme.blank? ? self.class.brand_theme_for(store_name) : color_theme
    CARD_FINISHES[theme] || CARD_FINISHES[self.class.brand_theme_for(store_name)]
  end

  def expired?
    expiration_date.present? && expiration_date < Date.current
  end

  def expiring_soon?
    expiration_date.present? && !expired? && expiration_date <= Date.current + 30.days
  end

  def days_remaining
    return nil unless expiration_date.present?

    (expiration_date - Date.current).to_i
  end

  def masked_card_number
    raw = card_number.to_s.gsub(/\s+/, "")
    if raw.length <= 4
      "••••"
    else
      last4 = raw.last(4)
      "•••• •••• •••• #{last4}"
    end
  end

  def masked_pin
    "••••"
  end

  def clean_card_number
    card_number.to_s.gsub(/\s+/, "")
  end

  def has_balance?
    balance.present? && balance > 0
  end
end
