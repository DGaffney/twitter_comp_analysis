class ChosenThread
  include DataMapper::Resource
  property :id, Serial
  property :count, Integer
  property :source_type, Integer
  property :first_text, Text
  property :identified, String
  property :mentioned, Text
  property :start, DateTime
  property :end, DateTime
  property :notes, Text
  property :duration, Integer
  property :duration_str, String
end
