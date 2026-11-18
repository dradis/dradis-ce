class Differ {
  constructor() {
    this.delRegex = /\x1b\[31m([\s\S]*?)\x1b\[0m/g;
    this.insRegex = /\x1b\[32m([\s\S]*?)\x1b\[0m/g;
  }

  ansiToHTML(text) {
    return text
      .replace(this.delRegex, '<del class="differ">$1</del>')
      .replace(this.insRegex, '<ins class="differ">$1</ins>');
  }

  highlightString(text, diffType) {
    if (diffType === 'del') {
      return text
        .replace(this.delRegex, '<mark>$1</mark>')
        .replace(this.insRegex, '');
    }
    else if (diffType === 'ins') {
      return text
        .replace(this.insRegex, '<mark>$1</mark>')
        .replace(this.delRegex, '');
    }
    else {
      console.log('Invalid diffType!');
    }
  }
}

document.addEventListener('turbo:load', () => {
  const differ = new Differ();

  document.querySelectorAll('[data-behavior~=revision-diff]').forEach((element) => {
    element.innerHTML = differ.ansiToHTML(element.innerHTML);
  });
});
