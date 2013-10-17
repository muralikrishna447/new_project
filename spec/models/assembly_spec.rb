require 'spec_helper'

describe Assembly do

  before :each do
    @assembly = Fabricate :assembly, title: 'Test Assembly', description: 'Test Assembly Description', assembly_type: 'Course'
  end

  context 'faq' do
    it 'returns an faq' do
      faq = Fabricate :page, title: 'Test Assembly FAQ', content: 'This is the test assembly faq.'
      expect(@assembly.faq).to be_an_instance_of(Page)
      expect(@assembly.faq.slug).to eq('test-assembly-faq')
    end
  end

  context 'testimonials' do
    it 'returns a testimonials page' do
      testimonial = Fabricate :page, title: 'Test Assembly Testimonial', content: 'This is an awesome assembly!'
      expect(@assembly.testimonials).to be_an_instance_of(Page)
      expect(@assembly.testimonials.slug).to eq('test-assembly-testimonial')
    end
  end

  context 'video count' do
    it 'returns a count of all the videos within assembly activities' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      activity2 = Fabricate :activity, title: 'activity2', youtube_id: 'activity2'
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: @assembly, includable: activity1
      assembly_inclusion_2 = Fabricate :assembly_inclusion, assembly: @assembly, includable: activity2
      expect(@assembly.video_count).to eq(2)
    end

    it 'returns a count of all the videos including videos within assembly activity steps' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      activity2 = Fabricate :activity, title: 'activity2', youtube_id: 'activity2'
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: @assembly, includable: activity1
      assembly_inclusion_2 = Fabricate :assembly_inclusion, assembly: @assembly, includable: activity2
      step1 = Fabricate :step, youtube_id: 'step1', activity: activity1
      expect(@assembly.video_count).to eq(3)
    end
  end

end
