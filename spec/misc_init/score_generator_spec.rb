require_relative '../../lib/misc_init/score_generator'
describe ScoreGenerator do
  def sg_factory(template: nil, parts: 4, verses: 2, transposed: false)
    ScoreGenerator.new(template: template, parts: parts, verses: verses, transposed: transposed)
  end
  describe "initialize" do
    it "has default template of score.ly.erb" do
      sg = ScoreGenerator.new(parts: 4, transposed: false, verses: 2)
      expect(sg.template).to include('\bookOutputSuffix') 
    end
    it "fails if no parts are given" do
      expect{ScoreGenerator.new(transposed: false, verses: 2) }.to raise_error(ArgumentError)
    end  
    it "fails if no transposed is given" do
      expect{ScoreGenerator.new(parts: 4, verses: 2) }.to raise_error(ArgumentError)
    end  
    it "fails if no verses are given" do
      expect{ScoreGenerator.new(parts: 4, transposed: false) }.to raise_error(ArgumentError)
    end  
    it "for given number of parts, produces parts in names" do
      sg = sg_factory(parts: 2)
      expect(sg.parts).to match_array(['One', 'Two'])
    end
  end
  describe "save(file)" do
    before(:each) do
      @file = 'tmp1234.ly'
      FileUtils.touch(@file)   
    end
    after(:each) do
      FileUtils.rm(@file)
    end
    it "saves transposed score if transposed flag indicated for given template" do
      sg = sg_factory(transposed: true)
      sg.save(@file)
      file_content = File.read(@file) 
      expect(file_content).to include('transposed')
    end
    
    it "does not save transposed score if transposed flag is false" do
      sg = sg_factory(transposed: false)
      sg.save(@file)
      file_content = File.read(@file) 
      expect(file_content).not_to include('transposed')
    end
  end

end
