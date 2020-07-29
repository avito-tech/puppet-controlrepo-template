# frozen_string_literal: true

control 'puppetserver is running' do
  describe port(8140) do
    it { should be_listening }
  end
  describe port(8088) do
    it { should be_listening }
  end
end
