module SupportHelper
  def self.included(base)
    included_ce(base)
    included_pro(base)
  end

  def self.included_ce(base)
    base.before(:each) do |example|
      # Disable the setup tour
      unless example.metadata[:skip_setup_mock]
        allow_any_instance_of(SetupRequiredController)
          .to receive(:setup_required).and_return(true)
      end
    end
  end

  def self.included_pro(base)
  end
end
