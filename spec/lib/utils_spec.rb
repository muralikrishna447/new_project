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

    it 'returns nil if not able to spelunk further' do
      expect(Utils.spelunk(@obj1, ['bar', 'baz', 'biz'])).to eq(nil)
      expect(Utils.spelunk(@obj1, ['bar', 'baz', 0])).to eq(nil)
      expect(Utils.spelunk(@obj1, ['people', 7, 'name'])).to eq(nil)
    end
  end

  context 'weighted_random_sample' do
    it 'returns empty when input is empty' do
      input = []
      expect(Utils.weighted_random_sample(input, :w, 10)).to eq([])
    end

    it 'returns all of the items when limit exceeds available' do
      input = [{m: "a", w: 1}, {m: "b", w: 2}]
      expect(Utils.weighted_random_sample(input, :w, 10).count).to eq(2)
    end

    it 'returns the correct number when enough are available' do
      input = [{m: "a", w: 1}, {m: "b", w: 2}]
      expect(Utils.weighted_random_sample(input, :w, 1).count).to eq(1)
    end

    it 'appears to sample correctly' do
      input = [{m: "a", w: 1}, {m: "c", w: 3}, {m: "b", w: 2}]
      output = {}
      count = 10000
      count.times do
        r = Utils.weighted_random_sample(input, :w, 1)[0][:m]
        output[r] = (output[r] || 0) + 1
      end

      # With only 10k samples, this is just a sanity check, can't set the
      # tolerance very tight without risking breaking the build.
      expect(output["a"]/count.to_f).to be_within(0.03).of(1/6.0)
      expect(output["b"]/count.to_f).to be_within(0.03).of(2/6.0)
      expect(output["c"]/count.to_f).to be_within(0.03).of(3/6.0)
    end
  end
end
