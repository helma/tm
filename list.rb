module Todo

  class List < Array

    attr_reader :current

    def initialize list
      if list.is_a? Array
        # No file path was given.
        @path = nil
        # If path is an array, loop over it, adding to self.
        list.each do |task|
          # If it's a string, make a new task out of it.
          if task.is_a? String
            push Todo::Task.new task
          # If it's a task, just add it.
          elsif task.is_a? Todo::Task
            push task
          end
          @current = last if last.punched?
        end
      elsif list.is_a? String
        @path = list
        File.open(list) do |file|
          file.each_line do |line| 
            push Todo::Task.new line
            @current = last if last.punched?
          end
        end
      end
    end

    def projects
      collect{|t| t.projects}.flatten.compact.uniq.sort
    end

    def overdue
      select{|t| t.overdue?}.sort{|a,b| a.due_date <=> b.due_date}
    end

    def today
      select{|t| t.today?}
    end

    def scheduled
      select{|t| t.scheduled?}.sort{|a,b| a.date <=> b.date}
    end

    def project_tasks project
      select{|t| t.projects.include? project}
    end

    def include? task
      collect{|t| t.text}.include? task.text
    end

    def save file=@path
      FileUtils.mv file, file+'~'
      File.open(file,"w+"){|f| f.puts collect{|t| t.orig}}
    end
  end
end
