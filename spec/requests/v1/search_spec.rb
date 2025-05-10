require 'rails_helper'

RSpec.describe 'V1::Searches', type: :request do
  describe 'GET /index', search: true do
    let!(:person1) { create(:person, first_name: 'Keith', active: true) }
    let!(:person2) { create(:person, first_name: 'Keith', last_name: 'Inactive', active: false) }
    let!(:school1) { create(:school, name: 'Keith Montessori', affiliated: true, directory_visible: true) }
    let!(:school2) { create(:school, name: 'Unaffiliated Montessori', affiliated: false, directory_visible: false) }

    before do
      Person.reindex
      School.reindex
      Bullet.enable = false
    end

    it 'succeeds for people' do
      get '/v1/search', params: { q: 'Keith', models: 'person' }, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)

      expect(json_response['data']).to include(have_type('personSearch').and(have_attribute(:firstName).with_value('Keith')))
      expect(json_response['data']).not_to include(have_type('personSearch').and(have_attribute(:lastName).with_value('Inactive')))
    end

    describe 'with show_all parameter' do
      it 'returns only active people by default' do
        get '/v1/search', params: { q: 'Keith', models: 'person' },
                          headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)

        expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
        expect(json_response['data'].map { |p| p['id'] }).not_to include(person2.external_identifier)
      end

      it 'returns both active and inactive people when show_all is true' do
        get '/v1/search', params: { q: 'Keith', models: 'person', show_all: 'true' },
                          headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)

        expect(json_response['data']).to include(
          have_type('personSearch').and(have_id(person1.external_identifier)),
          have_type('personSearch').and(have_id(person2.external_identifier))
        )
      end

      it 'applies show_all parameter to default search as well' do
        get '/v1/search', params: { q: 'Keith', show_all: 'true' },
                          headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)

        # Default search includes person model
        expect(json_response['data']).to include(
          have_type('personSearch').and(have_id(person1.external_identifier)),
          have_type('personSearch').and(have_id(person2.external_identifier))
        )
      end
    end

    it 'succeeds for schools' do
      get '/v1/search', params: { q: 'Keith', models: 'school' }, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)

      expect(json_response['data']).to include(have_type('schoolSearch').and(have_attribute(:name).with_value('Keith Montessori')))
      expect(json_response['data']).not_to include(have_type('schoolSearch').and(have_attribute(:name).with_value('Unaffiliated Montessori')))
    end

    describe 'school filters' do
    end

    describe 'people filters' do
      describe 'with language filters' do
        describe 'one language filter for person with one language' do
          before do
            person1.primary_language = 'German - Deutsch'
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { languages: ['German - Deutsch'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:languages]).to include('German - Deutsch')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end

        describe 'two language filter for person with one language' do
          before do
            person1.primary_language = 'German - Deutsch'
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { languages: ['German - Deutsch', 'English'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:languages]).to include('German - Deutsch')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end

        describe 'one language filter for person with two languages' do
          before do
            person1.primary_language = 'German - Deutsch'
            person1.language_list.add('English')
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { languages: ['German - Deutsch'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:languages]).to include('German - Deutsch')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end

        describe 'two language filter for person with two languages' do
          before do
            person1.primary_language = 'German - Deutsch'
            person1.language_list.add('English')
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { languages: ['English', 'German - Deutsch'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:languages]).to include('German - Deutsch')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end
      end

      describe 'with race/ethnicity filters' do
        describe 'one race/ethnicity filter that excludes person with one race/ethnicity' do
          before do
            person1.race_ethnicity_other = 'African-American'
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { race_ethnicities: ['Asian'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:race_ethnicities]).not_to include('Asian')
            expect(json_response['data']).to be_empty
          end
        end

        describe 'one race/ethnicity filter for person with one race/ethnicity' do
          before do
            person1.race_ethnicity_other = 'African-American'
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { race_ethnicities: ['African-American'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:race_ethnicities]).to include('African-American')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end

        describe 'two race/ethnicity filters for person with one race/ethnicity' do
          before do
            person1.race_ethnicity_other = 'African-American'
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search',
                params: { q: 'Keith', people_filters: { race_ethnicities: %w[African-American Asian] } }, headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:race_ethnicities]).to include('African-American')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end

        describe 'one race/ethnicity filter for person with two race/ethnicities' do
          before do
            person1.race_ethnicity_other = 'African-American'
            person1.race_ethnicity_list.add('Asian')
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { race_ethnicities: ['Asian'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:race_ethnicities]).to include('African-American')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end

        describe 'two race/ethnicity filters for person with two race/ethnicities' do
          before do
            person1.race_ethnicity_other = 'African-American'
            person1.race_ethnicity_list.add('Asian')
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search',
                params: { q: 'Keith', people_filters: { race_ethnicities: %w[African-American Asian] } }, headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:race_ethnicities]).to include('African-American')
            expect(json_response['data']).to include(have_type('personSearch').and(have_id(person1.external_identifier)))
          end
        end
      end

      describe 'with location filters' do
        let(:address) { create(:address, city: 'Buffalo', state: 'New York') }

        describe 'one location filter that excludes person with different location' do
          before do
            person1.address = address
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { address_state: ['California'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:address_state]).not_to include('California')
            expect(json_response['data']).to be_empty
          end
        end

        describe 'one location filter for person with that location' do
          before do
            person1.address = address
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search', params: { q: 'Keith', people_filters: { address_state: ['New York'] } },
                              headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:address_state]).to include('New York')
            expect(json_response['data']).to include(have_type('personSearch').and(have_attribute(:location).with_value(address.city + ', ' + address.state)))
          end
        end

        describe 'one multiple location filters for person inclusive of that location' do
          before do
            person1.address = address
            person1.save!
            Person.reindex
            School.reindex
          end

          it 'succeeds' do
            get '/v1/search',
                params: { q: 'Keith', people_filters: { address_state: ['Rhode Island', 'New York', 'California'] } }, headers: { 'ACCEPT' => 'application/json' }
            expect(response).to have_http_status(:success)

            expect(person1.search_data[:address_state]).to include('New York')
            expect(json_response['data']).to include(have_type('personSearch').and(have_attribute(:location).with_value(address.city + ', ' + address.state)))
          end
        end
      end
    end
  end
end
