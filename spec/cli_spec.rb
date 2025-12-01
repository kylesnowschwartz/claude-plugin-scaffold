# frozen_string_literal: true

RSpec.describe ClaudePluginScaffold::CLI::New do
  let(:command) { described_class.new }

  describe 'name validation' do
    # Access private method for testing
    def validate_name(name)
      command.send(:validate_name!, name)
    end

    context 'with valid names' do
      %w[
        my-plugin
        MyPlugin
        my_plugin
        plugin123
        my-plugin.v2
        a
        A
        my_Plugin-v2.0
      ].each do |name|
        it "accepts '#{name}'" do
          expect { validate_name(name) }.not_to raise_error
        end
      end
    end

    context 'with invalid names' do
      [
        '-starts-with-dash',
        '_starts-with-underscore',
        '.starts-with-dot',
        'has..consecutive-dots',
        'ends-with-dot.',
        'has spaces',
        'has@special!chars',
        ''
      ].each do |name|
        it "rejects '#{name}'" do
          expect { validate_name(name) }.to raise_error(SystemExit)
        end
      end
    end
  end
end
