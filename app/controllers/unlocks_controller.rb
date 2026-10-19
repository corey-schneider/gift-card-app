class UnlocksController < ApplicationController
  def create
    pin = params[:pin].to_s.strip

    if pin.blank?
      flash.now[:alert] = "Please enter a PIN code"
      return respond_with_auth_failure
    end

    if !AppSetting.passcode_set?
      # First-time setup
      AppSetting.set_passcode(pin)
      session[:unlocked_until] = 5.minutes.from_now.to_i
      flash[:notice] = "Master PIN set! Vault unlocked for 5 minutes."
      return respond_with_auth_success
    end

    if AppSetting.authenticate(pin)
      session[:unlocked_until] = 5.minutes.from_now.to_i
      flash[:notice] = "Vault unlocked for 5 minutes."
      respond_with_auth_success
    else
      flash.now[:alert] = "Incorrect PIN code. Please try again."
      respond_with_auth_failure
    end
  end

  def destroy
    session.delete(:unlocked_until)
    flash[:notice] = "Vault locked."

    respond_to do |format|
      format.turbo_stream { redirect_to root_path }
      format.html { redirect_to root_path }
    end
  end

  def update_passcode
    current_pin = params[:current_pin].to_s.strip
    new_pin = params[:new_pin].to_s.strip

    if AppSetting.passcode_set? && !AppSetting.authenticate(current_pin)
      redirect_to root_path, alert: "Current PIN is incorrect."
      return
    end

    if new_pin.blank? || new_pin.length < 4
      redirect_to root_path, alert: "New PIN must be at least 4 digits or characters."
      return
    end

    AppSetting.set_passcode(new_pin)
    session[:unlocked_until] = 5.minutes.from_now.to_i
    redirect_to root_path, notice: "Master PIN updated successfully!"
  end

  private

  def respond_with_auth_success
    respond_to do |format|
      format.turbo_stream { redirect_to root_path }
      format.html { redirect_to root_path }
    end
  end

  def respond_with_auth_failure
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "unlock_modal_content",
          partial: "unlocks/modal_content",
          locals: { error: flash.now[:alert], first_time: !AppSetting.passcode_set? }
        ), status: :unprocessable_entity
      end
      format.html { redirect_to root_path, alert: flash.now[:alert] }
    end
  end
end
