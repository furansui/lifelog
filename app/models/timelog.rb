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
    summary[:head][:range][:begin] = options[:begin]
    summary[:head][:range][:end] = options[:end]
    summary[:head][:total][:inseconds] = 0 #number of total duration
    summary[:head][:total][:days] = 0 #indicates number of days to show on graph
    summary[:dates] = Array.new

    @sortedTimelog = Timelog.where(time: options[:begin]..options[:end]).order("time")
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
          #thisrow[:event] = timelog.event
          summary[:row] << thisrow
        end
      end
      summary[:head][:total][:days] = currentDayi

    end #if not empty
    summary
  end
end
