class UserHardwareItem < ApplicationRecord
  belongs_to :user
  belongs_to :hardware_item
  accepts_nested_attributes_for :user

  def name
    "#{user.name}"
  end
end
