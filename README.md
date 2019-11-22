# MissileEmitter 导弹发射器

Ruby元编程小工具，让你能在类定义（class definition）级别触发 method_missing 事件，同时不用担心潜在的命名冲突（此工具来源于一次本地Ruby集会上的主题分享《[小题大做：Ruby元编程探秘](https://pan.baidu.com/s/1hs5hj04)》）。

Ruby 提供了 `method_missing` 钩子，利用它可以实现很多功能，但其使用场景也是有限的，基本上常见的用法都是在对象级别来触发（BasicObject的实例 就特别合适）。那有没有什么办法，能让我们在类定义级别来实现相同的目标呢？让我们尝试一下：

```ruby
class MyClass
  def self.method_missing(message, *args, &block)
    # 做爱做的事情
  end
end

MyClass.ooxx # 触发类级别的 method_missing
``` 

看似可行？可惜并不完美，大家都知道 `MyClass` 其实是 `Class` 类的实例，因此本身还是会带有很多与生俱来的方法：

```ruby
p MyClass.methods.size # => 111
```

其中不乏有 `name`、`trust`这些很常见的名称，导致无法正常触发 `method_missing`，实用性大打折扣。当然，我们可以借助 `undef_method` 来移除不需要的内置方法。以下是 `builder` 的 [BlankSlate](https://github.com/jimweirich/builder/blob/c80100f8205b2e918dbff605682b01ab0fabb866/lib/blankslate.rb#L41) 实现：

```ruby
class BlankSlate
  # Hide the method named +name+ in the BlankSlate class.  Don't
  # hide +instance_eval+ or any method beginning with "__".
  def self.hide(name)
    # ...
    if instance_methods.include?(name._blankslate_as_name) &&
        name !~ /^(__|instance_eval$)/
      # ...
      undef_method name # 利用 undef_method 移除内置方法定义
    end
    # ...
  end
  # ...
  instance_methods.each { |m| hide(m) }
end
```

当然，这个方案也不完美，很多时候我们并不能简单粗暴地把所有类方法都取消定义，特别是 `name` 这样的（返回类的字符串名称），你懂的。那该怎么办呢？嗯，采用 Missile Emitter 可以做到，在类方法级别绕开内置方法的名称冲突，顺利触发 `method_missing` ！有了它我们就能实现更多有趣的DSL。

## 安装说明

添加下面这行代码到项目的Gemfile文件:

```ruby
gem 'missile_emitter'
```

然后命令行执行:

    $ bundle

也可以通过下面的方式直接安装 gem 包:

    $ gem install missile_emitter

## 使用说明

`missile emitter` 需要先定义模块，然后才能在目标类中使用。

1. 定义模块:

```ruby
module Attributes
  MissileEmitter do |klass, field, value, *, &block|
    klass.define_method(field) { value || instance_eval(&block) }
  end
end
```

2. 扩展目标类（同时声明配置项）：

```ruby
require 'date'

class Person
  include Attributes {
    name 'Jerry Chen'
    sex 'male'
    birthday Date.parse('1983-08-08')
    age do
      (Date.today.strftime('%Y%m%d').to_i - birthday.strftime('%Y%m%d').to_i) / 10000
    end
  }
end
```

如此一来，我们就实现了在定义类的同时，配置好需要的属性，测试一下：

```ruby
me = Person.new
me.name # => 'Jerry Chen'
me.sex # => 'male'
me.age # => 36
```

上面的例子确实不太有趣，来个实用点的如何？让我们为 `ActiveRecord` 模型类实现声明式搜索。首先，定义模块：

```ruby
module Searchable
  # 搜索条件（klass => {field: scope}）
  # eg. {Person => {name_like: scope, older_than: scope}}
  conditions = {}

  MissileEmitter do |klass, key, *, &block|
    (conditions[klass] ||= {}.with_indifferent_access)[key] = block
  end

  extend ActiveSupport::Concern

  included do

    define_singleton_method :search do |hash|
      hash.reduce all do |relation, (key, value)|
        next relation if value.blank? # ignore empty value

        if filter = conditions.fetch(self, {})[key]
          relation.extending do
            # Just for fun :)
            define_method(:_) { value }
          end.instance_exec(value, &filter)
        elsif column_names.include?(key)
          relation.where key => value
        else
          relation
        end
      end
    end

end
```

然后，Mixin 模块：

```ruby
class Person < ApplicationRecord
  include Searchable {
    name_like { |keyword| where 'name like ?', "%#{keyword}%" }
    older_than { where 'age >= ?', _ }
  }
end
```

最后，在业务代码中使用：

```ruby
# params: {name: 'Jerry', older_than: 18, sex: 'male'}
Person.search params.slice(:name_like, :older_than, :sex)
# 参数值不为空的情况下，等价于：
Person.where('name like ?', "%#{params[:name_like]}%")
      .where('age >= ?', params[:older_than])
      .where(sex: params[:sex])
```

总而言之，使用导弹发射器，可以方便的在类定义级别实现声明式DSL（示例参见 [`attributes.rb`](https://github.com/coding-class-club/missile_emitter/blob/master/lib/missile_emitter/attributes.rb) 、[`searchable.rb`](https://github.com/coding-class-club/missile_emitter/blob/master/lib/missile_emitter/searchable.rb)），至于更多的用法，就留给你自己慢慢挖掘啦。
