require 'googleauth/stores/redis_token_store'

class CalendarsController < ApplicationController
  def create_calendar
    return if current_user.calendar_id != nil
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorization
    calendar = Google::Apis::CalendarV3::Calendar.new(summary: "ShiftCal")
    if service.authorization.nil?
    else
      result = service.insert_calendar(calendar)
      logger.debug(result)
      logger.debug(result.id)
      #current_user.calendar_id = calendar_id
      current_user.update(calendar_id: result.id)
      logger.debug("set calendar_id!!!!!!")
      redirect_to root_path
    end
  end

  def list_events(time_min = nil, time_max = nil)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorization
    return nil if service.authorization == nil
    calendar_id = current_user.calendar_id
    if calendar_id.nil?
      create_calendar
    else
      begin
        result = service.list_events(calendar_id, time_min: time_min, time_max: time_max, single_events: true)
      rescue
        result = service.list_calendar_lists
        logger.debug(result.items.map{|e| e.id})
        if result.items.map{|e| e.id}.include?(calendar_id)
        else
          create_calendar
        end
      end
    end
  end

  def record
    #calendar = Google::Apis::CalendarV3::Calendar.new(summary: params[:name])
    #service.insert_calendar(calendar)
    @events_list = list_events(Time.zone.now.beginning_of_month.rfc3339, Time.zone.now.end_of_month.rfc3339)
    start_time = Time.zone.now
    start_time_iso8601 = start_time.strftime('%Y-%m-%dT%H:%M:%SZ')
    today = start_time.to_date
    logger.debug(today)
    end_time = start_time + 1.hours
    end_time_iso8601 = end_time.strftime('%Y-%m-%dT%H:%M:%SZ')
    summary = Employee.find(params[:employee_id]).name
    #logger.debug(@events_list.items.select {|e| e.summary == summary})
    #logger.debug(@events_list.items.select {|e| e.summary == summary}.map{|e| e.start.date_time})
    #logger.debug(@events_list.items.select {|e| e.summary == summary}.map{|e| e.start.date_time.to_date})
    #logger.debug(@events_list.items.select {|e| e.summary == summary}.map{|e| e.start.date_time.to_date}.include?(today))
    event = @events_list.items.select{|e| e.summary == summary && e.start.date_time != nil}.find{|e| e.start.date_time.to_date == today}
    logger.debug(event)
      #if @events_list != nil && @events_list.items.map{|e| e.summary}.include?(summary)
    if @events_list != nil && event != nil
      if params[:commit] == '出勤'
        #logger.debug(event.start.date_time)
        event.start.date_time = start_time_iso8601
        #logger.debug(event.start.date_time)
        update_event(event)
      elsif params[:commit] == '退勤'
        #logger.debug(event.end.date_time)
        event.end.date_time = start_time_iso8601
        #logger.debug(event.end.date_time)
        update_event(event)
      end
    else
      insert_event(start_time_iso8601, end_time_iso8601, summary) if params[:commit] == '出勤'
      #logger.debug("insert") if params[:commit] == '出勤'
    end
  end

  def insert_event(start_time, end_time, summary)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorization
    logger.debug("credential is nil!!!!!!")
    return nil if service.authorization == nil
    logger.debug("credential not nil!!!!!!")
    calendar_id = current_user.calendar_id
    event = Google::Apis::CalendarV3::Event.new({
        summary: summary,
        start: {
            date_time: start_time,
            time_zone: 'Asia/Tokyo',
        },
        end: {
            date_time: end_time,
            time_zone: 'Asia/Tokyo'
        },
    })
    result = service.insert_event(calendar_id, event)
  end

  def update_event(event)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorization
    return nil if service.authorization == nil
    calendar_id = current_user.calendar_id
    result = service.update_event(calendar_id, event.id, event)
  end

  private

  def authorization
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new(url: Rails.application.config.redis_url))
    #token_store = Google::Auth::TokenStore.new
    authorizer = Google::Auth::UserAuthorizer.new(client_id, Google::Apis::CalendarV3::AUTH_CALENDAR, token_store, ENV['GOOGLE_CALLBACK_URL'])
    #user_id = current_user.id
    #credentials = authorizer.get_credentials(user_id.to_s)
    credentials = authorizer.get_credentials(current_user.email)
    logger.debug(credentials)
    if credentials.nil?
      # 認証が必要な場合は、Googleの認証画面にリダイレクトします。
      # 以下は例です。必要に応じて変更してください。
      callback_url = url_for(action: :google_oauth2_callback, controller: :auth)
      redirect_uri = URI.join(request.base_url, callback_url).to_s
      redirect_to authorizer.get_authorization_url
      nil
    else
      credentials
    end
  end
end
