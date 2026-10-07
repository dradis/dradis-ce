# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mention menus', js: true do
  it 'renders avatar metadata and preserves labels when selecting mentions' do
    page.driver.browser.navigate.to('about:blank')
    page.execute_script(File.read(Rails.root.join('vendor/assets/javascripts/tribute.js')))
    page.execute_script(File.read(Rails.root.join('app/assets/javascripts/hera/modules/mentions.js')))

    script = <<~'JS'
      window.$ = () => ({ on: () => {} });
      const originalTribute = window.Tribute;
      window.Tribute = class extends originalTribute {
        constructor(options) { super(options); window.testTribute = this; }
      };
      const meta = document.createElement('meta');
      meta.dataset.behavior = 'mentionable-users';
      const value = 'A<&"\'><img src=x onerror="window.badMention=true">@example.test';
      const user = { key: value, value, avatar_path: '/local.png', avatar_url: 'https://secure.gravatar.com/avatar/test?d=404' };
      meta.content = JSON.stringify([user]);
      document.head.append(meta);
      const input = document.createElement('textarea');
      document.body.append(input);
      window.Mentions.init(input);
      const menu = document.createElement('div');
      menu.innerHTML = window.testTribute.collection[0].menuItemTemplate({ original: user });
      if (menu.textContent !== ` ${value}` || menu.querySelectorAll('img').length !== 1 || menu.querySelector('[onerror]')) throw new Error('Unexpected mention markup');
      const img = menu.querySelector('img');
      if (img.getAttribute('src') !== '/local.png' || img.dataset.controller !== 'gravatar' || img.dataset.gravatarUrl !== user.avatar_url) throw new Error('Incorrect avatar metadata');
      const editor = document.createElement('div');
      editor.contentEditable = 'true';
      document.body.append(editor);
      window.testTribute.current = { element: editor, collection: window.testTribute.collection[0] };
      editor.innerHTML = window.testTribute.collection[0].selectTemplate({original: user});
      if (editor.textContent !== `@${value}` || editor.querySelector('img') || editor.querySelector('[onerror]')) throw new Error('Unexpected selected mention');
      window.testTribute.current.element = input;
      if (window.testTribute.collection[0].selectTemplate({original: user}) !== `@${value}`) throw new Error('Incorrect textarea insertion');
      return 'Mention rendering and insertion passed';
    JS

    result = page.evaluate_script("(() => { #{script} })()")
    expect(result).to eq('Mention rendering and insertion passed')
  end
end
