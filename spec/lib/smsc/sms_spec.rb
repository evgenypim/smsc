# coding: utf-8
require 'spec_helper'

describe Smsc::Sms do
  let(:password) { 'pass' }
  let(:login) { 'login' }

  describe '#initialize' do
    subject { described_class.new }

    it[:connection] { expect.to be be_a_kind_of(Faraday::Connection) }
    # it[:params] {  }
  end
end