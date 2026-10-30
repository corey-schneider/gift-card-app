class GiftCardsController < ApplicationController
  before_action :set_gift_card, only: %i[show edit update destroy toggle_redeemed]

  def index
    load_index

    respond_to do |format|
      format.html
      format.turbo_stream { render_index_turbo_stream }
    end
  end

  def merchant_suggestions
    render json: GiftCard.merchant_suggestions(params[:q])
  end

  def show
  end

  def new
    @gift_card = GiftCard.new(balance: 0.0, color_theme: "auto", currency: "USD")
  end

  def edit
  end

  def create
    @gift_card = GiftCard.new(gift_card_params)

    if @gift_card.save
      respond_after_save("#{@gift_card.store_name} card was successfully added!")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @gift_card.update(gift_card_params)
      respond_after_save("#{@gift_card.store_name} card was updated!")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    store = @gift_card.store_name
    @gift_card.destroy
    redirect_to root_path, status: :see_other, notice: "#{store} card was removed."
  end

  def toggle_redeemed
    @gift_card.update(redeemed: !@gift_card.redeemed)
    status_text = @gift_card.redeemed? ? "marked as redeemed" : "marked as active"

    respond_to do |format|
      format.turbo_stream do
        redirect_to root_path(status: params[:status], sort: params[:sort], q: params[:q]),
                    status: :see_other,
                    notice: "#{@gift_card.store_name} #{status_text}."
      end
      format.html do
        redirect_to root_path(status: params[:status], sort: params[:sort], q: params[:q]),
                    status: :see_other,
                    notice: "#{@gift_card.store_name} #{status_text}."
      end
    end
  end

  private

  def load_index
    @current_sort = params[:sort].presence || "expiring_first"
    @current_status = params[:status].presence || "active"
    @search_query = params[:q].to_s.strip

    cards = GiftCard.all
    cards = cards.filter_status(@current_status)
    cards = cards.search(@search_query) if @search_query.present?
    @gift_cards = cards.by_sort(@current_sort)

    @total_active_balance = GiftCard.active.where.not(balance: nil).sum(:balance)
    @active_count = GiftCard.active.count
    @voucher_count = GiftCard.active.where(balance: [nil, 0]).count
    @expiring_soon_count = GiftCard.active.where(
      "expiration_date IS NOT NULL AND expiration_date >= ? AND expiration_date <= ?",
      Date.current,
      Date.current + 30.days
    ).count
  end

  def respond_after_save(notice)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice
        load_index
        render_index_turbo_stream
      end
      format.html do
        redirect_to root_path, status: :see_other, notice: notice
      end
    end
  end

  def render_index_turbo_stream
    page = render_to_string(template: "gift_cards/index", formats: [:html], layout: false)

    render turbo_stream: [
      turbo_stream.replace("app-content", page),
      turbo_stream.update("flash-messages", partial: "layouts/flash_messages")
    ]
  end

  def set_gift_card
    @gift_card = GiftCard.find(params[:id])
  end

  def gift_card_params
    params.require(:gift_card).permit(
      :store_name,
      :card_number,
      :pin,
      :balance,
      :value_description,
      :currency,
      :expiration_date,
      :booking_url,
      :redeemed,
      :color_theme,
      :notes
    )
  end
end
