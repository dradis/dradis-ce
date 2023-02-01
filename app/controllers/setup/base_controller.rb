module Setup
  class BaseController < ApplicationController
    before_action :ensure_pristine, only: [:new]
    layout 'setup'
  end
end
