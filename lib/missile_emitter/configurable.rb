module MissileEmitter
  module Configurable

    # 配置项列表（klass => [key1, key2, ...]）
    # eg. {Setting => [:logo, :copyright, ...]}
    option_names = {}
    
    MissileEmitter do |klass, key_field = :key, value_field = :value, key, &default|
      (option_names[klass] ||= [].to_set) << key

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

    extend ActiveSupport::Concern

    included do
      # 获取所有配置：Klass.options ---> {logo: '', copyright: '', ...}
      define_singleton_method :options do
        option_names.fetch(self, []).each_with_object({}) do |key, result|
          result[key] = send key
        end
      end
    end

  end
end