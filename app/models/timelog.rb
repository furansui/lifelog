class Timelog < ActiveRecord::Base
  belongs_to :category
  validates :event, presence: true, length: {minimum: 3}
  validates :category_id, presence: true

  #to assign default category
  after_initialize :init
  def init
    self.category_id ||= 1
  end

  def self.duration()
    @timelogs = Timelog.all.order("time desc")
    @timelogs.each_with_index do |timelog,index|
      if index==0
        timelog.duration = Time.zone.now - timelog.time
      else
        timelog.duration =  @timelogs[index-1].time - timelog.time
      end
      timelog.save
    end
  end

  #import csv
  def self.import(file)    
    CSV.foreach(file.path, headers: true) do |row|      
      row_hash = row.to_hash

      regex = /(\S+)/
      if row_hash["event"]
        matches = row_hash["event"].match regex
      else
        raise "error on #{row_hash}"
      end
      
      #check the first word
      if matches        
        if matches[1].length <= 3
          #if length is 3, get id by shortcut
          cat = Category.find_by_shortcut(matches[1].downcase)
        else
          #else get id by event itself
          cat = Category.find_by_name(matches[1].downcase)
        end
      end

      #if category is not found, use id 1
      if cat
        id = cat.id
      else
        id = Category.find_by_name("unknown").id
      end

      timelog = Timelog.new(time: row_hash["time"], event: row_hash["event"], category_id: id)
      timelog.save!
    end                
    self.duration()
  end

  def self.summarize(options)
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| h3[k3]=0 } } }
    @sortedTimelog = Timelog.where(:time => options[:range]).order("time desc")

    summary[:head][:range][:start] = options[:range].begin
    summary[:head][:range][:end] = options[:range].end

    @sortedTimelog.each_with_index do |timelog,index|        
      if index != 0
        summary[:row][index][:duration] = (@sortedTimelog[index-1].time - timelog.time).to_i/60
      end
      summary[:row][index][:timelog] = timelog
    end
    summary
  end
end
