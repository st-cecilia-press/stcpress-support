require 'yaml'
require_relative './result'
require_relative './piece_validator'
require_relative './lyrics_validator'
class RepoValidator
  attr_reader :directory, :manuscripts_path, :books_path 
  def initialize(directory: './', manuscripts_path: File.join(__dir__, 'manuscripts.yaml'), books_path: File.join(__dir__, 'books.yaml'))
    if File.directory?(directory) 
      @directory = directory
      @directories = Dir.glob("#{directory}/*").select {|f| File.directory? f}
    else
      raise ArgumentError, 'directory does not exist'
    end
    @manuscripts_path = manuscripts_path
    @books_path = books_path

		begin 
      @manuscripts = YAML.load_file(@manuscripts_path)
	  rescue Errno::ENOENT
      raise ArgumentError, 'manuscripts_path file does not exist'
    rescue Exception => e
      raise ArgumentError, ("manuscripts_path yaml is invalid: #{e.message}")
		end

		begin 
      @books = YAML.load_file(@books_path)
	  rescue Errno::ENOENT
      raise ArgumentError, 'books_path file does not exist'
    rescue Exception => e
      raise ArgumentError, ("books_path yaml is invalid: #{e.message}")
		end
  end
  def validate
    rc = ResultCollection.new
    @directories.each do |dir|
      slug = File.basename(dir)

      results = []
      results.push(PieceValidator.new(repo_root: @directory, books: @books, manuscripts: @manuscripts, slug: slug).validate)
      results.push(LyricsValidator.new(repo_root: @directory, slug: slug).validate)

      rc.add(combine_results(results)) 
    end    
    rc
  end

  private
  def combine_results(results)
    combined_result = Result.new(results.first.slug) 
    results.each { |r| combined_result.add_error(r.errors) }
    combined_result
  end
    
end
