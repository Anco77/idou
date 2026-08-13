# ADR S6-02: Versioned backup manifest

Backups carry an explicit schema version and a media manifest. Restore code
must validate this envelope before replacing data and must preserve the
current database if validation fails. Hashes and archive transport are
subsequent infrastructure concerns; the pure manifest is tested first.
