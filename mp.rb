require 'sinatra'
require 'sinatra/json'
require_relative 'lib/people'

get '/' do
  hash =[]
  people = People.all(:update_mp.not => 3)
  people.map{|mp| hash << {rada_id: mp.rada_id, first_name: mp.first_name, middle_name: mp.middle_name,  last_name: mp.last_name, fraction: mp.fraction, okrug: mp.okrug, photo_url: mp.photo_url}}
  json hash
end