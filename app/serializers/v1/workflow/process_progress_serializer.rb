class V1::Workflow::ProcessProgressSerializer < ApplicationSerializer
  include V1::Statusable

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
        puts "##### process phase doesn't exist, id: #{process.id}"
        next
      end

      if grouped_processes[process.phase.first.name].nil?
        grouped_processes[process.phase.first.name] = {name: process.phase.first.name}.merge(status_hash)
      end

      grouped_processes[process.phase.first.name][:total] += 1
      grouped_processes[process.phase.first.name][process_status(process).parameterize(separator: '_').to_sym] += 1
    end

    return grouped_processes
  end

  def grouped_by_category(processes)
    grouped_processes = {}
    processes.each do |process|
      process.categories.each do |category|
        category_name = category.name.parameterize(separator: '_')

        if grouped_processes[category_name].nil?
          grouped_processes[category_name] = {name: category.name}.merge(status_hash)
        end

        grouped_processes[category_name][:total] += 1
        grouped_processes[category_name][process_status(process).parameterize(separator: '_').to_sym] += 1
      end
    end
    grouped_processes
  end

  def status_hash
    status_hash = {total: 0}
    V1::Statusable::STATUS.each do |status|
      status_hash[status.parameterize(separator: '_').to_sym] = 0
    end
    return status_hash
  end

  def process_status(process)
    self.class.process_status(process)
  end
end
