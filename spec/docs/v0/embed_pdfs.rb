module Docs
  module V0
    module EmbedPdfs
      extend Dox::DSL::Syntax

      document :api do
        resource 'EmbedPdfs' do
          group 'EmbedPdfs'
        end
      end

      document :show do
        action 'Get a embed pdf'
      end
    end
  end
end
