# frozen_string_literal: true

module Billing
  module Invoice
    class CostsCalculator
      def initialize(lifecycles, timeframe)
        @lifecycles = lifecycles
        @timeframe = timeframe
        @pricing = ApplicationCost.find_by(name: "default")
      end

      def call
        costs = calculate_total_costs
        costs[:sleep] + costs[:run] + costs[:build]
      end

      private

      def calculate_total_costs
        @lifecycles.each_with_object(sleep: 0, run: 0, build: 0) do |lifecycle, result|
          Billing::Lifecycle::InstanceLifecycle::STATE_TYPES.each do |type|
            next lifecycle.costs[type] = 0 if lifecycle.durations[type].zero?

            set_cost_to_lifecycle(lifecycle, type)
            result[type] += lifecycle.costs[type]
          end
        end
      end

      def set_cost_to_lifecycle(lifecycle, type)
        configurations = lifecycle.states[type].first&.configurations
        lifecycle.multipliers[type] = calculate_price(configurations, type)
        lifecycle.costs[type] = duration_to_cost(lifecycle.durations[type], @pricing["#{type}_cents".to_sym], configurations, type)
      end

      def duration_to_cost(duration_seconds, cost_cents, configurations, type)
        return 0 if duration_seconds.zero?

        days = duration_seconds / 60.to_d / 60.to_d / 24.to_d

        (days * (calculate_price(configurations, type) * cost_cents / 30.to_d)).floor
      end

      def calculate_price(configurations, type)
        if type == :build
          configurations.inject(0) { |result, configuration| result + configuration.web_processes.uniq { |web_process| web_process["dockerfile_path"] }.count }
        else
          configurations.inject(0) { |result, configuration| result + configuration.web_processes.count + configuration.addons.count }
        end
      end
    end
  end
end
