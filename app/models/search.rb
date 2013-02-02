class Search
	def self.query(query)
    formatted = query.split(' ').map(&:singularize)
    PgSearch.multisearch(formatted)
  end
end