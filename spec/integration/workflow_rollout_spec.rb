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

  context 'when removing the prerequisites of a process, and then reverting the changes' do
    it 'the process should have the original prerequisites again' do
      # create new version of workflow
      post "/v1/workflow/definition/workflows/#{wf_definition.id}/new_version"
      new_version_id = JSON.parse(response.body)['data']['id']
      new_wf_definition = Workflow::Definition::Workflow.find(new_version_id)

      # clones process that has a prerequisite
      sign_in(admin)
      dep_process = new_wf_definition.processes.find_by(title: 'Milestone C-X')
      post "/v1/workflow/definition/workflows/#{new_wf_definition.id}/new_version/#{dep_process.id}"
      expect(response).to have_http_status(:success)
      dependency_id = JSON.parse(response.body)['data']['relationships']['workableDependencies']['data'].first['id']
      selected_process_id = JSON.parse(response.body)['data']['relationships']['selectedProcesses']['data'].first['id']

      # remove prerequisite from newly cloned process
      sign_in(admin)
      delete "/v1/workflow/definition/dependencies/#{dependency_id}"
      expect(response).to have_http_status(:success)
      dep_process_cloned = new_wf_definition.reload.processes.find_by(title: 'Milestone C-X')
      expect(dep_process_cloned.workable_dependencies.where(workflow_id: new_wf_definition.id).count).to eq(0)

      # revert changes made to newly cloned process
      sign_in(admin)
      put "/v1/workflow/definition/selected_processes/#{selected_process_id}/revert"
      expect(response).to have_http_status(:success)

      dep_process_reverted = new_wf_definition.reload.processes.find_by(title: 'Milestone C-X')
      expect(dep_process_reverted.workable_dependencies.where(workflow_id: new_wf_definition.id).count).to eq(1)

      Bullet.enable = true
    end
  end

  context 'when upgrading two processes that are dependent on eachother' do
    it 'keeps the dependencies intact' do
      Bullet.enable = false
      # create new version of workflow
      post "/v1/workflow/definition/workflows/#{wf_definition.id}/new_version"
      new_version_id = JSON.parse(response.body)['data']['id']
      new_wf_definition = Workflow::Definition::Workflow.find(new_version_id)

      # start the instance of this process
      prereq_process = new_wf_definition.processes.find_by(title: 'Milestone C')
      prereq_process_instance = prereq_process.instances.first
      prereq_process_instance.started!

      # clones process that is a prerequisite
      sign_in(admin)
      post "/v1/workflow/definition/workflows/#{new_wf_definition.id}/new_version/#{prereq_process.id}"
      expect(response).to have_http_status(:success)

      # clones process that has a prerequisite
      sign_in(admin)
      dep_process = new_wf_definition.processes.find_by(title: 'Milestone C-X')
      post "/v1/workflow/definition/workflows/#{new_wf_definition.id}/new_version/#{dep_process.id}"
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
