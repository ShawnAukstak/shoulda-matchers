module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_absence_of` matcher tests the usage of the
      # `validates_absence_of` validation.
      #
      #     class PowerHungryCountry
      #       include ActiveModel::Model
      #       attr_accessor :nuclear_weapons
      #
      #       validates_absence_of :nuclear_weapons
      #     end
      #
      #     # RSpec
      #     RSpec.describe PowerHungryCountry, type: :model do
      #       it { should validate_absence_of(:nuclear_weapons) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PowerHungryCountryTest < ActiveSupport::TestCase
      #       should validate_absence_of(:nuclear_weapons)
      #     end
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class PowerHungryCountry
      #       include ActiveModel::Model
      #       attr_accessor :nuclear_weapons
      #
      #       validates_absence_of :nuclear_weapons, on: :create
      #     end
      #
      #     # RSpec
      #     RSpec.describe PowerHungryCountry, type: :model do
      #       it { should validate_absence_of(:nuclear_weapons).on(:create) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PowerHungryCountryTest < ActiveSupport::TestCase
      #       should validate_absence_of(:nuclear_weapons).on(:create)
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class PowerHungryCountry
      #       include ActiveModel::Model
      #       attr_accessor :nuclear_weapons
      #
      #       validates_absence_of :nuclear_weapons,
      #         message: "there shall be peace on Earth"
      #     end
      #
      #     # RSpec
      #     RSpec.describe PowerHungryCountry, type: :model do
      #       it do
      #         should validate_absence_of(:nuclear_weapons).
      #           with_message("there shall be peace on Earth")
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PowerHungryCountryTest < ActiveSupport::TestCase
      #       should validate_absence_of(:nuclear_weapons).
      #         with_message("there shall be peace on Earth")
      #     end
      #
      # @return [ValidateAbsenceOfMatcher}
      #
      def validate_absence_of(attr)
        ValidateAbsenceOfMatcher.new(attr)
      end

      # @private
      class ValidateAbsenceOfMatcher < ValidationMatcher
        def initialize(attribute)
          super(attribute)
          @expected_message = :present
        end

        def simple_description
          "fail validation when :#{attribute} is empty/falsy"
        end

        protected

        def add_submatchers
          add_matcher_disallowing([value], expected_message)
        end

        private

        attr_reader :expected_message

        def value
          if reflection
            obj = reflection.klass.new
            if collection?
              [ obj ]
            else
              obj
            end
          else
            case column_type
            when :integer, :float then 1
            when :decimal then BigDecimal.new(1, 0)
            when :datetime, :time, :timestamp then Time.now
            when :date then Date.new
            when :binary then '0'
            else 'an arbitrary value'
            end
          end
        end

        def column_type
          subject.class.respond_to?(:columns_hash) &&
            subject.class.columns_hash[attribute.to_s].respond_to?(:type) &&
            subject.class.columns_hash[attribute.to_s].type
        end

        def collection?
          if reflection
            [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
          else
            false
          end
        end

        def reflection
          subject.class.respond_to?(:reflect_on_association) &&
            subject.class.reflect_on_association(attribute)
        end
      end
    end
  end
end
