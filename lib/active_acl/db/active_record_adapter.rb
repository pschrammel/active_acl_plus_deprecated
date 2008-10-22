# Includes different DBMS adapters, some of them using C extensions to speed up DB access.
# DB adapter can be set with ActiveAcl::OPTIONS[:db].
module ActiveAcl::DB
  
  # Uses ActiveRecord for privilege queries. Should be compatible to all
  # db types.
  class ActiveRecordAdapter
    # Execute sql query against the DB, returning an array of results.
    def self.query(sql)
      ActiveRecord::Base.connection.select_all(sql)
    end
  end
end

ActiveAcl::OPTIONS[:db] = ActiveAcl::DB::ActiveRecordAdapter