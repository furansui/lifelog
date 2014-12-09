class Timelog < ActiveRecord::Base
  belongs_to :category
  validates :event, presence: true, length: {minimum: 3}
  validates :category_id, presence: true
  validates :time, :uniqueness => {:scope => :category_id, :message => 'same time should have unique event name'}
  before_validation {|timelog| timelog.time = timelog.time.in_time_zone.change(sec: 0) }

  # #to assign default category
  # after_initialize :init
  # def init
  #   category_id ||= 1
  # end

  def self.to_csv(options = {}) 
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |category|
        csv << category.attributes.values_at(*column_names)
      end
    end
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

  #find category and create
  def self.parse(row_hash)
    regex = /(\S+)/
    if row_hash[:event]
      matches = row_hash[:event].match regex
      else
      raise "error on #{row_hash}"
    end
    
    #check the first word
    if matches        
      cat = Category.find_by_shortcut(matches[1].downcase)
      if cat.nil?
        cat = Category.find_by_name(matches[1].downcase)
      end
    end
    
    #if category is not found, use id 1
    if cat
      id = cat.id
    else
      id = Category.find_by_name("unknown").id
    end
    
    timelog = Timelog.new(time: row_hash[:time], event: row_hash[:event], category_id: id)
    timelog.save
    timelog
  end

  #import csv
  def self.import(file)    
    CSV.foreach((file.class==String)?file:file.path, headers: true) do |row|      
      row_hash = row.to_hash
      begin
        Timelog.parse({event: row_hash["event"], time: row_hash["time"]})
      rescue Exception
        next
      end
    end                
    self.duration()
  end

  def self.summarize(options)
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| h3[k3]=0 } } }
    summary[:head][:range][:begin] = options[:begin]
    summary[:head][:range][:end] = options[:end]
    summary[:head][:total][:inseconds] = 0 #number of total duration
    summary[:head][:total][:days] = 0 #indicates number of days to show on graph
    summary[:dates] = Array.new

    @sortedTimelog = Timelog.where("time >= ? AND time <= ? AND duration > 0", options[:begin],options[:end]).order("time")
    if !@sortedTimelog.empty?            
      currentDay = @sortedTimelog.first.time.beginning_of_day;
      currentDayi = 1;
      summary[:dates] << currentDay.strftime("%Y.%m.%d %a")

      summary[:row] = Array.new
      @sortedTimelog.each_with_index do |timelog,index|
        if timelog.time.beginning_of_day != currentDay
          currentDayi += 1
          currentDay = timelog.time.beginning_of_day
          summary[:dates] << currentDay.strftime("%Y.%m.%d %a")
        end

        thisrow = Hash.new
        thisrow[:index] = index
        thisrow[:catid] = timelog.category_id
        thisrow[:color] = Category.find_by_id(thisrow[:catid]).root.color
        thisrow[:duration] = timelog.duration
        thisrow[:id] = timelog.id
        thisrow[:time] = timelog.time
        thisrow[:event] = timelog.event

        #if over the midnight, create new row
        if (timelog.time + timelog.duration) > timelog.time.end_of_day
          thisrow[:duration] = timelog.time.end_of_day - timelog.time          
          thisrow[:dayaccum] = timelog.time - timelog.time.beginning_of_day
          thisrow[:day] = currentDayi #indicates the day this record belong to on the graph        
          summary[:row] << thisrow
          
          extrarow = Hash.new
          extrarow[:index] = index
          extrarow[:color] = Category.find_by_id(timelog.category_id).root.color
          extrarow[:duration] = timelog.duration - thisrow[:duration]
          extrarow[:time] = (timelog.time + 1.day).beginning_of_day
          extrarow[:event] = timelog.event
          extrarow[:id] = timelog.id

          extrarow[:dayaccum] = 0
          currentDayi += 1
          currentDay = (timelog.time + 1.day).beginning_of_day
          summary[:dates] << currentDay.strftime("%Y.%m.%d %a")
          extrarow[:day] = currentDayi #indicates the day this record belong to on the graph        
          summary[:row] << extrarow

          summary[:head][:total][:inseconds] += thisrow[:duration]
          summary[:head][:total][:inseconds] += extrarow[:duration]
        else
          thisrow[:dayaccum] = timelog.time - timelog.time.beginning_of_day
          thisrow[:day] = currentDayi #indicates the day this record belong to on the graph        
          summary[:row] << thisrow
          summary[:head][:total][:inseconds] += thisrow[:duration]
        end
      end

      summary[:head][:prev][:remaining] = @sortedTimelog.first.time - @sortedTimelog.first.time.midnight
      if summary[:head][:prev][:remaining] > 0
        @prevDayTimelog = Timelog.where('time < ?', options[:begin]).order("time desc")
        if !@prevDayTimelog.empty? 
          thisrow = Hash.new
          thisrow[:catid] = @prevDayTimelog.first.category_id
          thisrow[:color] = Category.find_by_id(thisrow[:catid]).root.color
          thisrow[:duration] = summary[:head][:prev][:remaining]
          thisrow[:time] = @sortedTimelog.last.time.midnight
          thisrow[:dayaccum] = 0
          thisrow[:event] = @prevDayTimelog.first.event
          thisrow[:id] = @prevDayTimelog.first.id
          thisrow[:day] = 1
          summary[:row] << thisrow
        end
      end
      summary[:head][:total][:days] = currentDayi

    end #if not empty
    summary
  end
end
