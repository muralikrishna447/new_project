module ChargeBeeWorkers
  class ChargeBeeGiftProcessor
    @queue = 'sleeper'

    def self.perform(params)
      sleep(60)
    end
  end
end
