FactoryGirl.define do
  factory :user_request do
    ip "MyString"
    request_time "2017-10-22 17:53:39"
  end
  factory :role_user do
    
  end
  factory :role do
    name "MyString"
    info "MyString"
    full_info "MyString"
  end
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
