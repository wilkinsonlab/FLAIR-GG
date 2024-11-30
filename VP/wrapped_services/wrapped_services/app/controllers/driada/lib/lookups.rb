def species_lookup(species:)
  warn `pwd`
  warn species
  # abort
  table = CSV.parse(File.read(DRIADA), headers: true, col_sep: ";")
  table.each do |row|
    # warn row.inspect
    data = row.to_h
    # warn data.inspect
    # warn "found", data["Taxon"]
    next unless data["Taxon"] == species

    return data
  end
end
