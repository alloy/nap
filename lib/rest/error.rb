require 'net/http'

module REST
  # This constant can be used to rescue any of the known `Timeout`, `Connection`, and `Protocol`
  # error classes.
  #
  # For instance, to rescue _any_ type of error that could be raise while making a request:
  #
  #   begin
  #     REST.get('http://example.com/pigeons/12')
  #   rescue REST::Error => e
  #     p e # => Timeout::Error
  #   end
  #
  # If you want to rescue only `Timeout` related error classes, however, you can limit the scope:
  #
  #   begin
  #     REST.get('http://example.com/pigeons/12')
  #   rescue REST::Error::Timeout => e
  #     p e # => Timeout::Error
  #   end
  module Error
    # This constant can be used to rescue only the known `Timeout` error classes.
    module Timeout
      def self.classes
        [
          Errno::ETIMEDOUT,
          ::Timeout::Error,
          Net::OpenTimeout,
          Net::ReadTimeout,
        ]
      end
    end

    # This constant can be used to rescue only the known `Connection` error classes.
    module Connection
      # These need to be extended after requiring the `openssl` lib, because it
      # only extends the `OpenSSL::SSL::SSLError` class if it's loaded.
      def self.classes
        classes = [
          EOFError,
          Errno::ECONNABORTED,
          Errno::ECONNREFUSED,
          Errno::ECONNRESET,
          Errno::EHOSTUNREACH,
          Errno::EINVAL,
          Errno::ENETUNREACH,
          SocketError,
        ]
        classes << OpenSSL::SSL::SSLError if defined?(OpenSSL)
        classes
      end
    end

    # This constant can be used to rescue only the known `Protocol` error classes.
    module Protocol
      def self.classes
        [
          Net::HTTPBadResponse,
          Net::HTTPHeaderSyntaxError,
          Net::ProtocolError,
          Zlib::GzipFile::Error,
        ]
      end
    end

    private

    [Timeout, Connection, Protocol].each do |mod|
      mod.send(:include, Error)
      def mod.extend_classes!
        # Include the `mod` into the classes.
        classes.each { |klass| klass.send(:include, self) }
      end
      mod.extend_classes!
    end
  end
end
