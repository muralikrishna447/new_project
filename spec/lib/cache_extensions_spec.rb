require 'spec_helper'

describe CacheExtensions do
  describe 'cache_with_rescue' do
    before do
      Rails.cache.clear
    end

    it 'should behave like a normal cache when not expired and no throw' do
      r1 = CacheExtensions::fetch_with_rescue('foo', 1.minute, 1.minute) do
        'happy'
      end
      r2 = CacheExtensions::fetch_with_rescue('foo', 1.minute, 1.minute) do
        return 'not so much'
      end
      expect(r1).to eq 'happy'
      expect(r2).to eq 'happy'
    end

    it 'should recache when expired' do
      CacheExtensions::fetch_with_rescue('foo', 1.minute, 1.minute) do
        'happy'
      end
      Timecop.travel(Time.now + 2.minutes) do
        r = CacheExtensions::fetch_with_rescue('foo', 1.minute, 1.minute) do
          'so happy'
        end
        expect(r).to eq 'so happy'
      end
    end

    it 'should return the old value when expired if the block raises an exception' do
      CacheExtensions::fetch_with_rescue('foo', 1.minute, 1.minute) do
        'happy'
      end
      Timecop.travel(Time.now + 2.minutes) do
        r = CacheExtensions::fetch_with_rescue('foo', 1.minute, 1.minute) do
          raise 'not so happy'
        end
        expect(r).to eq 'happy'
      end
    end

    it 'should not retry the block after exception until after retry_expiration' do
      CacheExtensions::fetch_with_rescue('foo', 10.minute, 2.minute) do
        'happy'
      end
      Timecop.travel(Time.now + 11.minutes) do
        CacheExtensions::fetch_with_rescue('foo', 10.minute, 2.minute) do
          raise 'not so happy'
        end
      end
      Timecop.travel(Time.now + 12.minutes) do
        # One minute post-failure, should still be using 'happy'
        expect { |b| CacheExtensions::fetch_with_rescue('foo', 10.minute, 2.minute, &b)}.not_to yield_control
      end
      Timecop.travel(Time.now + 13.minutes) do
        # Three minutes post-faiure, should be retrying
        expect { |b| CacheExtensions::fetch_with_rescue('foo', 10.minute, 2.minute, &b)}.to yield_control
      end
    end
  end
end