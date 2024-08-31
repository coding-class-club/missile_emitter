require 'set'

module MissileEmitter
  module Configurable

    # 配置项列表（klass => [key1, key2, ...]）
    # eg. {Setting => [:logo, :copyright, ...]}
    mapping = {}
    
    MissileEmitter do |klass, key_field = :key, value_field = :value, key, &default|
      (mapping[klass] ||= [].to_set) << key

      define_method key do |locale='zh_CN', &writer|
        setting = find_or_initialize_by key_field => key, locale: locale

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

    # 获取所有配置项名称：Configurable.option_names_for(Klass) ---> [:logo, copyright, ...]
    define_singleton_method :option_names_for do |klass|
      mapping.fetch klass, []
    end

    # 获取所有配置：Configurable.options_for(Klass) ---> {logo: '', copyright: '', ...}
    define_singleton_method :options_for do |klass|
      option_names_for(klass).each_with_object({}) do |key, result|
        result[key] = klass.send key
      end
    end

  end
end