class Issues::EvidenceController < AuthenticatedController
  include MultipleDestroy
  include ProjectScoped
end
