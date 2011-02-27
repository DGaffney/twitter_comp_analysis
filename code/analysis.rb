require 'fastercsv'

class Analysis
  def self.to_csv(dataset, filename, path="analytical_results/")
    path.split("/").repack {|piece| `mkdir #{piece.join("/")}`}
    keys, values = dataset.first.keys, dataset.first.values
    FasterCSV.open(path+filename, "w") do |csv|
      csv << keys
      csv << values
      dataset.each do |row|
        csv << keys.collect{|key| row[key].to_s}
      end
    end
  end
end
