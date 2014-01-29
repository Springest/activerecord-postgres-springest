if defined? Rails 
  class ActiveRecordPostgresArray < Rails::Railtie

    initializer 'activerecord-postgres-springest' do
      ActiveSupport.on_load :active_record do
        require "activerecord-postgres-springest/activerecord"
      end
    end
  end
else
  ActiveSupport.on_load :active_record do
    require "activerecord-postgres-springest/activerecord"
  end
end

require "activerecord-postgres-springest/string"
require "activerecord-postgres-springest/array"
require "activerecord-postgres-springest/inet"
require "activerecord-postgres-springest/cidn"