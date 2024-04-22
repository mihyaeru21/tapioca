# typed: true
# frozen_string_literal: true

require "spec_helper"

module Tapioca
  module Dsl
    module Compilers
      class WillPaginateSpec < ::DslSpec
        include Tapioca::SorbetHelper

        describe "Tapioca::Dsl::Compilers::WillPaginate" do
          sig { void }
          def before_setup
            require "active_record"
            require "will_paginate"
          end

          # describe "initialize" do
          #   it "gathers no constants if there are no ActiveRecord classes" do
          #     assert_empty(gathered_constants)
          #   end

          #   it "gathers only ActiveRecord constants with no abstract classes" do
          #     add_ruby_file("post.rb", <<~RUBY)
          #       class Post < ActiveRecord::Base
          #       end

          #       class Product < ActiveRecord::Base
          #         self.abstract_class = true
          #       end

          #       class User
          #       end
          #     RUBY

          #     assert_equal(["Post"], gathered_constants)
          #   end
          # end

          describe "decorate" do
            before do
              require "active_record"

              ::ActiveRecord::Base.establish_connection(
                adapter: "sqlite3",
                database: ":memory:",
              )
            end

            it "generates proper relation classes and modules" do
              add_ruby_file("post.rb", <<~RUBY)
                class Post < ActiveRecord::Base
                end
              RUBY

              expected = template(<<~RUBY)
                # typed: strong

                class Post
                  extend WillPaginateMethods

                  module WillPaginateMethods
                  end

                  class PrivateAssociationRelationWillPaginateChain < PrivateAssociationRelation
                    Elem = type_member { { fixed: ::Post } }

                  end
                end
              RUBY

              assert_equal(expected, rbi_for(:Post))
            end
          end
        end
      end
    end
  end
end
