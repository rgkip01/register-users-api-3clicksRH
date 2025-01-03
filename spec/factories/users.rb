# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    document { Faker::Number.number(digits: 11) }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 70) }
  end
end
