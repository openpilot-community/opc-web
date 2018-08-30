require 'yaml'
require 'watir'
require 'fileutils'

class CheckActiveMakeModelsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  def perform(*args)
    make_models_file = '/tmp/make_models.yml'
    # unless File.exists?(make_models_file)
    #   make_models_yaml = YAML::load_file(make_models_file) #Load
    # end
    base_url = "#{ENV['VEHICLE_ROOT_HOST']}#{ENV['CARS_SEARCH_PATH']}"

    browser = Watir::Browser.new
    browser.goto base_url
    makes_select = browser.select_list(class: 'as-make-drop-down').wait_until(&:present?)
    models_select = browser.select_list(class: 'as-model-drop-down').wait_until(&:present?)
    make_models = []
    makes_select.options.each do |make|
      unless make.text == "All Makes"
        makes_select.select make.text
        make_hash = { 
          make: make.text,
          models: []
        }
        puts "Processing '#{make.text}'"
        models_select.options.each do |model|
          model_name = model.text

          if (!model_name.include?("(all)") && !model_name.ends_with?(" Trucks") && !model_name.ends_with?(" Vans") && !model_name.ends_with?("-Series"))
            if model_name.start_with?("- ")
              # model_name = model_name.gsub('- ', '')
              model_name[0,2] = ""
            end
            # puts "#{model.text} #{make.value}"
            unless model_name == "All Models"
              make_hash[:models] << model_name
            end
          end
        end

        make-_models << make_hash
      end
    end

    File.write(make_models_file,make_models.to_yaml)

    browser.close
  end
end