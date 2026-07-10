class DradisTasks < Thor
  class EditingSession < Thor
    namespace 'dradis:editing_sessions'

    desc 'purge_stale', 'Remove editing sessions that were never released'
    def purge_stale
      print '** Purging stale editing sessions...'
      ::EditingSession.purge_stale
    end
  end
end
