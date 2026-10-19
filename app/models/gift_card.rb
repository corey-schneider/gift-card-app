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

  # Understated, classic, mature card finishes (no loud casino gradients)
  CARD_FINISHES = {
    "classic" => { name: "Charcoal Matte", bg: "bg-neutral-900", border: "border-neutral-800", subtle_badge: "bg-neutral-800 text-neutral-300" },
    "navy"    => { name: "Midnight Navy",  bg: "bg-slate-900",   border: "border-slate-800",   subtle_badge: "bg-slate-800 text-slate-300" },
    "stone"   => { name: "Warm Stone",     bg: "bg-stone-900",   border: "border-stone-800",   subtle_badge: "bg-stone-800 text-stone-300" },
    "zinc"    => { name: "Obsidian Black", bg: "bg-zinc-950",    border: "border-zinc-800",    subtle_badge: "bg-zinc-800 text-zinc-300" },
    "forest"  => { name: "Forest Pine",    bg: "bg-emerald-950/60", border: "border-emerald-900/50", subtle_badge: "bg-emerald-900/40 text-emerald-300" }
  }.freeze

  def finish_config
    CARD_FINISHES[color_theme] || CARD_FINISHES["classic"]
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
