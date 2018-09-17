require 'optparse'
require_relative 'validate'

options = {url: false, verbose: false}
OptionParser.new do |parser|
    parser.on("-u", "--url", "Checks if URL for images work") do
        options[:url] = true
    end
    parser.on("-v", "--verbose",  "Prints name of directory as it runs") do 
        options[:verbose] = true
      puts parser
    end
    parser.on("-h", "--help",  "Prints this Help") do 
      puts parser
    end
end.parse!

val = Validator.new(options[:url], options[:verbose])
valid, errors =  val.validate_repo
if valid
  puts 'OK'
else
  puts 'Errors: '
  errors.each do |error|
    puts error
  end
end
