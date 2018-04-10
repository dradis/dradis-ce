# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Node::SyncSettings do
  def self.set_dummy_plugin(var, settings_template)
    eval(<<-STR
      let(:#{var}) do
        Class.new(Rails::Engine) do
          include ::Dradis::Plugins::Base
          include ::Dradis::Plugins::Sync

          def self.settings_template
            #{settings_template}
          end

          def self.name
            "Dradis::Plugins::#{var.to_s.camelize}::Engine"
          end
        end
      end
    STR
    )
  end

  set_dummy_plugin(:plugin_1, [ { key: 'username' }, { key: 'password' } ])

  set_dummy_plugin(
    :plugin_2,
    [ { key: 'email' }, { key: 'password' }, { key: 'repo' } ]
  )

  set_dummy_plugin(:plugin_3, [ { key: 'api_key' }, { key: 'api_secret' } ])

  let(:node) { create(:sync_node) }
  let(:sync_settings) { described_class.new(node) }

  before do
    Dradis::Plugins.register(plugin_1)
    Dradis::Plugins.register(plugin_2)
  end

  after do
    Dradis::Plugins.unregister(plugin_1)
    Dradis::Plugins.unregister(plugin_2)
  end

  describe '#value' do
    before do
      properties = <<-STR.strip_heredoc
        {
          "#{plugin_1.name}" : {
            "username" : "george",
            "password" : "hunter2"
          },
          "#{plugin_2.name}" : {
            "email"    : "george@securityroots.com",
            "password" : ""
          }
        }
      STR
      node.properties = JSON.load(properties)
    end

    it 'returns the value' do
      expect(sync_settings.value(plugin_1, 'username')).to eq 'george'
      expect(sync_settings.value(plugin_1, 'password')).to eq 'hunter2'
      expect(sync_settings.value(plugin_2, 'email')).to eq 'george@securityroots.com'
      expect(sync_settings.value(plugin_2, 'password')).to eq ''
    end

    example 'when setting is not set' do
      expect(sync_settings.value(plugin_2, 'repo')).to be_nil
    end

    describe 'when node has no settings for this plugin' do
      context 'and the key is for a valid setting' do
        it 'returns nil' do
          expect(sync_settings.value(plugin_3, 'api_key')).to be_nil
          expect(sync_settings.value(plugin_3, 'api_secret')).to be_nil
        end
      end

      example 'and the plugin does not have the setting' do
        expect do
          sync_settings.value(plugin_3, 'nonexistent')
        end.to raise_error ArgumentError
      end
    end

    example 'when plugin does not have the setting' do
      expect do
        sync_settings.value(plugin_2, 'nonexistent')
      end.to raise_error ArgumentError
    end
  end

  describe '#save_value' do
    describe '' do
      before do
        properties = "{ \"#{plugin_1.name}\" : { \"username\" : \"daniel\" } }"
        node.properties = JSON.load(properties)
      end

      example 'saving the setting' do
        sync_settings.save_value(plugin_1, 'username', 'george')
        sync_settings.save_value(plugin_1, 'password', 'xxxxxx')
        node.reload
        expect(node.properties[plugin_1.name][:username]).to eq 'george'
        expect(node.properties[plugin_1.name][:password]).to eq 'xxxxxx'
      end

      example 'when the setting isnt valid' do
        expect do
          sync_settings.save_value(plugin_1, 'nonexistent', 'george')
        end.to raise_error ArgumentError
      end
    end

    describe 'when no settings exist yet for this plugin' do
      before do
        properties = "{ \"#{plugin_1.name}\" : {} }"
        node.properties = JSON.load(properties)
      end

      it 'saves the setting' do
        sync_settings.save_value(plugin_2, 'email', 'g@m.com')
        node.reload
        expect(node.properties[plugin_2.name][:username]).to eq 'g@m.com'
      end
    end
  end
end
