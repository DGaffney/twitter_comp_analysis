class ChosenThread
  include DataMapper::Resource
  property :id, Serial
  property :count, Serial
  property :source_type, Serial
  property :first_text, Text
  property :identified, String
  property :mentioned, Text
  property :start, DateTime
  property :end, DateTime
  property :notes, Text
  property :duration, Serial
  property :duration_str, String
end
