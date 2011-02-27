class Tweet < ActiveRecord::Base
  
  def author
    return screen_name
  end
  
  def pubdate
    return created_at
  end
end
