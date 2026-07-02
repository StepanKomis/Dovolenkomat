class SessionsController < ApplicationController
  # Logging in requires NOT being logged in already, so this bypasses the
  # global require_login before_action we're adding to ApplicationController.
  # Without this line you could never reach the login form, because
  # require_login would redirect you... to the login form.
  skip_before_action :require_login

  # GET /session/new -> just renders the login form (app/views/sessions/new.html.erb)
  def new
  end

  # POST /session -> the form submits here with params[:email] and params[:password]
  def create
    # find_by returns nil if no user has that email, instead of raising.
    # &. (safe navigation) means: if user is nil, skip calling .authenticate
    # and just evaluate to nil, instead of crashing with NoMethodError.
    user = User.find_by(email: params[:email])&.authenticate(params[:password])

    if user
      # session is a signed cookie Rails manages for you. Storing the id
      # here is what "being logged in" MEANS in this app - every later
      # request, we read session[:user_id] back out to know who's asking.
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in as #{user.name}"
    else
      # re-render the same form instead of redirecting, so the error
      # shows without losing the fact we're on the login page
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /session -> logout
  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out"
  end
end
