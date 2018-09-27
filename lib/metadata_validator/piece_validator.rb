class PieceValidator
  attr_reader :books, :manuscripts, :piece
  def initialize(books:, manuscripts:, piece:)
    @books = books
    @manuscripts = manuscripts
    @piece = piece
  end

  def validate
    result = Result.new
		result.add_error('Need Title') if nempty?(@piece['title'])
		result.add_error('Need Composer') if nempty?(@piece["composer"])
    if nempty?(@piece["voicings"]) or @piece["voicings"].all? {|i| i.nil? or i == ""}
		  result.add_error('Need at least one Voicing') 
		else
			Array(@piece["voicings"]).each do |voicing|
				if voicing != 'Heterophonic' and voicing !~ /^[SATB]+$/
					result.add_error('Voicings must contain only SATB characters')
				end
			end
		end
    if nempty?(@piece["dates"]) or @piece["dates"].all? {|i| i.nil? or i == ""}
		  result.add_error('Dates must Exist') 
		else
			Array(@piece['dates']).each do |date|
				result.add_error('Dates must be integers') unless date.is_a? Integer
			end
      if @piece['dates'].count >1 and @piece['dates'][0] > @piece['dates'][1]
        result.add_error('Second date must be larger than the first date') 
			end
			result.add_error('Only two numbers allowed in dates list') if @piece['dates'].count > 2
    end
		result
  end

	private
	def nempty?(key)
		key.nil? or key.empty?
	end
end

class Result
  attr_reader :errors	
  def initialize
    @errors = [] 
  end

  def successful?
    @errors.empty? 
  end

	def add_error(error)
		@errors.push(error)
	end

end
