require 'sinatra'
require 'sinatra/json'
require_relative 'lib/people'
set :protection, except: [:json_csrf]

get '/' do
  hash =[]
  people = People.all
  people.map{|mp| hash << {rada_id: mp.rada_id, full_name: mp.full_name, first_name: mp.first_name, middle_name: mp.middle_name,  last_name: mp.last_name, fraction: mp.fraction, okrug: mp.okrug, photo_url: mp.photo_url, end_date: mp.end_date}}
  json hash
end