module ChargeBeeWorkers
  class Sleeper
    @queue = 'sleeper'

    def self.perform(params)
      sleep(60)
    end
  end
end
