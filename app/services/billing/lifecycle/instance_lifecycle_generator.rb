# frozen_string_literal: true

module Billing
  module Lifecycle
    class InstanceLifecycleGenerator
      Timeframe = Struct.new(:start, :end)

      def initialize(last_invoice, timeframe, queries)
        @last_invoice = last_invoice
        @queries = queries
        @timeframe = timeframe
        @build_actions_by_project_instance = @queries.build_actions_by_project_instance(@timeframe)
      end

      def call
        lifecycles = @build_actions_by_project_instance.map do |project_instance_id, build_actions|
          build_actions = build_actions.sort_by(&:end_time)
          lifecycle_for(project_instance_id, build_actions)
        end

        lifecycles_from_instances_without_build_actions + lifecycles
      end

      private

      def lifecycle_for(project_instance_id, build_actions)
        lifecycle = build_new_lifecycle(project_instance_id, build_actions.first.project_instance.name, build_actions)
        process_previously_created_instances(build_actions, lifecycle)

        build_actions.each_with_object(Billing::Lifecycle::ActionToState.new(lifecycle)) do |build_action, action_to_instance|
          action_to_instance.call(build_action)
        end

        lifecycle.end_last_active_state(@timeframe.end)
        lifecycle
      end

      def build_new_lifecycle(project_instance_id, project_instance_name, build_actions)
        Billing::Lifecycle::InstanceLifecycle.new(
          project_instance_id: project_instance_id,
          project_instance_name: project_instance_name,
          build_actions_ids: build_actions.map(&:id)
        )
      end

      def process_previously_created_instances(build_actions, lifecycle)
        first_action = build_actions.first
        return if first_action.action == BuildActionConstants::CREATE_INSTANCE

        previous_build_action = @queries.previous_successful_build_action_for(first_action)
        lifecycle.add_state_for_previous_actions(previous_build_action&.action, start_time: @timeframe.start, end_time: nil, configurations: previous_build_action&.configurations)
      end

      def lifecycles_from_instances_without_build_actions
        instances_without_build_actions.map do |project_instance|
          previous_action = @queries.previous_actions_for(project_instance, end_time: @timeframe.start).last
          lifecycle = build_new_lifecycle(project_instance.id, project_instance.name, [])
          lifecycle.add_state_for_previous_actions(previous_action&.action, start_time: @timeframe.start, end_time: @timeframe.end, configurations: previous_action&.configurations)
          lifecycle
        end
      end

      def instances_without_build_actions
        processed_ids = @build_actions_by_project_instance.map { |id, _| id }
        @queries.active_instances(@last_invoice).filter { |instance| processed_ids.exclude?(instance.id) }
      end
    end
  end
end
