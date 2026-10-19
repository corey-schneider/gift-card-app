class GiftCard < ApplicationRecord
  # Encrypt sensitive card details at rest (AES-256-GCM)
  encrypts :card_number
  encrypts :pin

  validates :store_name, presence: true, length: { maximum: 100 }
  validates :card_number, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

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
      order(balance: :desc, store_name: :asc)
    when "amount_asc"
      order(balance: :asc, store_name: :asc)
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
    where("LOWER(store_name) LIKE :term OR LOWER(notes) LIKE :term", term: term)
  }

  COLOR_THEMES = {
    "emerald" => { name: "Emerald Mint", gradient: "from-emerald-700 via-teal-800 to-slate-900", border: "border-emerald-500/30", text_accent: "text-emerald-400", badge_bg: "bg-emerald-500/20 text-emerald-300" },
    "indigo"  => { name: "Indigo Night", gradient: "from-indigo-700 via-blue-900 to-slate-950", border: "border-indigo-500/30", text_accent: "text-indigo-400", badge_bg: "bg-indigo-500/20 text-indigo-300" },
    "violet"  => { name: "Violet Velvet", gradient: "from-purple-700 via-violet-900 to-slate-950", border: "border-purple-500/30", text_accent: "text-purple-400", badge_bg: "bg-purple-500/20 text-purple-300" },
    "rose"    => { name: "Rose Ruby",    gradient: "from-rose-700 via-pink-900 to-slate-950", border: "border-rose-500/30", text_accent: "text-rose-400", badge_bg: "bg-rose-500/20 text-rose-300" },
    "amber"   => { name: "Sunset Gold",  gradient: "from-amber-600 via-orange-800 to-slate-950", border: "border-amber-500/30", text_accent: "text-amber-400", badge_bg: "bg-amber-500/20 text-amber-300" },
    "cyan"    => { name: "Cyan Breeze",  gradient: "from-cyan-700 via-blue-900 to-slate-950", border: "border-cyan-500/30", text_accent: "text-cyan-400", badge_bg: "bg-cyan-500/20 text-cyan-300" },
    "slate"   => { name: "Dark Titanium", gradient: "from-slate-700 via-zinc-800 to-slate-950", border: "border-slate-500/30", text_accent: "text-slate-300", badge_bg: "bg-slate-500/20 text-slate-300" }
  }.freeze

  def theme_config
    COLOR_THEMES[color_theme] || COLOR_THEMES["emerald"]
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
end
