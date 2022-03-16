module Setup
  class BaseController < ApplicationController
    before_action :ensure_pristine
    layout 'setup'
  end
end
