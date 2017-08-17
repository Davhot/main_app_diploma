require "rails_helper"

RSpec.describe MainHotCatchLog, :type => :model do
  describe "Method find_and_count_log_if_exist" do

    let(:log) { FactoryGirl.create(:main_hot_catch_log) }

    it "args nil" do
      expect(MainHotCatchLog.find_and_count_log_if_exist(nil, nil, nil)).to eq(false)
    end

    it "args empty strings" do
      expect(MainHotCatchLog.find_and_count_log_if_exist("", "", "")).to eq(false)
    end


  end
end
