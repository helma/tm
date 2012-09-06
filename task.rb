require 'date'

module Todo
  class Task
    include Comparable

    attr_accessor :orig# :line

    # Creates a new task. The argument that you pass in must be a string.
    def initialize task
      @orig = task.chomp
    end

    def contexts
      @contexts ||= orig.scan(/(?:\s+|^)@\w+/).map { |item| item.strip }
    end

    def projects
      @projects ||= orig.scan(/(?:\s+|^)\+\w+/).map { |item| item.strip.sub(/\+/,'') }
    end

    def text
      @orig.sub(/^\d{4}-\d{2}-\d{2}/,'').strip
    end

    def scheduled_date
      Date.parse orig.match(/t:(\d{4}-\d{2}-\d{2})/)[1]
    rescue
    end

    def scheduled?
      date and !today? and !overdue?
    end

    def today?
      if scheduled_date 
        scheduled_date <= Date.today
      else
        false
      end
    end

    def create_date
      Date.parse orig.match(/^(\d{4}-\d{2}-\d{2})/)[1]
    rescue
    end

    def due_date
      Date.parse orig.match(/due:(\d{4}-\d{2}-\d{2})/)[1]
    rescue
    end

    def overdue?
      due_date ? due_date <= Date.today : false
    end

    def date
      Date.parse orig.match(/:(\d{4}-\d{2}-\d{2})/)[1]
    rescue
    end

    def line
      `grep -xn '#{@orig}' #{TODO}|cut -f1 -d ':'`.chomp
    end

    def print
      str = "#{"%02d" % line}  #{text}"
      if overdue?
        punched? ? str = "#{str} (#{duration.to_m} min)".red.underline :  str = str.red
      elsif today?
        punched? ? str = "#{str} (#{duration.to_m} min)".green.underline :  str = str.green
      elsif punched?
        str = "#{str} (#{duration.to_m} min)".underline 
      end
      puts str
    end

    def punched?
      punch = `tail -1 #{Todo::PUNCH}`.split(", ")
      punch.size == 2 ?  @orig == punch.first.gsub(/"/,'') : false
    end

    def duration
      start = Time.parse `tail -1 #{Todo::PUNCH}`.split(", ")[1]
      Time.now - start
    end

  end
end
