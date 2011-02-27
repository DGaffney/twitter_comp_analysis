class Profile < ActiveRecord::Base
  r = ActiveRecord::Base.connection.execute("select p_screen_name, p_type from profiles").all_hashes
  @@index = {}
  r.each {|h| @@index[h["p_screen_name"].downcase] = h["p_type"].to_i }

  def self.classification(screen_name)
    return @@index[screen_name] || @@index.values.uniq.sort.last.to_i+1
  end

end
