module CalendarHelper
  CalendarDay = Struct.new(:date, :in_month, :requests)

  def self.grid_range(year, month)
    first = Date.new(year, month, 1)
    first.beginning_of_week(:monday)..first.end_of_month.end_of_week(:monday)
  end

  def calendar_weeks(year:, month:, vacation_requests:)
    requests_by_date = Hash.new { |h, k| h[k] = [] }
    vacation_requests.each do |vr|
      (vr.start_date..vr.end_date).each { |d| requests_by_date[d] << vr }
    end

    CalendarHelper.grid_range(year, month).map { |date|
      CalendarHelper::CalendarDay.new(date, date.month == month, requests_by_date[date])
    }.each_slice(7).to_a
  end
end
