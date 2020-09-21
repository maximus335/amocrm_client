# frozen_string_literal: true

module AmocrmClient
  class Error < ::StandardError; end

  class APIError < Error; end

  class AmoBadRequestError < APIError; end

  class AmoMovedPermanentlyError < APIError; end

  class AmoUnauthorizedError < APIError; end

  class AmoForbiddenError < APIError; end

  class AmoNotFoundError < APIError; end

  class AmoInternalError < APIError; end

  class AmoBadGatewayError < APIError; end

  class AmoServiceUnaviableError < APIError; end

  class AmoUnknownError < APIError; end

  class AmoRequestsPerSecExceeded < APIError; end
end
