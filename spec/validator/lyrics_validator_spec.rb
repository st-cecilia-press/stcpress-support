require_relative '../../lib/validator/lyrics_validator'

describe LyricsValidator do
  before(:each) do
    @slug = 'slug'
    @repo_root = "./"
    Dir.mkdir("./slug")
    FileUtils.copy('./spec/fixtures/good_lyrics.csv', './slug/lyrics.csv') 
  end
  after(:each) do
    FileUtils.rm_r('./slug')
  end
  describe "initialize" do
    it "accepts good input" do
      v = LyricsValidator.new(repo_root: @repo_root, slug: @slug)
      expect(v.slug).to eq(@slug)
      expect(v.repo_root).to eq(@repo_root)
    end 
    it "raises error for non existent slug" do
      expect{LyricsValidator.new(repo_root: @repo_root, slug: 'alewfiajew')}.to raise_error(ArgumentError, 'directory or slug does not exist')
    end
    it "raises error for non existent directory" do
      expect{LyricsValidator.new(repo_root: './alwefjawe/', slug: @slug)}.to raise_error(ArgumentError, 'directory or slug does not exist')
    end
  end
  describe "validate" do
    def lv_factory(repo_root: @repo_root, slug: @slug) 
      LyricsValidator.new(repo_root: repo_root, slug: slug) 
    end
    it "for good lyrics.csv returns successful result" do
      lv = lv_factory
      expect(lv.validate.successful?).to be_truthy
    end
    it "for nonexistent lyrics.csv returns successful result" do
      File.delete('./slug/lyrics.csv')
      lv = lv_factory
      expect(lv.validate.successful?).to be_truthy
    end 
    it "rejects non utf8 encoding for lyrcs csv" do
      FileUtils.cp 'spec/fixtures/bad_lyrics_encoding.csv', 'slug/lyrics.csv'
      result = lv_factory.validate
      expect(result.successful?).to be_falsey
      expect(result.errors.first).to eq("lyrics encoding not utf8")
    end
    it "rejects lyrics csv with empty rows" do
      FileUtils.cp 'spec/fixtures/bad_lyrics_extra_lines.csv', 'slug/lyrics.csv'
      result = lv_factory.validate
      expect(result.successful?).to be_falsey
      expect(result.errors.first).to eq("lyrics have empty rows at end")
    end
    it "rejects lyrics csv malformed csv" do
      FileUtils.cp 'spec/fixtures/bad_lyrics.csv', 'slug/lyrics.csv'
      result = lv_factory.validate
      expect(result.successful?).to be_falsey
      expect(result.errors.first).to eq("lyrics have malformed csv")
    end
  end
end
