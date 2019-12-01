module MissileEmitter
  module Configurable
    
    MissileEmitter do |klass, key_field = :key, value_field = :value, key, &block|
      klass.define_singleton_method key do
        setting = find_or_create_by! key_field => key

        setting.update(value_field => setting.instance_eval(&block)) if block

        setting.send value_field
      end
    end

  end
end