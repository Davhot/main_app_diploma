FactoryGirl.define do
  factory :main_hot_catch_log do
    log_data            "some message"
    count_log           1
    id_log_origin_app   1
    name_app            "my_app"
    from_log            "Rails"
    status              "ERROR"
  end
end
