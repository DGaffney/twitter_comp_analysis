class Lock
  include DataMapper::Resource
  property :id, Serial
  property :classname, String
  property :with_id, Integer
  property :instance_id, String#, :length => 40
end

module Locking
  def locked(opts=:all, where="")
    table = self.to_s.to_table
    where = " AND #{where}" if !where.empty?
    sql = "SELECT * FROM `#{table}` WHERE (`#{table}`.`id` IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{self.to_s}')#{where})"
    sql += " LIMIT 1" if opts == :first
    result = repository(:default).adapter.select(sql)
    return opts == :first ? object_from(result.first) : objects_from(result)
    # if opts == :first
    #   r = result.first
    #   hash = {}
    #   r.members.each_index {|i| hash[r.members[i]] = r.values[i] }
    #   return Self.new(hash)
    # else
    #   objs = []
    #   for r in results
    #     hash = {}
    #     r.members.each_index {|i| hash[r.members[i]] = r.values[i] }
    #     objs << Self.new(hash)
    #   end
    #   return objs
    # end
  end
  
  def unlocked(opts=:all, where="")
    table = self.to_s.to_table
    where = " AND #{where}" if !where.empty?
    sql = "SELECT * FROM `#{table}` WHERE (`#{table}`.`id` NOT IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{self.to_s}')#{where})"
    sql += " LIMIT 1" if opts == :first
    result = repository(:default).adapter.select(sql)
    # return result
    return opts == :first ? object_from(result.first) : objects_from(result)
  end
  
  protected
  
  def object_from(struct)
    return nil if struct.nil?
    attrs = self.properties.collect {|p| p.name.to_s }
    hash = {}
    struct.members.each_index {|i| hash[struct.members[i]] = struct.values[i] if attrs.include?(struct.members[i]) }
    return self.new(hash)
  end
  
  def objects_from(structs)
    return [] if structs.empty?
    attrs = self.properties.collect {|p| p.name.to_s }
    objs = []
    for struct in structs
      hash = {}
      struct.members.each_index {|i| hash[struct.members[i]] = struct.values[i] if attrs.include?(struct.members[i]) }
      objs << self.new(hash)
    end
    return objs
  end
  
end

DataMapper::Model.append_extensions(Locking)