require_relative '../../lib/validator/repo_validator'
require_relative '../../lib/validator/piece_validator'
require 'yaml'

describe RepoValidator do
  describe "initialize" do
    it "has default directory of './'" do
      rv = RepoValidator.new
      expect(rv.directory).to eq('./') 
    end
    it "accepts other values for directory" do
      rv = RepoValidator.new(directory: '../')
      expect(rv.directory).to eq('../')
    end
    it "rejects invalid directory" do
      expect{RepoValidator.new(directory: './alseifajesi')}.to raise_error(ArgumentError, 'directory does not exist')
    end
    it "has default manuscripts_path of lib/validator/manuscripts" do
      rv = RepoValidator.new
      expect(rv.manuscripts_path).to include('/lib/validator/manuscripts.yaml') 
    end
    it "has default books_path of lib/validator/books" do
      rv = RepoValidator.new
      expect(rv.books_path).to include('/lib/validator/books.yaml') 
    end
    it "accepts custom path for manuscripts" do
      rv = RepoValidator.new(manuscripts_path: './spec/fixtures/manuscript_list.yaml')
      expect(rv.manuscripts_path).to include('./spec/fixtures/manuscript_list.yaml') 
    end
    it "accepts custom path for books" do
      rv = RepoValidator.new(books_path: './spec/fixtures/book_list.yaml')
      expect(rv.books_path).to include('./spec/fixtures/book_list.yaml') 
    end
    it "rejects missing manuscripts file" do
      expect{RepoValidator.new(manuscripts_path: './ablieawjbg.yaml')}.to raise_error(ArgumentError, 'manuscripts_path file does not exist')
    end
    it "rejects bad manuscripts yaml file" do
      expect{RepoValidator.new(manuscripts_path: './spec/fixtures/bad.yaml')}.to raise_error(ArgumentError, /manuscripts_path yaml is invalid/)
    end
    it "rejects missing books file" do
      expect{RepoValidator.new(books_path: './ablieawjbg.yaml')}.to raise_error(ArgumentError, 'books_path file does not exist')
    end
    it "rejects bad books yaml file" do
      expect{RepoValidator.new(books_path: './spec/fixtures/bad.yaml')}.to raise_error(ArgumentError, /books_path yaml is invalid/)
    end
  end
  describe "validate" do
    before(:each) do
      @slug = 'slug'
      Dir.mkdir("./temp")
      Dir.mkdir("./temp/slug")
      `touch ./temp/slug/slug.pdf`
      FileUtils.copy("./spec/fixtures/basic.yaml","./temp/slug/metadata.yaml")
      @slug2 = 'slug2'
      Dir.mkdir("./temp/slug2")
      `touch ./temp/slug2/slug2.pdf`
      FileUtils.copy("./spec/fixtures/basic.yaml","./temp/slug2/metadata.yaml")
    end
    after(:each) do
      FileUtils.rm_r "./temp"
    end
    def rv_factory(directory: './temp', books_path: './spec/fixtures/book_list.yaml', manuscripts_path: './spec/fixtures/book_list.yaml') 
      return RepoValidator.new(directory: directory, books_path: books_path, manuscripts_path: manuscripts_path)
    end
    it "returns successful? true for valid repo" do
       rv = rv_factory
       result = rv.validate
       expect(result.successful?).to be_truthy
    end
    it "returns successful? false for repo with errors" do
      FileUtils.rm("./temp/slug2/metadata.yaml")
      rv = rv_factory
      result = rv.validate
      expect(result.successful?).to be_falsey
    end
  end
end
