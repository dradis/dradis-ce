module Setup
  class BaseController < ApplicationController
    before_action :ensure_pristine
    layout 'application'
  end
end
