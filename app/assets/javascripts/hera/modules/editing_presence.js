document.addEventListener('turbo:load', () => {
  const container = document.querySelector('[data-behavior~=editing-presence]');
  if (!container) return;

  const { recordType, recordId } = container.dataset;

  const subscription = App.cable.subscriptions.create({
    channel: 'EditingPresenceChannel',
    record_type: recordType,
    record_id: recordId
  });

  const cleanup = () => {
    if (subscription) {
      subscription.unsubscribe();
    }
  };

  document.addEventListener('turbo:before-visit', cleanup, { once: true });
  window.addEventListener('beforeunload', cleanup);
});
