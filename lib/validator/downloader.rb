class Downloader
  attr_reader :path, :manuscripts_remote, :books_remote, :force
  def initialize(path: File.join(__dir__), manuscripts_remote: 'https://raw.githubusercontent.com/st-cecilia-press/stcpress-data/master/manuscripts.yaml',
     books_remote:  'https://raw.githubusercontent.com/st-cecilia-press/stcpress-data/master/books.yaml', wget_strategy: nil, force: false )
    
	  @path = path 
		@manuscripts_remote = manuscripts_remote
		@books_remote = books_remote
		@wget_strategy = wget_strategy || WgetStrategy.new(path: @path, manuscripts_remote: @manuscripts_remote, books_remote: @books_remote)
    @force = force
	end

	def run
	    @wget_strategy.run if @force || !local_files_exist? || (local_files_exist? && local_files_too_old?)
	end

  private
	def local_files_exist?
		local_file_paths.map{|f| File.exists?(f)}.all?
	end
  def local_files_too_old?
		local_file_paths.map{|f| Time.now - File.mtime(f) >= (60*60*24)}.all?
	end
	def local_file_paths
		["#{@path}/manuscripts.yaml","#{@path}/books.yaml"]
  end
end

class WgetStrategy
		def initialize(path:, manuscripts_remote:, books_remote:)
	    @path = path 
		  @manuscripts_remote = manuscripts_remote
		  @books_remote = books_remote
	  end
		def run
		  `wget -O #{@path}/manuscripts.yaml #{@manuscripts_remote}`
		  `wget -O #{@path}/books.yaml #{@books_remote}`
		end
end
