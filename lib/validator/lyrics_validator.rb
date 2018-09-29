require 'csv'
require_relative "./result"
class LyricsValidator
  attr_reader :repo_root, :slug
  def initialize(repo_root:, slug:)
    @repo_root = repo_root
    @slug = slug
    raise ArgumentError, 'directory or slug does not exist' unless File.directory?(directory) 
  end
  def validate
    result = Result.new(@slug)
    if !File.exists?(lyrics_path)
      return result
    end

    utf8 = `grep -axv '.*' #{lyrics_path}`
    unless utf8.empty?
       result.add_error('lyrics encoding not utf8') 
       return result
    end

    begin
      CSV.read(lyrics_path)      
    rescue
      result.add_error('lyrics have malformed csv')
      return result
    end
    
    last_line = `tail -1 #{lyrics_path}`
    result.add_error('lyrics have empty rows at end') unless last_line =~ /[^\s,]/
    
    result
  end

  private
  def directory
    "#{@repo_root}/#{@slug}"
  end

  def lyrics_path
    "#{directory}/lyrics.csv"
  end
  
end
