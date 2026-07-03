class SettingsController < ApplicationController
  before_action { require_role(:head) }

  def edit
    @setting = Setting.current
  end

  def update
    @setting = Setting.current
    if @setting.update(setting_params.merge(updated_by: current_user))
      redirect_to edit_settings_path, notice: "Settings updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:max_concurrent_vacationers)
  end
end
