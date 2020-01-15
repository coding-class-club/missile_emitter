module MissileEmitter
  module Attributes
    MissileEmitter do |_, field, default, *, &block|
      attribute = "@#{field}" # 构造实例变量名称，如：name => @name
      # 动态定义实例⽅法
      define_method field do
        if instance_variable_defined?(attribute)
          instance_variable_get attribute
        else
          #返回声明的默认值，同样考虑传递Proc的情况
          block ? instance_eval(&block) : default
        end
      end
      # 写值⽅法
      attr_writer field
    end
  end
end