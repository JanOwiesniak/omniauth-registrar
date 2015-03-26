require 'omniauth'
require 'digest'

module OmniAuth
  module Strategies
    class Registrar
      AuthenticationError = Class.new(RuntimeError)

      include ::OmniAuth::Strategy
      option :name, 'registrar'
      option :fields, [:name, :email]

      uid do
        generate_uid(request.params['email'], request.params['password'])
      end

      info do
        options.fields.inject({}) do |hash, field|
          hash[field] = request.params[field.to_s]
          hash
        end
      end

      def request_phase
        if sign_up?
          title = "Sign Up"
          fields = sign_up_fields
        end

        if sign_in?
          title = "Sign In"
          fields = sign_in_fields
        end

        form = OmniAuth::Form.new(:title => title, :url => callback_path)

        fields.each do |field|
          form.text_field field.to_s.capitalize.gsub('_', ' '), field.to_s
        end

        form.button title

        html = form.instance_variable_get('@html')

        if sign_up?
          html << "\n<div style='text-align:center; margin:20px auto 0;'> or <a href='?sign_in'>Sign In</a></div>"
        end

        if sign_in?
          html << "\n<div style='text-align:center; margin:20px auto 0;'> or <a href='?sign_up'>Sign Up</a></div>"
        end

        form.instance_variable_set('@html', html)

        form.to_response
      end

      def callback_phase
        try_to_register
        super
      end

      private

      def sign_up_fields
        options.fields << 'password' << 'password_confirmation'
      end

      def sign_in_fields
        ['email', 'password']
      end

      def generate_uid(*args)
        Digest::SHA256.hexdigest(args.join(''))[0..19]
      end

      def try_to_register
        if sign_up?
          ensure_password_confirmed
          ensure_password_confirmation_exists
          ensure_password_exists
          ensure_email_exists
          ensure_name_exists
        end

        if sign_in?
          ensure_password_exists
          ensure_email_exists
        end

        validate!
      end

      def validate!
        raise error if error?
      end

      def sign_up?
        @env['QUERY_STRING'].match(/sign_up/) ||
        !!request.params['password_confirmation']
      end

      def sign_in?
        @env['QUERY_STRING'].match(/sign_in/) ||
        !sign_up?
      end

      def ensure_name_exists
        unless name?
          fail_with AuthenticationError.new(missing('name'))
        end
      end

      def ensure_email_exists
        unless email?
          fail_with AuthenticationError.new(missing('email'))
        end
      end

      def ensure_password_exists
        unless password?
          fail_with AuthenticationError.new(missing('password'))
        end
      end

      def ensure_password_confirmation_exists
        unless password_confirmation?
          fail_with AuthenticationError.new(missing('password_confirmation'))
        end
      end

      def ensure_password_confirmed
        unless password_confirmed?
          fail_with AuthenticationError.new(confirm('password'))
        end
      end

      def name?
        exist?('name')
      end

      def email?
        exist?('email')
      end

      def password?
        exist?('password')
      end

      def password_confirmation?
        exist?('password_confirmation')
      end

      def password_confirmed?
        same?('password', 'password_confirmation')
      end

      def exist?(attr)
        !!request.params[attr] && !request.params[attr].blank?
      end

      def same?(first, second)
        request.params[first] == request.params[second]
      end

      def fail_with(exception)
        env['omniauth.error'] = exception
      end

      def missing(key)
        "authentication.errors.#{key}.missing"
      end

      def confirm(key)
        "authentication.errors.#{key}.unconfirmed"
      end

      def error
        env['omniauth.error']
      end

      def error?
        !!error
      end
    end
  end
end
