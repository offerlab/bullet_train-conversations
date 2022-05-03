class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include CableReady::Updatable

  scope :newest, -> { order("created_at DESC") }
end
