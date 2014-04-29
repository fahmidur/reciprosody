# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :search_log_entry do
    user nil
    resource_type nil
    input "MyString"
    output "MyText"
  end
end
