class Unauthorized < RuntimeError; end

class Onboarder
  error(Unauthorized) do
    status(401)
  end
end
