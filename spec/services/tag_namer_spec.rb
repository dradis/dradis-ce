require 'rails_helper'

describe TagNamer do
  context 'just a name' do
    it 'creates a tag name when given only name' do
      name = TagNamer.new(name: 'Awesome').execute
      expect(name).to eq('Awesome')
    end
  end

  context 'colors' do
    it 'creates a tag name when given name and valid color' do
      name = TagNamer.new(name: 'Awesome', color: '#bbacca').execute
      expect(name).to eq('!bbacca_Awesome')
    end

    it 'creates a tag name when given name and invalid color' do
      name = TagNamer.new(name: 'Awesome', color: '#rrrrrr').execute
      expect(name).to eq('Awesome')
    end

    it 'returns nil if name is blank despite a value for color' do
      name = TagNamer.new(name: '', color: '#bbacca').execute
      expect(name).to be_nil
    end
  end

  context 'users' do
    it 'creates a tag name when given name and valid user' do
      create(:user, email: 'chewbacca')
      name = TagNamer.new(name: 'Awesome', user: 'chewbacca').execute
      expect(name).to eq('@chewbacca_Awesome')
    end

    it 'creates a tag name when given name and invalid user' do
      name = TagNamer.new(name: 'Awesome', user: 'chewbacca').execute
      expect(name).to eq('Awesome')
    end

    it 'returns nil if name is blank despite a value for user' do
      name = TagNamer.new(name: '', user: 'chewbacca').execute
      expect(name).to be_nil
    end
  end

  context 'groups' do
    it 'creates a tag name when given name and group' do
      name = TagNamer.new(name: 'Awesome', group: 'falcon').execute
      expect(name).to eq('#falcon_Awesome')
    end

    it 'returns nil if name is blank despite a value for group' do
      name = TagNamer.new(name: '', group: 'falcon').execute
      expect(name).to be_nil
    end
  end
end
