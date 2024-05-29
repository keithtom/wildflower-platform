# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Workflow Rollout Feature', type: :request do
  let(:wf_definition) { Workflow::Definition::Workflow::CreateDummy.run('Basic Workflow - Testing Prerequisites') }
  let(:wf_instance) { wf_definition.instances.create! }
  let(:admin) { create(:user, :admin) }

  before do
    SSJ::Initialize.run(wf_instance.id)
    sign_in(admin)
  end

  context 'when upgrading a process that is a prerequisite' do
    let(:process_with_prerequisites) { wf_instance.processes.find_by(title: 'Milestone D-E-F') }
    let(:new_title) { 'Milestone E - updated' }

    it 'updates the prerequisite instance' do
      # create new version of workflow
      post "/v1/workflow/definition/workflows/#{wf_definition.id}/new_version"
      new_version_id = JSON.parse(response.body)['data']['id']
      new_wf_definition = Workflow::Definition::Workflow.find(new_version_id)
      process = new_wf_definition.processes.find_by(title: 'Milestone E')

      # clones process
      sign_in(admin)
      post "/v1/workflow/definition/workflows/#{new_wf_definition.id}/new_version/#{process.id}"
      expect(response).to have_http_status(:success)
      new_process_id = JSON.parse(response.body)['data']['id']

      # edit newly cloned process
      sign_in(admin)
      put "/v1/workflow/definition/processes/#{new_process_id}", params: { process: { title: new_title } }
      expect(response).to have_http_status(:success)

      # publish workflow
      perform_enqueued_jobs do
        sign_in(admin)
        put "/v1/workflow/definition/workflows/#{new_wf_definition.id}/publish"
        expect(response).to have_http_status(:success)
      end

      # test that edited process is a prerequisite to another process
      expect(process_with_prerequisites.reload.prerequisites.find_by(title: new_title)).not_to be_nil
    end
  end

  context 'when removing a process that has a prerequisite' do
    it 'removes the prerequisite dependency' do
      Bullet.enable = false
      # create new version of workflow
      post "/v1/workflow/definition/workflows/#{wf_definition.id}/new_version"
      new_version_id = JSON.parse(response.body)['data']['id']
      new_wf_definition = Workflow::Definition::Workflow.find(new_version_id)
      process = new_wf_definition.processes.find_by(title: 'Milestone C')

      # clones process
      sign_in(admin)
      post "/v1/workflow/definition/workflows/#{new_wf_definition.id}/new_version/#{process.id}"
      expect(response).to have_http_status(:success)

      # clones another process where the cloned process is a prerequisite
      sign_in(admin)
      dep_process = new_wf_definition.processes.find_by(title: 'Milestone C-X')
      post "/v1/workflow/definition/workflows/#{new_wf_definition.id}/new_version/#{dep_process.id}"
      expect(response).to have_http_status(:success)
      new_dep_process_id = JSON.parse(response.body)['data']['id']
      dependency_id = JSON.parse(response.body)['data']['relationships']['workableDependencies']['data'].first['id']

      # remove prerequisite from newly cloned process
      sign_in(admin)
      delete "/v1/workflow/definition/dependencies/#{dependency_id}"
      expect(response).to have_http_status(:success)

      # remove process where the cloned process is a prerequisite
      sign_in(admin)
      put "/v1/workflow/definition/workflows/#{new_wf_definition.id}/remove_process/#{new_dep_process_id}"
      expect(response).to have_http_status(:success)

      # publish workflow
      perform_enqueued_jobs do
        sign_in(admin)
        put "/v1/workflow/definition/workflows/#{new_wf_definition.id}/publish"
        expect(response).to have_http_status(:success)
      end

      expect(new_wf_definition.reload.needs_support).to be_falsey
      Bullet.enable = true
    end
  end
end
