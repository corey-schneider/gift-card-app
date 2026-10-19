class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :session_unlocked?, :remaining_unlock_seconds, :passcode_configured?

  def session_unlocked?
    session[:unlocked_until].present? && Time.current.to_i < session[:unlocked_until].to_i
  end

  def remaining_unlock_seconds
    return 0 unless session_unlocked?

    [session[:unlocked_until].to_i - Time.current.to_i, 0].max
  end

  def passcode_configured?
    AppSetting.passcode_set?
  end
end
