require "rails_helper"

RSpec.describe MainHotCatchLog, :type => :model do
  describe "Method MainHotCatchLog.find_and_count_log_if_exist(id_log, name_app, count_log)" do

    before(:all) {3.times{ FactoryGirl.create(:main_hot_catch_log) }}

    it "args nil" do
      expect(MainHotCatchLog.find_and_count_log_if_exist(nil, nil, nil)).to eq(false)
    end

    it "args empty strings" do
      expect(MainHotCatchLog.find_and_count_log_if_exist("", "", "")).to eq(false)
    end

    it "no count_log" do
      expect(MainHotCatchLog.find_and_count_log_if_exist(1, "my_app1", nil)).to eq(true)
    end

  end
end
