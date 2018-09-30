require_relative '../../lib/validator/downloader'
describe Downloader do
  describe "initialize" do
    it "has default @path that includes lib/validator" do
      d = Downloader.new
      expect(d.path).to include('/lib/validator')
    end  
    it "has defaults @manuscripts_remote that includes stcpress-data/master/manuscripts.yaml" do
      d = Downloader.new
      expect(d.manuscripts_remote).to include('stcpress-data/master/manuscripts.yaml')
    end  
    it "has defaults @books_remote that includes stcpress-data/master/books.yaml" do
      d = Downloader.new
      expect(d.books_remote).to include('stcpress-data/master/books.yaml')
    end  
    it "has default @force of false" do
      d = Downloader.new
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

      def downloader_factory(wget_strategy: nil, path: './temp', force: false)
        Downloader.new(wget_strategy: wget_strategy, path: path, force: force) 
      end
      it "calls download when directory doesn't have manuscripts or books yamls" do
        d = downloader_factory(wget_strategy: @wget_dbl)
        d.run
        expect(@wget_dbl).to have_received(:run)
      end
      it "does not download files exist with age of today" do
        `touch ./temp/manuscripts.yaml`
        `touch ./temp/books.yaml`
       
        wget_dbl = double("WgetStrategy")
        allow(wget_dbl).to receive(:run)
        d = downloader_factory(wget_strategy: @wget_dbl)
        d.run
        expect(@wget_dbl).not_to have_received(:run)
      end
      it "calls download if files exist with age before today" do
        FileUtils.touch './temp/manuscripts.yaml', :mtime => Time.now - (60 * 60 * 24)
        FileUtils.touch './temp/books.yaml', :mtime => Time.now - (60 * 60 * 24)
        d = downloader_factory(wget_strategy: @wget_dbl)
        d.run
        expect(@wget_dbl).to have_received(:run)
      end
      it "calls download if force is true" do
        `touch ./temp/manuscripts.yaml`
        `touch ./temp/books.yaml`
       
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
#    @path = "./temp" 
#  end
#  after(:each) do
#    FileUtils.rm_r('./temp')
#  end
#  it "downloads manuscripts.yaml and books.yaml to path" do
#    wget = WgetStrategy.new(path: @path, books_remote: 'https://raw.githubusercontent.com/st-cecilia-press/stcpress-data/master/books.yaml', manuscripts_remote: 'https://raw.githubusercontent.com/st-cecilia-press/stcpress-data/master/manuscripts.yaml') 
#    wget.run
#    expect(File.exist?('./temp/manuscripts.yaml')).to be_truthy
#    expect(File.exist?('./temp/books.yaml')).to be_truthy
#  end
#end
