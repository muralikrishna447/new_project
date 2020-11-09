require 'spec_helper'

describe CutsService do
  context 'cuts page slugs list' do
    it 'empty array when cuts application failed to respond' do
      WebMock.stub_request(:get, "#{Rails.configuration.shared_config[:catalog_endpoint]}/cuts/list/slugs")
          .to_return(status: 500)
      CutsService.initiate
      expect(CutsService.get_routes).to match_array([])
    end

    it 'get all slugs from cuts application and store into memory' do
      WebMock.stub_request(:get, "#{Rails.configuration.shared_config[:catalog_endpoint]}/cuts/list/slugs")
             .to_return(status: 200, body: %w[fish chicken].to_json)
      CutsService.initiate
      expect(CutsService.get_routes).to match_array(%w[fish chicken])
    end
  end
end
