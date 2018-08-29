# == Schema Information
#
# Table name: vehicle_models
#
#  id              :bigint(8)        not null, primary key
#  name            :string
#  vehicle_make_id :bigint(8)
#  tmp_make_name   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  slug            :string
#

class VehicleModel < ApplicationRecord
  enum status: { active: 1, inactive: 0 }
  paginates_per 200
  extend FriendlyId
  has_one_attached :image
  friendly_id :name_for_slug, use: :slugged
  has_paper_trail
  belongs_to :vehicle_make
  has_many :vehicle_trims
  has_many :vehicle_configs
  has_many :vehicle_model_options
  has_many :vehicle_options, :through => :vehicle_model_options
  scope :with_configs, -> { VehicleModel.joins(:vehicle_configs).where("vehicle_configs.id IS NOT NULL").order("vehicle_models.name") }

  def has_configs?
    !vehicle_configs.blank?
  end

  # def to_param
  #   slug
  # end

  def name_for_select
    "#{vehicle_make.name} #{name}"
  end

  def name_for_slug
    "#{id} #{name}"
  end

  def has_driver_assist?
    !driver_assist.blank?
  end
  def scrape_image(trim_info = nil,year)
    # begin
      if !self.image.attached?
        if trim_info.blank?
          make_name_parameter = vehicle_make.name.parameterize(separator: '_').downcase
          model_name_parameter = self.name.gsub('-',' ').parameterize(separator: '_').downcase
          model_parameter = "#{make_name_parameter}-#{model_name_parameter}-#{year}"
          trim_info = Cars::Vehicle.retrieve("#{model_parameter}/trims")
        end
        
        image_url = trim_info[:image]
        tempfile = Down.download(image_url)
        
        self.image.attach(
          io: tempfile,
          filename: "#{slug}.#{tempfile.original_filename}",
          content_type: tempfile.content_type
        )
      end
    # rescue
    #   puts "Failed to scrape image"
    # end
  end
  def driver_assist
    vehicle_trims.select do |vt|
      !vt.driver_assist.blank?
    end
  end
  def trim_styles(year)
    VehicleTrimStyle.joins(:vehicle_trim).where('vehicle_trims.year IN (:years) AND vehicle_trim_id IN (:trim_ids)',{ :years => [year], :trim_ids => self.vehicle_trims.map(&:id) }).order("vehicle_trims.year, vehicle_trims.sort_order, vehicle_trim_styles.name")
  end
  def scrape_info
    (Time.zone.now.year + 1).downto(2017).each do |year|
      begin
        make_name_parameter = vehicle_make.name.parameterize(separator: '_').downcase
        model_name_parameter = vehicle_model.name.gsub('-',' ').parameterize(separator: '_').downcase
        model_parameter = "#{make_name_parameter}-#{model_name_parameter}-#{year}"
        trim_info = Cars::Vehicle.retrieve("#{model_parameter}/trims")
        # trim_info = Cars::Vehicle.retrieve("#{vehicle_make.name.parameterize('_').downcase}-#{name.gsub('-','_').parameterize('_').downcase}-#{year}/trims")
        # if !image.attached?
          scrape_image(trim_info,year)
        # end
        # scrape_image
        trim_info[:trims].each_with_index do |trim, index|
          vehicle_trim = VehicleTrim.find_or_initialize_by(name: trim.name, year: year, vehicle_model: self)
          vehicle_trim.sort_order = index
          vehicle_trim.save
          if vehicle_trim.new_record?
            puts "[#{vehicle_make.name}, #{name}, #{year}] New trim added: #{trim.name}"
          else
            puts "[#{vehicle_make.name}, #{name}, #{year}] Updated trim: #{trim.name}"
          end
          trim[:styles].each do |style|
            new_style = vehicle_trim.vehicle_trim_styles.find_or_initialize_by(:name => style[:name])
            new_style.inventory_prices = style[:inventory_prices]
            new_style.mpg = style[:mpg]
            new_style.engine = style[:engine]
            new_style.trans = style[:trans]
            new_style.drive = style[:drive]
            new_style.colors = style[:colors]
            new_style.seats = style[:seats]
            
            new_style.save!

            if !new_style.has_specs?
              specs = Cars::VehicleStyle.retrieve(style[:link].gsub("#{ENV['VEHICLE_ROOT_URL']}/",''))[:specs]

              specs.each do |spec|
                new_spec = new_style.vehicle_trim_style_specs.find_or_initialize_by(:name => spec[:name])
                new_spec.value = spec[:value]
                new_spec.inclusion = spec[:inclusion]
                new_spec.save!
              end
            end
          end
        end
      rescue
        puts "[#{vehicle_make.name}, #{name}, #{year}] ERROR: Record failed to process."
      end
    end
  end
  # def self.with_configs
  #   joins("LEFT OUTER JOIN vehicle_configs").where.not(vehicle_configs: {id: nil})
  # end

end
