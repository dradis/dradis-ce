require 'rails_helper'

describe HTML::Pipeline::Dradis::LiquidFilter do
  let(:assigns) { { 'issue' => { 'title' => 'I' }, 'project' => { 'name' => 'P' } } }

  def render(text)
    described_class.call(text, liquid_assigns: assigns)
  end

  it 'renders Liquid around links that contain an unclosed "{{"' do
    text = <<~TEXT
      #[Description]#
      Request

      {{ project.name }}

      {{ issue.title }}

      test

      bc. code block

      "Link text":https://te{{t.com

      bc.. test {{ project.name }}
      code line 2

      p. https://hello.world/hereit{{is
    TEXT

    result = render(text)

    expect(result).to include("\nP\n", "\nI\n")
    expect(result).to include('"Link text":https://te{{t.com', 'p. https://hello.world/hereit{{is')
    expect(result).to include('bc.. test {{ project.name }}')
    expect(result).not_to include('{% raw %}')
  end

  it 'does not swallow text between a link with "{{" and later Liquid' do
    result = render("https://te{{t.com\nkeep me\n{{ project.name }}\n")

    expect(result).to eq("https://te{{t.com\nkeep me\nP\n")
  end

  it 'renders intentional Liquid inside a URL' do
    expect(render('https://x/{{ issue.title }}')).to eq('https://x/I')
  end

  it 'returns the original text when Liquid cannot be parsed' do
    expect(render('foo {{ bar')).to eq('foo {{ bar')
  end
end
