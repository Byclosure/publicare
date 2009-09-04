class Publication < ActiveRecord::Base
  belongs_to :content, :polymorphic => true
  validates_inclusion_of :published, :in => [true, false]
  validates_presence_of :content_type
  
  def self.def_name_scope(name, published)
    named_scope name, lambda { |*params|
      klass,  = params # this is a hack to get 0, 1 parameters
      base = {:conditions => {:published => published}, :order => "updated_at DESC" }
      base[:conditions].merge!(:content_type => klass.name) unless klass.nil?
      base
    }
  end
  
  def_name_scope :published, true
  def_name_scope :unpublished, false
  
  def unpublished?
    !published?
  end
end