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

  context 'containing course' do
    it 'finds no containing course when none exists' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      expect(activity1.containing_course).to be_nil
    end

    it 'finds correct containing course when one exists as direct parent' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: @assembly, includable: activity1
      expect(activity1.containing_course).to eq(@assembly)
    end

    it 'finds no containing course when direct parent exists but isnt a course' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      assembly_direct_parent = Fabricate :assembly, title: 'Test Parent', description: 'Test Parent Description', assembly_type: 'Assembly'
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: assembly_direct_parent, includable: activity1
      expect(activity1.containing_course).to be_nil
    end

    it 'finds correct containing course when one exists as 2nd level parent' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      assembly_direct_parent = Fabricate :assembly, title: 'Test Parent', description: 'Test Parent Description', assembly_type: 'Assembly'
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: assembly_direct_parent, includable: activity1
      assembly_inclusion_2 = Fabricate :assembly_inclusion, assembly: @assembly, includable: assembly_direct_parent

      expect(activity1.containing_course).to eq(@assembly)
    end

    it 'finds no containing course when 2nd level parent exists but isnt a course' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      assembly_direct_parent = Fabricate :assembly, title: 'Test Parent', description: 'Test Parent Description', assembly_type: 'Assembly'
      assembly_next_parent = Fabricate :assembly, title: 'Test Parent 2', description: 'Test Parent Description 2', assembly_type: 'Assembly'
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: assembly_direct_parent, includable: activity1
      assembly_inclusion_2 = Fabricate :assembly_inclusion, assembly:assembly_next_parent, includable: assembly_direct_parent

      expect(activity1.containing_course).to be_nil
    end

    it 'finds containing course even if child has two parents, one of which is a dead end' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      assembly_direct_parent = Fabricate :assembly, title: 'Test Parent', description: 'Test Parent Description', assembly_type: 'Assembly'
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: assembly_direct_parent, includable: activity1
      assembly_inclusion_2 = Fabricate :assembly_inclusion, assembly: @assembly, includable: assembly_direct_parent
      assembly_dead_end_parent = Fabricate :assembly, title: 'Dead end parent', description: 'Dead End Parent Description', assembly_type: 'Assembly'
      assembly_dead_end_includsion = Fabricate :assembly_inclusion, assembly: assembly_dead_end_parent, includable: activity1

      expect(activity1.containing_course).to eq(@assembly)
    end

    it 'ditto with order reversed' do
      activity1 = Fabricate :activity, title: 'activity1', youtube_id: 'activity1'
      assembly_direct_parent = Fabricate :assembly, title: 'Test Parent', description: 'Test Parent Description', assembly_type: 'Assembly'
      assembly_dead_end_parent = Fabricate :assembly, title: 'Dead end parent', description: 'Dead End Parent Description', assembly_type: 'Assembly'
      assembly_dead_end_includsion = Fabricate :assembly_inclusion, assembly: assembly_dead_end_parent, includable: activity1
      assembly_inclusion_1 = Fabricate :assembly_inclusion, assembly: assembly_direct_parent, includable: activity1
      assembly_inclusion_2 = Fabricate :assembly_inclusion, assembly: @assembly, includable: assembly_direct_parent

      expect(activity1.containing_course).to eq(@assembly)
    end
  end


end
