module ActsAsPublication
  module InstanceMethods
    def publication?
      !publication.nil?
    end
    
    def publication
      publication_history.first
    end
    
    def unsaved_publication
      publication_history.select(&:new_record?).first
    end
    
    def published=(published_attributes)
      published, created_at = published_attributes
      if publication && publication.published == ActiveRecord::ConnectionAdapters::Column.value_to_boolean(published)
        created_at.nil? ? publication.touch(:updated_at) : publication.update_attribute(:updated_at, created_at)
      else
        self.publication_history_attributes = [{:published => published, :created_at => created_at}]
      end
    end
    
    def published?
      publication && publication.published?
    end

    def unpublished?
      publication && publication.unpublished?
    end
  end
  
  module ClassMethods
    def acts_as_publication(options={})
      include InstanceMethods
      has_many :publication_history, :as => :content, :class_name => "Publication", :order => "created_at DESC"
      
      named_scope :published, :include => :publication, :conditions => {"publications.published" => true}
      named_scope :unpublished, :include => :publication, :conditions => {"publications.published" => false}
      
      accepts_nested_attributes_for :publication_history
    end
  end
  
  def self.append_features(base)
    base.extend ClassMethods
  end
end