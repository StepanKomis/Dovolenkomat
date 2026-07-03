class DecisionsController < ApplicationController
  before_action :set_vacation_request
  before_action :authorize_stage!

  def create
    approved = decision_params[:outcome] == "approved"
    comment  = decision_params[:comment]

    success =
      if current_user.hr?
        @vacation_request.record_hr_decision!(by: current_user, approved: approved, comment: comment)
      else
        @vacation_request.record_head_decision!(by: current_user, approved: approved, comment: comment)
      end

    if success
      redirect_to @vacation_request, notice: "Decision recorded"
    else
      redirect_to @vacation_request, alert: @vacation_request.errors.full_messages.to_sentence
    end
  end

  private

  def set_vacation_request
    @vacation_request = VacationRequest.find(params[:vacation_request_id])
  end

  def authorize_stage!
    allowed = (current_user.hr? && @vacation_request.hr_status_pending?) ||
              (current_user.head? && @vacation_request.head_status_pending? &&
               !@vacation_request.hr_status_rejected?)
    head :forbidden unless allowed
  end

  def decision_params
    params.require(:decision).permit(:outcome, :comment)
  end
end
