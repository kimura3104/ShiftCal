class PagesController < CalendarsController
  before_action :authenticate_user!, only: [:dashboard, :admin, :attendance]

  def dashboard
  end

  def admin
  end

  def attendance
    @employees = Employee.all

    #render controller: 'calendars', action: 'list_events'
    @events_list = list_events
    #logger.debug(@events_list)
    #logger.debug(@events_list.items.map{|e| e.summary})
    #logger.debug(@events_list.items.map{|e| (e.end.date_time - e.start.date_time).to_f * 24})
  end

  def tally
    @employees = Employee.all
    @events_list = list_events.items

    @attendance_counts = {}
    @attendance_hours = {}
    @attendance_wage = {}
    @employees.each do |employee|
      extracted_events = @events_list.select {|e| e.summary == employee.name}
      @attendance_counts[employee.id] = extracted_events.length
      @attendance_hours[employee.id] = extracted_events
      .map{|e| (e.end.date_time - e.start.date_time).to_f * 24}.sum
      @attendance_wage[employee.id] = (@attendance_hours[employee.id] * employee.wage).to_i
    end
    
=begin
    start_time = Time.now.prev_month.beginning_of_month.utc.iso8601
    end_time = Time.now.prev_month.end_of_month.utc.iso8601

    if params[:employee_id]
      # 従業員を1人選択した場合の処理
      @employee = Employee.find(params[:employee_id])
      @events = @employee.events.between(start_time, end_time)
    else
      # 全従業員の処理
      #@events = Event.between(start_time, end_time)
    end

    # 集計結果を計算する
    @attendance_counts = {}
    @attendance_hours = {}
    @events.each do |event|
      employee_id = event.employee_id
      @attendance_counts[employee_id] ||= 0
      @attendance_counts[employee_id] += 1
      @attendance_hours[employee_id] ||= 0
      @attendance_hours[employee_id] += (event.end_time - event.start_time) / 3600.0
    end
=end
  end

  def record
    logger.debug(params[:employee_id])
    logger.debug(Employee.find(params[:employee_id]).name)
    logger.debug(params[:commit])
    logger.debug("clock in!!!") if params[:commit] == '出勤'
    logger.debug("clock out!!!") if params[:commit] == '退勤'
  end
end
