module Ramaze
  DEPRECATED_CONSTANTS = {
    :ThreadAccessor => :StateAccessor
  }

  def self.deprecated(from, to = nil)
    message = "%s is deprecated"
    message << ", use %s instead" unless to.nil?
    Log.warn(message % [from, to])
  end

  def self.const_missing(name)
    if to = DEPRECATED_CONSTANTS[name]
      Log.warn "Ramaze::#{name} is deprecated, use #{to} instead"
      constant(to)
    else
      super
    end
  end
end
