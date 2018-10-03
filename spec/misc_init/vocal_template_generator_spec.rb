require_relative '../../lib/misc_init/vocal_template_generator'
describe VocalTemplateGenerator do
  def vtg_factory(template: nil, parts: 4, verses: 2, transposed: false)
    VocalTemplateGenerator.new(template: template, parts: parts, verses: verses, transposed: transposed)
  end
  describe "initialize" do
    it "has default template of vocal_template.ly.erb" do
      sg = VocalTemplateGenerator.new(parts: 4, transposed: false, verses: 2)
      expect(sg.template).to include('english.ly') 
    end
    it "for given number of parts, produces parts in names" do
      vtg = vtg_factory(parts: 1)
      expect(vtg.parts).to match_array([{number: 'One', clef: 'treble', name: 'cantus'}])
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
      vtg = vtg_factory(transposed: true)
      vtg.save(@file)
      file_content = File.read(@file) 
      expect(file_content).to include('scMinimumSystemSpacingTranspose')
    end
    
    it "does not save transposed score if transposed flag is false" do
      vtg = vtg_factory(transposed: false)
      vtg.save(@file)
      file_content = File.read(@file) 
      expect(file_content).not_to include('scMinimumSystemSpacingTranspose')
    end
  end

end
