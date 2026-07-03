class VacationRequestsController < ApplicationController
  before_action :set_vacation_request, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    month = parse_month_param
    @year, @month = month.year, month.month
    range = CalendarHelper.grid_range(@year, @month)

    scope = current_user.employee? ? current_user.vacation_requests : VacationRequest.all
    @vacation_requests = scope.where("start_date <= ? AND end_date >= ?", range.last, range.first)

    @prev_month = month.prev_month
    @next_month = month.next_month
  end

  def show; end

  def new
    @vacation_request = VacationRequest.new
  end

  def create
    @vacation_request = current_user.vacation_requests.build(vacation_request_params)
    apply_self_approval(@vacation_request)

    if @vacation_request.save
      redirect_to @vacation_request, notice: "Request submitted"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @vacation_request.update(vacation_request_params)
      redirect_to @vacation_request, notice: "Request updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vacation_request.destroy
    redirect_to vacation_requests_path, notice: "Request cancelled"
  end

  private

  def parse_month_param
    year  = params[:year].presence&.to_i  || Date.current.year
    month = params[:month].presence&.to_i || Date.current.month
    Date.new(year, month, 1)
  rescue ArgumentError
    Date.current.beginning_of_month
  end

  # HR/head requesters don't need peer review at their own level - see plan
  # doc for the self-approval + head-capacity-check rules.
  def apply_self_approval(request)
    return unless current_user.hr? || current_user.head?

    request.hr_status = :approved
    request.hr_decided_by = current_user
    request.hr_decided_at = Time.current
    request.hr_comment = "Self-approved (#{current_user.role})"

    return unless current_user.head?
    return if VacationRequest.would_exceed_capacity?(request.start_date, request.end_date)

    request.head_status = :approved
    request.head_decided_by = current_user
    request.head_decided_at = Time.current
    request.head_comment = "Self-approved (head)"
  end

  def set_vacation_request
    @vacation_request = VacationRequest.find(params[:id])
  end

  def authorize_owner!
    head :forbidden unless @vacation_request.user == current_user && @vacation_request.pending?
  end

  def vacation_request_params
    params.require(:vacation_request).permit(:start_date, :end_date, :reason)
  end
end
