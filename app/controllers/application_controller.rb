class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Every controller that inherits from this one (i.e. all of them) will
  # run require_login before every action, UNLESS that controller opts out
  # with skip_before_action (like SessionsController does).
  before_action :require_login

  private

  # Memoized lookup: the ||= means "only hit the database once per request,
  # even if current_user gets called multiple times while rendering a view".
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # helper_method exposes this controller method to the views too, so you
  # can write current_user.name directly in .html.erb files.
  helper_method :current_user

  # The actual gatekeeper: if there's no logged-in user, bounce to login
  # instead of letting the request reach the controller action at all.
  def require_login
    redirect_to login_path, alert: "Please log in first" unless current_user
  end

  # Usage in a controller: before_action { require_role(:head) }
  # *roles is a splat - lets you call require_role(:hr, :head) too.
  # head :forbidden returns a bare 403 response with no body.
  def require_role(*roles)
    head :forbidden unless roles.map(&:to_s).include?(current_user.role)
  end
end
