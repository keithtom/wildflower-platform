class V1::Ssj::ProcessProgressSerializer < ApplicationSerializer
  include V1::Statusable
  include V1::Categorizable

  # method override
  def serializable_hash
    {
      by_phase: grouped_by_phase(@resource),
      by_category: grouped_by_category(@resource)

    }
  end

  private

  def grouped_by_phase(processes)
    grouped_processes = {}

    Workflow::Definition::Process::PHASES.each do |phase|
      grouped_processes[phase] = {name: phase, total: 0, statuses: []}
    end

    processes.each do |process|
      if process.phase.empty?
        Rails.logger.warn("process phase doesn't exist, id: #{process.id}")
        next
      end

      grouped_processes[process.phase.first.name][:total] += 1
      grouped_processes[process.phase.first.name][:statuses] << process_status(process)
    end

    grouped_processes.each do |phase, status_info|
      status_info[:statuses] = status_info[:statuses].sort_by{|status| V1::Statusable::STATUS.index(status)}
    end
    return grouped_processes.values
  end

  def grouped_by_category(processes)
    grouped_processes = {}

    ActsAsTaggableOn::Tag.for_context(:categories).sort_by{|tag| tag.name.downcase}.each do |category|
      category_name = category.name.parameterize(separator: '_')
      grouped_processes[category_name] = {name: category.name, total: 0, statuses: []}
    end

    processes.each do |process|
      process_categories(process).each do |category|
        category_name = category.parameterize(separator: '_')
        grouped_processes[category_name][:total] += 1
        grouped_processes[category_name][:statuses] << process_status(process)
      end
    end

    grouped_processes.each do |category, status_info|
      status_info[:statuses] = status_info[:statuses].sort_by{|status| V1::Statusable::STATUS.index(status)}
    end

    return grouped_processes.values
  end

  def process_status(process)
    self.class.process_status(process)
  end

  def process_categories(process)
    self.class.get_categories(process)
  end
end
