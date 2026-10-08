# Default-cost hashing takes ~250ms per call and dominates specs that create
# users or stub the shared password. Tests don't need a secure work factor.
BCrypt::Engine.cost = BCrypt::Engine::MIN_COST
