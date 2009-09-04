require File.dirname(__FILE__) + "/../spec_helper"

describe Publication, "when created" do
  it "without should :published attribute should raise ActiveRecord::RecordInvalid"do
    lambda { Publication.create! :content => News.create!(:title => "Bombastic") }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it "without should :content attribute should raise ActiveRecord::RecordInvalid"do
    lambda { Publication.create! :published => true }.should raise_error(ActiveRecord::RecordInvalid)
  end
end

describe Publication, "when 2 news and 2 books are published and 3 news and 2 book unpublished" do
  before do
    # updated_at times differ in order to guarantee its order on the following specs
    1.upto(2) do |i|
      content =  News.create!(:title => "Published #{i}")
      Publication.create! :content => content, :published => true, :updated_at => Time.now + i
    end
    
    3.upto(4) do |i|
      content = Book.create!(:title => "Published #{i}")
      Publication.create! :content => content, :published => true, :updated_at => Time.now + i
    end
    
    5.upto(7) do |i|
      content = News.create!(:title => "Unpublished #{i}")
      Publication.create! :content => content, :published => false, :updated_at => Time.now + i
    end
    
    8.upto(9) do |i|
      content = Book.create!(:title => "Unpublished #{i}")
      Publication.create! :content => content, :published => false, :updated_at => Time.now + i
    end
  end
  
  it "Publication#published(News) should return 2 news" do
    Publication.published(News).should have(2).news
  end
  
  it "Publication#published(News) should be ordered by publication's updated_at" do
    publications = Publication.published(News)
    publications.should == publications.sort {|p1, p2| p2.updated_at <=> p1.updated_at }
  end
  
  it "Publication#published should return 4 items" do
    Publication.published.should have(4).items
  end
  
  it "Publication#published should be ordered by publication's updated_at" do
    publications = Publication.published
    publications.should == publications.sort {|p1, p2| p2.updated_at <=> p1.updated_at }
  end
  
  it "Publication#unpublished(News) should return 3 news" do
    Publication.unpublished(News).should have(3).news
  end
  
  it "Publication#unpublished(News) should be ordered by publication's updated_at" do
    publications = Publication.unpublished(News)
    publications.should == publications.sort {|p1, p2| p2.updated_at <=> p1.updated_at }
  end
  
  it "Publication#unpublihed should return 5 items" do
    Publication.unpublished.should have(5).items
  end
  
  it "Publication#unpublihed should be ordered by publication's updated_at" do
    publications = Publication.unpublished
    publications.should == publications.sort {|p1, p2| p2.updated_at <=> p1.updated_at }
  end
end