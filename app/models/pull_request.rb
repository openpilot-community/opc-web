# == Schema Information
#
# Table name: pull_requests
#
#  id                 :bigint(8)        not null, primary key
#  name               :string
#  number             :string
#  title              :string
#  state              :string
#  locked             :string
#  user               :string
#  body               :string
#  pr_created_at      :string
#  pr_updated_at      :string
#  closed_at          :string
#  merged_at          :string
#  merge_commit_sha   :string
#  head               :string
#  author_association :string
#  html_url           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class PullRequest < ApplicationRecord
  has_many :vehicle_config_pull_requests
  has_many :vehicle_configs, :through => :vehicle_config_pull_requests
  include PgSearch
  pg_search_scope :search_for, :against => {
                    :name => 'A',
                    :title => 'B',
                    :body => 'C'
                  },
                  :using => {
                    :tsearch => {:highlight => true, :any_word => true, :dictionary => "english"}
                  }
  multisearchable :against => [:name, :title, :body]
  def vehicles
    if !vehicle_configs.blank?
      vehicle_configs.map(&:name).join(", ")
    end
  end
end
