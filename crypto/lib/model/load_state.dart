/// UI load status. Plain enum (never serialized; states are in-memory only).
enum LoadState { idle, loading, loaded, empty, error }
