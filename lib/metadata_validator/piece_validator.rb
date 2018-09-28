require_relative "./result"
class PieceValidator
  attr_reader :books, :manuscripts, :slug, :repo_root
  def initialize(repo_root:, books:, manuscripts:, slug:)
    @books = books
    @manuscripts = manuscripts
		@slug = slug
    @repo_root = repo_root
  end

  def validate
    result = Result.new(@slug)
		begin 
      piece = YAML.load_file("#{repo_root}/#{@slug}/metadata.yaml")
	  rescue Errno::ENOENT
			result.add_error('metadata.yaml file missing')
			return result
    rescue Exception => e
      result.add_error("metadata.yaml is invalid: #{e.message}")
      return result
		end
	  result.add_error("'#{@slug}.pdf' doesn't exist") unless File.exists?("#{repo_root}/#{@slug}/#{@slug}.pdf")
		result.add_error('Need Title') if nempty?(piece['title'])
		result.add_error('Need Composer') if nempty?(piece["composer"])
    if nempty?(piece["voicings"]) or piece["voicings"].all? {|i| i.nil? or i == ""}
		  result.add_error('Need at least one Voicing') 
		else
			Array(piece["voicings"]).each do |voicing|
				if voicing != 'Heterophonic' and voicing !~ /^[SATB]+$/
					result.add_error('Voicings must contain only SATB characters')
				end
			end
		end
    if nempty?(piece["dates"]) or piece["dates"].all? {|i| i.nil? or i == ""}
		  result.add_error('Dates must Exist') 
		else
			Array(piece['dates']).each do |date|
				result.add_error('Dates must be integers') unless date.is_a? Integer
			end
      if piece['dates'].count >1 and piece['dates'][0] > piece['dates'][1]
        result.add_error('Second date must be larger than the first date') 
			end
			result.add_error('Only two numbers allowed in dates list') if piece['dates'].count > 2
    end
	  Array(piece["manuscripts"]).each do |man|
			result.add_error('Need Manuscript Name') if nempty?(man["name"])
			result.add_error('Manuscript name not found in Manuscript list') unless @manuscripts.detect { |m| m['name'] == man['name']}
			img_result = validate_images(Array(man["images"]))
		  result.add_error(img_result.errors) if !img_result.successful?

		end
	  Array(piece["books"]).each do |book|
			result.add_error('Need Book Slug') if nempty?(book["slug"])
			result.add_error('Book Slug not found in Book list') unless @books.detect { |b| b['slug'] == book['slug']}
			img_result = validate_images(Array(book["images"]))
		  result.add_error(img_result.errors) if !img_result.successful?

		end
		result
  end

	private
	def nempty?(key)
		key.nil? or key.empty?
	end

	def validate_images(images)
		result = Result.new
		images.each do |img|
			result.add_error('Image must have URL') if nempty?(img["url"])
			result.add_error('Image must have Filename') if nempty?(img["filename"])
			result.add_error("'#{img["filename"]}' doesn't exist") unless File.exists?("#{@repo_root}/#{@slug}/#{img["filename"]}")
		end
	  result	
	end
end

