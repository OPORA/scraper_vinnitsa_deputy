require 'data_mapper'
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'])
class People
  include DataMapper::Resource

  property :id,           Serial    # An auto-increment integer key
  property :rada_id,      Integer
  property :first_name,   String
  property :middle_name,  String
  property :last_name,    String
  property :photo_url,    Text    # A varchar type string, for short strings
  property :fraction,     String
  property :okrug,        Integer
  property :update_mp,    Integer
  property :created_at,   DateTime  # A DateTime, for any date you might like.
  property :updated_at,   DateTime
end
DataMapper.finalize


