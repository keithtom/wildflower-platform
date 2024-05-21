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
end

# create a new workflow using CreateDummy service
# instantiate that workflow
# create a person, with an ssj team, using the new workflow instance

# hit the new_version of workflow endpoint, grab the workflow id
# get the workflow process with name "Milestone E"
# hit new version endpoint for Milestone E
# hit publish endpoint

# observe that the process instance for Milestone D-E-F does not have the prerequisite Milestone E
