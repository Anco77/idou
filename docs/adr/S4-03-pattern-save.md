# ADR S4-03: Persist the confirmed pattern draft

Pattern persistence now carries the schema-v3 fields through `PatternItem`:
palette, dimensions, serialized grid, preview asset, recognition summary, and
the inventory-deducted flag. The DAO writes all fields in one insert/replace
statement so a confirmed editor draft is not silently reduced to only its
legacy image metadata.
