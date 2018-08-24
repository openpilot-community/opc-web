class Version < ApplicationRecord
  default_scope { order(:id => :desc) }
  belongs_to :item, polymorphic: true
  # belongs_to :user, :foreign_key => :whodunnit

  def user
    if !whodunnit.blank?
      User.find(whodunnit)
    end
  end
  
  def name
    id
  end
end