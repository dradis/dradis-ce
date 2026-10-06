import { Controller } from '@hotwired/stimulus';

// The strip supplies data-local-storage-key. Addon tabs participate automatically;
// data-tab-memory-restore="#info-tab" remembers a different tab on return.
export default class extends Controller {
  initialize() {
    this.clicked = this.clicked.bind(this);
    this.shown = this.shown.bind(this);
  }

  connect() {
    this.storageKey = `dradis:tab-memory:${this.element.dataset.localStorageKey}`;
    this.element.addEventListener('click', this.clicked);
    this.element.addEventListener('shown.bs.tab', this.shown);
    this.restore();
  }

  disconnect() {
    this.element.removeEventListener('click', this.clicked);
    this.element.removeEventListener('shown.bs.tab', this.shown);
  }

  clicked(event) {
    const link = event.target.closest('[data-tab-memory-restore]');
    if (!link || !this.element.contains(link) || event.defaultPrevented) return;

    // Bootstrap tabs are remembered only after a successful activation. Links
    // to separate pages (such as calculators) must be remembered before leaving.
    if (link.dataset.bsToggle === 'tab') return;
    this.remember(link.dataset.tabMemoryRestore);
  }

  findTab(target) {
    return this.tabs.find((tab) => this.tabTarget(tab) === target &&
      !tab.matches(':disabled') && !tab.classList.contains('disabled') &&
      tab.getAttribute('aria-disabled') !== 'true');
  }

  read() {
    try {
      return localStorage.getItem(this.storageKey);
    } catch {
      // Storage can be unavailable even when ordinary tab navigation works.
      return null;
    }
  }

  remember(target) {
    if (!this.findTab(target)) return;

    try {
      localStorage.setItem(this.storageKey, target);
    } catch {
      // A blocked or full localStorage must not prevent navigation.
    }
  }

  restore() {
    // Initializing Bootstrap also establishes aria-selected on the default tab.
    this.tabs.forEach((tab) => bootstrap.Tab.getOrCreateInstance(tab));
    const requested = new URL(window.location.href).searchParams.get('tab');
    const tab = this.findTab(`#${requested}`) || this.findTab(this.read()) ||
      this.tabs.find((tab) => tab.classList.contains('active'));
    if (!tab) return;

    this.restoring = true;
    bootstrap.Tab.getOrCreateInstance(tab).show();
    this.restoring = false;

    // An already-active tab does not emit shown.bs.tab (including explicit URLs).
    if (tab.getAttribute('aria-selected') === 'true') {
      this.remember(tab.dataset.tabMemoryRestore || this.tabTarget(tab));
    }
  }

  shown(event) {
    const tab = event.target;
    if (!this.tabs.includes(tab)) return;

    const target = this.tabTarget(tab);
    this.remember(tab.dataset.tabMemoryRestore || target);
    const url = new URL(window.location.href);
    if (url.searchParams.get('tab') === target.slice(1)) return;

    url.searchParams.set('tab', target.slice(1));
    const path = `${url.pathname}${url.search}${url.hash}`;
    const state = { ...history.state, turbo: true, url: path };
    // Restoring a preference should not create an extra Back-button entry.
    if (this.restoring) {
      history.replaceState(state, '', path);
    } else {
      history.pushState(state, '', path);
    }
  }

  get tabs() {
    return Array.from(this.element.querySelectorAll('[data-bs-toggle="tab"]'))
      .filter((tab) => tab.closest('[data-controller~="tab-memory"]') === this.element);
  }

  tabTarget(tab) {
    return tab.dataset.bsTarget || tab.getAttribute('href');
  }
}
