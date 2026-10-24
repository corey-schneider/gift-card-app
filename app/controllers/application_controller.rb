class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # NOTE: stale_when_importmap_changes is intentionally removed.
  # This app is session-dependent (vault lock/unlock state). If ETag caching were enabled,
  # Turbo would receive a 304 Not Modified after a redirect and render stale cached HTML
  # (e.g. still showing "Locked" after a successful unlock). Assets are fingerprinted
  # via Propshaft so JS/CSS cache-busting does not require ETags on HTML responses.
  before_action :set_no_cache_headers

  private

  def set_no_cache_headers
    response.headers["Cache-Control"] = "no-store"
  end

  public

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
