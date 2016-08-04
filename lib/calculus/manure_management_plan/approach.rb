module Calculus
  module ManureManagementPlan
    class Approach < AbstractApproach
      #An approach has to answer to a question_group, by filling the question_group.answer hash

      delegate :name, :actions, :supply_nature, :parameters, :manure_management_plan_zone, :questions, to: :@application

      def initialize(application)
        @application = application
        @question_group = QuestionGroup.new(questions["questions"].values)
      end

      def self.build_approach(application)
        approach = Object.const_get("Calculus::ManureManagementPlan::"+application.approach.name).new(application)
      end

      def questions_answered?
        @question_group.has_answers?
      end

    end
  end
end