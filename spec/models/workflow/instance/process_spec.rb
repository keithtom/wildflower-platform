require 'rails_helper'

RSpec.describe Workflow::Instance::Process, type: :model do
  let(:process) { create(:workflow_instance_process) }

  describe ".past_due" do
    let!(:process1) { create(:workflow_instance_process, due_date: 2.days.ago, completion_status: :unstarted) }
    let!(:process2) { create(:workflow_instance_process, due_date: 1.day.ago, completion_status: :started) }
    let!(:process3) { create(:workflow_instance_process, due_date: Time.zone.today, completion_status: :finished) }
    let!(:process4) { create(:workflow_instance_process, due_date: Time.zone.today, completion_status: :unstarted) }
    let!(:process5) { create(:workflow_instance_process, due_date: 1.day.from_now, completion_status: :unstarted) }
    let!(:process6) { create(:workflow_instance_process, due_date: 1.day.from_now, completion_status: :finished) }

    it 'returns processes that are past due and not finished' do
      expect(described_class.past_due).to match_array([process1, process2])
    end
  end

  describe ".within_timeframe" do
    let!(:process1) { create(:workflow_instance_process, suggested_start_date: 2.days.ago, due_date: 1.day.ago) }
    let!(:process2) { create(:workflow_instance_process, suggested_start_date: 1.day.ago, due_date: Time.zone.today) }
    let!(:process3) { create(:workflow_instance_process, suggested_start_date: Time.zone.today, due_date: 1.day.from_now) }
    let!(:process4) { create(:workflow_instance_process, suggested_start_date: 1.day.from_now, due_date: 2.days.from_now) }

    it 'returns processes within the specified timeframe' do
      expect(described_class.within_timeframe(Time.zone.today)).to match_array([process2, process3])
    end
  end
end
