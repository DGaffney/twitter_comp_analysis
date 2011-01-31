require 'fastercsv'

class Analysis
  def to_csv(dataset, filename, path="analytical_results/")
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

users = ["cnnbrk","nytimes","mashable","BreakingNews","TheOnion","TIME","BBCBreaking","TechCrunch","andersoncooper","GStephanopoulos","Newsweek","peoplemag","WSJ","HuffingtonPost","eonline","davidgregory","wired","TheEconomist","NickKristof","GMA","leolaporte","TweetSmarter","sanjayguptaCNN","NBA","Nightline"]