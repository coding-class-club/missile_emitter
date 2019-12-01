module MissileEmitter
  module Configurable
    
    MissileEmitter do |klass, key_field = :key, value_field = :value, key, &default|
      klass.define_singleton_method key do |&writer|
        setting = find_or_create_by! key_field => key

        value = setting.instance_eval &(writer || default || -> {})

        setting.update(value_field => value)

        setting.send value_field
      end
    end

  end
end