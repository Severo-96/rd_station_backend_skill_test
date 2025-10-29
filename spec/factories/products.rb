FactoryBot.define do
  factory :product do
    name { 'Product one' }
    price { 1 }

    trait :product_two do
      name { 'Product two' }
      price { 2 }
    end
  end
end
