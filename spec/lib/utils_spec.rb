require 'spec_helper'

describe Utils do
  context 'spelunk' do
    before :each do
      @obj1 = {
        'foo' => '123',
        'bar' => {
          'baz' => 456
        },
        'people' => [
          {'name' => 'Alice'},
          {'name' => 'Bob', 'pets' => ['Snookums']},
          {'name' => 'Sue'},
        ]
      }
    end
    it 'can fetch into hashes' do
      expect(Utils.spelunk(@obj1, ['foo'])).to eq('123')
      expect(Utils.spelunk(@obj1, ['bar', 'baz'])).to eq(456)
    end

    it 'can fetch into arrays' do
      expect(Utils.spelunk(@obj1, ['people', 0, 'name'])).to eq('Alice')
      expect(Utils.spelunk(@obj1, ['people', 1, 'pets', 0])).to eq('Snookums')
    end
  end
end
