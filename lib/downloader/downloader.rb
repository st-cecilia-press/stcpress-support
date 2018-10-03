class Downloader
  attr_reader :output, :remote, :force
  def initialize(output:, remote:, wget_strategy: nil, force: false )
    
	  @remote = remote 
		@output = output 
		@wget_strategy = wget_strategy || WgetStrategy.new(output: @output, remote: @remote)
    @force = force
	end

	def run
	    @wget_strategy.run if @force || !local_file_exists? || (local_file_exists? && local_file_too_old?)
	end

  private
	def local_file_exists?
		File.exists?(@output)
	end
  def local_file_too_old?
		Time.now - File.mtime(@output) >= (60*60*24)
	end
end

class WgetStrategy
		def initialize(output:, remote:)
	    @output = output 
		  @remote = remote
		  
	  end
		def run
		  `wget -O #{@output} #{@remote}`
		end
end
