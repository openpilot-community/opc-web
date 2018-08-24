class Version < ApplicationRecord
  default_scope { order(:id => :desc) }
  belongs_to :item, polymorphic: true
  # belongs_to :user, :foreign_key => :whodunnit

  def user
    if !whodunnit.blank?
      scope = User.where(id: whodunnit)

      if !scope.blank?
        scope.first
      end
    end
  end
  
  def name
    id
  end
end