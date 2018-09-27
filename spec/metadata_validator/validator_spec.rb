require_relative '../../lib/metadata_validator/validator'
require 'yaml'

describe "Validator" do
	describe "initialize" do
		it "has default books_yaml path of ./books.yaml"  do
			v = Validator.new
			expect(v.books_yaml_path).to include('lib/metadata_validator/books.yaml')
		end
		it "has default manuscripts_yaml path of ./manuscripts.yaml"  do
			v = Validator.new
			expect(v.manuscripts_yaml_path).to include('lib/metadata_validator/manuscripts.yaml')
		end
	end
end
