require 'omniauth'

module OmniAuth
  module Strategies
    class Registrar
      class Form
        def initialize(fields, callback_path)
          @fields = fields
          @callback_path = callback_path
        end

        def render
          add_fields_to_form
          add_submit_button_to_form
          add_opposite_auth_link
          to_html
        end

        private

        def to_html
          form.to_response
        end

        def add_opposite_auth_link
          form.instance_variable_set('@html', html << opposite_link_tag)
        end

        def html
          form.instance_variable_get('@html')
        end

        def opposite_link_tag
          "\n<div style='text-align:center; margin:20px auto 0;'>" \
          "or <a href='?#{opposite_type}'>#{opposite_title}</a></div>"
        end

        def add_submit_button_to_form
          form.button title
        end

        def add_fields_to_form
          fields.each do |field|
            form.text_field field.to_s.capitalize.gsub('_', ' '), field.to_s
          end
        end

        def callback_path
          @callback_path
        end

        def fields
          @fields
        end

        def form
          @form ||= OmniAuth::Form.new(:title => title, :url => callback_path)
        end
      end

      class SignInForm < Form
        private

        def title
          @title ||= "Sign In"
        end

        def opposite_title
          @opposite_title ||= "Sign Up"
        end

        def type
          @type ||= :sign_in
        end

        def opposite_type
          @opposite_type ||= :sign_up
        end
      end

      class SignUpForm < Form
        private

        def title
          @title ||= "Sign Up"
        end

        def opposite_title
          @opposite_title ||= "Sign In"
        end

        def type
          @type ||= :sign_up
        end

        def opposite_type
          @opposite_type ||= :sign_in
        end
      end
    end
  end
end

