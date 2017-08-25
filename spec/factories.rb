FactoryGirl.define do
  factory :user do
    email "MyString"
    crypted_password "MyString"
  end
  factory :hot_catch_app do
    name "MyString"
  end
  factory :main_hot_catch_log do
    log_data            "some message"
    count_log           1
    sequence(:id_log_origin_app)  { |n| n }
    sequence(:name_app)  { |n| "my_app#{n}" }
    from_log            "Rails"
    status              "SERVER_ERROR"
  end
end
