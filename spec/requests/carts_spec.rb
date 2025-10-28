require 'rails_helper'

RSpec.describe "/cart", type: :request do
  describe 'POST' do
    let(:product_one) { Product.create(name: "Product one", price: 1.0) }
    let(:product_two) { Product.create(name: "Product two", price: 2.0) }

    context 'when the cart_id does not exist on the session' do
      it 'creates a new cart and add the item' do
        expect {
          post '/cart', params: { product_id: product_one.id, quantity: 1 }, as: :json
          expect(response).to have_http_status(:ok)

          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:total_price].to_d).to eq(1)
          expect(response_body[:products].length).to eq(1)
          expect(response_body[:products].first[:id]).to eq(product_one.id)
          expect(response_body[:products].first[:name]).to eq(product_one.name)
          expect(response_body[:products].first[:quantity].to_d).to eq(1)
          expect(response_body[:products].first[:unit_price].to_d).to eq(product_one.price)
          expect(response_body[:products].first[:total_price].to_d).to eq(1)
        }.to change { Cart.count }.by(1)
         .and change { CartItem.count }.by(1)
      end
    end

    context 'when the cart_id does exist on the session' do
      before do
        post '/cart', params: { product_id: product_one.id, quantity: 1 }, as: :json
      end

      it 'updates the cart by adding the new item' do
        expect {
          post '/cart', params: { product_id: product_two.id, quantity: 1 }, as: :json
          expect(response).to have_http_status(:ok)

          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:total_price].to_d).to eq(3)
          expect(response_body[:products].length).to eq(2)
          expect(response_body[:products].second[:id]).to eq(product_two.id)
          expect(response_body[:products].second[:name]).to eq(product_two.name)
          expect(response_body[:products].second[:quantity].to_d).to eq(1)
          expect(response_body[:products].second[:unit_price].to_d).to eq(product_two.price)
          expect(response_body[:products].second[:total_price].to_d).to eq(2)
        }.to change { Cart.count }.by(0)
         .and change { CartItem.count }.by(1)
      end

      it 'return error when there is the same product already on the cart' do
          expect {
            post '/cart', params: { product_id: product_one.id, quantity: 1 }, as: :json
            expect(response).to have_http_status(:unprocessable_entity)

            response_body = JSON.parse(response.body, symbolize_names: true)
            expect(response_body[:error]).to eq("Product already on cart")

          }.to change { Cart.count }.by(0)
          .and change { CartItem.count }.by(0)
        end
    end

    context 'return error when' do
      it 'trying to add a product with invalid quantity' do
        expect {
          post '/cart', params: { product_id: product_one.id, quantity: -1 }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)

          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:error]).to include('Quantity must be greater than or equal to 0')

        }.to change { Cart.count }.by(0)
         .and change { CartItem.count }.by(0)
      end

      it 'trying to add a invalid product' do
        expect {
          post '/cart', params: { product_id: 'not_a_product_id', quantity: 1 }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)

          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:error]).to include('Validation failed: Product must exist')
        }.to change { Cart.count }.by(0)
        .and change { CartItem.count }.by(0)
      end

      it 'it lacks the product_id parameter' do
        expect {
          post '/cart', params: { quantity: 1 }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)

          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:error]).to include('Validation failed: Product must exist')
        }.to change { Cart.count }.by(0)
        .and change { CartItem.count }.by(0)
      end

      it 'it lacks the quantity parameter' do
        expect {
          post '/cart', params: { product_id: product_one.id }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)

          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:error]).to include('Validation failed: Quantity is not a number')
        }.to change { Cart.count }.by(0)
        .and change { CartItem.count }.by(0)
      end
    end
  end

  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
