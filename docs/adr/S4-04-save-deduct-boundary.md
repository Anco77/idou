# ADR S4-04: Save-and-deduct must be one application transaction

The UI may prepare a confirmed `PatternItem`, but it must not save the
pattern and then deduct inventory in separate calls. The final application
use case must persist controlled assets, validate consumptions, deduct through
the atomic inventory DAO, write pattern-linked movements, and commit or
compensate as one boundary. Existing preview-page sequential code remains a
known migration target until S4-03/S4-04 are verified.
