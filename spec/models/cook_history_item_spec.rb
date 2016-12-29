require 'spec_helper'

joule_program_data = {
  "set_point"=>58,
   "cook_time"=>64800,
   "holding_temperature"=>58,
   "program_type"=>"AUTOMATIC",
   "program_id"=>"65lArYOHsseoMseoAoyySY",
   "guide_id"=>"48FZLHVtTqauC4qK8YskY",
   "cook_id"=>"9c9f6e14f6ac48479eeab391d4376b77",
   "timer_id"=>"6B9gdJ14cMsMI4W6YWyIWY"
 }

describe CookHistoryItem do
  before(:each) do
    @history_item = Fabricate :cook_history_item,  history_item_type: 'joule', 
      joule_cook_history_program_attributes: joule_program_data
  end


  context 'with child joule_cook_history_program' do
    before(:each) do
      @joule_program = @history_item.joule_cook_history_program
    end
    
    it 'can be created' do
      JouleCookHistoryProgram.exists?(@joule_program).should == true
    end
    
    it 'can be serialized' do
      serializer = Api::CookHistoryItemSerializer.new @history_item
      serializer.serializable_hash.is_a?(Hash)
    end
    
    it 'contains program_metadata' do
      serializer = Api::CookHistoryItemSerializer.new @history_item
      cook_hash = serializer.serializable_hash
      cook_hash[:jouleCookHistoryProgram][:programMetadata].is_a?(Hash)
    end
  end

end
