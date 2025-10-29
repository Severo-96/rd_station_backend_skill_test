FactoryBot.define do
  factory :cart do
    total_price { 1 }

    trait :abandoned do
      abandoned { true }
    end
  end
end
