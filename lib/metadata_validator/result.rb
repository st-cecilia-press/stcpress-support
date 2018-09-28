require 'byebug'
class Result
  attr_reader :errors, :slug
  def initialize(slug = 'slug')
    @slug = slug
    @errors = [] 
  end

  def successful?
    @errors.empty? 
  end

	def add_error(error)
		@errors.concat(Array(error))
	end

end

class ResultCollection
  attr_reader :errors	
  def initialize
    @results = [] 
  end

  def successful?
    if @results.empty?
      true
    else
      !@results.map {|r| r.successful? }.include?(false)
    end
  end

	def add(result)
		@results.push(result)
	end

  def to_s
    if self.successful?
      puts 'OK'
    else
      @results.each do |r|
        unless r.successful?
          puts r.slug
          r.errors.each { |e| puts "\t#{e}"}
        end
      end 
    end
  end
end
