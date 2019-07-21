# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'sqlite3'
require 'active_record'

######################################################################################
# active record configuration
######################################################################################
# Rails will do this for you automatically.
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'database.sqlite3'
)
ActiveRecord::Base.logger = Logger.new(STDERR)

class InteriorDesignStyle < ActiveRecord::Base
  has_many :furnitures, dependent: :destroy
end
class Furniture < ActiveRecord::Base
  belongs_to :interior_design_style, foreign_key: 'interior_design_style_id'
end

######################################################################################
# interior design style routes
######################################################################################

get '/' do
  redirect to('/styles')
end

get '/styles' do
  @interior_design_style = InteriorDesignStyle.all
  erb :"styles/home"
end

get '/styles/new' do
  erb :"styles/new"
end

post '/styles' do
  interior_design_style = InteriorDesignStyle.new
  interior_design_style.name = params[:name]
  interior_design_style.description = params[:description]
  interior_design_style.image = params[:image]
  interior_design_style.save
  redirect to("/styles/#{interior_design_style.id}")
end

get '/styles/:id' do
  @style = InteriorDesignStyle.find params[:id]
  erb :"styles/show"
end

get '/styles/:id/edit' do
  @style = InteriorDesignStyle.find params[:id]
  erb :"styles/edit"
end

post '/styles/:id' do
  interior_design_style = InteriorDesignStyle.find params[:id]
  interior_design_style.name = params[:name]
  interior_design_style.description = params[:description]
  interior_design_style.image = params[:image]
  interior_design_style.save
  redirect to("/styles/#{params[:id]}")
end

get '/styles/:id/delete' do
  interior_design_style = InteriorDesignStyle.find params[:id]
  interior_design_style.destroy
  redirect to('/styles')
end

######################################################################################
# furnitures routes
######################################################################################

get '/furnitures' do
  @furnitures = Furniture.all
  erb :"furnitures/home"
end

get '/furnitures/new' do
  @styles = InteriorDesignStyle.all

  erb :"furnitures/new"
end

post '/furnitures' do
  furniture = Furniture.new
  furniture.name = params[:name]
  furniture.description = params[:description]
  furniture.image = params[:image]
  furniture.interior_design_style_id = params[:interior_design_style_id]
  furniture.save
  redirect to("/furnitures/#{furniture.id}")
end

get '/furnitures/:id' do
  @furniture = Furniture.find params[:id]
  @interior_design_style_name = @furniture.interior_design_style.name

  erb :"furnitures/show"
end

get '/furnitures/:id/edit' do
  @furniture = Furniture.find params[:id]
  @styles = InteriorDesignStyle.all
  @interior_design_style_id = @furniture.interior_design_style.id
  erb :"furnitures/edit"
end

post '/furnitures/:id' do
  furniture = Furniture.find params[:id]
  furniture.name = params[:name]
  furniture.description = params[:description]
  furniture.image = params[:image]
  furniture.interior_design_style_id = params[:interior_design_style_id]
  furniture.save
  redirect to("/furnitures/#{params[:id]}")
end

get '/furnitures/:id/delete' do
  furniture = Furniture.find params[:id]
  furniture.destroy
  redirect to('/furnitures')
end

after do
  ActiveRecord::Base.connection.close
end
