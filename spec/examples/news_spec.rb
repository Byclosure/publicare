require File.dirname(__FILE__) + "/../spec_helper"

describe News, "when first created" do
  before do
    @news = News.create :title => "My first news!"
  end

  it { @news.should_not be_unpublished }
  it { @news.should_not be_published }
end

describe News, "when first created with 2 publications attached" do
  before do
    @news = News.create! :title => "Strange news", :publication_history_attributes => [
      {:published => true, :created_at => Time.now - 1},
      {:published => false}
    ]
  end
  
  it { @news.should have(2).publication_history }
  
  it { @news.should be_published }
  
  it { @news.should_not be_unpublished }
end

describe News, "when first created with option :published => true" do
  before do
    @news = News.create! :title => "My first news!", :published => true
    @news.reload
  end
  
  it { @news.should have(1).publication_history }
  it { @news.should be_published }
  it { @news.should_not be_unpublished }
end

describe News, "when :published => false and updated to true" do
  before do
    @news = News.create! :title => "My first news!", :published => false
    # saves are too fast in order to created_at changed
    @news.update_attributes! :published => [true, Time.now + 1]
    @news.reload
  end
  
  it { @news.should have(2).publication_history }
  
  it "#publication should be the most recent one" do
    @news.publication.should == @news.publication_history.sort {|p1, p2| p1.created_at <=> p2.created_at}.last
  end
  
  it { @news.should be_published }
  it { @news.should_not be_unpublished }
end

describe News, "when :published => false and updated to false with timestamp (same value)" do
  before do
    @news = News.create! :title => "My first news!", :published => false
    @news.published = [false, @time = Time.now + 1]
    @news.reload
  end
  
  it { @news.should have(1).publication_history }
  
  it "should update updated_at to received time from its most recent publication" do
    @news.publication.updated_at.should == @time
  end
  
  it { @news.should_not be_published }
  it { @news.should be_unpublished }
end

describe News, "when :published => true and exclusively updated to true (same value)" do
  before do
    @news = News.create! :title => "My first news!", :published => true
  end
  
  it "should touch its publication" do
    publication = @news.publication
    publication.should_receive(:touch).with(:updated_at)
    @news.published = true
  end
end