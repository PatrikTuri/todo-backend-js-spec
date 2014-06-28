require 'sinatra'
require 'json'
require 'securerandom'

class TodoRepo
  def initialize
    @store = {}
  end

  def add_todo(todo)
    todo = todo.clone
    uid = SecureRandom.uuid
    todo["uid"] = uid
    @store[uid] = todo
    todo
  end

  def [](uid)
    @store[uid]
  end
end

class TodoApp < Sinatra::Base
  def initialize
    @repo = TodoRepo.new
  end

  def json_body
    JSON.parse(request.env["rack.input"].read)
  end

  def todo_url(todo)
    "/todos/#{todo.fetch("uid")}"
  end

  get '/' do
    "[]"
    # content_type :json
  end
  
  post "/" do
    new_todo = json_body
    stored_todo = @repo.add_todo(new_todo)


    headers["Location"] = todo_url(stored_todo)
    status 201
    # content_type :json
    new_todo.to_json
  end

  get "/todos/:todo_uid" do
    todo = @repo[params[:todo_uid]]
    
    halt 404 if todo.nil?

    todo.to_json
  end
end