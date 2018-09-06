module CapabilityMethods
  include ActiveSupport::Concern
  def modulo(num, div)
    return ((num.to_i % div.to_i) + div.to_i) % div.to_i;
  end
  def current_numeric_state
    if self.state.present?
      self.class.states[self.state]
    end
  end
  def next_state
    modulo(current_numeric_state + 1, VehicleConfigCapability.states.keys.size)
  end

  def prev_state
    modulo(current_numeric_state - 1, VehicleConfigCapability.states.keys.size)
  end

  def humanize(secs = 0)
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        if n > 0
        "#{n.to_i} #{name}"
        end
      end
    }.compact.reverse.join(' ')
  end
  
  def timeout_friendly
    if timeout.present?
      humanize(timeout.to_i)
    end
  end

  def speed
    if kph.present?
      "#{mph} mph (#{kph} kph)"
    end
  end

  def mph
    if kph.present?
      (kph.to_i*0.621371).round
    end
  end
end