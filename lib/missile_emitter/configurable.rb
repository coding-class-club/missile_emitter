module MissileEmitter
  module Configurable
    
    MissileEmitter do |klass, key_field = :key, value_field = :value, key, &default|
      klass.define_singleton_method key do |&writer|
        setting = find_or_initialize_by key_field => key

        value = setting.send value_field

        if setting.new_record? # 记录不存在
          value = setting.instance_exec &(writer || default || -> { value })
        else
          value = setting.instance_exec &writer if writer
        end

        setting.attributes = {value_field => value}

        setting.save!

        value
      end
    end

  end
end