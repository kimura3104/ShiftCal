require 'googleauth/stores/redis_token_store'

class AuthController < ApplicationController
  def google_oauth2_callback
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new(url: Rails.application.config.redis_url))
    authorization = Google::Auth::UserAuthorizer.new(client_id, Google::Apis::CalendarV3::AUTH_CALENDAR, token_store, ENV['GOOGLE_CALLBACK_URL'])
    if params[:code] !=nil
      credentials = authorization.get_credentials_from_code(code: params[:code])
      authorization.store_credentials(current_user.email, credentials)
    end
    redirect_to '/calendars/create_calendar'
  end
end
