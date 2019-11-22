require 'missile_emitter/attributes'
require 'date'

module MissileEmitter
  RSpec.describe Attributes do

    it "为目标类动态定义存取方法" do
      birth_at = Date.parse '1983-08-08'

      object = Class.new do
        include MissileEmitter.Attributes {
          name 'Jerry Chen'
          birthday birth_at
          age do
            (Date.today.strftime('%Y%m%d').to_i - birthday.strftime('%Y%m%d').to_i) / 10000
          end
        }
      end.new

      expect(object.name).to eq 'Jerry Chen'
      expect(object.birthday).to eq birth_at
      expect(object).to respond_to :age

      object.name = 'Metaprogramming'
      expect(object.name).to eq 'Metaprogramming'
    end

  end
end