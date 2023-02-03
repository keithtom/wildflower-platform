class V1::Workflow::ProcessByStatusSerializer < ApplicationSerializer  
  include V1::Statusable

  belongs_to :workflow, record_type: :workflow_instance_workflow, id_method_name: :external_identifier,
    serializer: V1::Workflow::WorkflowSerializer do |process|
      process.workflow
    end

  has_many :steps, record_type: :workflow_instance_step, id_method_name: :external_identifier,
    serializer: V1::Workflow::StepSerializer do |process, params|
      process.steps
    end

  # method override
  def serializable_hash
    grouped_processes = grouped_by_status(@resource)
    grouped_processes.map do |key, processes|
      [key, serialized_processes(processes)]
    end.to_h
  end

  private

  def serialized_processes(processes)
    processes.map do |process|
      V1::Workflow::ProcessSerializer.new(process, root: false, include: @includes)
    end
  end

  def grouped_by_status(processes)
    grouped_processes = {}
    processes.each do |process|
      if grouped_processes[self.class.process_status(process)].nil?
        grouped_processes[self.class.process_status(process)] = []
      end

      grouped_processes[self.class.process_status(process)] << process
    end

    return grouped_processes
  end
end
