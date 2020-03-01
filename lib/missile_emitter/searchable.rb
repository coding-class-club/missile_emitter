require 'rubygems'

module MissileEmitter
  module Searchable
    
    # 搜索条件（klass => {field: scope}）
    # eg. {Person => {name_like: scope, older_than: scope}}
    conditions = {}

    MissileEmitter do |klass, key, *, &block|
      (conditions[klass] ||= {}.with_indifferent_access)[key] = block
    end

    has_underline_method = Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7.0')

    define_method :search do |hash|
      hash.reduce all do |relation, (key, value)|
        next relation if value.blank? # ignore empty value

        if filter = conditions.fetch(self, {})[key]
          # Inside the scope block, You can get value through calling the _ method
          relation.extending do
            # Just for fun :) 
            define_method(:_) { value }
            # With ruby >= 2.7 you can use _1 instead of _
            # Polyfill for the earlier version
            alias_method :_1, :_ unless has_underline_method
          end.instance_exec(value, &filter)
        elsif column_names.include?(key.to_s)
          relation.where key => value
        else
          relation
        end
      end
    end

  end
end