class Search
	def self.query(query)
    PgSearch.multisearch(query)
  end
end