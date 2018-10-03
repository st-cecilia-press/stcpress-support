require_relative '../../lib/downloader/downloader'
describe Downloader do
  describe "initialize" do
    it "fails if no output given" do
      expect{Downloader.new(remote: 'http://some_remote_path') }.to raise_error(ArgumentError)
    end  
    it "fails if no remote diven" do
      expect{Downloader.new(output: './temp/') }.to raise_error(ArgumentError)
    end  
    it "has default @force of false" do
      d = Downloader.new(remote: 'http://some_remote_path', output: './temp/')
      expect(d.force).to be_falsey
    end
    describe "run" do
      before(:each) do
        Dir.mkdir("./temp")
        @path = "./temp" 
        @wget_dbl = double("WgetStrategy")
        allow(@wget_dbl).to receive(:run)
      end
      after(:each) do
        FileUtils.rm_r('./temp')
      end

      def downloader_factory(wget_strategy: nil, output: './temp/manuscripts.yaml', remote: 'http://some_remote_site', force: false)
        Downloader.new(wget_strategy: wget_strategy, output: output, remote: remote, force: force) 
      end
      it "calls download when directory doesn't have manuscripts or books yamls" do
        d = downloader_factory(wget_strategy: @wget_dbl)
        d.run
        expect(@wget_dbl).to have_received(:run)
      end
      it "does not download files exist with age of today" do
        `touch ./temp/manuscripts.yaml`
       
        wget_dbl = double("WgetStrategy")
        allow(wget_dbl).to receive(:run)
        d = downloader_factory(wget_strategy: @wget_dbl)
        d.run
        expect(@wget_dbl).not_to have_received(:run)
      end
      it "calls download if files exist with age before today" do
        FileUtils.touch './temp/manuscripts.yaml', :mtime => Time.now - (60 * 60 * 24)
        d = downloader_factory(wget_strategy: @wget_dbl)
        d.run
        expect(@wget_dbl).to have_received(:run)
      end
      it "calls download if force is true" do
        `touch ./temp/manuscripts.yaml`
       
        wget_dbl = double("WgetStrategy")
        allow(wget_dbl).to receive(:run)
        d = downloader_factory(wget_strategy: @wget_dbl, force: true)
        d.run
        expect(@wget_dbl).to have_received(:run)
      end
    end
  end
end
#describe WgetStrategy do
#  before(:each) do
#    Dir.mkdir("./temp")
#    @output = "./temp/manuscripts.yaml" 
#  end
#  after(:each) do
#    FileUtils.rm_r('./temp')
#  end
#  it "downloads manuscripts.yaml and books.yaml to path" do
#    wget = WgetStrategy.new(output: @output, remote: 'https://raw.githubusercontent.com/st-cecilia-press/stcpress-data/master/manuscripts.yaml') 
#    expect(File.exist?('./temp/manuscripts.yaml')).to be_falsey
#    wget.run
#    expect(File.exist?('./temp/manuscripts.yaml')).to be_truthy
#  end
#end
