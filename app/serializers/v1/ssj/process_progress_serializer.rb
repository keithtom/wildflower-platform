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
    processes.each do |process|
      if process.phase.empty?
        Rails.logger.warn("process phase doesn't exist, id: #{process.id}")
        next
      end

      if grouped_processes[process.phase.first.name].nil?
        grouped_processes[process.phase.first.name] = {name: process.phase.first.name, total: 0, statuses: []}
      end

      grouped_processes[process.phase.first.name][:total] += 1
      grouped_processes[process.phase.first.name][:statuses] << process_status(process)
    end

    grouped_processes.each do |phase, status_info|
      status_info[:statuses] = status_info[:statuses].sort_by{|status| V1::Statusable::STATUS.index(status) * -1}
    end
    return grouped_processes.values
  end

  def grouped_by_category(processes)
    grouped_processes = {}
    processes.each do |process|
      process_categories(process).each do |category|
        category_name = category.parameterize(separator: '_')

        if grouped_processes[category_name].nil?
          grouped_processes[category_name] = {name: category, total: 0, statuses: []}
        end

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
