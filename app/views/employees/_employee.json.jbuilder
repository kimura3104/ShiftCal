json.extract! employee, :id, :name, :password, :wage, :user_id, :created_at, :updated_at
json.url employee_url(employee, format: :json)
