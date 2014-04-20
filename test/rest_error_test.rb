require File.expand_path('../helper', __FILE__)

require 'openssl'
REST::Error::Connection.extend_classes!

describe "REST::Error" do
  it "extends any Timeout related exception" do
    REST::Error::Timeout.classes.each do |error_class|
      lambda { raise error_class }.should.raise REST::Error::Timeout
      lambda { raise error_class }.should.raise REST::Error
    end
  end

  it "extends any Connection related exception" do
    REST::Error::Connection.classes.each do |error_class|
      lambda { raise error_class }.should.raise REST::Error::Connection
      lambda { raise error_class }.should.raise REST::Error
    end
  end

  it "extends any Protocol related exception" do
    REST::Error::Protocol.classes.each do |error_class|
      lambda { raise error_class }.should.raise REST::Error::Protocol
      lambda { raise error_class }.should.raise REST::Error
    end
  end
end
