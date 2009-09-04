require File.dirname(__FILE__) + "/../spec_helper"

describe News, "when first created" do
  before do
    @news = News.create :title => "My first news!"
  end
  
  it "should default to unpublished" do
    @news.unpublished?.should_not be_true
  end
  
  it "should not default to publish" do
    @news.published?.should be_true
  end
end

describe News, "when first created with 2 publications attached" do
  before do
    @news = News.create! :title => "Strange news", :publication_history_attributes => [
      {:published => true, :created_at => Time.now - 1},
      {:published => false}
    ]
  end
  
  it do
    @news.publication_history.should have(2).items
  end
  
  it "should be published" do
    @news.published?.should be_true
  end
  
  it "should not be unpublished" do
    @news.unpublished?.should_not be_true
  end
end

describe News, "when first created with option :published => true" do
  before do
    @news = News.create! :title => "My first news!", :published => true
    @news.reload
  end
  
  it do
    @news.should have(1).publication_history
  end
  
  it "should be published" do
    @news.published?.should be_true
  end
  
  it "should not be unpublished" do
    @news.unpublished?.should_not be_true
  end
end

describe News, "when :published => false and updated to true" do
  before do
    @news = News.create! :title => "My first news!", :published => false
    # saves are too fast in order to created_at changed
    @news.update_attributes! :published => [true, Time.now + 1]
    @news.reload
  end
  
  it do
    @news.should have(2).publication_history
  end
  
  it "#publication should be the most recent one" do
    @news.publication.should == @news.publication_history.sort {|p1, p2| p1.created_at <=> p2.created_at}.last
  end
  
  it "should be published" do
    @news.published?.should be_true
  end
  
  it "should not be unpublished" do
    @news.unpublished?.should_not be_true
  end
end

describe News, "when :published => false and updated to false with timestamp (same value)" do
  before do
    @news = News.create! :title => "My first news!", :published => false
    @news.published = [false, @time = Time.now + 1]
    @news.reload
  end
  
  it do
    @news.should have(1).publication_history
  end
  
  it "should update updated_at to received time from its most recent publication" do
    @news.publication.updated_at.should == @time
  end
  
  it "should not be published" do
    @news.published?.should_not be_true
  end
  
  it "should be unpublished" do
    @news.unpublished?.should be_true
  end
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