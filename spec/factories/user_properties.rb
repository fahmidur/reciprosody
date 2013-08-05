# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_property do
    user nil
    name "MyString"
    value "MyString"
  end
end
