require 'uuid'
require 'md5'

module Ramaze
  module Helper
    module HttpDigest

      UUID_GENERATOR = UUID.new

      @session_nonce = "authentication_digest_nonce"

      def httpdigest_logout
        session.delete( @session_nonce )
      end

      def httpdigest(uid, realm)
        session_opaque = "authentication_digest_opaque_#{uid}"

        session[session_opaque] ||= UUID_GENERATOR.generate

        authorized = false

        if session[@session_nonce] and request.env['HTTP_AUTHORIZATION']

          auth_split = request.env['HTTP_AUTHORIZATION'].split
          authentication_type = auth_split[0]
          authorization = Rack::Auth::Digest::Params.parse( auth_split[1..-1].join(' ') )
          digest_response, username, nonce, nc, cnonce, qop =
            authorization.values_at(*%w[response username nonce nc cnonce qop])

          if authentication_type == 'Digest'
            if nonce == session[@session_nonce]
              ha1 = yield(username)
              ha2 = MD5.hexdigest("#{request.request_method}:#{request.fullpath}")
              md5 = MD5.hexdigest([ha1, nonce, nc, cnonce, qop, ha2].join(':'))

              authorized = digest_response == md5
            end
          end
        end

        unless authorized
          session[@session_nonce] = UUID_GENERATOR.generate
          response['WWW-Authenticate'] =
            %|Digest realm="#{realm}",| +
            %|qop="auth,auth-int",| +
            %|nonce="#{session[@session_nonce]}",| +
            %|opaque="#{session[session_opaque]}"|
          if respond_to?( :httpdigest_failure )
            httpdigest_failure
          else
            respond('Unauthorized', 401)
          end
        end

        authorization["username"]
      end

    end
  end
end
