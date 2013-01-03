require 'spec_helper'

describe Delve::OrderSortQuestion::Scorer do
  describe '#matches?' do
    let(:solution) { [:a, :b, :c] }
    subject { described_class.new(solution) }

    it 'should return true for an exact match' do
      subject.matches?([:a, :b, :c]).should be_true
    end

    it 'should return false for not an exact match' do
      subject.matches?([:b, :a, :c]).should be_false
    end
  end

  describe '#distance_from_solution' do
    describe 'simple 4-element solution' do
      let(:solution) { [:a, :b, :c, :d] }

      subject { described_class.new(solution) }

      it 'should do adjacent swaps' do
        subject.distance_from_solution([:b, :a, :c, :d]).should == 1
      end

      it 'should pass non-adjacent single swaps' do
        subject.distance_from_solution([:d, :b, :c, :a]).should == 3
      end

      it 'should deal with double swaps' do
        subject.distance_from_solution([:b, :a, :d, :c]).should == 1
      end

      it 'should deal with insertions' do
        subject.distance_from_solution([:a, :d, :b, :c]).should == 1
      end

      it 'should deal with exact matches' do
        subject.distance_from_solution([:a, :b, :c, :d]).should == 0
      end

      it 'should raise an error if the solution and attempt does not match' do
        expect {
          subject.distance_from_solution([:haha, :not, :real, :answers])
        }.to raise_error
      end
    end

    describe 'multi-element solution' do
      let(:solution) { (1..8).to_a }
      subject { described_class.new(solution) }

      it 'should deal with end swaps' do
        subject.distance_from_solution([8, 2, 3, 4, 5, 6, 7, 1]).should == 7
      end
    end
  end
end
