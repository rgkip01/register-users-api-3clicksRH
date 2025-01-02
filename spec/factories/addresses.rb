FactoryBot.define do
  factory :address do
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip_code }
    country { Faker::Address.country }
    complement { nil }
    user { nil }
  end
end
