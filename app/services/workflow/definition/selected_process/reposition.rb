module Workflow
  module Definition
    class SelectedProcess
      class Reposition < BaseService
        def initialize(selected_process, position)
          @selected_process = selected_process
          @workflow = @selected_process.workflow
          @position = position
        end

        def run
          validate_position
          validate_if_renumbering_needed

          if @workflow.published? # instantaneous change
            update_selected_process_position
            propagate_position_change_to_instances(@selected_process.reload)
          else
            unless @selected_process.upgraded? || @selected_process.added? || @selected_process.initialized?
              @selected_process.reposition!
            end # keep the state of an upgraded, added or initialized selected process, even after a position change
            @selected_process.update!(position: @position)
          end

          if renumbering_needed?
            renumber_all_positions(@workflow.published?)
            if @workflow.published?
              @workflow.selected_processes.each do |sp|
                propagate_position_change_to_instances(sp)
              end
            end
          end
        end

        private

        def validate_position
          raise RepositionError, 'new position must be an integer' if @position.to_i.to_s != @position.to_s

          raise RepositionError, 'new position cannot be 0' if @position.to_i == 0
        end

        def validate_if_renumbering_needed
          if renumbering_needed?
            raise RepositionError, 'cannot reposition selected process because of potential collision'
          end
        end

        def update_selected_process_position
          @selected_process.position = @position
          @selected_process.save!
        end

        def propagate_position_change_to_instances(selected_process)
          workflow_instance_ids = @workflow.instances.pluck(:id)
          selected_process.process.instances.where(workflow_id: workflow_instance_ids).update_all(position: selected_process.position)
        end

        def renumbering_needed?
          last_position = 0
          @workflow.selected_processes.where.not(position: nil).order(:position).each do |sp|
            delta = sp.position - last_position
            return true if delta < 2

            last_position = sp.position
          end
          false
        end

        def renumber_all_positions(published)
          @workflow.selected_processes.where.not(position: nil).order(:position).each_with_index do |selected_process, i|
            selected_process.position = ::Workflow::Definition::SelectedProcess::DEFAULT_INCREMENT * (i + 1)
            selected_process.save!
            selected_process.reposition! if !published && selected_process.replicated?
          end
        end
      end

      class RepositionError < StandardError
      end
    end
  end
end
