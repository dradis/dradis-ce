import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "startDate", "endDate", "specificDate", "clearButton"]

  connect() {
    this.addDateFieldListeners();
  }

  addDateFieldListeners() {
    if (this.hasSpecificDateTarget) {
      this.specificDateTarget.addEventListener('change', () => {
        if (this.specificDateTarget.value) {
          this.clearDateRange();
        }
      });
    }

    if (this.hasStartDateTarget) {
      this.startDateTarget.addEventListener('change', () => {
        if (this.startDateTarget.value) {
          this.clearSpecificDate();
        }
      });
    }

    if (this.hasEndDateTarget) {
      this.endDateTarget.addEventListener('change', () => {
        if (this.endDateTarget.value) {
          this.clearSpecificDate();
        }
      });
    }

    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener('click', (event) => {
        event.preventDefault();
        this.clearAllFilters();
        this.formTarget.submit();
      });
    }
  }

  clearDateRange() {
    if (this.hasStartDateTarget) {
      this.startDateTarget.value = '';
    }
    if (this.hasEndDateTarget) {
      this.endDateTarget.value = '';
    }
  }

  clearSpecificDate() {
    if (this.hasSpecificDateTarget) {
      this.specificDateTarget.value = '';
    }
  }

  clearAllFilters() {
    const inputs = this.formTarget.querySelectorAll('input:not([type="submit"]), select');
    inputs.forEach(input => {
      input.value = '';
    });
  }

  submitForm(event) {
    const submitBtn = this.formTarget.querySelector('input[type="submit"]');
    if (submitBtn) {
      submitBtn.value = 'Filtering...';
      submitBtn.disabled = true;
    }
  }
}
