require 'rails_helper'

describe 'Meals API', type: :request do

  context 'authenticated' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:meals) { user.meals.create FactoryGirl.attributes_for_list(:meal, 2) }

    before do
      post "/api/users/sign_in", user: { email: user.email, password: user.password }
    end

    describe 'index' do
      it 'success' do
        get '/api/meals'
        expect(response).to have_http_status(200)

        json_arr = JSON.parse(response.body)
        expect(json_arr.length).to eq 2

        expect(json_arr.map{|m| m['id']}).to eq meals.map(&:id)

        json_meal = json_arr.first
        meal = meals.first
        expect(json_meal.keys.sort).to eq %w{id eaten_at calories description}.sort
        expect(json_meal['id']).to eq meal.id
        expect(json_meal['calories']).to eq meal.calories
        expect(json_meal['description']).to eq meal.description
        expect(json_meal['eaten_at']).to eq meal.eaten_at.as_json
      end
    end

    describe 'create' do
      let(:meal_attr) {
        {
          eaten_at: Time.now.utc.as_json,
          description: 'description',
          calories: 500
        }
      }

      it 'success' do
        post '/api/meals', meal: meal_attr
        expect(response).to have_http_status(201)

        expect(user.meals.count).to eq 3
        meal = user.meals.last
        expect(meal.calories).to eq meal_attr[:calories]
        expect(meal.description).to eq meal_attr[:description]
        expect(meal.eaten_at.as_json).to eq meal_attr[:eaten_at].as_json

        json = JSON.parse(response.body)
        expect(json.keys.sort).to eq %w{id calories eaten_at description}.sort
        expect(json['id']).to eq meal.id
        expect(json['calories']).to eq meal.calories
        expect(json['description']).to eq meal.description
        expect(json['eaten_at']).to eq meal.eaten_at.as_json
      end
    end
  end

  context 'unauthenticated' do
    it 'index' do
      get '/api/meals'
      expect(response).to have_http_status(401)
    end

    it 'create' do
      post '/api/meals'
      expect(response).to have_http_status(401)
    end
  end
end