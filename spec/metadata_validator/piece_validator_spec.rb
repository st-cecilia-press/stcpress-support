require_relative '../../lib/metadata_validator/piece_validator'
require 'yaml'


def pv_factory(books: YAML.load_file('./spec/fixtures/book_list.yaml'), manuscripts: YAML.load_file('./spec/fixtures/manuscript_list.yaml'),
  piece: YAML.load_file('./spec/fixtures/basic.yaml'))  
  PieceValidator.new(books: books, manuscripts: manuscripts, piece: piece)
end
describe PieceValidator do
  before(:each) do
    @books = YAML.load_file('./spec/fixtures/book_list.yaml')
    @manuscripts = YAML.load_file('./spec/fixtures/manuscript_list.yaml')
  end
  describe "initialize" do
    before(:each) do
      @piece = YAML.load_file('./spec/fixtures/basic.yaml')
    end
    it "accepts good input" do
      v = pv_factory
      expect(v.books[0]['slug'].class).to eq(String)
      expect(v.manuscripts[0]['slug'].class).to eq(String)
      expect(v.piece['title'].class).to eq(String)
    end
    it "rejects missing books" do
      expect{PieceValidator.new(manuscripts: @manuscripts, piece: @piece)}.to raise_error(ArgumentError)
    end
    it "rejects missing manuscripts" do
      expect{PieceValidator.new(books: @books, piece: @piece)}.to raise_error(ArgumentError)
    end
    it "rejects missing piece" do
      expect{PieceValidator.new(books: @books, manuscripts: @manuscripts)}.to raise_error(ArgumentError)
    end
  end
  describe "validate" do
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
   #NOT SURE IF THIS MAKES SENSE ANYMORE
   # context "manuscript checks" do
   #   before(:each) do
   #     @piece = YAML.load_file('./spec/fixtures/manuscript.yaml')
   #     @slug = 'slug'
   #     Dir.mkdir("./slug")
   #     `touch ./slug/file.jpg`
   #   end
   #   after(:each) do
   #     FileUtils.rm_r "./slug" 
   #   end
   # end
  end
end
