# typed: strict
# frozen_string_literal: true

return unless defined?(WillPaginate)

require "tapioca/dsl/helpers/active_record_constants_helper"

module Tapioca
  module Dsl
    module Compilers
      # `Tapioca::Dsl::Compilers::WillPaginate` generate types for WillPaginate.
      class WillPaginate < Compiler
        extend T::Sig
        include Helpers::ActiveRecordConstantsHelper

        ConstantType = type_member { { fixed: T.class_of(::ActiveRecord::Base) } }

        ChainClassName = T.let("PrivateAssociationRelationWillPaginateChain", String)

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[Module]) }
          def gather_constants
            ActiveRecord::Base.descendants.reject(&:abstract_class?)
          end
        end

        sig { override.void }
        def decorate
          root.create_path(constant) do |klass|
            klass.create_extend("WillPaginateMethods")

            scope = klass.create_module("WillPaginateMethods")

            scope.create_method(
              "paginate",
              parameters: [
                create_param("options", type: "T.untyped"),
              ],
              return_type: ChainClassName,
            )
            scope.create_method(
              "page",
              parameters: [
                create_param("num", type: "T.untyped"),
              ],
              return_type: ChainClassName,
            )
            scope.create_method(
              "paginate_by_sql",
              parameters: [
                create_param("sql", type: "String"),
                create_param("options", type: "T.untyped"),
              ],
              return_type: "::WillPaginate::Collection",
            )


            klass.create_class(ChainClassName, superclass_name: RelationClassName) do |chain_class|
              create_collection_methods(chain_class)
            end
          end
        end

        sig { params(scope: RBI::Scope).void }
        def create_collection_methods(scope)
          scope.create_method(
            "total_pages",
            parameters: [],
            return_type: "Integer",
          )
          scope.create_method(
            "previous_page",
            parameters: [],
            return_type: "T.nilable(Integer)",
          )
          scope.create_method(
            "next_page",
            parameters: [],
            return_type: "T.nilable(Integer)",
          )
          scope.create_method(
            "out_of_bounds?",
            parameters: [],
            return_type: "T::Boolean",
          )
        end
      end
    end
  end
end
