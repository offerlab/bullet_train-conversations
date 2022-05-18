class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include CableReady::Updatable

  scope :newest, -> { order("created_at DESC") }
  scope :oldest, -> { order("created_at ASC") }

  def label_string
    name
  end
end
