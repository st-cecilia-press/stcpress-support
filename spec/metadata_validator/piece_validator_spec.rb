require_relative '../../lib/metadata_validator/piece_validator'
require 'yaml'


def pv_factory(books: YAML.load_file('./spec/fixtures/book_list.yaml'), manuscripts: YAML.load_file('./spec/fixtures/manuscript_list.yaml'),
  piece: YAML.load_file('./spec/fixtures/basic.yaml'), slug: 'slug')  
  File.open("./#{slug}/metadata.yaml", 'w') {|f| f.write piece.to_yaml } 
  PieceValidator.new(books: books, manuscripts: manuscripts, slug: slug)
end
describe PieceValidator do
  before(:each) do
    @slug = 'slug'
    Dir.mkdir("./slug")
  end
  after(:each) do
    FileUtils.rm_r "./slug"
  end
  describe "initialize" do
    before(:each) do
      @books = YAML.load_file('./spec/fixtures/book_list.yaml')
      @manuscripts = YAML.load_file('./spec/fixtures/manuscript_list.yaml')
      piece = YAML.load_file('./spec/fixtures/basic.yaml')
      File.open("./#{@slug}/metadata.yaml", 'w') {|f| f.write piece.to_yaml } 
    end
    it "accepts good input" do
      v = PieceValidator.new(books: @books, manuscripts: @manuscripts, slug: @slug)
      expect(v.books[0]['slug'].class).to eq(String)
      expect(v.manuscripts[0]['slug'].class).to eq(String)
      expect(v.slug.class).to eq(String)
    end
    it "rejects missing books" do
      expect{PieceValidator.new(manuscripts: @manuscripts, slug: @slug)}.to raise_error(ArgumentError)
    end
    it "rejects missing manuscripts" do
      expect{PieceValidator.new(books: @books, slug: @slug)}.to raise_error(ArgumentError)
    end
    it "rejects missing slug" do
      expect{PieceValidator.new(books: @books, manuscripts: @manuscripts)}.to raise_error(ArgumentError)
    end
  end
  describe "validate" do
    it "rejects missing metadata file" do
      pv = pv_factory 
      File.delete('./slug/metadata.yaml')
      result = pv.validate
      expect(result.successful?).to be_falsey
      expect(result.errors.first).to eq('metadata.yaml file missing')
    end
    context "basic data" do
      before(:each) do
        @piece = YAML.load_file('./spec/fixtures/basic.yaml')
      end
      it "has successful result" do
        pv = pv_factory
        result = pv.validate
        expect(result.successful?).to be_truthy
      end
      it "rejects missing title" do
        @piece.delete("title")
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Title')
      end
      it "rejects nil title" do
        @piece['title'] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Title')
      end
      it "rejects empty title" do
        @piece['title'] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Title')
      end
      it "rejects missing composer" do
        @piece.delete("composer")
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Composer')
      end
      it "rejects nil composer" do
        @piece["composer"] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Composer')
      end
      it "rejects nil composer" do
        @piece["composer"] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Composer')
      end
      it "rejects missing voicings" do
        @piece.delete("voicings")
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need at least one Voicing')
      end
      it "rejects nil voicings" do
        @piece['voicings'] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need at least one Voicing')
      end
      it "rejects nil voicings" do
        @piece['voicings'] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need at least one Voicing')
      end
      it "rejects missing voicing array entries" do
        @piece['voicings'] = [] 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need at least one Voicing')
      end
      
      it "rejects empty voicing array entries" do
        @piece['voicings'][0] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need at least one Voicing')
      
      end
      it "rejects nil voicing array entries" do
        @piece['voicings'][0] = nil 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need at least one Voicing')
      end
      context "voicings character checks" do
        before(:each) do
          @piece["voicings"][0] = "SATB"
        end
        it "accepts Heterophonic" do
          @piece["voicings"][1] = "Heterophonic"
          pv = pv_factory(piece: @piece)
          result = pv.validate
          expect(result.successful?).to be_truthy
        end
        it "rejects voicings with uncapitalized 'SATB' characters" do
          @piece["voicings"][1] = "saTB"
          pv = pv_factory(piece: @piece)
          result = pv.validate
          expect(result.successful?).to be_falsey
          expect(result.errors.first).to eq('Voicings must contain only SATB characters')
        end
        it "rejects voicings with non 'SATB' characters" do
          @piece["voicings"][1] = "xxx"
          pv = pv_factory(piece: @piece)
          result = pv.validate
          expect(result.successful?).to be_falsey
          expect(result.errors.first).to eq('Voicings must contain only SATB characters')
        end
      end
      it "rejects missing dates" do
        @piece.delete("dates")
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Dates must Exist')
      end
      it "rejects nil dates" do
        @piece['dates'] = nil 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Dates must Exist')
      end
      it "rejects empty dates" do
        @piece['dates'] = [] 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Dates must Exist')
      end
      it "rejects dates with non number" do
        @piece['dates'][0] = 'abc' 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Dates must be integers')
      end
      it "rejects dates where first number is greater than the second" do
        @piece['dates'][0] = 1500 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        @piece['dates'][1] = 1400 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Second date must be larger than the first date')
      end
      it "rejects date lists of more than two numbers" do
        @piece['dates'][0] = 1400 
        @piece['dates'][1] = 1500 
        @piece['dates'][2] = 1600 
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Only two numbers allowed in dates list')
      end
    end
    context "manuscript checks" do
      before(:each) do
        @piece = YAML.load_file('./spec/fixtures/manuscript.yaml')
        `touch ./slug/file.jpg`
      end

      
      it "accepts good data" do
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_truthy
      end
      it "rejects empty manuscript name" do
        @piece["manuscripts"][0]["name"] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Manuscript Name')
      end
      it "rejects nil manuscript name" do
        @piece["manuscripts"][0]["name"] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Manuscript Name')
      end
      it "rejects missing manuscript name" do
        @piece["manuscripts"][0].delete('name')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Manuscript Name')
      end
      it "rejects empty image url" do
        @piece["manuscripts"][0]["images"][0]["url"] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have URL')
      end
      it "rejects nil image url" do
        @piece["manuscripts"][0]["images"][0]["url"] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have URL')
      end
      it "rejects missing image url" do
        @piece["manuscripts"][0]["images"][0].delete('url')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have URL')
      end
      it "rejects empty image filename" do
        @piece["manuscripts"][0]["images"][0]["filename"] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have Filename')
      end
      it "rejects nil image filename" do
        @piece["manuscripts"][0]["images"][0]["filename"] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have Filename')
      end
      it "rejects missing image filename" do
        @piece["manuscripts"][0]["images"][0].delete('filename')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have Filename')
      end
      it "rejects if filename's file doesn't exist" do
        File.delete('./slug/file.jpg')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq("'file.jpg' doesn't exist")
      end
      it "rejects manuscript name that's not in manuscript list" do
        @piece["manuscripts"][0]["name"] = 'alwefijalewij'
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Manuscript name not found in Manuscript list')
      end
    end
    context "book checks" do
      before(:each) do
        @piece = YAML.load_file('./spec/fixtures/book.yaml')
        `touch ./slug/file.jpg`
      end
      
      it "accepts good data" do
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_truthy
      end
      it "rejects empty book slug" do
        @piece["books"][0]["slug"] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Book Slug')
      end
      it "rejects nil book slug" do
        @piece["books"][0]["slug"] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Book Slug')
      end
      it "rejects missing book slug" do
        @piece["books"][0].delete('slug')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Need Book Slug')
      end
      it "rejects empty image url" do
        @piece["books"][0]["images"][0]["url"] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have URL')
      end
      it "rejects nil image url" do
        @piece["books"][0]["images"][0]["url"] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have URL')
      end
      it "rejects missing image url" do
        @piece["books"][0]["images"][0].delete('url')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have URL')
      end
      it "rejects empty image filename" do
        @piece["books"][0]["images"][0]["filename"] = ''
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have Filename')
      end
      it "rejects nil image filename" do
        @piece["books"][0]["images"][0]["filename"] = nil
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have Filename')
      end
      it "rejects missing image filename" do
        @piece["books"][0]["images"][0].delete('filename')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Image must have Filename')
      end
      it "rejects if filename's file doesn't exist" do
        File.delete('./slug/file.jpg')
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq("'file.jpg' doesn't exist")
      end
      it "rejects book slug that's not in book list" do
        @piece["books"][0]["slug"] = 'alwefijalewij'
        pv = pv_factory(piece: @piece)
        result = pv.validate
        expect(result.successful?).to be_falsey
        expect(result.errors.first).to eq('Book Slug not found in Book list')
      end
    end
  end
end
