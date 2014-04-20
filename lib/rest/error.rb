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
      def self.class_names
        %w(
          Errno::ETIMEDOUT
          Timeout::Error
          Net::OpenTimeout
          Net::ReadTimeout
        )
      end
    end

    # This constant can be used to rescue only the known `Connection` error classes.
    module Connection
      def self.class_names
        %w(
          EOFError
          Errno::ECONNABORTED
          Errno::ECONNREFUSED
          Errno::ECONNRESET
          Errno::EHOSTUNREACH
          Errno::EINVAL
          Errno::ENETUNREACH
          SocketError
          OpenSSL::SSL::SSLError
        )
      end
    end

    # This constant can be used to rescue only the known `Protocol` error classes.
    module Protocol
      def self.class_names
        %w(
          Net::HTTPBadResponse
          Net::HTTPHeaderSyntaxError
          Net::ProtocolError
          Zlib::GzipFile::Error
          Foobla
        )
      end
    end

    private

    [Timeout, Connection, Protocol].each do |mod|
      mod.send(:include, Error)

      def mod.classes
        class_names.map do |name|
          Object.const_get(name) rescue NameError
        end.compact
      end

      def mod.extend_classes!
        # Include the `mod` into the classes.
        classes.each { |klass| klass.send(:include, self) }
      end

      mod.extend_classes!
    end
  end
end
